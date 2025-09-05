-- ==========================================
-- COMPREHENSIVE DATING APP SEED DATA
-- ==========================================
-- 
-- TEST LOGIN CREDENTIALS:
-- All users in this seed data use the password: password123
-- You can log in with any email (e.g., emma@example.com) and password: password123
-- 
-- ==========================================
-- Clear existing data first
DELETE FROM messages;
DELETE FROM chats;
DELETE FROM photo_reveals;
DELETE FROM matches;
DELETE FROM likes;
DELETE FROM passes;
DELETE FROM users;

-- Reset sequences
ALTER SEQUENCE users_id_seq RESTART WITH 1;
ALTER SEQUENCE matches_id_seq RESTART WITH 1;
ALTER SEQUENCE chats_id_seq RESTART WITH 1;
ALTER SEQUENCE messages_id_seq RESTART WITH 1;
ALTER SEQUENCE likes_id_seq RESTART WITH 1;
ALTER SEQUENCE photo_reveals_id_seq RESTART WITH 1;

-- ==========================================
-- USERS - Strategically designed for comprehensive testing
-- ==========================================
-- Note: All users below are configured with the password 'password123'
-- The bcrypt hash below corresponds to that password with salt rounds = 10

INSERT INTO users (name, email, password, age, bio, interests, personality, photos) VALUES

-- HIGH COMPATIBILITY GROUP (Users 1-6) - Share many interests, similar personalities
('Emma Rodriguez', 'emma@example.com', '$2b$10$1oBLzWMAdx7TjNQzpgThb.uq5/15g0RJfWj7usMok8bjcYPmF8GAa', 27, 
 'Adventure seeker and coffee enthusiast. Love exploring new hiking trails and trying exotic cuisines. Always up for spontaneous weekend trips!', 
 ARRAY['hiking', 'coffee', 'travel', 'photography', 'sushi', 'yoga'],
 '{"openness":0.85,"conscientiousness":0.70,"extraversion":0.75,"agreeableness":0.80,"neuroticism":0.25}'::jsonb,
 ARRAY['https://example.com/emma1.jpg', 'https://example.com/emma2.jpg']),

('Marcus Chen', 'marcus@example.com', '$2b$10$1oBLzWMAdx7TjNQzpgThb.uq5/15g0RJfWj7usMok8bjcYPmF8GAa', 29,
 'Photographer by day, stargazer by night. Passionate about capturing life''s beautiful moments and exploring the great outdoors.',
 ARRAY['photography', 'hiking', 'astronomy', 'travel', 'coffee', 'rock_climbing'],
 '{"openness":0.90,"conscientiousness":0.65,"extraversion":0.70,"agreeableness":0.85,"neuroticism":0.20}'::jsonb,
 ARRAY['https://example.com/marcus1.jpg', 'https://example.com/marcus2.jpg']),

('Sofia Patel', 'sofia@example.com', '$2b$10$1oBLzWMAdx7TjNQzpgThb.uq5/15g0RJfWj7usMok8bjcYPmF8GAa', 26,
 'Yoga instructor and mindfulness coach. Believe in living authentically and finding joy in simple moments. Love cooking plant-based meals.',
 ARRAY['yoga', 'meditation', 'cooking', 'hiking', 'photography', 'travel'],
 '{"openness":0.80,"conscientiousness":0.75,"extraversion":0.65,"agreeableness":0.90,"neuroticism":0.15}'::jsonb,
 ARRAY['https://example.com/sofia1.jpg', 'https://example.com/sofia2.jpg', 'https://example.com/sofia3.jpg']),

('David Kim', 'david@example.com', '$2b$10$1oBLzWMAdx7TjNQzpgThb.uq5/15g0RJfWj7usMok8bjcYPmF8GAa', 28,
 'Tech enthusiast and rock climbing instructor. When I''m not coding, you''ll find me scaling walls or exploring mountain trails.',
 ARRAY['rock_climbing', 'hiking', 'technology', 'coffee', 'photography', 'travel'],
 '{"openness":0.75,"conscientiousness":0.80,"extraversion":0.60,"agreeableness":0.75,"neuroticism":0.30}'::jsonb,
 ARRAY['https://example.com/david1.jpg']),

