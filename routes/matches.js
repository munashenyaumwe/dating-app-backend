// routes/matches.js
const express = require("express");
const pool = require("../db");
const auth = require("../middleware/auth");

const router = express.Router();

/** Compatibility helper (Jaccard interests + OCEAN similarity) */
function compat(myInterests = [], myPers = {}, theirInterests = [], theirPers = {}) {
  const setA = new Set(myInterests), setB = new Set(theirInterests);
  const inter = [...setA].filter(x => setB.has(x)).length;
  const union = new Set([...setA, ...setB]).size || 1;
  const interestsScore = inter / union;

  const dims = ["openness","conscientiousness","extraversion","agreeableness","neuroticism"];
  let s = 0, c = 0;
  for (const d of dims) {
    const a = Number(myPers?.[d]), b = Number(theirPers?.[d]);
    if (Number.isFinite(a) && Number.isFinite(b)) { s += 1 - Math.min(1, Math.abs(a - b)); c++; }
  }
  const personalityScore = c ? s / c : 0.5;
  return Math.round((0.6*interestsScore + 0.4*personalityScore) * 100);
}

/** GET /suggestions?limit=10
 * - Excludes self and people I've already liked
 * - Prioritizes users who liked me (EXISTS), then shared interests
 */
router.get("/suggestions", auth, async (req, res) => {
  const userId = Number(req.userId);
  const limit = Math.max(1, Math.min(Number(req.query.limit) || 10, 50));
  if (!Number.isInteger(userId) || userId <= 0) return res.status(400).json({ error: "Invalid auth user" });

  try {
    const { rows: meRows } = await pool.query(
      "SELECT interests, personality FROM users WHERE id=$1",
      [userId]
    );
    if (!meRows.length) return res.status(404).json({ error: "User not found" });
    const myInterests = meRows[0].interests || [];
    const myPers = meRows[0].personality || {};

    const { rows } = await pool.query(
      `
      WITH me AS (
        SELECT $1::int AS id, $2::text[] AS interests
      )
      SELECT
        u.id, u.name, u.age, u.bio, u.interests, u.personality, u.photos,
        s.shared_interests,
        cardinality(s.shared_interests) AS shared_count,
        EXISTS (SELECT 1 FROM likes l WHERE l.user_id = u.id AND l.target_id = me.id) AS liked_me
      FROM users u
      CROSS JOIN me
      CROSS JOIN LATERAL (
        SELECT ARRAY(
          SELECT DISTINCT ui
          FROM unnest(u.interests) ui
          INNER JOIN unnest(me.interests) mi ON mi = ui
        ) AS shared_interests
      ) s
      WHERE u.id <> me.id
        AND u.id NOT IN (SELECT target_id FROM likes WHERE user_id = me.id)
      ORDER BY liked_me DESC, shared_count DESC, u.id
      LIMIT $3;
      `,
      [userId, myInterests, limit]
    );

    const suggestions = rows.map(u => ({
      id: u.id,
      name: u.name,
      age: u.age,
      bio: u.bio,
      interests: u.interests || [],
      personality: u.personality || {},
      photos: u.photos || [],
      shared_interests: u.shared_interests || [],
      liked_me: u.liked_me,
      compatibility: compat(myInterests, myPers, u.interests || [], u.personality || {})
    }));

    res.json(suggestions);
  } catch (e) {
    console.error("GET /suggestions error:", e);
    res.status(500).json({ error: "Failed to get suggestions" });
  }
});

/** GET /likes-received - Alias for incoming-likes to match frontend calls */
router.get("/likes-received", auth, async (req, res) => {
  const userId = Number(req.userId);
  if (!Number.isInteger(userId) || userId <= 0) return res.status(400).json({ error: "Invalid auth user" });

  try {
    const { rows } = await pool.query(
      `
      SELECT u.id, u.name, u.age, u.bio, u.photos, u.interests, u.personality
      FROM likes l
      JOIN users u ON u.id = l.user_id
      WHERE l.target_id = $1
        AND NOT EXISTS (
          SELECT 1 FROM likes mine WHERE mine.user_id = $1 AND mine.target_id = u.id
        )
        AND NOT EXISTS (
          SELECT 1 FROM matches m
          WHERE (m.user_a_id = LEAST($1,u.id) AND m.user_b_id = GREATEST($1,u.id))
            AND m.status = 'active'
        )
      ORDER BY l.created_at DESC
      LIMIT 50;
      `,
      [userId]
    );
    res.json(rows);
  } catch (e) {
    console.error("GET /likes-received error:", e);
    res.status(500).json({ error: "Failed to get likes received" });
  }
});

