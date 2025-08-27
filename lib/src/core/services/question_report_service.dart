import 'package:k53app/src/core/models/question_report.dart';
import './supabase_service.dart';

class QuestionReportService {
  static final _client = SupabaseService.client;

  /// Report a question with the given reason and optional comment
  static Future<bool> reportQuestion({
    required String questionId,
    required ReportReason reason,
    String? comment,
    String? sessionId,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to report questions');
      }

      // Try to create profile if it doesn't exist (handle_new_user trigger might not have fired)
      try {
        await _client
            .from('profiles')
            .upsert({
              'id': user.id,
              'handle': 'user_${user.id.substring(0, 8)}',
              'learner_code': 1,
              'locale': 'en'
            }, onConflict: 'id');
      } catch (e) {
        print('DEBUG: Error creating/updating profile: $e');
        // Continue anyway - the foreign key constraint might still work
      }

      await _client
          .from('question_reports')
          .insert({
            'question_id': questionId,
            'reporter_user_id': user.id,
            'reason': reason.value,
            'comment': comment,
            'session_id': sessionId,
          });

      return true;
    } catch (e) {
      // Handle duplicate report error gracefully
      if (e.toString().contains('duplicate key')) {
        return false; // Already reported
      }
      rethrow;
    }
  }

  /// Check if the current user has already reported a specific question
  static Future<bool> hasUserReportedQuestion(String questionId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return false;
      }

      final response = await _client
          .from('question_reports')
          .select('id')
          .eq('question_id', questionId)
          .eq('reporter_user_id', user.id);

      return (response as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get all reports for a specific question (admin functionality)
  static Future<List<QuestionReport>> getQuestionReports(String questionId) async {
    try {
      final response = await _client
          .from('question_reports')
          .select()
          .eq('question_id', questionId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => QuestionReport.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get reports made by the current user
  static Future<List<QuestionReport>> getUserReports() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return [];
      }

      final response = await _client
          .from('question_reports')
          .select()
          .eq('reporter_user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => QuestionReport.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get report statistics for a question
  static Future<Map<String, dynamic>> getQuestionReportStats(String questionId) async {
    try {
      final response = await _client
          .from('question_reports')
          .select()
          .eq('question_id', questionId);

      final reports = (response as List)
          .map((json) => QuestionReport.fromJson(json as Map<String, dynamic>))
          .toList();

      final stats = <String, int>{};
      for (final report in reports) {
        final reason = report.reason.value;
        stats[reason] = (stats[reason] ?? 0) + 1;
      }

      return {
        'total_reports': reports.length,
        'by_reason': stats,
      };
    } catch (e) {
      return {
        'total_reports': 0,
        'by_reason': {},
      };
    }
  }

  /// Check if user has reached daily report limit (10 reports per day)
  static Future<bool> hasReachedDailyLimit() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return false;
      }

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      final response = await _client
          .from('question_reports')
          .select('id')
          .eq('reporter_user_id', user.id)
          .gte('created_at', startOfDay.toIso8601String());

      return (response as List).length >= 10;
    } catch (e) {
      return false;
    }
  }

  /// Get user's remaining daily reports
  static Future<int> getRemainingDailyReports() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return 0;
      }

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      final response = await _client
          .from('question_reports')
          .select('id')
          .eq('reporter_user_id', user.id)
          .gte('created_at', startOfDay.toIso8601String());

      final todayReports = (response as List).length;
      return 10 - todayReports;
    } catch (e) {
      return 0;
    }
  }
}