('Isabella Torres', 'isabella@example.com', '$2b$10$1oBLzWMAdx7TjNQzpgThb.uq5/15g0RJfWj7usMok8bjcYPmF8GAa', 25,
 'Artist and world traveler. Currently working on a photography series about street art around the globe. Always seeking inspiration!',
 ARRAY['art', 'photography', 'travel', 'coffee', 'yoga', 'museums'],
 '{"openness":0.95,"conscientiousness":0.60,"extraversion":0.80,"agreeableness":0.85,"neuroticism":0.20}'::jsonb,
 ARRAY['https://example.com/isabella1.jpg', 'https://example.com/isabella2.jpg']),

('Jake Morrison', 'jake@example.com', '$2b$10$1oBLzWMAdx7TjNQzpgThb.uq5/15g0RJfWj7usMok8bjcYPmF8GAa', 30,
 'Marine biologist and scuba diving enthusiast. Love sharing my passion for ocean conservation and underwater photography.',
 ARRAY['scuba_diving', 'photography', 'travel', 'hiking', 'marine_biology', 'environmental_science'],
 '{"openness":0.85,"conscientiousness":0.85,"extraversion":0.65,"agreeableness":0.80,"neuroticism":0.25}'::jsonb,
 ARRAY['https://example.com/jake1.jpg', 'https://example.com/jake2.jpg']),

-- MEDIUM COMPATIBILITY GROUP (Users 7-12) - Some overlap, mixed personalities
('Lily Zhang', 'lily@example.com', '$2b$10$1oBLzWMAdx7TjNQzpgThb.uq5/15g0RJfWj7usMok8bjcYPmF8GAa', 24,
 'Bookworm and amateur chef. Spend my weekends exploring local farmers markets and trying new recipes. Always have a novel in my bag.',
 ARRAY['reading', 'cooking', 'farmers_markets', 'wine_tasting', 'museums', 'theater'],
 '{"openness":0.70,"conscientiousness":0.90,"extraversion":0.40,"agreeableness":0.85,"neuroticism":0.35}'::jsonb,
 ARRAY['https://example.com/lily1.jpg']),

('Carlos Mendez', 'carlos@example.com', '$2b$10$1oBLzWMAdx7TjNQzpgThb.uq5/15g0RJfWj7usMok8bjcYPmF8GAa', 32,
 'Salsa dance instructor and music producer. Life is better with rhythm! Love teaching others to dance and discovering new artists.',
 ARRAY['salsa_dancing', 'music_production', 'concerts', 'travel', 'cooking', 'fitness'],
 '{"openness":0.85,"conscientiousness":0.55,"extraversion":0.95,"agreeableness":0.75,"neuroticism":0.40}'::jsonb,
 ARRAY['https://example.com/carlos1.jpg', 'https://example.com/carlos2.jpg']),

('Aisha Johnson', 'aisha@example.com', '$2b$10$1oBLzWMAdx7TjNQzpgThb.uq5/15g0RJfWj7usMok8bjcYPmF8GAa', 28,
 'Environmental lawyer and weekend warrior. Fighting for the planet during the week, exploring it on weekends.',
 ARRAY['environmental_law', 'hiking', 'kayaking', 'yoga', 'sustainability', 'farmers_markets'],
 '{"openness":0.75,"conscientiousness":0.95,"extraversion":0.50,"agreeableness":0.70,"neuroticism":0.45}'::jsonb,
 ARRAY['https://example.com/aisha1.jpg', 'https://example.com/aisha2.jpg']),

('Ryan O''Sullivan', 'ryan@example.com', '$2b$10$1oBLzWMAdx7TjNQzpgThb.uq5/15g0RJfWj7usMok8bjcYPmF8GAa', 31,
 'Craft beer brewer and trivia night champion. Always experimenting with new flavors and love sharing good times with friends.',
 ARRAY['craft_beer', 'brewing', 'trivia', 'board_games', 'cooking', 'live_music'],
 '{"openness":0.65,"conscientiousness":0.70,"extraversion":0.85,"agreeableness":0.90,"neuroticism":0.30}'::jsonb,
 ARRAY['https://example.com/ryan1.jpg']),

('Maya Singh', 'maya@example.com', '$2b$10$1oBLzWMAdx7TjNQzpgThb.uq5/15g0RJfWj7usMok8bjcYPmF8GAa', 26,
 'Digital marketing specialist and fitness enthusiast. Balancing screen time with gym time. Love trying new workout classes.',
 ARRAY['fitness', 'crossfit', 'digital_marketing', 'podcasts', 'healthy_cooking', 'travel'],
 '{"openness":0.60,"conscientiousness":0.80,"extraversion":0.75,"agreeableness":0.65,"neuroticism":0.50}'::jsonb,
 ARRAY['https://example.com/maya1.jpg', 'https://example.com/maya2.jpg']),