/** GET /mutual - Get mutual matches */
router.get("/mutual", auth, async (req, res) => {
  const userId = Number(req.userId);
  if (!Number.isInteger(userId) || userId <= 0) return res.status(400).json({ error: "Invalid auth user" });

  try {
    const { rows } = await pool.query(
      `
      SELECT
        u.id, u.name, u.age, u.bio, u.photos, u.interests, u.personality,
        m.created_at as matched_at
      FROM matches m
      JOIN users u ON u.id = CASE
        WHEN m.user_a_id = $1 THEN m.user_b_id
        ELSE m.user_a_id
      END
      WHERE (m.user_a_id = $1 OR m.user_b_id = $1)
        AND m.status = 'active'
      ORDER BY m.created_at DESC
      LIMIT 50;
      `,
      [userId]
    );
    res.json(rows);
  } catch (e) {
    console.error("GET /mutual error:", e);
    res.status(500).json({ error: "Failed to get mutual matches" });
  }
});

/** GET /most-compatible - High compatibility matches (80%+) */
router.get("/most-compatible", auth, async (req, res) => {
  const userId = Number(req.userId);
  const limit = Math.max(1, Math.min(Number(req.query.limit) || 20, 50));
  if (!Number.isInteger(userId) || userId <= 0) return res.status(400).json({ error: "Invalid auth user" });

  try {
    const { rows: meRows } = await pool.query(
      "SELECT interests, personality FROM users WHERE id=$1",
      [userId]
    );
    if (!meRows.length) return res.status(404).json({ error: "User not found" });
    const myInterests = meRows[0].interests || [];
    const myPers = meRows[0].personality || {};

    const { rows } = await pool.query(
      `
      WITH me AS (
        SELECT $1::int AS id, $2::text[] AS interests
      )
      SELECT
        u.id, u.name, u.age, u.bio, u.interests, u.personality, u.photos,
        s.shared_interests,
        cardinality(s.shared_interests) AS shared_count
      FROM users u
      CROSS JOIN me
      CROSS JOIN LATERAL (
        SELECT ARRAY(
          SELECT DISTINCT ui
          FROM unnest(u.interests) ui
          INNER JOIN unnest(me.interests) mi ON mi = ui
        ) AS shared_interests
      ) s
      WHERE u.id <> me.id
        AND u.id NOT IN (SELECT target_id FROM likes WHERE user_id = me.id)
        AND u.id NOT IN (
          SELECT CASE WHEN m.user_a_id = me.id THEN m.user_b_id ELSE m.user_a_id END
          FROM matches m
          WHERE (m.user_a_id = me.id OR m.user_b_id = me.id) AND m.status = 'active'
        )
      ORDER BY shared_count DESC, u.id
      LIMIT $3;
      `,
      [userId, myInterests, limit]
    );

    // Calculate compatibility and filter for high compatibility (>=80%)
    const compatibleUsers = rows
      .map(u => ({
        user_id: u.id,
        id: u.id,
        name: u.name,
        age: u.age,
        bio: u.bio,
        interests: u.interests || [],
        personality: u.personality || {},
        photos: u.photos || [],
        shared_interests: u.shared_interests || [],
        compatibility_score: compat(myInterests, myPers, u.interests || [], u.personality || {}) / 100
      }))
      .filter(u => u.compatibility_score >= 0.80);

    res.json(compatibleUsers);
  } catch (e) {
    console.error("GET /most-compatible error:", e);
    res.status(500).json({ error: "Failed to get most compatible users" });
  }
});

/** POST /:userId/action   { action: "like" | "pass" }
 * - Records like; on mutual, creates normalized match (a<b), ensures chat exists, returns {match, chat_id}
 * - “pass” is acknowledged (no table in current schema)
 */
