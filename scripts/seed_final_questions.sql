-- Final Set of K53 Questions for 45-Minute Exams
-- Adds 20+ additional questions to reach a total of 44+ questions
-- Run this in Supabase SQL Editor after previous seed scripts

INSERT INTO questions (id, category, learner_code, question_text, options, correct_index, explanation, version, is_active, difficulty_level, created_at, updated_at)
SELECT 
  gen_random_uuid(),
  data.category,
  data.learner_code,
  data.question_text,
  data.options,
  data.correct_index,
  data.explanation,
  1,
  true,
  data.difficulty_level,
  NOW(),
  NOW()
FROM (
  VALUES
    -- Rules of the Road - Additional Questions
    ('rules_of_road', 1, 'What should you do when you see a pedestrian crossing the road?', '[{"text": "Speed up to pass quickly"}, {"text": "Stop and give way to the pedestrian"}, {"text": "Sound your horn to alert them"}, {"text": "Swerve around them"}]'::jsonb, 1, 'You must stop and give way to pedestrians at crossings. Their safety is your responsibility.', 1),
    ('rules_of_road', 2, 'What does a flashing yellow traffic light mean?', '[{"text": "Proceed with caution"}, {"text": "Stop immediately"}, {"text": "Speed limit applies"}, {"text": "No stopping"}]'::jsonb, 0, 'A flashing yellow light means proceed with caution - be prepared to stop if necessary.', 2),
    ('rules_of_road', 3, 'When driving in fog, you should:', '[{"text": "Use high beam headlights"}, {"text": "Use low beam headlights"}, {"text": "Drive without lights"}, {"text": "Use hazard lights"}]'::jsonb, 1, 'In fog, use low beam headlights. High beams reflect off the fog and reduce visibility.', 3),
    
    -- Road Signs - Additional Questions
    ('road_signs', 1, 'What does a red octagonal sign indicate?', '[{"text": "Yield"}, {"text": "Stop"}, {"text": "No entry"}, {"text": "Danger"}]'::jsonb, 1, 'A red octagonal sign means STOP. You must come to a complete stop.', 1),
    ('road_signs', 2, 'What does a blue circular sign with a white arrow pointing right mean?', '[{"text": "Turn right only"}, {"text": "No right turn"}, {"text": "Right lane ends"}, {"text": "Roundabout"}]'::jsonb, 0, 'A blue circular sign with a white arrow indicates a mandatory direction - you must turn right.', 2),
    ('road_signs', 3, 'What does a yellow diamond sign with a picture of a deer mean?', '[{"text": "Zoo ahead"}, {"text": "Animal crossing"}, {"text": "Hunting area"}, {"text": "Nature reserve"}]'::jsonb, 1, 'A yellow diamond with a deer warns of possible animal crossings - reduce speed and be alert.', 3),
    
    -- Vehicle Controls - Additional Questions
    ('vehicle_controls', 1, 'What is the purpose of the tachometer on a motorcycle?', '[{"text": "Measures engine RPM"}, {"text": "Measures speed"}, {"text": "Measures fuel level"}, {"text": "Measures temperature"}]'::jsonb, 0, 'The tachometer shows engine revolutions per minute (RPM), helping you shift gears optimally.', 1),
    ('vehicle_controls', 2, 'What should you do if your vehicle''s temperature warning light comes on?', '[{"text": "Continue driving normally"}, {"text": "Stop and check coolant level"}, {"text": "Turn on the heater"}, {"text": "Accelerate to cool the engine"}]'::jsonb, 1, 'If the temperature warning light comes on, stop safely and check coolant levels to prevent engine damage.', 2),
    ('vehicle_controls', 3, 'What is the function of a differential in a vehicle?', '[{"text": "To allow wheels to rotate at different speeds"}, {"text": "To improve fuel efficiency"}, {"text": "To increase torque"}, {"text": "To reduce emissions"}]'::jsonb, 0, 'The differential allows wheels on the same axle to rotate at different speeds, essential for turning corners.', 3),
    
    -- More Rules of the Road Questions
    ('rules_of_road', 1, 'When approaching a railway crossing, you should:', '[{"text": "Speed up to cross quickly"}, {"text": "Stop and look both ways"}, {"text": "Sound your horn"}, {"text": "Change gears"}]'::jsonb, 1, 'At railway crossings, always stop, look both ways, and listen for trains before proceeding.', 2),
    ('rules_of_road', 2, 'What is the legal blood alcohol limit for drivers in South Africa?', '[{"text": "0.05g/100ml"}, {"text": "0.08g/100ml"}, {"text": "0.02g/100ml"}, {"text": "0.10g/100ml"}]'::jsonb, 0, 'The legal blood alcohol limit is 0.05g per 100ml. Driving under influence is dangerous and illegal.', 3),
    
    -- More Road Signs Questions
    ('road_signs', 1, 'What does a white sign with a red circle and slash mean?', '[{"text": "Warning"}, {"text": "Prohibition"}, {"text": "Mandatory action"}, {"text": "Information"}]'::jsonb, 1, 'A white sign with red circle and slash indicates prohibition - the action shown is not allowed.', 1),
    ('road_signs', 2, 'What does a green rectangular sign with white writing indicate?', '[{"text": "Direction or destination"}, {"text": "Warning"}, {"text": "Prohibition"}, {"text": "Construction"}]'::jsonb, 0, 'Green rectangular signs provide directional information, such as distances to destinations.', 2),
    
    -- More Vehicle Controls Questions
    ('vehicle_controls', 1, 'What should you check regularly on your motorcycle chain?', '[{"text": "Tension and lubrication"}, {"text": "Color and design"}, {"text": "Length and weight"}, {"text": "Age and brand"}]'::jsonb, 0, 'Regularly check chain tension and lubrication for safety and optimal performance.', 2),
    ('vehicle_controls', 2, 'What is the purpose of the ABS (Anti-lock Braking System)?', '[{"text": "To prevent wheel lock-up during braking"}, {"text": "To improve acceleration"}, {"text": "To reduce fuel consumption"}, {"text": "To enhance comfort"}]'::jsonb, 0, 'ABS prevents wheels from locking during hard braking, maintaining steering control and reducing stopping distance.', 3),
    
    -- Even More Questions to Ensure Adequate Pool
    ('rules_of_road', 3, 'When may you use the emergency lane on a freeway?', '[{"text": "For overtaking"}, {"text": "For stopping in emergencies"}, {"text": "For faster travel"}, {"text": "For loading goods"}]'::jsonb, 1, 'The emergency lane is only for genuine emergencies, breakdowns, or when directed by authorities.', 2),
    ('road_signs', 3, 'What does a yellow sign with a black arrow pointing down mean?', '[{"text": "Steep hill descent"}, {"text": "Road narrows"}, {"text": "Falling rocks"}, {"text": "Slippery road"}]'::jsonb, 0, 'A yellow sign with downward arrow warns of a steep hill descent - reduce speed and use lower gear.', 3),
    ('vehicle_controls', 3, 'What is the purpose of a turbocharger in a diesel engine?', '[{"text": "To increase engine power and efficiency"}, {"text": "To reduce noise"}, {"text": "To improve fuel quality"}, {"text": "To clean exhaust"}]'::jsonb, 0, 'A turbocharger compresses air entering the engine, increasing power and efficiency.', 2)
) AS data(category, learner_code, question_text, options, correct_index, explanation, difficulty_level)
WHERE NOT EXISTS (
  SELECT 1 FROM questions WHERE question_text = data.question_text
);

-- Confirm the insertions
SELECT 'Successfully inserted ' || COUNT(*) || ' additional questions' AS result FROM questions WHERE created_at > NOW() - INTERVAL '1 minute';