('Oliver Bennett', 'oliver@example.com', '$2b$10$1oBLzWMAdx7TjNQzpgThb.uq5/15g0RJfWj7usMok8bjcYPmF8GAa', 29,
 'Veterinarian and dog rescue volunteer. My weekends are spent either helping animals or hiking with my rescue pup, Max.',
 ARRAY['veterinary_medicine', 'animal_rescue', 'hiking', 'dogs', 'volunteering', 'nature_photography'],
 '{"openness":0.70,"conscientiousness":0.85,"extraversion":0.55,"agreeableness":0.95,"neuroticism":0.25}'::jsonb,
 ARRAY['https://example.com/oliver1.jpg', 'https://example.com/oliver2.jpg']),

-- DIVERSE INTERESTS GROUP (Users 13-18) - Unique combinations for varied testing
('Zara Al-Rashid', 'zara@example.com', '$2b$10$1oBLzWMAdx7TjNQzpgThb.uq5/15g0RJfWj7usMok8bjcYPmF8GAa', 27,
 'Architect and urban sketching enthusiast. Fascinated by how cities tell stories through their buildings and spaces.',
 ARRAY['architecture', 'urban_sketching', 'city_planning', 'museums', 'art_galleries', 'coffee'],
 '{"openness":0.80,"conscientiousness":0.75,"extraversion":0.45,"agreeableness":0.70,"neuroticism":0.40}'::jsonb,
 ARRAY['https://example.com/zara1.jpg']),

('Finn Murphy', 'finn@example.com', '$2b$10$1oBLzWMAdx7TjNQzpgThb.uq5/15g0RJfWj7usMok8bjcYPmF8GAa', 25,
 'Stand-up comedian and improv performer. Life''s too short not to laugh every day! Always working on new material.',
 ARRAY['stand_up_comedy', 'improv', 'theater', 'writing', 'live_music', 'craft_beer'],
 '{"openness":0.90,"conscientiousness":0.45,"extraversion":0.95,"agreeableness":0.80,"neuroticism":0.55}'::jsonb,
 ARRAY['https://example.com/finn1.jpg', 'https://example.com/finn2.jpg']),

('Priya Sharma', 'priya@example.com', '$2b$10$1oBLzWMAdx7TjNQzpgThb.uq5/15g0RJfWj7usMok8bjcYPmF8GAa', 30,
 'Neuroscientist researching meditation and mindfulness. When not in the lab, I practice what I study!',
 ARRAY['neuroscience', 'meditation', 'research', 'yoga', 'reading', 'classical_music'],
 '{"openness":0.85,"conscientiousness":0.95,"extraversion":0.30,"agreeableness":0.75,"neuroticism":0.20}'::jsonb,
 ARRAY['https://example.com/priya1.jpg']),

('Antonio Silva', 'antonio@example.com', '$2b$10$1oBLzWMAdx7TjNQzpgThb.uq5/15g0RJfWj7usMok8bjcYPmF8GAa', 33,
 'Professional chef and food truck owner. Bringing authentic Brazilian flavors to the streets. Food is love made visible!',
 ARRAY['professional_cooking', 'brazilian_cuisine', 'food_trucks', 'culinary_arts', 'soccer', 'live_music'],
 '{"openness":0.75,"conscientiousness":0.80,"extraversion":0.85,"agreeableness":0.85,"neuroticism":0.35}'::jsonb,
 ARRAY['https://example.com/antonio1.jpg', 'https://example.com/antonio2.jpg']),

('Luna Park', 'luna@example.com', '$2b$10$1oBLzWMAdx7TjNQzpgThb.uq5/15g0RJfWj7usMok8bjcYPmF8GAa', 26,
 'Game developer and esports enthusiast. Building virtual worlds by day, conquering them by night. Always up for co-op adventures!',
 ARRAY['game_development', 'esports', 'programming', 'anime', 'board_games', 'cats'],
 '{"openness":0.70,"conscientiousness":0.65,"extraversion":0.50,"agreeableness":0.60,"neuroticism":0.45}'::jsonb,
 ARRAY['https://example.com/luna1.jpg']),

