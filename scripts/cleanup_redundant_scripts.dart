import 'dart:io';

void main() {
  print('Cleaning up redundant seeding scripts...\n');
  
  // List of files to remove (redundant SQL and JavaScript files)
  final filesToRemove = [
    'scripts/create_questions_table.sql',
    'scripts/seed_additional_questions.sql',
    'scripts/seed_final_questions.sql',
    'scripts/seed_comprehensive_questions.sql',
    'scripts/seed_evolve_questions.sql',
    'scripts/seed_level2_questions.sql',
    'scripts/insert_questions.js',
    'scripts/run_seed.js',
    'scripts/manual_insert.js',
    'scripts/simple_insert.js',
    'scripts/test_connection.js',
    'scripts/execute_sql.js',
  ];

  int removedCount = 0;
  int errorCount = 0;

  for (final filePath in filesToRemove) {
    final file = File(filePath);
    if (file.existsSync()) {
      try {
        file.deleteSync();
        print('✅ Removed: $filePath');
        removedCount++;
      } catch (e) {
        print('❌ Error removing $filePath: $e');
        errorCount++;
      }
    } else {
      print('ℹ️  Not found (skipping): $filePath');
    }
  }

  print('\nCleanup completed!');
  print('Removed $removedCount files');
  print('Errors: $errorCount');
  print('\nKept essential files:');
  print('✅ scripts/seed_k53_questions.dart - Main Dart seeder');
  print('✅ scripts/seed_comprehensive_k53.dart - Enhanced comprehensive seeder');
  print('✅ supabase/migrations/ - Database schema migrations');
  print('\nNext steps:');
  print('1. Run the comprehensive seeder: dart run scripts/seed_comprehensive_k53.dart');
  print('2. Verify database contains all questions');
  print('3. Delete this cleanup script when done');
}