
-- Evolve Driving Academy K53 Questions - Complete Set
-- This file replaces all existing questions with the official Evolve Driving Academy questions
-- Run this in Supabase SQL Editor after clearing the database

-- First, clear existing questions (optional - use if you want to replace everything)
-- DELETE FROM questions;

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
    -- RULES OF THE ROAD QUESTIONS (72 questions)
    -- All Rules of the Road questions apply to all learner codes (1, 2, 3)
    
    -- Q1
    ('rules_of_road', 1, 'You may...', '[{"text": "Drive your vehicle on the sidewalk at night"}, {"text": "Reverse your vehicle only if it is safe to do so"}, {"text": "Leave the engine of your vehicle idling when you put petrol in it"}]'::jsonb, 1, 'You may only reverse your vehicle when it is safe to do so. Driving on sidewalks is illegal and leaving engine running while refueling is dangerous.', 2),
    
    -- Q2
    ('rules_of_road', 1, 'When you want to change lanes and drive from one lane to the other you must...', '[{"text": "Only do it when it is safe to do so"}, {"text": "Switch on your indicators in time to show what you are going to do"}, {"text": "Use the mirrors of your vehicle to ensure that you know of other traffic around you"}, {"text": "All of the above are correct"}]'::jsonb, 3, 'All options are correct: change lanes only when safe, use indicators in time, and check mirrors for surrounding traffic.', 2),
    
    -- Q3
    ('rules_of_road', 1, 'When may you not overtake another vehicle?... When you ...', '[{"text": "Are nearing the top of hill"}, {"text": "Are nearing a curve"}, {"text": "Can only see 100m in front of you because of dust over the road"}, {"text": "All of the above are correct"}]'::jsonb, 3, 'You may not overtake when nearing hills, curves, or when visibility is limited to 100m due to dust or other obstructions.', 3),
    
    -- Q4
    ('rules_of_road', 1, 'When are you allowed to drive on the shoulder of a road?', '[{"text": "Any time if you want to let another vehicle to pass you"}, {"text": "In daytime when you want to allow another vehicle pass you and its safe"}, {"text": "When on a freeway with 4 lanes in both directions, you want to drive slower than 120 km/h"}, {"text": "When you have a flat tyre and you want to park there to change it"}, {"text": "Only (ii) and (iv) are correct"}]'::jsonb, 4, 'You may only drive on the shoulder to allow another vehicle to pass (when safe) or when you have a flat tire and need to park to change it.', 2),
    
    -- Q5
    ('rules_of_road', 1, 'You may not obtain a learner''s licence if...', '[{"text": "You already have a licence that authorises the driving of the same vehicle class"}, {"text": "You are declared unfit to obtain a driving licence for a certain period and that period still prevails"}, {"text": "Your licence was suspended temporarily and the suspension has not yet expired"}, {"text": "All of the above are correct"}]'::jsonb, 3, 'All conditions prevent obtaining a learner''s license: existing license for same class, declared unfit period, or active suspension.', 2),
    
    -- Q6
    ('rules_of_road', 1, 'At an intersection...', '[{"text": "Vehicles have the right of way over pedestrians"}, {"text": "You must yield to oncoming traffic if you want to turn right"}, {"text": "You can use a stop sign as a yield sign if there is no other traffic"}]'::jsonb, 1, 'When turning right at an intersection, you must yield to oncoming traffic. Pedestrians have right of way at crossings.', 1),
    
    -- Q7
    ('rules_of_road', 1, 'The licence for your vehicle (clearance certificate) is valid for...', '[{"text": "12 months"}, {"text": "90 days"}, {"text": "21 days"}]'::jsonb, 0, 'A vehicle license (clearance certificate) is typically valid for 12 months and must be renewed annually.', 1),
    
    -- Q8
    ('rules_of_road', 1, 'Unless otherwise shown by a sign, the general speed limit in an urban area is ...km/h.', '[{"text": "60"}, {"text": "80"}, {"text": "100"}]'::jsonb, 0, 'The default speed limit in urban areas is 60 km/h unless otherwise indicated by road signs.', 1),
    
    -- Q9
    ('rules_of_road', 1, 'The legal speed limit which you may drive...', '[{"text": "Is always 120km/h outside an urban area"}, {"text": "Can be determined by yourself if you look at the number of lanes the road has"}, {"text": "Is shown to you by signs next to the road"}]'::jsonb, 2, 'Legal speed limits are indicated by road signs. Do not assume limits based on road type or number of lanes.', 1),
    
    -- Q10
    ('rules_of_road', 1, 'You may...', '[{"text": "Leave your vehicles engine running without supervision"}, {"text": "Allow someone to ride on the bumper of your vehicle"}, {"text": "Put your arm out of the window only to give legal hand signals"}]'::jsonb, 2, 'You may only extend your arm out of the window to give legal hand signals. Never leave engine running unattended or allow riding on bumpers.', 1),
    
    -- Q11
    ('rules_of_road', 1, 'If you see that someone wants to overtake you, you must...', '[{"text": "Not drive faster"}, {"text": "Keep to the left as far as is safe"}, {"text": "Give hand signals to allow the person to pass safely"}, {"text": "Only (i) and (ii) are correct"}]'::jsonb, 3, 'When being overtaken, do not accelerate and keep left as far as safe. Hand signals are not required for this situation.', 2),
    
    -- Q12
    ('rules_of_road', 1, 'The furthest that your vehicle''s dim light may shine in front of you, is...m', '[{"text": "45"}, {"text": "100"}, {"text": "150"}]'::jsonb, 0, 'Dim (dipped) headlights should illuminate the road for approximately 45 meters ahead of your vehicle.', 1),
    
    -- Q13
    ('rules_of_road', 1, 'What is the longest period that a vehicle may be parked on one place on a road outside urban areas?', '[{"text": "7 days"}, {"text": "48 hours"}, {"text": "24 hours"}]'::jsonb, 0, 'Outside urban areas, a vehicle may be parked in one place for up to 7 days unless otherwise prohibited.', 1),
    
    -- Q14
    ('rules_of_road', 1, 'At an intersection...', '[{"text": "You can pass another vehicle waiting to turn right on his left side by going off the road"}, {"text": "You can stop in it to off load passengers"}, {"text": "Pedestrians who are already crossing the road when the red man signal starts showing, have right of way"}]'::jsonb, 2, 'Pedestrians already crossing when the signal changes to red have right of way to complete their crossing safely.', 2),
    
    -- Q15
    ('rules_of_road', 1, 'You are not allowed to stop...', '[{"text": "On the pavement"}, {"text": "With the front of your vehicle facing oncoming traffic"}, {"text": "Next to any obstruction in the road"}]'::jsonb, 0, 'Stopping on the pavement (sidewalk) is prohibited as it obstructs pedestrian access.', 1),
    
    -- Q16
    ('rules_of_road', 1, 'You are not allowed to stop...', '[{"text": "Where you are also prohibited to park"}, {"text": "5m from a bridge"}, {"text": "Opposite a vehicle, where the roadway is 10m wide"}]'::jsonb, 0, 'If an area is designated as no parking, it also means no stopping. Other restrictions may have specific distances.', 2),
    
    -- Q17
    ('rules_of_road', 1, 'You may pass another vehicle on the left-hand side if it...', '[{"text": "Indicates that it is going to turn right"}, {"text": "Drives on the right-hand side of a road with a shoulder were you can pass"}, {"text": "Drives in a town in the right hand lane with 2 lanes in the same direction"}, {"text": "Only (i) and (iii) are correct"}]'::jsonb, 3, 'You may pass on the left when a vehicle is turning right or when in multi-lane roads with designated lanes.', 2),
    
    -- Q18
    ('rules_of_road', 1, 'You may overtake another vehicle on the left hand side...', '[{"text": "When that vehicle is going to turn right and the road is wide enough that it is not necessary to drive on the shoulder"}, {"text": "Where the road has 2 lanes for traffic in the same direction"}, {"text": "If a police officer instructs you to do so"}, {"text": "All of the above are correct"}]'::jsonb, 3, 'All scenarios allow overtaking on the left: vehicle turning right, multi-lane roads, or when directed by authorities.', 2),
    
    -- Q19
    ('rules_of_road', 1, 'You may on a public road...', '[{"text": "Pass another vehicle turning right, on it''s left-hand side without driving on the shoulder of the road"}, {"text": "Pass another vehicle at any place on the left-hand side if it is turning right"}, {"text": "Not pass any vehicle on the left-hand side"}]'::jsonb, 0, 'You may pass on the left of a vehicle turning right, provided you can do so without driving on the shoulder.', 2),
    
    -- Q20
    ('rules_of_road', 1, 'The last action that you must take before moving to another lane is to...', '[{"text": "Switch on your indicator"}, {"text": "Check the blind spot"}, {"text": "Look in rear view mirror"}]'::jsonb, 1, 'The final check before changing lanes should be a blind spot check to ensure no vehicles are in your intended path.', 1),
    
    -- Q21
    ('rules_of_road', 1, 'When are you allowed to drive your vehicle on the right-hand side of a road with traffic in both directions?', '[{"text": "When you switch the emergency lights of your vehicle on"}, {"text": "When a traffic officer shows you to do so"}, {"text": "Under no circumstances"}]'::jsonb, 1, 'You may drive on the right side only when directed by a traffic officer or in specific emergency situations.', 2),
    
    -- Q22
    ('rules_of_road', 1, 'If you come to a robot and the red light flashes, you must...', '[{"text": "Stop and wait for the light to change to green before you go"}, {"text": "Stop and go only if it safe to do so"}, {"text": "Look out for a road block as the light shows you a policestop"}]'::jsonb, 1, 'A flashing red light functions as a stop sign - stop completely and proceed only when safe to do so.', 1),
    
    -- Q23
    ('rules_of_road', 1, 'A vehicle of which the brakes are not good, must be towed', '[{"text": "With a rope"}, {"text": "With a tow-bar"}, {"text": "On a trailer"}]'::jsonb, 2, 'A vehicle with faulty brakes must be transported on a trailer or flatbed tow truck for safety.', 2),
    
    -- Q24
    ('rules_of_road', 1, 'A safe following distance is, when the vehicle in front of you suddenly stops, you could....', '[{"text": "Stop without swerving"}, {"text": "Swerve and stop next to it"}, {"text": "Swerve and pass"}]'::jsonb, 0, 'Maintain sufficient distance to stop completely without swerving if the vehicle ahead stops suddenly.', 1),
    
    -- Q25
    ('rules_of_road', 1, 'You may not', '[{"text": "Have passengers in the vehicle if you only have a learner''s licence"}, {"text": "Leave your vehicle unattended while the engine is running"}, {"text": "Drive in reverse for more than a 100m"}]'::jsonb, 1, 'Never leave a vehicle unattended with the engine running. Learner drivers may carry passengers with supervision.', 1),
    
    -- Q26
    ('rules_of_road', 1, 'If you want to change lanes you must', '[{"text": "Switch on your indicator and change lanes"}, {"text": "Give the necessary signal and after looking for other traffic, change lanes"}, {"text": "Apply the brakes lightly and then change lanes"}]'::jsonb, 1, 'Signal your intention, check mirrors and blind spots for other traffic, then change lanes when safe.', 1),
    
    -- Q27
    ('rules_of_road', 1, 'The fastest speed at which you may tow a vehicle with a rope is .. km/h', '[{"text": "60"}, {"text": "45"}, {"text": "30"}]'::jsonb, 2, 'When towing with a rope, the maximum speed is 30 km/h for safety reasons.', 1),
    
    -- Q28
    ('rules_of_road', 1, 'You may cross or enter a public road...', '[{"text": "If the road is clear of traffic for a short distance"}, {"text": "If the road is clear of traffic for a long distance and it can be done without obstructing traffic"}, {"text": "In any manner as long as you use your indicators in time"}]'::jsonb, 1, 'Enter roads only when you have clear visibility for a sufficient distance and can do so without obstructing traffic.', 2),
    
    -- Q29
    ('rules_of_road', 1, 'Your vehicle''s headlights must be switched on...', '[{"text": "At any time of the day when you can not see persons and vehicle''s 150m in front of you"}, {"text": "From sunset to sunrise"}, {"text": "When it rains and you cannot see vehicles 100m in front of you"}, {"text": "All of the above are correct"}]'::jsonb, 3, 'Headlights must be used from sunset to sunrise, in poor visibility (<150m), and when raining with visibility <100m.', 2),
    
    -- Q30
    ('rules_of_road', 1, 'You may not drive into an intersection when...', '[{"text": "The robot (traffic signal) is yellow and you are already in the intersection"}, {"text": "The vehicle in front of you wants to turn right and the road is wide enough to pass on the left side"}, {"text": "There is not enough space in the intersection to turn right without blocking other traffic"}]'::jsonb, 2, 'Do not enter an intersection unless there is sufficient space to clear it without obstructing cross traffic.', 2),
    
    -- Q31
    ('rules_of_road', 1, 'When you were involved in an accident you...', '[{"text": "Must immediately stop your vehicle"}, {"text": "Must determine the damage to the vehicles"}, {"text": "May refuse to give your name and address to anyone except the police"}, {"text": "Only (i) and (ii) are correct"}]'::jsonb, 3, 'After an accident, stop immediately and assess damage. You must provide details to other involved parties, not just police.', 2),
    
    -- Q32
    ('rules_of_road', 1, 'When you were involved in an accident you...', '[{"text": "Must immediately stop your vehicle"}, {"text": "Must see if someone is injured"}, {"text": "May use a bit of alcohol for the shock"}, {"text": "Only (i) and (ii) are correct"}]'::jsonb, 3, 'Stop immediately, check for injuries, and render assistance. Never consume alcohol after an accident.', 2),
    
    -- Q33
    ('rules_of_road', 1, 'When do you have the right of way?', '[{"text": "When you are within a traffic circle"}, {"text": "When you have stopped first at a four – way stop"}, {"text": "When you want to turn right at an intersection in a two-way road"}, {"text": "Only (i) and (ii) are correct"}]'::jsonb, 3, 'You have right of way when already in a traffic circle and when you stop first at a four-way stop intersection.', 2),
    
    