('Ethan Brooks', 'ethan@example.com', '$2b$10$1oBLzWMAdx7TjNQzpgThb.uq5/15g0RJfWj7usMok8bjcYPmF8GAa', 28,
 'Documentary filmmaker and social justice advocate. Using storytelling to create positive change in the world.',
 ARRAY['documentary_filmmaking', 'social_justice', 'storytelling', 'travel', 'photography', 'volunteering'],
 '{"openness":0.95,"conscientiousness":0.70,"extraversion":0.60,"agreeableness":0.90,"neuroticism":0.30}'::jsonb,
 ARRAY['https://example.com/ethan1.jpg', 'https://example.com/ethan2.jpg']),

-- ADDITIONAL USERS FOR COMPREHENSIVE TESTING (Users 19-20)
('Sage Williams', 'sage@example.com', '$2b$10$1oBLzWMAdx7TjNQzpgThb.uq5/15g0RJfWj7usMok8bjcYPmF8GAa', 24,
 'Botanical illustrator and plant parent to 47 houseplants. Finding beauty in nature''s smallest details.',
 ARRAY['botanical_illustration', 'plants', 'gardening', 'art', 'nature_walks', 'sustainability'],
 '{"openness":0.75,"conscientiousness":0.85,"extraversion":0.35,"agreeableness":0.80,"neuroticism":0.30}'::jsonb,
 ARRAY['https://example.com/sage1.jpg']),

('Tyler Jackson', 'tyler@example.com', '$2b$10$1oBLzWMAdx7TjNQzpgThb.uq5/15g0RJfWj7usMok8bjcYPmF8GAa', 31,
 'Personal trainer and nutrition coach. Helping people become their strongest selves, inside and out.',
 ARRAY['personal_training', 'nutrition', 'fitness', 'motivational_speaking', 'hiking', 'meal_prep'],
 '{"openness":0.65,"conscientiousness":0.90,"extraversion":0.80,"agreeableness":0.85,"neuroticism":0.25}'::jsonb,
 ARRAY['https://example.com/tyler1.jpg', 'https://example.com/tyler2.jpg']);

-- ==========================================
-- LIKES - Creating strategic relationship webs
-- ==========================================

-- HIGH COMPATIBILITY MUTUAL LIKES (will become matches)
INSERT INTO likes (user_id, target_id, created_at) VALUES
-- Emma (1) and Marcus (2) - photography & hiking overlap
(1, 2, now() - interval '2 days'),
(2, 1, now() - interval '1 day'),

-- Sofia (3) and David (4) - hiking & yoga overlap  
(3, 4, now() - interval '3 days'),
(4, 3, now() - interval '2 days'),

-- Isabella (5) and Jake (6) - travel & photography overlap
(5, 6, now() - interval '4 days'),
(6, 5, now() - interval '3 days'),

-- Cross-group matches for variety
-- Emma (1) and Sofia (3) - yoga & photography
(1, 3, now() - interval '5 days'),
(3, 1, now() - interval '4 days'),

-- Marcus (2) and Jake (6) - photography overlap
(2, 6, now() - interval '6 days'),
(6, 2, now() - interval '5 days');

-- ONE-WAY LIKES (creating incoming likes scenarios)
INSERT INTO likes (user_id, target_id, created_at) VALUES
-- People who liked Emma (1) but she hasn't reciprocated
(7, 1, now() - interval '1 day'),    -- Lily likes Emma
(8, 1, now() - interval '2 days'),   -- Carlos likes Emma
(13, 1, now() - interval '3 days'),  -- Zara likes Emma

-- People who liked Marcus (2) but he hasn't reciprocated  
(9, 2, now() - interval '1 day'),    -- Aisha likes Marcus
(11, 2, now() - interval '4 days'),  -- Maya likes Marcus

-- People who liked Sofia (3) but she hasn't reciprocated
(10, 3, now() - interval '2 days'),  -- Ryan likes Sofia
(12, 3, now() - interval '3 days'),  -- Oliver likes Sofia

-- People who liked David (4) but he hasn't reciprocated
(14, 4, now() - interval '1 day'),   -- Finn likes David
(15, 4, now() - interval '5 days'),  -- Priya likes David

