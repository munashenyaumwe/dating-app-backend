-- ============================
-- EXTENSIONS (safe if present)
-- ============================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pg_trgm;     -- fuzzy search/sort for names/bios

-- =====================================================
-- USERS
--  - age constraint
--  - created_at/updated_at use TIMESTAMPTZ
--  - case-insensitive email uniqueness (index on lower(email))
--  - tsvector search column for simple search
-- =====================================================
CREATE TABLE IF NOT EXISTS users (
  id           SERIAL PRIMARY KEY,
  name         VARCHAR(100) NOT NULL,
  email        VARCHAR(100) UNIQUE NOT NULL,
  password     TEXT NOT NULL,              -- bcrypt hash
  age          INT,
  bio          TEXT,
  interests    TEXT[],                     -- e.g., {'hiking','jazz'}
  personality  JSONB,                      -- Big Five, etc.
  photos       TEXT[],                     -- CDN URLs
  created_at   TIMESTAMP DEFAULT now()
);

-- Age sanity (18..120) - FIXED VERSION
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'users_age_ck'
    AND conrelid = 'users'::regclass
  ) THEN
    ALTER TABLE users ADD CONSTRAINT users_age_ck
    CHECK (age IS NULL OR age BETWEEN 18 AND 120);
  END IF;
END$$;

-- created_at -> TIMESTAMPTZ
ALTER TABLE users
  ALTER COLUMN created_at TYPE TIMESTAMPTZ
  USING created_at AT TIME ZONE 'UTC';

-- updated_at column + trigger
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT now();

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_users_set_updated_at') THEN
    CREATE TRIGGER trg_users_set_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;
END$$;

-- Case-insensitive uniqueness on email
-- (Run this BEFORE inserting any potentially colliding rows)
CREATE UNIQUE INDEX IF NOT EXISTS users_email_ci_unique
  ON users ((lower(email)));

-- Simple search vector (name + bio + interests) - FIXED VERSION
-- Remove the generated column approach and use a trigger instead

ALTER TABLE users
  ADD COLUMN IF NOT EXISTS search TSVECTOR;

CREATE OR REPLACE FUNCTION update_user_search()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.search := to_tsvector('simple',
    coalesce(NEW.name,'') || ' ' ||
    coalesce(NEW.bio,'')  || ' ' ||
    array_to_string(coalesce(NEW.interests,'{}'::text[]),' ')
  );
  RETURN NEW;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_users_update_search') THEN
    CREATE TRIGGER trg_users_update_search
    BEFORE INSERT OR UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_user_search();
  END IF;
END$$;

-- Update existing rows
UPDATE users SET search = to_tsvector('simple',
  coalesce(name,'') || ' ' ||
  coalesce(bio,'')  || ' ' ||
  array_to_string(coalesce(interests,'{}'::text[]),' ')
) WHERE search IS NULL;

CREATE INDEX IF NOT EXISTS users_search_gin ON users USING GIN (search);
CREATE INDEX IF NOT EXISTS users_name_trgm ON users USING GIN (name gin_trgm_ops);

-- =========================================
-- LIKES
-- =========================================
CREATE TABLE IF NOT EXISTS likes (
  id         SERIAL PRIMARY KEY,
  user_id    INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  target_id  INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (user_id, target_id)
);

-- Speed up "incoming likes" and "who I liked"
CREATE INDEX IF NOT EXISTS likes_target_created_idx ON likes (target_id, created_at DESC);
CREATE INDEX IF NOT EXISTS likes_user_created_idx   ON likes (user_id, created_at DESC);

-- =========================================
-- MATCHES
--  - Normalize pair via unique expression index (LEAST/GREATEST)
--  - Status enum check + timestamptz
-- =========================================
CREATE TABLE IF NOT EXISTS matches (
  id           SERIAL PRIMARY KEY,
  user_a_id    INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user_b_id    INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status       VARCHAR(20) NOT NULL DEFAULT 'active',  -- active, unmatched, blocked
  created_at   TIMESTAMPTZ DEFAULT now(),
  UNIQUE (user_a_id, user_b_id)
);

-- Ensure status is one of allowed values - FIXED VERSION
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'matches_status_ck'
    AND conrelid = 'matches'::regclass
  ) THEN
    ALTER TABLE matches ADD CONSTRAINT matches_status_ck
    CHECK (status IN ('active','unmatched','blocked'));
  END IF;
END$$;

-- (Optional but recommended) Normalize any pre-existing reversed pairs.
-- Review duplicates first (this DELETE would drop duplicate matches):
-- SELECT LEAST(user_a_id,user_b_id) a, GREATEST(user_a_id,user_b_id) b, COUNT(*) c
-- FROM matches GROUP BY 1,2 HAVING COUNT(*)>1;
-- DELETE FROM matches m USING (
--   SELECT MIN(id) keep_id, LEAST(user_a_id,user_b_id) a, GREATEST(user_a_id,user_b_id) b
--   FROM matches GROUP BY 2,3 HAVING COUNT(*)>1
-- ) d
-- WHERE LEAST(m.user_a_id,m.user_b_id)=d.a AND GREATEST(m.user_a_id,m.user_b_id)=d.b AND m.id<>d.keep_id;

