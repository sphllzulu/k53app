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

  // Use ANON key directly since RLS is disabled for questions table
  final supabaseUrl = envVars['SUPABASE_URL'] ?? '';
  final supabaseKey = envVars['SUPABASE_ANON_KEY'] ?? '';

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    print('Error: SUPABASE_URL or SUPABASE_ANON_KEY not found in .env file');
    exit(1);
  }

  final supabase = SupabaseClient(supabaseUrl, supabaseKey);
  print('Using ANON key: ${supabaseKey.substring(0, 10)}...');
  print('Using Supabase URL: ${supabaseUrl.substring(0, 20)}...');
  print(
    'Note: RLS should be disabled for the questions table for this to work',
  );
  final uuid = Uuid();

  try {
    print('Starting to seed K53 questions...');

    // Sample questions for Rules of the Road
    final rulesQuestions = [
      {
        'category': 'rules_of_road',
        'learner_code': 1,
        'question_text':
            'What does a solid white line across the road indicate?',
        'options': [
          {'text': 'You may overtake if safe'},
          {'text': 'You must stop behind the line'},
          {'text': 'You can park here'},
          {'text': 'No stopping allowed'},
        ],
        'correct_index': 1,
        'explanation':
            'A solid white line across the road indicates a stop line. You must stop behind this line.',
        'difficulty_level': 1,
      },
      {
        'category': 'rules_of_road',
        'learner_code': 2,
        'question_text': 'When approaching a roundabout, you should:',
        'options': [
          {'text': 'Speed up to get through quickly'},
          {'text': 'Give way to traffic from your right'},
          {'text': 'Sound your horn before entering'},
          {'text': 'Stop completely before entering'},
        ],
        'correct_index': 1,
        'explanation':
            'At a roundabout, you must give way to traffic already on the roundabout (approaching from your right).',
        'difficulty_level': 1,
      },
      {
        'category': 'rules_of_road',
        'learner_code': 3,
        'question_text':
            'What is the minimum following distance in good conditions?',
        'options': [
          {'text': '1 second'},
          {'text': '2 seconds'},
          {'text': '3 seconds'},
          {'text': '4 seconds'},
        ],
        'correct_index': 1,
        'explanation':
            'The minimum safe following distance in good conditions is 2 seconds.',
        'difficulty_level': 1,
      },
    ];

    // Sample questions for Road Signs
    final signsQuestions = [
      {
        'category': 'road_signs',
        'learner_code': 1,
        'question_text':
            'What does a red triangle sign with an exclamation mark mean?',
        'options': [
          {'text': 'Danger ahead'},
          {'text': 'No entry'},
          {'text': 'Speed limit'},
          {'text': 'Parking area'},
        ],
        'correct_index': 0,
        'explanation':
            'A red triangle with an exclamation mark is a warning sign indicating potential danger ahead.',
        'difficulty_level': 1,
      },
      {
        'category': 'road_signs',
        'learner_code': 2,
        'question_text':
            'What does a blue circular sign with a white arrow pointing left mean?',
        'options': [
          {'text': 'Turn left only'},
          {'text': 'No left turn'},
          {'text': 'Left lane ends'},
          {'text': 'Roundabout ahead'},
        ],
        'correct_index': 0,
        'explanation':
            'A blue circular sign with a white arrow indicates a mandatory direction - you must turn left.',
        'difficulty_level': 1,
      },
      {
        'category': 'road_signs',
        'learner_code': 3,
        'question_text': 'What does a yellow diamond sign indicate?',
        'options': [
          {'text': 'General warning'},
          {'text': 'Construction ahead'},
          {'text': 'Pedestrian crossing'},
          {'text': 'School zone'},
        ],
        'correct_index': 1,
        'explanation':
            'Yellow diamond signs indicate road construction or maintenance ahead.',
        'difficulty_level': 1,
      },
    ];

    // Sample questions for Vehicle Controls
    final controlsQuestions = [
      {
        'category': 'vehicle_controls',
        'learner_code': 1,
        'question_text': 'What should you check before starting a motorcycle?',
        'options': [
          {'text': 'Fuel level and brakes'},
          {'text': 'Radio volume'},
          {'text': 'Seat comfort'},
          {'text': 'Paint color'},
        ],
        'correct_index': 0,
        'explanation':
            'Before starting a motorcycle, always check fuel level, brakes, tires, and lights.',
        'difficulty_level': 1,
      },
      {
        'category': 'vehicle_controls',
        'learner_code': 2,
        'question_text':
            'What does the anti-lock braking system (ABS) prevent?',
        'options': [
          {'text': 'Wheel lock-up during braking'},
          {'text': 'Engine overheating'},
          {'text': 'Fuel evaporation'},
          {'text': 'Tire punctures'},
        ],
        'correct_index': 0,
        'explanation':
            'ABS prevents wheels from locking up during hard braking, maintaining steering control.',
        'difficulty_level': 1,
      },
      {
        'category': 'vehicle_controls',
        'learner_code': 3,
        'question_text': 'What is the purpose of a retarder in heavy vehicles?',
        'options': [
          {'text': 'To assist with braking'},
          {'text': 'To increase speed'},
          {'text': 'To improve fuel economy'},
          {'text': 'To enhance comfort'},
        ],
        'correct_index': 0,
        'explanation':
            'A retarder helps slow down heavy vehicles without using the service brakes, reducing brake wear.',
        'difficulty_level': 1,
      },
    ];

    // Combine all questions
    final allQuestions = [
      ...rulesQuestions,
      ...signsQuestions,
      ...controlsQuestions,
    ];

    int insertedCount = 0;

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
        print('Inserted question: ${questionData['question_text']}');
      } catch (e) {
        print('Error inserting question: $e');
      }
    }

    print(
      '\n✅ Successfully inserted $insertedCount questions into the database!',
    );
    print(
      'Categories covered: Rules of the Road, Road Signs, Vehicle Controls',
    );
    print(
      'Learner codes: 1 (Motorcycles), 2 (Light Vehicles), 3 (Heavy Vehicles)',
    );
    print('Difficulty: Level 1 (Easy)');
  } catch (e) {
    print('Error seeding questions: $e');
    exit(1);
  } finally {
    supabase.dispose();
  }
}