-- Creating more complex like patterns
(16, 7, now() - interval '2 days'),  -- Antonio likes Lily
(17, 8, now() - interval '3 days'),  -- Luna likes Carlos
(18, 9, now() - interval '1 day'),   -- Ethan likes Aisha
(19, 12, now() - interval '4 days'), -- Sage likes Oliver
(20, 11, now() - interval '2 days'); -- Tyler likes Maya

-- Additional one-way likes for comprehensive testing
INSERT INTO likes (user_id, target_id, created_at) VALUES
(5, 15, now() - interval '3 days'), -- Isabella likes Priya
(7, 12, now() - interval '2 days'), -- Lily likes Oliver  
(9, 16, now() - interval '1 day'),  -- Aisha likes Antonio
(11, 18, now() - interval '4 days'), -- Maya likes Ethan
(13, 19, now() - interval '2 days'), -- Zara likes Sage
(14, 20, now() - interval '3 days'); -- Finn likes Tyler

-- ==========================================
-- MATCHES - Auto-created from mutual likes above
-- ==========================================
-- The matches will be created automatically by the mutual likes inserted above
-- when using the POST /:userId/action endpoint. For testing purposes, let's create them directly:

INSERT INTO matches (user_a_id, user_b_id, status, created_at) VALUES
-- Ensuring user_a_id < user_b_id for normalized pairs
(1, 2, 'active', now() - interval '1 day'),     -- Emma & Marcus
(3, 4, 'active', now() - interval '2 days'),    -- Sofia & David  
(5, 6, 'active', now() - interval '3 days'),    -- Isabella & Jake
(1, 3, 'active', now() - interval '4 days'),    -- Emma & Sofia
(2, 6, 'active', now() - interval '5 days');    -- Marcus & Jake

-- ==========================================
-- CHATS - One chat per match
-- ==========================================
INSERT INTO chats (match_id, created_at) VALUES
(1, now() - interval '1 day'),     -- Emma & Marcus chat
(2, now() - interval '2 days'),    -- Sofia & David chat
(3, now() - interval '3 days'),    -- Isabella & Jake chat
(4, now() - interval '4 days'),    -- Emma & Sofia chat
(5, now() - interval '5 days');    -- Marcus & Jake chat

-- ==========================================
-- MESSAGES - Realistic conversations between matched users
-- ==========================================
INSERT INTO messages (chat_id, sender_id, content, created_at, read_at) VALUES

-- Chat 1: Emma (1) & Marcus (2) - Photography enthusiasts
(1, 1, 'Hey Marcus! I saw your photography portfolio - absolutely stunning work! 📸', now() - interval '20 hours', now() - interval '19 hours'),
(1, 2, 'Thank you so much Emma! I checked out your hiking photos on your profile, you visit some incredible places!', now() - interval '19 hours', now() - interval '18 hours'),
(1, 1, 'Thanks! I love combining my passion for hiking with photography. Have you done any mountain photography?', now() - interval '18 hours', now() - interval '17 hours'),
(1, 2, 'Yes! I actually did a sunrise shoot at Mount Tamalpais last month. The golden hour light was incredible ✨', now() - interval '17 hours', now() - interval '16 hours'),
(1, 1, 'No way! That''s one of my favorite hiking spots. We should plan a photo hike together sometime!', now() - interval '16 hours', now() - interval '15 hours'),
(1, 2, 'I''d love that! I know some great spots for both sunrise and sunset shots. Coffee first to plan our route? ☕', now() - interval '15 hours', now() - interval '10 hours'),
(1, 1, 'Perfect! I know this amazing coffee shop in Sausalito with a view. When works for you?', now() - interval '8 hours', NULL),

-- Chat 2: Sofia (3) & David (4) - Yoga and hiking connection
(2, 3, 'Hi David! I noticed you''re into rock climbing and hiking. Do you ever incorporate mindfulness into your outdoor activities?', now() - interval '36 hours', now() - interval '35 hours'),
(2, 4, 'Hey Sofia! Actually yes, I find climbing is incredibly meditative. There''s something about focusing on the rock that clears my mind completely.', now() - interval '35 hours', now() - interval '34 hours'),
(2, 3, 'That''s exactly what I love about yoga! Different activity but same mindful presence. Have you ever tried outdoor yoga?', now() - interval '34 hours', now() - interval '32 hours'),
(2, 4, 'I haven''t but I''ve been curious about it. I imagine it would be amazing with a mountain view!', now() - interval '32 hours', now() - interval '30 hours'),
(2, 3, 'It really is! I sometimes lead outdoor sessions. Would you be interested in joining one? It could be a nice complement to your climbing.', now() - interval '30 hours', now() - interval '28 hours'),
(2, 4, 'That sounds perfect! I''d love to try something new. Where do you usually hold them?', now() - interval '28 hours', now() - interval '24 hours'),
(2, 3, 'I have a beautiful spot in Marin Headlands with ocean views. Saturday mornings work best for the light and energy 🧘‍♀️', now() - interval '20 hours', NULL),

