-- Additional K53 Questions for Supabase Database
-- This SQL file adds more questions to the questions table
-- Run this in your Supabase SQL editor after disabling RLS or with service role privileges
-- Prevents duplicates by checking for existing question_text

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
    ('rules_of_road', 1, 'What should you do when approaching a traffic light that turns yellow?', '[{"text": "Speed up to cross before it turns red"}, {"text": "Stop if it is safe to do so"}, {"text": "Continue at the same speed"}, {"text": "Sound your horn and proceed"}]'::jsonb, 1, 'A yellow traffic light means prepare to stop. You should stop if it is safe, otherwise proceed with caution.', 2),
    ('rules_of_road', 2, 'What is the minimum safe following distance in wet conditions?', '[{"text": "1 second"}, {"text": "2 seconds"}, {"text": "3 seconds"}, {"text": "4 seconds"}]'::jsonb, 3, 'In wet conditions, you should maintain at least a 4-second following distance to allow for increased stopping distance.', 2),
    ('rules_of_road', 3, 'When may you overtake another vehicle on the left?', '[{"text": "When the vehicle in front is turning right"}, {"text": "Never in South Africa"}, {"text": "On any multi-lane road"}, {"text": "When the vehicle is moving slowly"}]'::jsonb, 0, 'You may overtake on the left when the vehicle in front is turning right and there is sufficient space.', 3),
    
    -- Road Signs - Additional Questions
    ('road_signs', 1, 'What does a blue circular sign with a white bicycle indicate?', '[{"text": "Bicycle crossing ahead"}, {"text": "No bicycles allowed"}, {"text": "Compulsory bicycle path"}, {"text": "Bicycle parking area"}]'::jsonb, 2, 'A blue circular sign with a white bicycle indicates a compulsory bicycle path - cyclists must use this path.', 1),
    ('road_signs', 2, 'What does a red triangle sign with a picture of children playing mean?', '[{"text": "School zone ahead"}, {"text": "Playground area"}, {"text": "Children crossing ahead"}, {"text": "No children allowed"}]'::jsonb, 2, 'A red triangle with children playing warns of children crossing ahead - reduce speed and be prepared to stop.', 2),
    ('road_signs', 3, 'What does a yellow diamond sign with a picture of falling rocks mean?', '[{"text": "Road construction ahead"}, {"text": "Falling rocks danger"}, {"text": "Steep hill ahead"}, {"text": "Tunnel ahead"}]'::jsonb, 1, 'A yellow diamond with falling rocks warns of potential rockfalls in the area - proceed with caution.', 3),
    
    -- Vehicle Controls - Additional Questions
    ('vehicle_controls', 1, 'What is the purpose of the clutch on a motorcycle?', '[{"text": "To change gears smoothly"}, {"text": "To increase engine power"}, {"text": "To activate the brakes"}, {"text": "To control the throttle"}]'::jsonb, 0, 'The clutch disengages the engine from the transmission, allowing you to change gears smoothly.', 1),
    ('vehicle_controls', 2, 'What should you check in your vehicle during the pre-trip inspection?', '[{"text": "Fuel level, oil, water, tires, and lights"}, {"text": "Radio station and seat position"}, {"text": "Interior cleanliness only"}, {"text": "Previous trip distance"}]'::jsonb, 0, 'A proper pre-trip inspection includes checking fuel, oil, water, tire pressure and condition, and all lights.', 2),
    ('vehicle_controls', 3, 'What is the function of a Jake brake in heavy vehicles?', '[{"text": "To assist with engine braking"}, {"text": "To improve fuel efficiency"}, {"text": "To activate emergency brakes"}, {"text": "To measure brake wear"}]'::jsonb, 0, 'A Jake brake (engine brake) helps slow down heavy vehicles by using engine compression, reducing wear on service brakes.', 3),
    
    -- More Rules of the Road Questions
    ('rules_of_road', 1, 'When must you use your headlights?', '[{"text": "Only at night"}, {"text": "When visibility is less than 150m"}, {"text": "Only in rain"}, {"text": "When overtaking"}]'::jsonb, 1, 'You must use headlights when visibility is less than 150 meters, regardless of time of day.', 2),
    ('rules_of_road', 2, 'What does a solid yellow line along the center of the road mean?', '[{"text": "No overtaking allowed"}, {"text": "Overtaking allowed with caution"}, {"text": "Bus lane only"}, {"text": "No stopping allowed"}]'::jsonb, 0, 'A solid yellow line means no overtaking is permitted - you must not cross this line to pass other vehicles.', 1),
    
    -- More Road Signs Questions
    ('road_signs', 1, 'What does a white rectangular sign with black writing "STOP" mean?', '[{"text": "Slow down and proceed"}, {"text": "Stop completely and yield"}, {"text": "No entry beyond this point"}, {"text": "Parking not allowed"}]'::jsonb, 1, 'A STOP sign requires you to come to a complete stop and yield to all traffic before proceeding.', 1),
    ('road_signs', 2, 'What does a blue square sign with a white "P" mean?', '[{"text": "No parking"}, {"text": "Parking area"}, {"text": "Pedestrian crossing"}, {"text": "Police station ahead"}]'::jsonb, 1, 'A blue square with a white "P" indicates a parking area where vehicles may be parked.', 1),
    
    -- More Vehicle Controls Questions
    ('vehicle_controls', 1, 'What is the purpose of the choke on a motorcycle?', '[{"text": "To enrich the fuel mixture for cold starts"}, {"text": "To control engine speed"}, {"text": "To activate the clutch"}, {"text": "To measure fuel consumption"}]'::jsonb, 0, 'The choke enriches the air-fuel mixture to help start a cold engine, then should be gradually turned off as the engine warms.', 2),
    ('vehicle_controls', 2, 'What should you do if your vehicle starts to aquaplane?', '[{"text": "Brake hard to stop quickly"}, {"text": "Steer sharply to regain control"}, {"text": "Ease off the accelerator and steer straight"}, {"text": "Accelerate to get through the water"}]'::jsonb, 2, 'If aquaplaning, ease off the accelerator and hold the steering wheel straight until you regain traction - do not brake suddenly.', 3)
) AS data(category, learner_code, question_text, options, correct_index, explanation, difficulty_level)
WHERE NOT EXISTS (
  SELECT 1 FROM questions WHERE question_text = data.question_text
);

-- Confirm the insertions
SELECT 'Successfully inserted ' || COUNT(*) || ' additional questions' AS result FROM questions WHERE created_at > NOW() - INTERVAL '1 minute';