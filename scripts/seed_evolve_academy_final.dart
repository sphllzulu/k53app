import 'dart:io';
import 'package:supabase/supabase.dart';
import 'package:uuid/uuid.dart';

void main() async {
  // Read environment variables from .env file
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('Error: .env file not found in the root directory');
    exit(1);
  }

  final envLines = envFile.readAsLinesSync();
  final envVars = <String, String>{};

  for (final line in envLines) {
    if (line.contains('=') && !line.startsWith('#')) {
      final parts = line.split('=');
      if (parts.length >= 2) {
        envVars[parts[0]] = parts.sublist(1).join('=');
      }
    }
  }

  // Use SERVICE_ROLE key to bypass RLS for seeding
  final supabaseUrl = envVars['SUPABASE_URL'] ?? '';
  final supabaseKey =
      envVars['SUPABASE_SERVICE_ROLE_KEY'] ??
      envVars['SUPABASE_ANON_KEY'] ??
      '';

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    print(
      'Error: SUPABASE_URL and at least one key (SERVICE_ROLE or ANON) not found in .env file',
    );
    exit(1);
  }

  final keyType = envVars['SUPABASE_SERVICE_ROLE_KEY'] != null
      ? 'SERVICE_ROLE'
      : 'ANON';
  final supabase = SupabaseClient(supabaseUrl, supabaseKey);
  print('Using $keyType key: ${supabaseKey.substring(0, 10)}...');
  print('Using Supabase URL: ${supabaseUrl.substring(0, 20)}...');
  if (keyType == 'ANON') {
    print(
      'Note: RLS policies may prevent insertion - consider using SERVICE_ROLE key',
    );
  }
  final uuid = Uuid();

  try {
    print('Starting to seed Evolve Driving Academy questions...');

    // Optional: Clear existing questions for fresh start
    print('Do you want to clear existing questions first? (y/N)');
    final input = stdin.readLineSync()?.toLowerCase();
    if (input == 'y' || input == 'yes') {
      print('Clearing existing questions...');
      try {
        await supabase
            .from('questions')
            .delete()
            .neq('id', '00000000-0000-0000-0000-000000000000');
        print('Existing questions cleared.');
      } catch (e) {
        if (e.toString().contains('Could not find the table')) {
          print(
            'Questions table does not exist yet - proceeding with fresh insert...',
          );
        } else {
          rethrow;
        }
      }
    }

    // Complete Evolve Driving Academy question set
    final rulesOfRoad = _getRulesOfRoadQuestions();
    final vehicleControls = _getVehicleControlsQuestions();
    final allQuestions = [
      // Rules of the Road - Complete Set
      ...rulesOfRoad,

      // Vehicle Controls - Complete Set
      ...vehicleControls,
    ];

    int insertedCount = 0;
    int errorCount = 0;

    print('Actual question counts:');
    print('- Rules of the Road: ${rulesOfRoad.length} questions');
    print('- Vehicle Controls: ${vehicleControls.length} questions');
    print('- Total: ${allQuestions.length} questions');
    print('Starting database insertion...\n');

    for (final questionData in allQuestions) {
      final questionId = uuid.v4();
      final now = DateTime.now().toIso8601String();

      try {
        await supabase.from('questions').insert({
          'id': questionId,
          'category': questionData['category'],
          'learner_code': questionData['learner_code'],
          'question_text': questionData['question_text'],
          'options': questionData['options'],
          'correct_index': questionData['correct_index'],
          'explanation': questionData['explanation'],
          'version': 1,
          'is_active': true,
          'difficulty_level': questionData['difficulty_level'],
          'created_at': now,
          'updated_at': now,
        });

        insertedCount++;
        if (insertedCount % 20 == 0) {
          print('Inserted $insertedCount questions...');
        }
      } catch (e) {
        errorCount++;
        if (errorCount <= 5) {
          // Only show first 5 errors to avoid spam
          print('Error inserting question: ${questionData['question_text']}');
          print('Error details: $e');
        }
      }

      // Add small delay to avoid rate limiting
      await Future.delayed(Duration(milliseconds: 30));
    }

    print('\n✅ Seeding completed!');
    print('Successfully inserted: $insertedCount questions');
    print('Errors: $errorCount');
    if (insertedCount != allQuestions.length) {
      print('⚠️  WARNING: Only $insertedCount of ${allQuestions.length} questions were inserted!');
      print('   This may indicate database constraint violations or duplicate questions.');
    }
    print('\nCategories covered: Rules of the Road, Vehicle Controls');
    print(
      'Learner codes: 1 (Motorcycles), 2 (Light Vehicles), 3 (Heavy Vehicles)',
    );
    print('Total questions by category:');
    print('- Rules of the Road: ${rulesOfRoad.length} questions (Evolve Academy)');
    print('- Vehicle Controls: ${vehicleControls.length} questions (Evolve Academy)');
    print('- Total: ${allQuestions.length} questions (Evolve Academy Official)');
  } catch (e) {
    print('Error seeding questions: $e');
    exit(1);
  } finally {
    supabase.dispose();
  }
}