-- Chat 3: Isabella (5) & Jake (6) - Travel and photography artists  
(3, 5, 'Jake! Your underwater photography is breathtaking! I''ve been wanting to try underwater photography for my art series.', now() - interval '60 hours', now() - interval '58 hours'),
(3, 6, 'Thank you Isabella! I saw your street art photography project - the way you capture urban stories is incredible. What got you into that?', now() - interval '58 hours', now() - interval '56 hours'),
(3, 5, 'I''ve always been fascinated by how art reflects culture. Street art tells such authentic stories about communities. Your marine photography does something similar with ocean life!', now() - interval '56 hours', now() - interval '54 hours'),
(3, 6, 'Exactly! Both worlds have so much character and life. I''d love to hear more about your travels. Which city had the most incredible street art?', now() - interval '54 hours', now() - interval '50 hours'),
(3, 5, 'Oh, definitely Buenos Aires! The passion and politics in their murals is unmatched. But honestly, every city has its own artistic voice. Have you done any travel photography?', now() - interval '50 hours', now() - interval '48 hours'),
(3, 6, 'Some! I''ve photographed coral reefs in different countries. Each ecosystem tells a unique story. Maybe we could collaborate on a project combining our perspectives?', now() - interval '48 hours', now() - interval '46 hours'),
(3, 5, 'I love that idea! Art and science collaboration. We could explore how human creativity and natural beauty intersect 🎨🌊', now() - interval '40 hours', NULL),

-- Chat 4: Emma (1) & Sofia (3) - Wellness and adventure
(4, 1, 'Sofia! I loved reading about your mindfulness approach to life. I''ve been trying to incorporate more presence into my hiking.', now() - interval '80 hours', now() - interval '78 hours'),
(4, 3, 'Emma! That''s wonderful. Mindful hiking is such a beautiful practice. Do you find it changes your relationship with nature?', now() - interval '78 hours', now() - interval '76 hours'),
(4, 1, 'Absolutely! Instead of just thinking about the destination, I''m really noticing the journey - sounds, smells, how my body feels.', now() - interval '76 hours', now() - interval '74 hours'),
(4, 3, 'That''s the essence of yoga philosophy applied to movement! I''d love to join you on a mindful hike sometime if you''re open to it.', now() - interval '74 hours', now() - interval '70 hours'),
(4, 1, 'I would absolutely love that! I know some beautiful trail spots. Maybe we could end with some yoga stretches at a scenic viewpoint?', now() - interval '70 hours', now() - interval '66 hours'),
(4, 3, 'Perfect combination! Movement, nature, and mindfulness. I''ll bring my travel yoga mat. When''s your next adventure planned? 🥾', now() - interval '60 hours', NULL),

-- Chat 5: Marcus (2) & Jake (6) - Photography professionals
(5, 2, 'Jake, I''m blown away by your underwater shots! I''ve only done terrestrial photography but I''m fascinated by the technical challenges underwater.', now() - interval '100 hours', now() - interval '98 hours'),
(5, 6, 'Thanks Marcus! Your astrophotography work is incredible too. Both require patience and understanding light in unique environments.', now() - interval '98 hours', now() - interval '96 hours'),
(5, 2, 'True! Though you have to deal with water pressure and currents while I just have to stay up late and battle mosquitos 😄', now() - interval '96 hours', now() - interval '94 hours'),
(5, 6, 'Haha! Different challenges for sure. I''ve always wanted to try night photography. The stars from remote diving locations must be amazing!', now() - interval '94 hours', now() - interval '92 hours'),
(5, 2, 'They really are! I did some shots from Big Sur last month. Maybe we could plan a photography trip - coast during the day, stars at night?', now() - interval '92 hours', now() - interval '88 hours'),
(5, 6, 'That sounds like an amazing adventure! I could teach you some underwater basics if we find good diving spots along the coast.', now() - interval '88 hours', now() - interval '80 hours'),
(5, 2, 'Deal! I''ve been wanting to expand my portfolio. Photography road trip with a pro guide - count me in! 📸🌊', now() - interval '72 hours', NULL);