-- Then normalize ordering so a<b
UPDATE matches
SET user_a_id = LEAST(user_a_id, user_b_id),
    user_b_id = GREATEST(user_a_id, user_b_id)
WHERE user_a_id > user_b_id;

-- Enforce normalized uniqueness across both directions
CREATE UNIQUE INDEX IF NOT EXISTS matches_unique_normalized
  ON matches (LEAST(user_a_id,user_b_id), GREATEST(user_a_id,user_b_id));

-- Helpful indexes
CREATE INDEX IF NOT EXISTS matches_user_a_idx ON matches (user_a_id);
CREATE INDEX IF NOT EXISTS matches_user_b_idx ON matches (user_b_id);
CREATE INDEX IF NOT EXISTS matches_status_idx ON matches (status);

-- =========================================
-- CHATS (one chat per match)
-- =========================================
CREATE TABLE IF NOT EXISTS chats (
  id           SERIAL PRIMARY KEY,
  match_id     INT NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  created_at   TIMESTAMPTZ DEFAULT now(),
  UNIQUE (match_id)
);

CREATE INDEX IF NOT EXISTS chats_match_idx ON chats (match_id);

-- =========================================
-- MESSAGES
--  - Enforce sender belongs to match (trigger)
--  - Keep created_at as timestamptz
-- =========================================
CREATE TABLE IF NOT EXISTS messages (
  id         SERIAL PRIMARY KEY,
  chat_id    INT NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
  sender_id  INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content    TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Existing helpful index
CREATE INDEX IF NOT EXISTS idx_messages_chat_id_created ON messages (chat_id, created_at);
-- Sender lookup (audit/moderation/user feed)
CREATE INDEX IF NOT EXISTS messages_sender_created_idx ON messages (sender_id, created_at DESC);

-- Enforce: the message sender must be one of the two users in the chat's match and match must be active
CREATE OR REPLACE FUNCTION enforce_sender_in_match()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
  a INT; b INT; s VARCHAR(20);
BEGIN
  SELECT m.user_a_id, m.user_b_id, m.status
    INTO a, b, s
  FROM chats c
  JOIN matches m ON m.id = c.match_id
  WHERE c.id = NEW.chat_id;

  IF s IS DISTINCT FROM 'active' THEN
    RAISE EXCEPTION 'Cannot post to chat for non-active match';
  END IF;

  IF NEW.sender_id <> a AND NEW.sender_id <> b THEN
    RAISE EXCEPTION 'Sender % is not a participant of chat %', NEW.sender_id, NEW.chat_id;
  END IF;

  RETURN NEW;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_messages_enforce_sender') THEN
    CREATE TRIGGER trg_messages_enforce_sender
    BEFORE INSERT ON messages
    FOR EACH ROW EXECUTE FUNCTION enforce_sender_in_match();
  END IF;
END$$;

-- =========================================
-- PHOTO REVEAL CONSENT
-- =========================================
CREATE TABLE IF NOT EXISTS photo_reveals (
  id           SERIAL PRIMARY KEY,
  match_id     INT NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  user_id      INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  consent      BOOLEAN NOT NULL DEFAULT FALSE,
  revealed_at  TIMESTAMPTZ DEFAULT now(),
  UNIQUE (match_id, user_id)
);

-- For quick mutual checks and lookups
CREATE INDEX IF NOT EXISTS photo_reveals_match_idx         ON photo_reveals (match_id);
CREATE INDEX IF NOT EXISTS photo_reveals_match_consent_idx ON photo_reveals (match_id, consent);

-- =========================================
-- OPTIONAL: PASSES
--  - If you want to avoid showing the same user again
-- =========================================
CREATE TABLE IF NOT EXISTS passes (
  user_id    INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  target_id  INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (user_id, target_id)
);

-- =========================================
-- VIEWS (helper for app queries)
-- =========================================
CREATE OR REPLACE VIEW v_my_matches AS
SELECT
  m.id                                              AS match_id,
  m.status,
  m.created_at,
  LEAST(m.user_a_id, m.user_b_id)                  AS user_left,
  GREATEST(m.user_a_id, m.user_b_id)               AS user_right
FROM matches m;

-- Compact view returning "the other user" for a given viewer_id
CREATE OR REPLACE VIEW v_matches_with_partner AS
SELECT
  m.id AS match_id,
  CASE WHEN m.user_a_id = u.id THEN m.user_b_id ELSE m.user_a_id END AS partner_id,
  m.status,
  m.created_at
FROM matches m
JOIN users u ON (u.id = m.user_a_id OR u.id = m.user_b_id);