-- Q34
('rules_of_road', 1, 'If you come across an emergency vehicle on the road sounding a siren you must...', '[{"text": "Flash your headlight to warn other traffic"}, {"text": "Give right of way to the emergency vehicle"}, {"text": "Switch on your vehicles emergency light and blow your hooter"}]'::jsonb, 1, 'Yield right of way to emergency vehicles by moving to the side of the road and allowing them to pass safely.', 1),

   
    
    -- Q35
    ('rules_of_road', 1, 'If you want to turn left with your vehicle, you must...', '[{"text": "Slow down completely, stop and then turn"}, {"text": "First move to the right to enable you to turn left easily"}, {"text": "Give the necessary signal in good time"}]'::jsonb, 2, 'Always signal your intention to turn left in good time to alert other road users of your planned maneuver.', 1),
    
    -- Q36
    ('rules_of_road', 1, 'When you drive...', '[{"text": "You must have both hands on the steering wheel"}, {"text": "Your vision of the road and the traffic must be unobstructed"}, {"text": "You must wear shoes with rubber soles"}]'::jsonb, 1, 'Your view of the road and traffic must always be clear and unobstructed for safe driving.', 1),
    
    -- Q37
    ('rules_of_road', 1, 'Where may you legally stop with your vehicle?', '[{"text": "4m from a tunnel"}, {"text": "5m from a pedestrian crossing"}, {"text": "6m from a railway crossing"}]'::jsonb, 2, 'You may stop 6m from a railway crossing. Other distances may have specific restrictions.', 2),
    
    -- Q38
    ('rules_of_road', 1, 'You may not...', '[{"text": "Run the engine unattended"}, {"text": "Use your vehicle without a cap on the fuel tank"}, {"text": "Spin the wheels of your vehicle when pulling off"}, {"text": "All of the above are correct"}]'::jsonb, 3, 'All actions are prohibited: never leave engine running unattended, always use fuel cap, and avoid wheel spinning.', 2),
    
    -- Q39
    ('rules_of_road', 1, 'What is important with regard to the hooter of your vehicle?', '[{"text": "The tone and pitch of the sound may not change"}, {"text": "Someone must hear it from a distance of at least 50m"}, {"text": "You may use it to get the attention of someone that you would like to offer a lift"}]'::jsonb, 1, 'Your vehicle''s hooter must be audible from at least 50m away for safety warning purposes.', 1),
    
    -- Q40
    ('rules_of_road', 1, 'When the robot is red and the green arrow flashes to the right, it shows you that...', '[{"text": "Only pedestrians may walk"}, {"text": "If you want to turn right, you may go"}, {"text": "All traffic must turn right there"}]'::jsonb, 1, 'A flashing green arrow with red light allows right turns only, while through traffic must wait.', 2),
    
    -- Q41
    ('rules_of_road', 1, 'You must stop your vehicle ...', '[{"text": "On a public road at the signal of a person driving sheep"}, {"text": "On a freeway when directed to do so by a traffic officer"}, {"text": "On any road to avoid an accident"}, {"text": "All the above are correct"}]'::jsonb, 3, 'You must stop for animal drivers, when directed by traffic officers, or to prevent accidents in any situation.', 2),
    
    -- Q42
    ('rules_of_road', 1, 'An accident in which no one has or has not been injured must be reported within ... hours', '[{"text": "24"}, {"text": "36"}, {"text": "48"}]'::jsonb, 0, 'All accidents must be reported to police within 24 hours, regardless of whether injuries occurred.', 1),
    
    -- Q43
    ('rules_of_road', 1, 'In which case is it permitted to travel with only the parking lights of your vehicle switched on?', '[{"text": "When driving in heavy rain"}, {"text": "When dusk is falling"}, {"text": "In none of the above cases"}]'::jsonb, 2, 'Parking lights are only for stationary vehicles. Always use proper headlights when driving.', 1),
    
    -- Q44
    ('rules_of_road', 1, 'The only instance where you may stop on a freeway...', '[{"text": "To obey the road traffic sign"}, {"text": "For a rest during a tiring journey"}, {"text": "To pick up hitchhikers"}]'::jsonb, 0, 'You may only stop on a freeway to obey traffic signs or in genuine emergencies, not for rest or picking up people.', 2),
    
    -- Q45
    ('rules_of_road', 1, 'When may a driver disobey a rule of the road...?', '[{"text": "Only when directed to do so by a traffic officer"}, {"text": "Under no circumstances"}, {"text": "If you are driving in a emergency situation"}]'::jsonb, 0, 'You may only disobey traffic rules when specifically directed to do so by a traffic officer.', 2),
    
    -- Q46
    ('rules_of_road', 1, 'What is the duty of a driver when driving on a public road that has been divided into two or more roadways?', '[{"text": "You may drive on any part of the roadway"}, {"text": "You are allowed to drive on any part of the roadway after sunset, or when there is no other traffic on the road"}, {"text": "Drive on the left hand roadway unless directed or shown to do so by a traffic officer or traffic sign"}]'::jsonb, 2, 'On divided roadways, drive on the left-hand roadway unless signs or officers direct otherwise.', 2),
    
    -- Q47
    ('rules_of_road', 1, 'When a motor vehicle is standing still, what must the driver do to make sure the motor vehicle does not move...?', '[{"text": "The gear lever must be put in the neutral position"}, {"text": "The parking brake must be applied"}, {"text": "The driver must hold the service brake"}]'::jsonb, 1, 'Always apply the parking brake when the vehicle is stationary to prevent unintended movement.', 1),
    
    -- Q48
    ('rules_of_road', 1, 'What colour and size must flags be to indicate projections on a vehicle on a public road,....', '[{"text": "They can be any size as long as they are red"}, {"text": "They must be red and at least 300 x 300mm"}, {"text": "They may be any colour as long as they are visible"}]'::jsonb, 1, 'Projection flags must be red and at least 300x300mm to be clearly visible to other road users.', 2),
    
    -- Q49
    ('rules_of_road', 1, 'A Temporary sign...?', '[{"text": "Need not be taken seriously at all times"}, {"text": "Is of less importance to road users than a permanent sign"}, {"text": "Has the same legal significance as a permanent sign"}]'::jsonb, 2, 'Temporary signs have the same legal force as permanent signs and must be obeyed.', 1),
    
    -- Q50
    ('rules_of_road', 1, 'What is the duty of a driver, about pedestrians at a pedestrian crossing...?', '[{"text": "A driver must only stop for a pedestrian waiting to enter the road at a pedestrian signal"}, {"text": "A driver must yield right of way to a pedestrian crossing a pedestrian crossing"}, {"text": "A driver must yield to all pedestrians wishing to cross over the road way"}]'::jsonb, 1, 'Drivers must yield to pedestrians actually crossing at designated pedestrian crossings.', 1),
    
    -- Q51
    ('rules_of_road', 1, 'When is it permissible to allow a portion of the body to project beyond the vehicle...?', '[{"text": "Only for the driver to give hand signals"}, {"text": "Only passengers may allow a portion of their bodies to project, they don''t need 2 hands on the steering wheel"}, {"text": "When it is hot and the driver''s window is open"}]'::jsonb, 0, 'Only the driver may extend body parts to give legal hand signals. Passengers should remain fully inside.', 1),
    
    -- Q52
    ('rules_of_road', 1, 'What are the requirements for a vehicle being used with excessive noise...?', '[{"text": "There are no requirements with regards to excessive noise on a vehicle"}, {"text": "No person shall operate a vehicle on a public road that causes any excessive noise"}, {"text": "Excessive noise is acceptable during festive periods, Christmas new year"}]'::jsonb, 1, 'Vehicles must not produce excessive noise that could disturb others or indicate mechanical problems.', 1),
    
    -- Q53
    ('rules_of_road', 1, 'How far behind a vehicle must the warning triangle be placed if your car breaks down?', '[{"text": "At least 45 m"}, {"text": "At least 10m"}, {"text": "At least 100m"}]'::jsonb, 0, 'Place warning triangles at least 45m behind your broken down vehicle to alert approaching traffic.', 1),
    
    -- Q54
    ('rules_of_road', 1, 'When driving a motor vehicle, the minimum safe following distance is...?', '[{"text": "12 meters at 120kph, (1meter for every 10 kph)"}, {"text": "A distance determined by the 2 second rule"}, {"text": "A driver may follow as close as they want so that overtaking is easier when the gap is there"}]'::jsonb, 1, 'Maintain at least a 2-second following distance, increasing to 4 seconds in poor conditions.', 1),
    
    -- Q55
    ('rules_of_road', 1, 'How far may you park from the left edge of a road way outside an urban area...?', '[{"text": "A vehicle may not park on a public road unless in a parking bay"}, {"text": "Not more than 450mm from the edge of the road way"}, {"text": "Not more than 1m from the edge of the road way"}]'::jsonb, 1, 'When parking outside urban areas, stay within 450mm of the road edge to avoid obstructing traffic.', 2),
    
    -- Q56
    ('rules_of_road', 1, 'Show the correct statement......A driver may stop their vehicle on the road way of a public road...?', '[{"text": "When indicated by a traffic officer"}, {"text": "In an intersection"}, {"text": "In contravention with any road traffic sign"}]'::jsonb, 0, 'You may only stop on the roadway when directed by a traffic officer or in genuine emergencies.', 2),
    
    -- Q57
    ('rules_of_road', 1, 'What is the duty of a driver when refilling the fuel tank of a motor vehicle...?', '[{"text": "The driver may not allow the engine to run whilst flammable fuel is being transferred to the fuel tank"}, {"text": "To check if they are filling the tank with diesel not petrol"}, {"text": "Is allowed to start the vehicle while fuel is being pumped to check if the tank is full"}]'::jsonb, 0, 'Never leave the engine running while refueling due to fire hazard from flammable vapors.', 1),
    
    -- Q58
    ('rules_of_road', 1, 'Which one of the following statements are wrong...?', '[{"text": "The driver of a motor vehicle shall ensure that a child seated in a car wears a seatbelt, and where available use an appropriate child restraint"}, {"text": "It is not the drivers responsibility to ensure a child is in a child restraint"}, {"text": "If a seat not equipped with a seatbelt is available the driver shall ensure that a child 14yrs and younger is seated on the rear seat"}]'::jsonb, 1, 'The driver IS responsible for ensuring children use appropriate restraints - this statement is incorrect.', 2),
    
    -- Q59
    ('rules_of_road', 1, 'The driver of a vehicle shall not cross a public road unless...?', '[{"text": "They put on the indicator and then enter the road"}, {"text": "They look in the rear view mirror, engage a gear and go"}, {"text": "The road is clear of traffic for a safe distance, without obstructing or endangering other traffic"}]'::jsonb, 2, 'Only enter a road when you have clear visibility and can do so without obstructing or endangering other traffic.', 1),
    
    -- Q60
    ('rules_of_road', 1, 'The following vehicle may not be used on a freeway...?', '[{"text": "An animal drawn vehicle"}, {"text": "An articulated motor vehicle"}, {"text": "An abnormal loaded motor vehicle"}]'::jsonb, 0, 'Animal-drawn vehicles are prohibited on freeways due to speed differential and safety concerns.', 1),
    
    -- Q61
    ('rules_of_road', 1, 'A person under the influence of intoxicating liquor or a drug...?', '[{"text": "May sit in the driver seat of a vehicle of which the engine is running"}, {"text": "May not sit in the driver''s seat while the engine is running"}, {"text": "May sleep in the driver''s seat while the engine is running"}]'::jsonb, 1, 'Intoxicated persons may not occupy the driver''s seat with engine running, as this implies control of the vehicle.', 2),
    
    -- Q62
    ('rules_of_road', 1, 'Which of the following statements are correct... a silencer?', '[{"text": "With a small hole in it is acceptable"}, {"text": "Need not be fitted only on heavy vehicles"}, {"text": "Must be fitted to a vehicle to restrict the engine noise to a suitable noise level"}]'::jsonb, 2, 'All vehicles must have properly functioning silencers to reduce engine noise to acceptable levels.', 1),
    
    -- Q63
    ('rules_of_road', 1, 'What is the minimum distance stop lamps must be visible to a person with normal eyesight in sunlight...?', '[{"text": "20m"}, {"text": "30m"}, {"text": "10m"}]'::jsonb, 1, 'Stop lamps (brake lights) must be visible from at least 30m in sunlight to effectively warn following traffic.', 1),
    
    -- Q64
    ('rules_of_road', 1, 'When driving a vehicle alone, what documents must you carry with you...?', '[{"text": "Any persons valid drivers licence if you only have a learners licence"}, {"text": "Your original valid drivers licence"}, {"text": "A certified copy of your drivers licence and id document"}]'::jsonb, 1, 'You must carry your original, valid driver''s license when operating a motor vehicle.', 1),
    
    -- Q65
    ('rules_of_road', 1, 'When are you allowed to drive on the right hand side of a freeway...?', '[{"text": "When you are driving 120kph"}, {"text": "At anytime as long as I don''t stop in the right hand lane"}, {"text": "Only when overtaking another vehicle"}]'::jsonb, 2, 'The right lane on freeways is primarily for overtaking. Return to left lanes after passing.', 1),
    
    -- Q66
    ('rules_of_road', 1, 'How long must a flicker be displayed?', '[{"text": "for long enough to show vehicles or persons approaching you of your intentions"}, {"text": "For about 3 mins"}, {"text": "For about 2 mins"}]'::jsonb, 0, 'Indicators must be used long enough to clearly communicate your intentions to other road users.', 1),
    
    -- Q67
    ('rules_of_road', 1, 'When may you pass another vehicle that has stopped at a pedestrian crossing?', '[{"text": "You can pass if its safe to do so"}, {"text": "It is prohibited to pass any vehicle that has stopped at a pedestrian crossing"}, {"text": "You may pass only once the pedestrian has crossed"}]'::jsonb, 1, 'Never pass a vehicle stopped at a pedestrian crossing, as pedestrians may be crossing out of view.', 2),
    
    -- Q68
    ('rules_of_road', 1, 'A light motor vehicle fitted with a spot lamp may be used on a public road...', '[{"text": "If it''s a breakdown vehicle at a collision scene"}, {"text": "With a light that''s beam can shine in any direction"}, {"text": "If the lights are not connected"}]'::jsonb, 0, 'Spot lamps may only be used by authorized emergency or breakdown vehicles at incident scenes.', 2),
    
    -- Q69
    ('rules_of_road', 1, 'Which statement is False? A vehicle may be used on a public road if......', '[{"text": "The battery and electrical wiring are properly installed"}, {"text": "The fuel cap is effective and closed"}, {"text": "The fuel tank is defective"}]'::jsonb, 2, 'A vehicle with a defective fuel tank may NOT be used on public roads due to safety hazards.', 2),
    
    -- Q70
