-- Passwords below are placeholders; sign up via API to create real bcrypt hashes.
INSERT INTO users (name, email, password, age, bio, interests, personality, photos)
VALUES
  ('Alex','alex@example.com','$2b$10$replace_me',28,'Love hiking and jazz',
   ARRAY['hiking','jazz','sushi'],
   '{"openness":0.8,"conscientiousness":0.6,"extraversion":0.4,"agreeableness":0.7,"neuroticism":0.2}'::jsonb,
   ARRAY['https://example.com/blur1.jpg']),
  ('Jamie','jamie@example.com','$2b$10$replace_me',29,'Foodie & trail runner',
   ARRAY['sushi','hiking','reading'],
   '{"openness":0.7,"conscientiousness":0.5,"extraversion":0.6,"agreeableness":0.6,"neuroticism":0.3}'::jsonb,
   ARRAY['https://example.com/blur2.jpg']);