List<Map<String, dynamic>> _getRulesOfRoadQuestions() {
  return [
    // Evolve Driving Academy Rules of the Road Questions
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text': 'You may...',
      'options': [
        {'text': 'Drive your vehicle on the sidewalk at night'},
        {'text': 'Reverse your vehicle only if it is safe to do so'},
        {
          'text':
              'Leave the engine of your vehicle idling when you put petrol in it',
        },
      ],
      'correct_index': 1,
      'explanation':
          'You may only reverse your vehicle when it is safe to do so. Driving on sidewalks is illegal and leaving engine running while refueling is dangerous.',
      'difficulty_level': 2,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'When you want to change lanes and drive from one lane to the other you must...',
      'options': [
        {'text': 'Only do it when it is safe to do so'},
        {
          'text':
              'Switch on your indicators in time to show what you are going to do',
        },
        {
          'text':
              'Use the mirrors of your vehicle to ensure that you know of other traffic around you',
        },
        {'text': 'All of the above are correct'},
      ],
      'correct_index': 3,
      'explanation':
          'All options are correct: change lanes only when safe, use indicators in time, and check mirrors for surrounding traffic.',
      'difficulty_level': 2,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'When may you not overtake another vehicle?... When you ...',
      'options': [
        {'text': 'Are nearing the top of hill'},
        {'text': 'Are nearing a curve'},
        {
          'text':
              'Can only see 100m in front of you because of dust over the road',
        },
        {'text': 'All of the above are correct'},
      ],
      'correct_index': 3,
      'explanation':
          'You may not overtake when nearing hills, curves, or when visibility is limited to 100m due to dust or other obstructions.',
      'difficulty_level': 3,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'When are you allowed to drive on the shoulder of a road?',
      'options': [
        {'text': 'Any time if you want to let another vehicle to pass you'},
        {
          'text':
              'In daytime when you want to allow another vehicle pass you and its safe',
        },
        {
          'text':
              'When on a freeway with 4 lanes in both directions, you want to drive slower than 120 km/h',
        },
        {
          'text':
              'When you have a flat tyre and you want to park there to change it',
        },
        {'text': 'Only (ii) and (iv) are correct'},
      ],
      'correct_index': 4,
      'explanation':
          'You may only drive on the shoulder to allow another vehicle to pass (when safe) or when you have a flat tire and need to park to change it.',
      'difficulty_level': 2,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'You may not obtain a learner'
          's licence if...',
      'options': [
        {
          'text':
              'You already have a licence that authorises the driving of the same vehicle class',
        },
        {
          'text':
              'You are declared unfit to obtain a driving licence for a certain period and that period still prevails',
        },
        {
          'text':
              'Your licence was suspended temporarily and the suspension has not yet expired',
        },
        {'text': 'All of the above are correct'},
      ],
      'correct_index': 3,
      'explanation':
          'All conditions prevent obtaining a learner'
          's license: existing license for same class, declared unfit period, or active suspension.',
      'difficulty_level': 2,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text': 'At an intersection...',
      'options': [
        {'text': 'Vehicles have the right of way over pedestrians'},
        {
          'text':
              'You must yield to oncoming traffic if you want to turn right',
        },
        {
          'text':
              'You can use a stop sign as a yield sign if there is no other traffic',
        },
      ],
      'correct_index': 1,
      'explanation':
          'When turning right at an intersection, you must yield to oncoming traffic. Pedestrians have right of way at crossings.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'The licence for your vehicle (clearance certificate) is valid for...',
      'options': [
        {'text': '12 months'},
        {'text': '90 days'},
        {'text': '21 days'},
      ],
      'correct_index': 0,
      'explanation':
          'A vehicle license (clearance certificate) is typically valid for 12 months and must be renewed annually.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'Unless otherwise shown by a sign, the general speed limit in an urban area is ...km/h.',
      'options': [
        {'text': '60'},
        {'text': '80'},
        {'text': '100'},
      ],
      'correct_index': 0,
      'explanation':
          'The default speed limit in urban areas is 60 km/h unless otherwise indicated by road signs.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text': 'The legal speed limit which you may drive...',
      'options': [
        {'text': 'Is always 120km/h outside an urban area'},
        {
          'text':
              'Can be determined by yourself if you look at the number of lanes the road has',
        },
        {'text': 'Is shown to you by signs next to the road'},
      ],
      'correct_index': 2,
      'explanation':
          'Legal speed limits are indicated by road signs. Do not assume limits based on road type or number of lanes.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text': 'You may...',
      'options': [
        {'text': 'Leave your vehicles engine running without supervision'},
        {'text': 'Allow someone to ride on the bumper of your vehicle'},
        {
          'text':
              'Put your arm out of the window only to give legal hand signals',
        },
      ],
      'correct_index': 2,
      'explanation':
          'You may only extend your arm out of the window to give legal hand signals. Never leave engine running unattended or allow riding on bumpers.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'If you see that someone wants to overtake you, you must...',
      'options': [
        {'text': 'Not drive faster'},
        {'text': 'Keep to the left as far as is safe'},
        {'text': 'Give hand signals to allow the person to pass safely'},
        {'text': 'Only (i) and (ii) are correct'},
      ],
      'correct_index': 3,
      'explanation':
          'When being overtaken, do not accelerate and keep left as far as safe. Hand signals are not required for this situation.',
      'difficulty_level': 2,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'The furthest that your vehicle'
          's dim light may shine in front of you, is...m',
      'options': [
        {'text': '45'},
        {'text': '100'},
        {'text': '150'},
      ],
      'correct_index': 0,
      'explanation':
          'Dim (dipped) headlights should illuminate the road for approximately 45 meters ahead of your vehicle.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'What is the longest period that a vehicle may be parked on one place on a road outside urban areas?',
      'options': [
        {'text': '7 days'},
        {'text': '48 hours'},
        {'text': '24 hours'},
      ],
      'correct_index': 0,
      'explanation':
          'Outside urban areas, a vehicle may be parked in one place for up to 7 days unless otherwise prohibited.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text': 'At an intersection...',
      'options': [
        {
          'text':
              'You can pass another vehicle waiting to turn right on his left side by going off the road',
        },
        {'text': 'You can stop in it to off load passengers'},
        {
          'text':
              'Pedestrians who are already crossing the road when the red man signal starts showing, have right of way',
        },
      ],
      'correct_index': 2,
      'explanation':
          'Pedestrians already crossing when the signal changes to red have right of way to complete their crossing safely.',
      'difficulty_level': 2,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text': 'You are not allowed to stop...',
      'options': [
        {'text': 'On the pavement'},
        {'text': 'With the front of your vehicle facing oncoming traffic'},
        {'text': 'Next to any obstruction in the road'},
      ],
      'correct_index': 0,
      'explanation':
          'Stopping on the pavement (sidewalk) is prohibited as it obstructs pedestrian access.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text': 'You are not allowed to stop...',
      'options': [
        {'text': 'Where you are also prohibited to park'},
        {'text': '5m from a bridge'},
        {'text': 'Opposite a vehicle, where the roadway is 10m wide'},
      ],
      'correct_index': 0,
      'explanation':
          'If an area is designated as no parking, it also means no stopping. Other restrictions may have specific distances.',
      'difficulty_level': 2,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'You may pass another vehicle on the left-hand side if it...',
      'options': [
        {'text': 'Indicates that it is going to turn right'},
        {
          'text':
              'Drives on the right-hand side of a road with a shoulder were you can pass',
        },
        {
          'text':
              'Drives in a town in the right hand lane with 2 lanes in the same direction',
        },
        {'text': 'Only (i) and (iii) are correct'},
      ],
      'correct_index': 3,
      'explanation':
          'You may pass on the left when a vehicle is turning right or when in multi-lane roads with designated lanes.',
      'difficulty_level': 2,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'You may overtake another vehicle on the left hand side...',
      'options': [
        {
          'text':
              'When that vehicle is going to turn right and the road is wide enough that it is not necessary to drive on the shoulder',
        },
        {
          'text':
              'Where the road has 2 lanes for traffic in the same direction',
        },
        {'text': 'If a police officer instructs you to do so'},
        {'text': 'All of the above are correct'},
      ],
      'correct_index': 3,
      'explanation':
          'All scenarios allow overtaking on the left: vehicle turning right, multi-lane roads, or when directed by authorities.',
      'difficulty_level': 2,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text': 'You may on a public road...',
      'options': [
        {
          'text':
              'Pass another vehicle turning right, on it'
              's left-hand side without driving on the shoulder of the road',
        },
        {
          'text':
              'Pass another vehicle at any place on the left-hand side if it is turning right',
        },
        {'text': 'Not pass any vehicle on the left-hand side'},
      ],
      'correct_index': 0,
      'explanation':
          'You may pass on the left of a vehicle turning right, provided you can do so without driving on the shoulder.',
      'difficulty_level': 2,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'The last action that you must take before moving to another lane is to...',
      'options': [
        {'text': 'Switch on your indicator'},
        {'text': 'Check the blind spot'},
        {'text': 'Look in rear view mirror'},
      ],
      'correct_index': 1,
      'explanation':
          'The final check before changing lanes should be a blind spot check to ensure no vehicles are in your intended path.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'When are you allowed to drive your vehicle on the right-hand side of a road with traffic in both directions?',
      'options': [
        {'text': 'When you switch the emergency lights of your vehicle on'},
        {'text': 'When a traffic officer shows you to do so'},
        {'text': 'Under no circumstances'},
      ],
      'correct_index': 1,
      'explanation':
          'You may drive on the right side only when directed by a traffic officer or in specific emergency situations.',
      'difficulty_level': 2,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'If you come to a robot and the red light flashes, you must...',
      'options': [
        {
          'text':
              'Stop and wait for the light to change to green before you go',
        },
        {'text': 'Stop and go only if it safe to do so'},
        {
          'text':
              'Look out for a road block as the light shows you a policestop',
        },
      ],
      'correct_index': 1,
      'explanation':
          'A flashing red light functions as a stop sign - stop completely and proceed only when safe to do so.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'A vehicle of which the brakes are not good, must be towed',
      'options': [
        {'text': 'With a rope'},
        {'text': 'With a tow-bar'},
        {'text': 'On a trailer'},
      ],
      'correct_index': 2,
      'explanation':
          'A vehicle with faulty brakes must be transported on a trailer or flatbed tow truck for safety.',
      'difficulty_level': 2,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'A safe following distance is, when the vehicle in front of you suddenly stops, you could....',
      'options': [
        {'text': 'Stop without swerving'},
        {'text': 'Swerve and stop next to it'},
        {'text': 'Swerve and pass'},
      ],
      'correct_index': 0,
      'explanation':
          'Maintain sufficient distance to stop completely without swerving if the vehicle ahead stops suddenly.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text': 'You may not',
      'options': [
        {
          'text':
              'Have passengers in the vehicle if you only have a learner'
              's licence',
        },
        {'text': 'Leave your vehicle unattended while the engine is running'},
        {'text': 'Drive in reverse for more than a 100m'},
      ],
      'correct_index': 1,
      'explanation':
          'Never leave a vehicle unattended with the engine running. Learner drivers may carry passengers with supervision.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text': 'If you want to change lanes you must',
      'options': [
        {'text': 'Switch on your indicator and change lanes'},
        {
          'text':
              'Give the necessary signal and after looking for other traffic, change lanes',
        },
        {'text': 'Apply the brakes lightly and then change lanes'},
      ],
      'correct_index': 1,
      'explanation':
          'Signal your intention, check mirrors and blind spots for other traffic, then change lanes when safe.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'The fastest speed at which you may tow a vehicle with a rope is .. km/h',
      'options': [
        {'text': '60'},
        {'text': '45'},
        {'text': '30'},
      ],
      'correct_index': 2,
      'explanation':
          'When towing with a rope, the maximum speed is 30 km/h for safety reasons.',
      'difficulty_level': 1,
    },
    // Add these to your _getRulesOfRoadQuestions() function
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'If you come across an emergency vehicle on the road sounding a siren you must...',
      'options': [
        {'text': 'Flash your headlight to warn other traffic'},
        {'text': 'Give right of way to the emergency vehicle'},
        {
          'text':
              'Switch on your vehicles emergency light and blow your hooter',
        },
      ],
      'correct_index': 1,
      'explanation':
          'Yield right of way to emergency vehicles by moving to the side of the road and allowing them to pass safely.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'If you want to turn left with your vehicle, you must...',
      'options': [
        {'text': 'Slow down completely, stop and then turn'},
        {'text': 'First move to the right to enable you to turn left easily'},
        {'text': 'Give the necessary signal in good time'},
      ],
      'correct_index': 2,
      'explanation':
          'Always signal your intention to turn left in good time to alert other road users of your planned maneuver.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text': 'When you drive...',
      'options': [
        {'text': 'You must have both hands on the steering wheel'},
        {
          'text':
              'Your vision of the road and the traffic must be unobstructed',
        },
        {'text': 'You must wear shoes with rubber soles'},
      ],
      'correct_index': 1,
      'explanation':
          'Your view of the road and traffic must always be clear and unobstructed for safe driving.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text': 'Where may you legally stop with your vehicle?',
      'options': [
        {'text': '4m from a tunnel'},
        {'text': '5m from a pedestrian crossing'},
        {'text': '6m from a railway crossing'},
      ],
      'correct_index': 2,
      'explanation':
          'You may stop 6m from a railway crossing. Other distances may have specific restrictions.',
      'difficulty_level': 2,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text': 'You may not...',
      'options': [
        {'text': 'Run the engine unattended'},
        {'text': 'Use your vehicle without a cap on the fuel tank'},
        {'text': 'Spin the wheels of your vehicle when pulling off'},
        {'text': 'All of the above are correct'},
      ],
      'correct_index': 3,
      'explanation':
          'All actions are prohibited: never leave engine running unattended, always use fuel cap, and avoid wheel spinning.',
      'difficulty_level': 2,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'What is important with regard to the hooter of your vehicle?',
      'options': [
        {'text': 'The tone and pitch of the sound may not change'},
        {'text': 'Someone must hear it from a distance of at least 50m'},
        {
          'text':
              'You may use it to get the attention of someone that you would like to offer a lift',
        },
      ],
      'correct_index': 1,
      'explanation':
          'Your vehicle\'s hooter must be audible from at least 50m away for safety warning purposes.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'When the robot is red and the green arrow flashes to the right, it shows you that...',
      'options': [
        {'text': 'Only pedestrians may walk'},
        {'text': 'If you want to turn right, you may go'},
        {'text': 'All traffic must turn right there'},
      ],
      'correct_index': 1,
      'explanation':
          'A flashing green arrow with red light allows right turns only, while through traffic must wait.',
      'difficulty_level': 2,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text': 'You must stop your vehicle ...',
      'options': [
        {'text': 'On a public road at the signal of a person driving sheep'},
        {'text': 'On a freeway when directed to do so by a traffic officer'},
        {'text': 'On any road to avoid an accident'},
        {'text': 'All the above are correct'},
      ],
      'correct_index': 3,
      'explanation':
          'You must stop for animal drivers, when directed by traffic officers, or to prevent accidents in any situation.',
      'difficulty_level': 2,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'An accident in which no one has or has not been injured must be reported within ... hours',
      'options': [
        {'text': '24'},
        {'text': '36'},
        {'text': '48'},
      ],
      'correct_index': 0,
      'explanation':
          'All accidents must be reported to police within 24 hours, regardless of whether injuries occurred.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'In which case is it permitted to travel with only the parking lights of your vehicle switched on?',
      'options': [
        {'text': 'When driving in heavy rain'},
        {'text': 'When dusk is falling'},
        {'text': 'In none of the above cases'},
      ],
      'correct_index': 2,
      'explanation':
          'Parking lights are only for stationary vehicles. Always use proper headlights when driving.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text': 'The only instance where you may stop on a freeway...',
      'options': [
        {'text': 'To obey the road traffic sign'},
        {'text': 'For a rest during a tiring journey'},
        {'text': 'To pick up hitchhikers'},
      ],
      'correct_index': 0,
      'explanation':
          'You may only stop on a freeway to obey traffic signs or in genuine emergencies, not for rest or picking up people.',
      'difficulty_level': 2,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text': 'When may a driver disobey a rule of the road...?',
      'options': [
        {'text': 'Only when directed to do so by a traffic officer'},
        {'text': 'Under no circumstances'},
        {'text': 'If you are driving in a emergency situation'},
      ],
      'correct_index': 0,
      'explanation':
          'You may only disobey traffic rules when specifically directed to do so by a traffic officer.',
      'difficulty_level': 2,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'What is the duty of a driver when driving on a public road that has been divided into two or more roadways?',
      'options': [
        {'text': 'You may drive on any part of the roadway'},
        {
          'text':
              'You are allowed to drive on any part of the roadway after sunset, or when there is no other traffic on the road',
        },
        {
          'text':
              'Drive on the left hand roadway unless directed or shown to do so by a traffic officer or traffic sign',
        },
      ],
      'correct_index': 2,
      'explanation':
          'On divided roadways, drive on the left-hand roadway unless signs or officers direct otherwise.',
      'difficulty_level': 2,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'When a motor vehicle is standing still, what must the driver do to make sure the motor vehicle does not move...?',
      'options': [
        {'text': 'The gear lever must be put in the neutral position'},
        {'text': 'The parking brake must be applied'},
        {'text': 'The driver must hold the service brake'},
      ],
      'correct_index': 1,
      'explanation':
          'Always apply the parking brake when the vehicle is stationary to prevent unintended movement.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'What colour and size must flags be to indicate projections on a vehicle on a public road,....',
      'options': [
        {'text': 'They can be any size as long as they are red'},
        {'text': 'They must be red and at least 300 x 300mm'},
        {'text': 'They may any colour as long as they are visible'},
      ],
      'correct_index': 1,
      'explanation':
          'Projection flags must be red and at least 300x300mm to be clearly visible to other road users.',
      'difficulty_level': 2,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text': 'A Temporary sign...?',
      'options': [
        {'text': 'Need not be taken seriously at all times'},
        {'text': 'Is of less importance to road users than a permanent sign'},
        {'text': 'Has the same legal significance as a permanent sign'},
      ],
      'correct_index': 2,
      'explanation':
          'Temporary signs have the same legal force as permanent signs and must be obeyed.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'What is the duty of a driver, about pedestrians at a pedestrian crossing...?',
      'options': [
        {
          'text':
              'A driver must only stop for a pedestrian waiting to enter the road at a pedestrian signal',
        },
        {
          'text':
              'A driver must yield right of way to a pedestrian crossing a pedestrian crossing',
        },
        {
          'text':
              'A driver must yield to all pedestrians wishing to cross over the road way',
        },
      ],
      'correct_index': 1,
      'explanation':
          'Drivers must yield to pedestrians actually crossing at designated pedestrian crossings.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'When is it permissible to allow a portion of the body to project beyond the vehicle...?',
      'options': [
        {'text': 'Only for the driver to give hand signals'},
        {
          'text':
              'Only passengers may allow a portion of their bodies to project, they don\'t need 2 hands on the steering wheel',
        },
        {'text': 'When it is hot and the driver\'s window is open'},
      ],
      'correct_index': 0,
      'explanation':
          'Only the driver may extend body parts to give legal hand signals. Passengers should remain fully inside.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'What are the requirements for a vehicle being used with excessive noise...?',
      'options': [
        {
          'text':
              'There are no requirements with regards to excessive noise on a vehicle',
        },
        {
          'text':
              'No person shall operate a vehicle on a public road that causes any excessive noise',
        },
        {
          'text':
              'Excessive noise is acceptable during festive periods, Christmas new year',
        },
      ],
      'correct_index': 1,
      'explanation':
          'Vehicles must not produce excessive noise that could disturb others or indicate mechanical problems.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'How far behind a vehicle must the warning triangle be placed if your car breaks down?',
      'options': [
        {'text': 'At least 45 m'},
        {'text': 'At least 10m'},
        {'text': 'At least 100m'},
      ],
      'correct_index': 0,
      'explanation':
          'Place warning triangles at least 45m behind your broken down vehicle to alert approaching traffic.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'When driving a motor vehicle, the minimum safe following distance is...?',
      'options': [
        {'text': '12 meters at 120kph, (1meter for every 10 kph)'},
        {'text': 'A distance determined by the 2 second rule'},
        {
          'text':
              'A driver may follow as close as they want so that overtaking is easier when the gap is there',
        },
      ],
      'correct_index': 1,
      'explanation':
          'Maintain at least a 2-second following distance, increasing to 4 seconds in poor conditions.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'How far may you park from the left edge of a road way outside an urban area...?',
      'options': [
        {
          'text':
              'A vehicle may not park on a public road unless in a parking bay',
        },
        {'text': 'Not more than 450mm from the edge of the road way'},
        {'text': 'Not more than 1m from the edge of the road way'},
      ],
      'correct_index': 1,
      'explanation':
          'When parking outside urban areas, stay within 450mm of the road edge to avoid obstructing traffic.',
      'difficulty_level': 2,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'Show the correct statement......A driver may stop their vehicle on the road way of a public road...?',
      'options': [
        {'text': 'When indicated by a traffic officer'},
        {'text': 'In an intersection'},
        {'text': 'In contravention with any road traffic sign'},
      ],
      'correct_index': 0,
      'explanation':
          'You may only stop on the roadway when directed by a traffic officer or in genuine emergencies.',
      'difficulty_level': 2,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'What is the duty of a driver when refilling the fuel tank of a motor vehicle...?',
      'options': [
        {
          'text':
              'The driver may not allow the engine to run whilst flammable fuel is being transferred to the fuel tank',
        },
        {
          'text':
              'To check if they are filling the tank with diesel not petrol',
        },
        {
          'text':
              'Is allowed to start the vehicle while fuel is being pumped to check if the tank is full',
        },
      ],
      'correct_index': 0,
      'explanation':
          'Never leave the engine running while refueling due to fire hazard from flammable vapors.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text': 'Which one of the following statements are wrong...?',
      'options': [
        {
          'text':
              'The driver of a motor vehicle shall ensure that a child seated in a car wears a seatbelt, and where available use an appropriate child restraint',
        },
        {
          'text':
              'It is not the drivers responsibility to ensure a child is in a child restraint',
        },
        {
          'text':
              'If a seat not equipped with a seatbelt is available the driver shall ensure that a child 14yrs and younger is seated on the rear seat',
        },
      ],
      'correct_index': 1,
      'explanation':
          'The driver IS responsible for ensuring children use appropriate restraints - this statement is incorrect.',
      'difficulty_level': 2,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'The driver of a vehicle shall not cross a public road unless...?',
      'options': [
        {'text': 'They put on the indicator and then enter the road'},
        {'text': 'They look in the rear view mirror, engage a gear and go'},
        {
          'text':
              'The road is clear of traffic for a safe distance, without obstructing or endangering other traffic',
        },
      ],
      'correct_index': 2,
      'explanation':
          'Only enter a road when you have clear visibility and can do so without obstructing or endangering other traffic.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text': 'The following vehicle may not be used on a freeway...?',
      'options': [
        {'text': 'An animal drawn vehicle'},
        {'text': 'An articulated motor vehicle'},
        {'text': 'An abnormal loaded motor vehicle'},
      ],
      'correct_index': 0,
      'explanation':
          'Animal-drawn vehicles are prohibited on freeways due to speed differential and safety concerns.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'A person under the influence of intoxicating liquor or a drug...?',
      'options': [
        {
          'text':
              'May sit in the driver seat of a vehicle of which the engine is running',
        },
        {
          'text':
              'May not sit in the driver\'s seat while the engine is running',
        },
        {'text': 'May sleep in the driver\'s seat while the engine is running'},
      ],
      'correct_index': 1,
      'explanation':
          'Intoxicated persons may not occupy the driver\'s seat with engine running, as this implies control of the vehicle.',
      'difficulty_level': 2,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'Which of the following statements are correct... a silencer?',
      'options': [
        {'text': 'With a small hole in it is acceptable'},
        {'text': 'Need not be fitted only on heavy vehicles'},
        {
          'text':
              'Must be fitted to a vehicle to restrict the engine noise to a suitable noise level',
        },
      ],
      'correct_index': 2,
      'explanation':
          'All vehicles must have properly functioning silencers to reduce engine noise to acceptable levels.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'What is the minimum distance stop lamps must be visible to a person with normal eyesight in sunlight...?',
      'options': [
        {'text': '20m'},
        {'text': '30m'},
        {'text': '10m'},
      ],
      'correct_index': 1,
      'explanation':
          'Stop lamps (brake lights) must be visible from at least 30m in sunlight to effectively warn following traffic.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'When driving a vehicle alone, what documents must you carry with you...?',
      'options': [
        {
          'text':
              'Any persons valid drivers licence if you only have a learners licence',
        },
        {'text': 'Your original valid drivers licence'},
        {'text': 'A certified copy of your drivers licence and id document'},
      ],
      'correct_index': 1,
      'explanation':
          'You must carry your original, valid driver\'s license when operating a motor vehicle.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'When are you allowed to drive on the right hand side of a freeway...?',
      'options': [
        {'text': 'When you are driving 120kph'},
        {'text': 'At anytime as long as I don\'t stop in the right hand lane'},
        {'text': 'Only when overtaking another vehicle'},
      ],
      'correct_index': 2,
      'explanation':
          'The right lane on freeways is primarily for overtaking. Return to left lanes after passing.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text': 'How long must a flicker be displayed?',
      'options': [
        {
          'text':
              'for long enough to show vehicles or persons approaching you of your intentions',
        },
        {'text': 'For about 3 mins'},
        {'text': 'For about 2 mins'},
      ],
      'correct_index': 0,
      'explanation':
          'Indicators must be used long enough to clearly communicate your intentions to other road users.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'When may you pass another vehicle that has stopped at a pedestrian crossing?',
      'options': [
        {'text': 'You can pass if its safe to do so'},
        {
          'text':
              'It is prohibited to pass any vehicle that has stopped at a pedestrian crossing',
        },
        {'text': 'You may pass only once the pedestrian has crossed'},
      ],
      'correct_index': 1,
      'explanation':
          'Never pass a vehicle stopped at a pedestrian crossing, as pedestrians may be crossing out of view.',
      'difficulty_level': 2,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'A light motor vehicle fitted with a spot lamp may be used on a public road...',
      'options': [
        {'text': 'If it\'s a breakdown vehicle at a collision scene'},
        {'text': 'With a light that\'s beam can shine in any direction'},
        {'text': 'If the lights are not connected'},
      ],
      'correct_index': 0,
      'explanation':
          'Spot lamps may only be used by authorized emergency or breakdown vehicles at incident scenes.',
      'difficulty_level': 2,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'Which statement is False? A vehicle may be used on a public road if......',
      'options': [
        {'text': 'The battery and electrical wiring are properly installed'},
        {'text': 'The fuel cap is effective and closed'},
        {'text': 'The fuel tank is defective'},
      ],
      'correct_index': 2,
      'explanation':
          'A vehicle with a defective fuel tank may NOT be used on public roads due to safety hazards.',
      'difficulty_level': 2,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'You are in heavy traffic in the right hand lane,..the car in front wants to turn into his driveway and has stopped, waiting for heavy oncoming traffic, what do you do?',
      'options': [
        {
          'text':
              'Wait behind the car until you get the opportunity to pass, and when its safe ...proceed',
        },
        {'text': 'Switch on your left flicker and move to the left lane'},
        {'text': 'Hoot, wave and pass'},
      ],
      'correct_index': 0,
      'explanation':
          'Wait patiently behind the turning vehicle. Never attempt dangerous maneuvers like swerving into other lanes.',
      'difficulty_level': 2,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'The use of a temporary sign implies that for some reason...?',
      'options': [
        {'text': 'The rules of the road do not apply'},
        {'text': 'The situation on the road is not normal'},
        {'text': 'Traffic must move slowly'},
      ],
      'correct_index': 1,
      'explanation':
          'Temporary signs indicate abnormal road conditions that require special attention and caution.',
      'difficulty_level': 1,
    },
    {
      'category': 'rules_of_road',
      'learner_code': 1,
      'question_text':
          'How far must you be parked from either side of a fire hydrant',
      'options': [
        {'text': '1.5 meter'},
        {'text': '750mm'},
        {'text': '1 meter'},
      ],
      'correct_index': 0,
      'explanation':
          'Maintain at least 1.5m clearance from fire hydrants to ensure emergency access if needed.',
      'difficulty_level': 1,
    },
  ];
}