-- Q70
('rules_of_road', 1, 'You are in heavy traffic in the right hand lane,..the car in front wants to turn into his driveway and has stopped, waiting for heavy oncoming traffic, what do you do?', '[{"text": "Wait behind the car until you get the opportunity to pass, and when its safe ...proceed"}, {"text": "Switch on your left flicker and move to the left lane"}, {"text": "Hoot, wave and pass"}]'::jsonb, 0, 'Wait patiently behind the turning vehicle. Never attempt dangerous maneuvers like swerving into other lanes.', 2),
    -- Q70
    ('rules_of_road', 1, 'You are in heavy traffic in the right hand lane,..the car in front wants to turn into his driveway and has stopped, waiting for heavy oncoming traffic, what do you do?', '[{"text": "Wait behind the car until you get the opportunity to pass, and when its safe ...proceed"}, {"text": "Switch on your left flicker and move to the left lane"}, {"text": "Hoot, wave and pass"}]'::jsonb, 0, 'Wait patiently behind the turning vehicle. Never attempt dangerous maneuvers like swerving into other lanes.', 2),
    
    -- Q71
    ('rules_of_road', 1, 'The use of a temporary sign implies that for some reason...?', '[{"text": "The rules of the road do not apply"}, {"text": "The situation on the road is not normal"}, {"text": "Traffic must move slowly"}]'::jsonb, 1, 'Temporary signs indicate abnormal road conditions that require special attention and caution.', 1),
    
    -- Q72
    ('rules_of_road', 1, 'How far must you be parked from either side of a fire hydrant', '[{"text": "1.5 meter"}, {"text": "750mm"}, {"text": "1 meter"}]'::jsonb, 0, 'Maintain at least 1.5m clearance from fire hydrants to ensure emergency access if needed.', 1),

    -- VEHICLE CONTROLS QUESTIONS
    -- Code 1 (Motorcycle) Controls
    
    -- Q192
    ('vehicle_controls', 1, 'To ride faster, you must use number...', '[{"text": "7"}, {"text": "5"}, {"text": "4"}]'::jsonb, 2, 'Number 4 is the throttle control. To increase speed, gradually roll the throttle forward.', 1),
    
    -- Q193
    ('vehicle_controls', 1, 'To turn you must use number', '[{"text": "8"}, {"text": "1"}, {"text": "7"}]'::jsonb, 0, 'Number 8 is the steering. To turn, lean the motorcycle and gently counter-steer in the desired direction.', 1),
    
    -- Q194
    ('vehicle_controls', 1, 'To stop you must use number...', '[{"text": "4 and 7"}, {"text": "2 and 7"}, {"text": "1 and 2"}]'::jsonb, 1, 'Number 2 (front brake lever) and 7 (rear brake pedal) are used together for controlled stopping.', 1),
    
    -- Q195
    ('vehicle_controls', 1, 'To change gears, you must use numbers...', '[{"text": "1 and 5"}, {"text": "2 and 7"}, {"text": "1 and 2"}]'::jsonb, 0, 'Number 1 (clutch lever) and 5 (gear lever) are used together for smooth gear changes.', 1),
    
    -- Q196
    ('vehicle_controls', 1, 'To indicate that you are going to turn you must use number...', '[{"text": "6"}, {"text": "4"}, {"text": "8"}]'::jsonb, 0, 'Number 6 is the indicator switch. Use it to signal your intention to turn well in advance.', 1),
    
    -- Q197
    ('vehicle_controls', 1, 'What controls must you use when you are going to make a sharp turn?', '[{"text": "1,3,5,6 and 8 only"}, {"text": "1,2,4 and 8 only"}, {"text": "1,2,3,4,6 and 8 only"}]'::jsonb, 2, 'Sharp turns require clutch control, both brakes, throttle modulation, indicators, and steering coordination.', 2),
    
    -- Q198
    ('vehicle_controls', 1, 'What controls must you never use in combination?', '[{"text": "2 and 4"}, {"text": "4 and 8"}, {"text": "4 and 7"}]'::jsonb, 0, 'Never use front brake (2) and throttle (4) aggressively together as this can cause loss of control.', 2),

    -- Code 2 (Light Motor Vehicle) Controls
    
    -- Q212
    ('vehicle_controls', 2, 'To select a gear you must use numbers...', '[{"text": "789"}, {"text": "588"}, {"text": "688"}]'::jsonb, 2, 'In manual vehicles, use clutch (8) and gear lever (4) to select gears. "688" likely refers to clutch and gear operation.', 1),
    
    -- Q213
    ('vehicle_controls', 2, 'To stop your vehicle, you must use number...', '[{"text": "9"}, {"text": "8"}, {"text": "7"}]'::jsonb, 2, 'Number 7 is the foot brake (service brake) used for normal stopping in light motor vehicles.', 1),
    
    -- Q214
    ('vehicle_controls', 2, 'Number...is not found in an automatic vehicle', '[{"text": "2"}, {"text": "6"}, {"text": "8"}]'::jsonb, 2, 'Number 8 is the clutch pedal, which is not present in automatic transmission vehicles.', 1),
    
    -- Q215
    ('vehicle_controls', 2, 'To turn, number...is used', '[{"text": "4"}, {"text": "5"}, {"text": "10"}]'::jsonb, 0, 'Number 4 is the steering wheel, used to control the direction of the vehicle.', 1),
    
    -- Q216
    ('vehicle_controls', 2, 'To ensure that your parked vehicle does not move you must use number...', '[{"text": "7"}, {"text": "8"}, {"text": "9"}]'::jsonb, 2, 'Number 9 is the handbrake (parking brake), used to secure the vehicle when parked.', 1),
    
    -- Q217
    ('vehicle_controls', 2, 'To accelerate your vehicle you must use number', '[{"text": "6"}, {"text": "8"}, {"text": "10"}]'::jsonb, 0, 'Number 6 is the accelerator pedal, used to increase engine speed and vehicle velocity.', 1),
    
    -- Q218
    ('vehicle_controls', 2, 'What controls must you use when you are going to turn sharp', '[{"text": "1,3,5,6 and 8 only"}, {"text": "3,4,5,9 and 10 only"}, {"text": "1,3,4,5,6,8,9 and 10 only"}]'::jsonb, 2, 'Sharp turns require comprehensive control: steering, indicators, gear selection, acceleration, clutch, handbrake, and mirror checks.', 2),

    -- Code 3 (Heavy Motor Vehicle) Controls
    
    -- Q230
    ('vehicle_controls', 3, 'To select a gear, you must use numbers...', '[{"text": "789"}, {"text": "588"}, {"text": "688"}]'::jsonb, 2, 'Heavy vehicles use clutch (8) and gear lever (4) for gear selection. "688" refers to clutch operation.', 1),
    
    -- Q231
    ('vehicle_controls', 3, 'To stop your vehicle you must use number...', '[{"text": "9"}, {"text": "8"}, {"text": "7"}]'::jsonb, 2, 'Number 7 is the foot brake, essential for controlled stopping in heavy vehicles.', 1),
    
    -- Q232
    ('vehicle_controls', 3, 'To turn your vehicle, number... is used', '[{"text": "5"}, {"text": "4"}, {"text": "6"}]'::jsonb, 1, 'Number 4 is the steering wheel, used to direct heavy vehicles through turns.', 1),
    
    -- Q233
    ('vehicle_controls', 3, 'To ensure that your parked vehicle does not move, use number...', '[{"text": "7"}, {"text": "8"}, {"text": "9"}]'::jsonb, 2, 'Number 9 is the parking brake, crucial for securing heavy vehicles when stationary.', 1),
    
    -- Q234
    ('vehicle_controls', 3, 'To accelerate your vehicle you must use number...', '[{"text": "6"}, {"text": "8"}, {"text": "10"}]'::jsonb, 0, 'Number 6 is the accelerator, used to increase speed in heavy vehicles.', 1),
    
    -- Q235
    ('vehicle_controls', 3, 'What controls must you use when you are going to turn sharp?', '[{"text": "1, 3, 5, 6 and 8 only"}, {"text": "3, 4, 5, 9 and 10 only"}, {"text": "1, 3, 4, 5, 6, 8 and 9 only"}]'::jsonb, 2, 'Sharp turns in heavy vehicles require steering, indicators, gear control, acceleration, clutch, and parking brake management.', 2),
    
    -- Q236
    ('vehicle_controls', 3, 'To indicate that you are going to turn, you must use number...', '[{"text": "3"}, {"text": "5"}, {"text": "11"}]'::jsonb, 0, 'Number 3 is the indicator lever, used to signal turning intentions in heavy vehicles.', 1)
) AS data(category, learner_code, question_text, options, correct_index, explanation, difficulty_level)
WHERE NOT EXISTS (
  SELECT 1 FROM questions WHERE question_text = data.question_text
));

-- Confirm the insertions
SELECT 'Successfully inserted ' || COUNT(*) || ' Evolve Driving Academy questions' AS result FROM questions WHERE created_at > NOW() - INTERVAL '1 minute';