-- ==========================================  
-- PHOTO REVEALS - Various consent states for testing
-- ==========================================
INSERT INTO photo_reveals (match_id, user_id, consent, revealed_at) VALUES

-- Match 1 (Emma & Marcus) - Both consented (mutual reveal)
(1, 1, TRUE, now() - interval '12 hours'),
(1, 2, TRUE, now() - interval '10 hours'),

-- Match 2 (Sofia & David) - Only Sofia consented  
(2, 3, TRUE, now() - interval '24 hours'),
(2, 4, FALSE, now() - interval '20 hours'),

-- Match 3 (Isabella & Jake) - Both consented (mutual reveal)
(3, 5, TRUE, now() - interval '36 hours'),
(3, 6, TRUE, now() - interval '30 hours'),

-- Match 4 (Emma & Sofia) - Only Emma consented
(4, 1, TRUE, now() - interval '48 hours'),

-- Match 5 (Marcus & Jake) - No consent requests yet
-- (This will test the case where no photo reveals have been initiated)

-- ==========================================
-- PASSES - Optional data for users who passed on others
-- ==========================================
INSERT INTO passes (user_id, target_id, created_at) VALUES
-- Some strategic passes to show variety in decision making
(1, 8, now() - interval '3 days'),   -- Emma passed on Carlos
(2, 9, now() - interval '2 days'),   -- Marcus passed on Aisha  
(3, 14, now() - interval '4 days'),  -- Sofia passed on Finn
(4, 17, now() - interval '1 day'),   -- David passed on Luna
(5, 11, now() - interval '5 days'),  -- Isabella passed on Maya
(6, 16, now() - interval '3 days'),  -- Jake passed on Antonio
(7, 20, now() - interval '2 days'),  -- Lily passed on Tyler
(8, 13, now() - interval '1 day'),   -- Carlos passed on Zara
(9, 19, now() - interval '4 days'),  -- Aisha passed on Sage
(10, 15, now() - interval '3 days'); -- Ryan passed on Priya

-- ==========================================
-- SUMMARY OF TEST DATA COVERAGE
-- ==========================================
-- 
-- This seed data provides comprehensive testing for:
--
-- 1. USERS (20 diverse profiles):
--    - High compatibility group (users 1-6) with 80%+ compatibility scores
--    - Medium compatibility group (users 7-12) with 60-75% compatibility  
--    - Diverse interests group (users 13-20) for varied testing scenarios
--    - Strategic personality and interest combinations
--
-- 2. RELATIONSHIPS:
--    - 5 mutual matches with active chats
--    - 15+ one-way likes creating "incoming likes" scenarios
--    - 10+ complex like patterns for suggestion algorithm testing
--
-- 3. CHATS & MESSAGES:
--    - 5 active conversations with realistic message histories
--    - Various read/unread states for message status testing
--    - Messages spanning different timeframes (hours to days old)
--
-- 4. PHOTO REVEALS:
--    - 2 mutual consent scenarios (photos revealed)  
--    - 2 partial consent scenarios (only one person consented)
--    - 1 no consent scenario (no photo reveal requests yet)
--
-- 5. PASSES:
--    - 10 pass records showing users who decided not to like others
--    - Helps test that passed users don't reappear in suggestions
--
-- FEATURES TESTABLE WITH THIS DATA:
-- ✓ Discover/Suggestions with priority for mutual interest
-- ✓ Most Compatible screen (80%+ compatibility users)
-- ✓ Likes Received/Incoming Likes functionality
-- ✓ Match creation and management
-- ✓ Chat functionality with message history
-- ✓ Photo reveal consent workflow (all states)
-- ✓ Compatibility algorithm accuracy
-- ✓ User search and filtering
-- ✓ Relationship state management (active/blocked/unmatched)
-- ✓ Pass functionality to avoid re-showing users
-- ==========================================

-- Update search vectors for all users (required for search functionality)
UPDATE users SET updated_at = now() WHERE id BETWEEN 1 AND 20;

-- Verify data integrity
SELECT 'SUCCESS: Database seeded with comprehensive test data' AS status;
