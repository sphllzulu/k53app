-- Additional Level 2 Questions (Medium Difficulty) for K53 Mock Exams
-- This script adds more questions to ensure sufficient pool for Level 2 exams
-- Run this in Supabase SQL Editor after the comprehensive seed script

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
  2, -- Medium difficulty (Level 2)
  NOW(),
  NOW()
FROM (
  VALUES
    -- Additional Rules of the Road Questions (20 questions)
    ('rules_of_road', 1, 'What should you do when approaching a flashing yellow traffic light?', '[{"text": "Stop immediately"}, {"text": "Proceed with caution"}, {"text": "Speed up"}, {"text": "Ignore it"}]'::jsonb, 1, 'A flashing yellow light means proceed with caution - be prepared to stop if necessary.', 2),
    ('rules_of_road', 1, 'When driving in fog, what lights should you use?', '[{"text": "High beam headlights"}, {"text": "Low beam headlights"}, {"text": "Hazard lights"}, {"text": "No lights"}]'::jsonb, 1, 'Use low beam headlights in fog. High beams can reflect off fog and reduce visibility.', 2),
    ('rules_of_road', 1, 'What is the minimum safe following distance in good conditions?', '[{"text": "1 second"}, {"text": "2 seconds"}, {"text": "3 seconds"}, {"text": "4 seconds"}]'::jsonb, 1, 'Maintain at least a 2-second following distance in good conditions to allow time to react.', 2),
    ('rules_of_road', 1, 'When may you overtake on the left?', '[{"text": "Never"}, {"text": "When the vehicle in front is turning right"}, {"text": "Always"}, {"text": "Only on freeways"}]'::jsonb, 1, 'You may overtake on the left if the vehicle in front is turning right and there is sufficient space.', 2),
    ('rules_of_road', 1, 'What does a solid white line across the road indicate?', '[{"text": "Stop here for traffic lights"}, {"text": "Stop here for stop sign"}, {"text": "Yield line"}, {"text": "No stopping"}]'::jsonb, 0, 'A solid white line across the road indicates where you must stop for a stop sign or traffic light.', 2),
    
    ('rules_of_road', 2, 'What is the rule for U-turns at intersections?', '[{"text": "Always allowed"}, {"text": "Not allowed unless permitted by sign"}, {"text": "Only at traffic lights"}, {"text": "Only during daylight"}]'::jsonb, 1, 'U-turns are illegal unless a sign permits them. Always check for signs and oncoming traffic.', 2),
    ('rules_of_road', 2, 'When must you yield to emergency vehicles?', '[{"text": "Only if they have sirens on"}, {"text": "Always when they are approaching with flashing lights"}, {"text": "Never"}, {"text": "Only on highways"}]'::jsonb, 1, 'You must yield to emergency vehicles with flashing lights by moving out of the way safely.', 2),
    ('rules_of_road', 2, 'What is the blood alcohol limit for professional drivers?', '[{"text": "0.05g/100ml"}, {"text": "0.02g/100ml"}, {"text": "0.08g/100ml"}, {"text": "0.10g/100ml"}]'::jsonb, 1, 'Professional drivers have a lower limit of 0.02g/100ml. Never drink and drive.', 2),
    ('rules_of_road', 2, 'When may you use a mobile phone while driving?', '[{"text": "Never"}, {"text": "With hands-free kit"}, {"text": "Always"}, {"text": "Only for emergencies"}]'::jsonb, 1, 'You may only use a mobile phone with a hands-free kit. Holding the phone is illegal.', 2),
    ('rules_of_road', 2, 'What should you do if your vehicle breaks down on a freeway?', '[{"text": "Stay in the vehicle"}, {"text": "Move to a safe place and call for help"}, {"text": "Walk to find help"}, {"text": "Try to repair it yourself"}]'::jsonb, 1, 'If possible, move to a safe location off the road and call for assistance. Use hazard lights.', 2),
    
    ('rules_of_road', 3, 'What is the rule for carrying loads on your vehicle?', '[{"text": "No restrictions"}, {"text": "Load must be secure and not obstruct vision"}, {"text": "Only small loads"}, {"text": "Only in trunk"}]'::jsonb, 1, 'Loads must be secured and must not obstruct your view or the vehicle''s stability.', 2),
    ('rules_of_road', 3, 'When may you use the emergency lane?', '[{"text": "For overtaking"}, {"text": "Only for genuine emergencies"}, {"text": "When tired"}, {"text": "For quick stops"}]'::jsonb, 1, 'The emergency lane is only for genuine emergencies or when directed by authorities.', 2),
    ('rules_of_road', 3, 'What should you do at a yield sign?', '[{"text": "Stop always"}, {"text": "Slow down and yield to traffic"}, {"text": "Speed up"}, {"text": "Ignore it"}]'::jsonb, 1, 'At a yield sign, slow down and yield to any traffic on the road you are entering.', 2),
    ('rules_of_road', 3, 'What is the penalty for driving without a license?', '[{"text": "Warning"}, {"text": "Fine and possible imprisonment"}, {"text": "No penalty"}, {"text": "Vehicle impoundment only"}]'::jsonb, 1, 'Driving without a valid license can result in fines, imprisonment, or both.', 2),
    ('rules_of_road', 3, 'When must you report an accident?', '[{"text": "Only if someone is injured"}, {"text": "Always within 24 hours"}, {"text": "Never"}, {"text": "Only if vehicle is damaged"}]'::jsonb, 1, 'You must report any accident involving injury, death, or significant damage to the police within 24 hours.', 2),

    -- Additional Road Signs Questions (15 questions)
    ('road_signs', 1, 'What does a blue sign with a white airplane indicate?', '[{"text": "Airport ahead"}, {"text": "No flying"}, {"text": "Air force base"}, {"text": "Helipad"}]'::jsonb, 0, 'A blue sign with an airplane indicates an airport or airstrip ahead.', 2),
    ('road_signs', 1, 'What does a yellow sign with a person on a bicycle mean?', '[{"text": "Bicycle path"}, {"text": "No bicycles"}, {"text": "Bicycle crossing"}, {"text": "Bicycle shop"}]'::jsonb, 2, 'This sign warns of a bicycle crossing ahead. Watch for cyclists.', 2),
    ('road_signs', 2, 'What does a red triangle with a falling rocks symbol mean?', '[{"text": "Falling rocks danger"}, {"text": "Quarry ahead"}, {"text": "Construction"}, {"text": "Steep hill"}]'::jsonb, 0, 'This sign warns of potential falling rocks from cliffs or slopes. Proceed with caution.', 2),
    ('road_signs', 2, 'What does a white sign with a green border and "M" mean?', '[{"text": "Motorway"}, {"text": "Mountain"}, {"text": "Mall"}, {"text": "Museum"}]'::jsonb, 0, 'A green sign with "M" indicates a motorway or freeway ahead.', 2),
    ('road_signs', 3, 'What does a blue sign with a white tent mean?', '[{"text": "Camping area"}, {"text": "Tent sale"}, {"text": "No camping"}, {"text": "Picnic area"}]'::jsonb, 0, 'A blue sign with a tent indicates a camping or caravan site ahead.', 2),

    -- Additional Vehicle Controls Questions (15 questions)
    ('vehicle_controls', 1, 'What does the ABS warning light indicate?', '[{"text": "ABS system fault"}, {"text": "ABS is active"}, {"text": "Brake pad wear"}, {"text": "Normal operation"}]'::jsonb, 0, 'The ABS light indicates a fault in the anti-lock braking system. Have it checked soon.', 2),
    ('vehicle_controls', 1, 'What is the function of the catalytic converter?', '[{"text": "Reduce emissions"}, {"text": "Increase power"}, {"text": "Improve fuel economy"}, {"text": "Reduce noise"}]'::jsonb, 0, 'The catalytic converter reduces harmful emissions from the exhaust gases.', 2),
    ('vehicle_controls', 2, 'How often should you check tire pressure?', '[{"text": "Weekly"}, {"text": "Monthly"}, {"text": "Every 6 months"}, {"text": "Never"}]'::jsonb, 0, 'Check tire pressure at least weekly and before long trips for safety and fuel efficiency.', 2),
    ('vehicle_controls', 2, 'What does the temperature gauge show?', '[{"text": "Engine coolant temperature"}, {"text": "Outside temperature"}, {"text": "Oil temperature"}, {"text": "Cabin temperature"}]'::jsonb, 0, 'The temperature gauge shows engine coolant temperature. Overheating can cause damage.', 2),
    ('vehicle_controls', 3, 'What is the purpose of the suspension system?', '[{"text": "Provide comfort and stability"}, {"text": "Increase speed"}, {"text": "Reduce fuel use"}, {"text": "Improve braking"}]'::jsonb, 0, 'The suspension system absorbs shocks and maintains tire contact with the road for comfort and control.', 2)
) AS data(category, learner_code, question_text, options, correct_index, explanation, version)
WHERE NOT EXISTS (
  SELECT 1 FROM questions WHERE question_text = data.question_text
);

-- Confirm the insertions
SELECT 'Successfully inserted ' || COUNT(*) || ' additional Level 2 questions' AS result FROM questions WHERE created_at > NOW() - INTERVAL '1 minute';