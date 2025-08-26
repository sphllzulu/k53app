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
  }) async {
    try {
      // First check if this question already has an open flag
      final existingFlags = await _client
          .from('question_flags')
          .select()
          .eq('question_id', questionId)
          .eq('status', 'open');

      String flagId;
      
      if (existingFlags.isEmpty) {
        // Create new flag
        final flagResponse = await _client
            .from('question_flags')
            .insert({
              'question_id': questionId,
              'severity': severity,
              'status': 'open',
            })
            .select();

        flagId = flagResponse.first['id'] as String;
      } else {
        // Use existing flag
        flagId = existingFlags.first['id'] as String;
      }

      // Create the report
      await _client
          .from('question_reports')
          .insert({
            'question_id': questionId,
            'flag_id': flagId,
            'reason': reason,
            'description': description,
          });

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get report reasons for dropdown selection
  static List<String> getReportReasons() {
    return [
      'incorrect_answer',
      'poor_explanation',
      'typo',
      'outdated',
      'other',
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
      case 'poor_explanation':
        return 'Poor Explanation';
      case 'typo':
        return 'Typo/Grammar Error';
      case 'outdated':
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