List<Map<String, dynamic>> _getVehicleControlsQuestions() {
  return [
    // Evolve Driving Academy Vehicle Controls Questions
    {
      'category': 'vehicle_controls',
      'learner_code': 1,
      'question_text': 'To ride faster, you must use number...',
      'options': [
        {'text': '7'},
        {'text': '5'},
        {'text': '4'},
      ],
      'correct_index': 2,
      'explanation':
          'Number 4 is the throttle control. To increase speed, gradually roll the throttle forward.',
      'difficulty_level': 1,
    },
    {
      'category': 'vehicle_controls',
      'learner_code': 1,
      'question_text': 'To turn you must use number',
      'options': [
        {'text': '8'},
        {'text': '1'},
        {'text': '7'},
      ],
      'correct_index': 0,
      'explanation':
          'Number 8 is the steering. To turn, lean the motorcycle and gently counter-steer in the desired direction.',
      'difficulty_level': 1,
    },
    {
      'category': 'vehicle_controls',
      'learner_code': 1,
      'question_text': 'To stop you must use number...',
      'options': [
        {'text': '4 and 7'},
        {'text': '2 and 7'},
        {'text': '1 and 2'},
      ],
      'correct_index': 1,
      'explanation':
          'Number 2 (front brake lever) and 7 (rear brake pedal) are used together for controlled stopping.',
      'difficulty_level': 1,
    },
    {
      'category': 'vehicle_controls',
      'learner_code': 1,
      'question_text': 'To change gears, you must use numbers...',
      'options': [
        {'text': '1 and 5'},
        {'text': '2 and 7'},
        {'text': '1 and 2'},
      ],
      'correct_index': 0,
      'explanation':
          'Number 1 (clutch lever) and 5 (gear lever) are used together for smooth gear changes.',
      'difficulty_level': 1,
    },
    {
      'category': 'vehicle_controls',
      'learner_code': 1,
      'question_text':
          'To indicate that you are going to turn you must use number...',
      'options': [
        {'text': '6'},
        {'text': '4'},
        {'text': '8'},
      ],
      'correct_index': 0,
      'explanation':
          'Number 6 is the indicator switch. Use it to signal your intention to turn well in advance.',
      'difficulty_level': 1,
    },
    {
      'category': 'vehicle_controls',
      'learner_code': 2,
      'question_text': 'To select a gear you must use numbers...',
      'options': [
        {'text': '789'},
        {'text': '588'},
        {'text': '688'},
      ],
      'correct_index': 2,
      'explanation':
          'In manual vehicles, use clutch (8) and gear lever (4) to select gears. "688" likely refers to clutch and gear operation.',
      'difficulty_level': 1,
    },
    {
      'category': 'vehicle_controls',
      'learner_code': 2,
      'question_text': 'To stop your vehicle, you must use number...',
      'options': [
        {'text': '9'},
        {'text': '8'},
        {'text': '7'},
      ],
      'correct_index': 2,
      'explanation':
          'Number 7 is the foot brake (service brake) used for normal stopping in light motor vehicles.',
      'difficulty_level': 1,
    },
    {
      'category': 'vehicle_controls',
      'learner_code': 2,
      'question_text': 'Number...is not found in an automatic vehicle',
      'options': [
        {'text': '2'},
        {'text': '6'},
        {'text': '8'},
      ],
      'correct_index': 2,
      'explanation':
          'Number 8 is the clutch pedal, which is not present in automatic transmission vehicles.',
      'difficulty_level': 1,
    },
    {
      'category': 'vehicle_controls',
      'learner_code': 2,
      'question_text': 'To turn, number...is used',
      'options': [
        {'text': '4'},
        {'text': '5'},
        {'text': '10'},
      ],
      'correct_index': 0,
      'explanation':
          'Number 4 is the steering wheel, used to control the direction of the vehicle.',
      'difficulty_level': 1,
    },
    {
      'category': 'vehicle_controls',
      'learner_code': 3,
      'question_text': 'To select a gear, you must use numbers...',
      'options': [
        {'text': '789'},
        {'text': '588'},
        {'text': '688'},
      ],
      'correct_index': 2,
      'explanation':
          'Heavy vehicles use clutch (8) and gear lever (4) for gear selection. "688" refers to clutch operation.',
      'difficulty_level': 1,
    },
    {
      'category': 'vehicle_controls',
      'learner_code': 3,
      'question_text': 'To stop your vehicle you must use number...',
      'options': [
        {'text': '9'},
        {'text': '8'},
        {'text': '7'},
      ],
      'correct_index': 2,
      'explanation':
          'Number 7 is the foot brake, essential for controlled stopping in heavy vehicles.',
      'difficulty_level': 1,
    },
    {
      'category': 'vehicle_controls',
      'learner_code': 3,
      'question_text': 'To turn your vehicle, number... is used',
      'options': [
        {'text': '5'},
        {'text': '4'},
        {'text': '6'},
      ],
      'correct_index': 1,
      'explanation':
          'Number 4 is the steering wheel, used to direct heavy vehicles through turns.',
      'difficulty_level': 1,
    },
    {
      'category': 'vehicle_controls',
      'learner_code': 3,
      'question_text':
          'To ensure that your parked vehicle does not move, use number...',
      'options': [
        {'text': '7'},
        {'text': '8'},
        {'text': '9'},
      ],
      'correct_index': 2,
      'explanation':
          'Number 9 is the parking brake, crucial for securing heavy vehicles when stationary.',
      'difficulty_level': 1,
    },
    {
      'category': 'vehicle_controls',
      'learner_code': 3,
      'question_text': 'To accelerate your vehicle you must use number...',
      'options': [
        {'text': '6'},
        {'text': '8'},
        {'text': '10'},
      ],
      'correct_index': 0,
      'explanation':
          'Number 6 is the accelerator, used to increase speed in heavy vehicles.',
      'difficulty_level': 1,
    },
  ];
}