router.post("/:userId/action", auth, async (req, res) => {
  const me = Number(req.userId);
  const target = Number(req.params.userId);
  const action = String(req.body?.action || "").toLowerCase();

  if (!Number.isInteger(me) || me <= 0) return res.status(400).json({ error: "Invalid auth user" });
  if (!Number.isInteger(target) || target <= 0) return res.status(400).json({ error: "Invalid target userId" });
  if (me === target) return res.status(400).json({ error: "You cannot act on yourself" });
  if (!["like","pass"].includes(action)) return res.status(400).json({ error: "Invalid action" });

  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    if (action === "like") {
      await client.query(
        "INSERT INTO likes (user_id, target_id) VALUES ($1,$2) ON CONFLICT DO NOTHING",
        [me, target]
      );

      // Did they already like me?
      const { rows: recip } = await client.query(
        "SELECT 1 FROM likes WHERE user_id=$1 AND target_id=$2",
        [target, me]
      );

      if (recip.length) {
        const a = Math.min(me, target), b = Math.max(me, target);

        // Upsert match (status active), get match_id
        const { rows: matchRows } = await client.query(
          `
          WITH upsert AS (
            INSERT INTO matches (user_a_id, user_b_id, status)
            VALUES ($1,$2,'active')
            ON CONFLICT (user_a_id, user_b_id)
            DO UPDATE SET status='active'
            RETURNING id
          )
          SELECT id FROM upsert
          UNION ALL
          SELECT id FROM matches WHERE user_a_id=$1 AND user_b_id=$2
          LIMIT 1;
          `,
          [a, b]
        );
        const matchId = matchRows[0].id;

        // Ensure chat exists for the match
        await client.query(
          "INSERT INTO chats (match_id) VALUES ($1) ON CONFLICT (match_id) DO NOTHING",
          [matchId]
        );

        // Get chat id to return
        const { rows: chatRows } = await client.query(
          "SELECT id FROM chats WHERE match_id=$1",
          [matchId]
        );

        await client.query("COMMIT");
        return res.json({ match: true, message: "It's a match!", match_id: matchId, chat_id: chatRows[0].id });
      }

      await client.query("COMMIT");
      return res.json({ match: false, message: "Like recorded" });
    } else {
      // No 'passes' table in current schema; just acknowledge
      await client.query("COMMIT");
      return res.json({ message: "Passed" });
    }
  } catch (e) {
    await client.query("ROLLBACK");
    console.error("POST /action error:", e);
    res.status(500).json({ error: "Failed to process action" });
  } finally {
    client.release();
  }
});

/** GET /incoming-likes
 * People who liked me but I haven't liked yet (and not already matched)
 */
router.get("/incoming-likes", auth, async (req, res) => {
  const userId = Number(req.userId);
  if (!Number.isInteger(userId) || userId <= 0) return res.status(400).json({ error: "Invalid auth user" });

  try {
    const { rows } = await pool.query(
      `
      SELECT u.id, u.name, u.age, u.bio, u.photos, u.interests, u.personality
      FROM likes l
      JOIN users u ON u.id = l.user_id
      WHERE l.target_id = $1
        AND NOT EXISTS (
          SELECT 1 FROM likes mine WHERE mine.user_id = $1 AND mine.target_id = u.id
        )
        AND NOT EXISTS (
          SELECT 1 FROM matches m
          WHERE (m.user_a_id = LEAST($1,u.id) AND m.user_b_id = GREATEST($1,u.id))
            AND m.status = 'active'
        )
      ORDER BY l.created_at DESC
      LIMIT 50;
      `,
      [userId]
    );
    res.json(rows);
  } catch (e) {
    console.error("GET /incoming-likes error:", e);
    res.status(500).json({ error: "Failed to get incoming likes" });
  }
});

/** GET /   (my matches with chat + mutual photo reveal) */
router.get("/", auth, async (req, res) => {
  const userId = Number(req.userId);
  if (!Number.isInteger(userId) || userId <= 0) return res.status(400).json({ error: "Invalid auth user" });

  try {
    const { rows } = await pool.query(
      `
      WITH my_matches AS (
        SELECT m.*
             , CASE WHEN m.user_a_id = $1 THEN m.user_b_id ELSE m.user_a_id END AS other_id
        FROM matches m
        WHERE (m.user_a_id = $1 OR m.user_b_id = $1) AND m.status = 'active'
      ),
      reveal AS (
        SELECT match_id, COUNT(*) FILTER (WHERE consent = TRUE) AS consents
        FROM photo_reveals
        GROUP BY match_id
      )
      SELECT
        mm.id            AS match_record_id,
        u.id             AS match_id,
        u.name,
        u.photos,
        c.id             AS chat_id,
        mm.created_at,
        COALESCE(r.consents,0) = 2 AS mutual_photo_reveal
      FROM my_matches mm
      JOIN users u ON u.id = mm.other_id
      LEFT JOIN chats c ON c.match_id = mm.id
      LEFT JOIN reveal r ON r.match_id = mm.id
      ORDER BY mm.created_at DESC;
      `,
      [userId]
    );
    res.json(rows);
  } catch (e) {
    console.error("GET / (matches) error:", e);
    res.status(500).json({ error: "Failed to get matches" });
  }
});

