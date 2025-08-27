import 'package:k53app/src/core/services/supabase_service.dart';

/// Service for user-facing QA reporting functionality
class QAService {
  static final _client = SupabaseService.client;

  /// Report a question with specified reason and severity
  static Future<bool> reportQuestion({
    required String questionId,
    required String reason,
    String? description,
    String severity = 'medium',
    String? sessionId,
  }) async {
    try {
      print('DEBUG: Starting question report for question ID: $questionId');
      
      // Get current user ID
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        print('DEBUG: No authenticated user found');
        return false;
      }
      
      print('DEBUG: Current user ID: ${currentUser.id}');
      
      // Try to create profile if it doesn't exist (handle_new_user trigger might not have fired)
      try {
        await _client
            .from('profiles')
            .upsert({
              'id': currentUser.id,
              'handle': 'user_${currentUser.id.substring(0, 8)}',
              'learner_code': 1,
              'locale': 'en'
            }, onConflict: 'id');
            
        print('DEBUG: Profile created/updated successfully');
      } catch (e) {
        print('DEBUG: Error creating/updating profile: $e');
        // Continue anyway - the foreign key constraint might still work
      }

      // Create the report - note: question_reports table uses 'comment' column, not 'description'
      print('DEBUG: Inserting report with data: question_id=$questionId, reporter_user_id=${currentUser.id}, reason=$reason, session_id=$sessionId');
      
      final response = await _client
          .from('question_reports')
          .insert({
            'question_id': questionId,
            'reporter_user_id': currentUser.id,
            'reason': reason,
            'comment': description,
            'session_id': sessionId,
          });

      print('DEBUG: Report insertion successful: $response');
      return true;
    } catch (e) {
      print('DEBUG: Error reporting question: $e');
      print('DEBUG: Error type: ${e.runtimeType}');
      return false;
    }
  }

  /// Get report reasons for dropdown selection
  static List<String> getReportReasons() {
    return [
      'incorrect_answer',
      'confusing_question',
      'multiple_correct',
      'outdated_info',
      'other'
    ];
  }

  /// Get severity levels for dropdown selection
  static List<String> getSeverityLevels() {
    return [
      'low',
      'medium',
      'high',
      'critical',
    ];
  }

  /// Get display name for report reason
  static String getReasonDisplayName(String reason) {
    switch (reason) {
      case 'incorrect_answer':
        return 'Incorrect Answer';
      case 'confusing_question':
        return 'Confusing Question';
      case 'multiple_correct':
        return 'Multiple Correct Answers';
      case 'outdated_info':
        return 'Outdated Information';
      case 'other':
        return 'Other Issue';
      default:
        return reason;
    }
  }

  /// Get display name for severity level
  static String getSeverityDisplayName(String severity) {
    switch (severity) {
      case 'low':
        return 'Low Priority';
      case 'medium':
        return 'Medium Priority';
      case 'high':
        return 'High Priority';
      case 'critical':
        return 'Critical Issue';
      default:
        return severity;
    }
  }
}