/** POST /:matchId/photo-reveal   { consent: boolean } */
router.post("/:matchId/photo-reveal", auth, async (req, res) => {
  const userId = Number(req.userId);
  const matchId = Number(req.params.matchId);
  const consent = Boolean(req.body?.consent);
  if (!Number.isInteger(userId) || userId <= 0) return res.status(400).json({ error: "Invalid auth user" });
  if (!Number.isInteger(matchId) || matchId <= 0) return res.status(400).json({ error: "Invalid matchId" });

  try {
    const { rows: mm } = await pool.query(
      "SELECT user_a_id, user_b_id FROM matches WHERE id=$1 AND status='active'",
      [matchId]
    );
    if (!mm.length) return res.status(404).json({ error: "Match not found" });
    if (![mm[0].user_a_id, mm[0].user_b_id].includes(userId)) {
      return res.status(403).json({ error: "Not a participant in this match" });
    }

    await pool.query(
      `
      INSERT INTO photo_reveals (match_id, user_id, consent, revealed_at)
      VALUES ($1,$2,$3, now())
      ON CONFLICT (match_id, user_id)
      DO UPDATE SET consent = EXCLUDED.consent, revealed_at = now();
      `,
      [matchId, userId, consent]
    );

    const { rows: cons } = await pool.query(
      "SELECT COUNT(*)::int AS c FROM photo_reveals WHERE match_id=$1 AND consent=TRUE",
      [matchId]
    );
    res.json({ message: "Photo reveal consent updated", mutual: cons[0].c === 2 });
  } catch (e) {
    console.error("POST /photo-reveal error:", e);
    res.status(500).json({ error: "Failed to update photo reveal" });
  }
});

/** GET /:matchId/photo-reveal */
router.get("/:matchId/photo-reveal", auth, async (req, res) => {
  const matchId = Number(req.params.matchId);
  if (!Number.isInteger(matchId) || matchId <= 0) return res.status(400).json({ error: "Invalid matchId" });

  try {
    const { rows } = await pool.query(
      "SELECT user_id, consent FROM photo_reveals WHERE match_id=$1",
      [matchId]
    );
    const reveals = {};
    for (const r of rows) reveals[r.user_id] = r.consent === true;
    const mutual = Object.values(reveals).filter(Boolean).length === 2;
    res.json({ ...reveals, mutual });
  } catch (e) {
    console.error("GET /photo-reveal error:", e);
    res.status(500).json({ error: "Failed to get photo reveal status" });
  }
});

/** POST /:matchId/unmatch  (sets status='unmatched') */
router.post("/:matchId/unmatch", auth, async (req, res) => {
  const userId = Number(req.userId);
  const matchId = Number(req.params.matchId);
  if (!Number.isInteger(userId) || userId <= 0 || !Number.isInteger(matchId) || matchId <= 0) {
    return res.status(400).json({ error: "Invalid input" });
  }
  try {
    const { rowCount } = await pool.query(
      `
      UPDATE matches
      SET status='unmatched'
      WHERE id=$1 AND (user_a_id=$2 OR user_b_id=$2) AND status='active'
      `,
      [matchId, userId]
    );
    if (!rowCount) return res.status(404).json({ error: "Match not found or already closed" });
    res.json({ message: "Unmatched" });
  } catch (e) {
    console.error("POST /unmatch error:", e);
    res.status(500).json({ error: "Failed to unmatch" });
  }
});

/** POST /:matchId/block  (sets status='blocked') */
router.post("/:matchId/block", auth, async (req, res) => {
  const userId = Number(req.userId);
  const matchId = Number(req.params.matchId);
  if (!Number.isInteger(userId) || userId <= 0 || !Number.isInteger(matchId) || matchId <= 0) {
    return res.status(400).json({ error: "Invalid input" });
  }
  try {
    const { rowCount } = await pool.query(
      `
      UPDATE matches
      SET status='blocked'
      WHERE id=$1 AND (user_a_id=$2 OR user_b_id=$2) AND status='active'
      `,
      [matchId, userId]
    );
    if (!rowCount) return res.status(404).json({ error: "Match not found or already closed" });
    res.json({ message: "Blocked" });
  } catch (e) {
    console.error("POST /block error:", e);
    res.status(500).json({ error: "Failed to block" });
  }
});

module.exports = router;
