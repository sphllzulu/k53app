import 'package:k53app/src/core/models/question_report.dart';
import './supabase_service.dart';

class AdminQAService {
  static final _client = SupabaseService.client;

  /// Get all flagged questions with details
  static Future<List<Map<String, dynamic>>> getFlaggedQuestions({
    String? severity,
    String? status = 'open',
    int limit = 50,
  }) async {
    try {
      // Get all flags and filter manually
      final allFlags = await _client
          .from('question_flags')
          .select()
          .order('created_at', ascending: false);

      List<Map<String, dynamic>> filteredFlags = (allFlags as List)
          .cast<Map<String, dynamic>>()
          .where((flag) => flag['status'] == status)
          .toList();

      if (severity != null) {
        filteredFlags = filteredFlags
            .where((flag) => flag['severity'] == severity)
            .toList();
      }

      if (limit > 0) {
        filteredFlags = filteredFlags.take(limit).toList();
      }

      final results = <Map<String, dynamic>>[];

      // For each flag, get additional details
      for (final flag in filteredFlags) {
        final questionId = flag['question_id'] as String;
        
        // Get question details
        final question = await _client
            .from('questions')
            .select()
            .eq('id', questionId)
            .single()
            .catchError((_) => null);

        // Get report count
        final reports = await _client
            .from('question_reports')
            .select()
            .eq('question_id', questionId)
            .catchError((_) => []);

        // Get quality metrics
        final metrics = await _client
            .from('question_quality_metrics')
            .select()
            .eq('question_id', questionId)
            .single()
            .catchError((_) => null);

        results.add({
          ...flag,
          'question': question,
          'report_count': (reports as List).length,
          'quality_metrics': metrics,
        });
      }

      return results;
    } catch (e) {
      return [];
    }
  }

  /// Get question reports for a specific question
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

  /// Resolve a flag with specific action
  static Future<bool> resolveFlag({
    required String flagId,
    required String action,
    String? notes,
    Map<String, dynamic>? updatedQuestionData,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      // Update flag status
      await _client
          .from('question_flags')
          .update({
            'status': 'resolved',
            'resolved_at': DateTime.now().toIso8601String(),
            'resolved_by': user.id,
          })
          .eq('id', flagId);

      // Log the action
      await _client
          .from('qa_actions')
          .insert({
            'flag_id': flagId,
            'reviewer_user_id': user.id,
            'action_type': action,
            'details': {
              'notes': notes,
              'question_updates': updatedQuestionData,
            },
            'created_at': DateTime.now().toIso8601String(),
          });

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update a question (edit content)
  static Future<bool> updateQuestion({
    required String questionId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _client
          .from('questions')
          .update(updates)
          .eq('id', questionId);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove a question from active pool
  static Future<bool> deactivateQuestion(String questionId) async {
    try {
      await _client
          .from('questions')
          .update({'is_active': false})
          .eq('id', questionId);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get QA analytics and statistics
  static Future<Map<String, dynamic>> getQAAnalytics() async {
    try {
      // Get all flags and process manually
      final allFlags = await _client
          .from('question_flags')
          .select();

      // Get all reports
      final allReports = await _client
          .from('question_reports')
          .select();

      // Get quality metrics
      final qualityMetrics = await _client
          .from('question_quality_metrics')
          .select();

      return {
        'flag_stats': _processFlagStats(allFlags as List),
        'report_stats': _processReportStats(allReports as List),
        'quality_metrics': _processQualityMetrics(qualityMetrics as List),
      };
    } catch (e) {
      return {};
    }
  }

  static Map<String, dynamic> _processFlagStats(List flags) {
    final bySeverity = <String, int>{};
    final byStatus = <String, int>{};
    int total = 0;

    for (final flag in flags) {
      final flagMap = flag as Map<String, dynamic>;
      final severity = flagMap['severity'] as String? ?? 'unknown';
      final status = flagMap['status'] as String? ?? 'unknown';

      total += 1;
      bySeverity[severity] = (bySeverity[severity] ?? 0) + 1;
      byStatus[status] = (byStatus[status] ?? 0) + 1;
    }

    return {
      'total': total,
      'by_severity': bySeverity,
      'by_status': byStatus,
    };
  }

  static Map<String, int> _processReportStats(List reports) {
    final stats = <String, int>{};
    for (final report in reports) {
      final reportMap = report as Map<String, dynamic>;
      final reason = reportMap['reason'] as String? ?? 'other';
      stats[reason] = (stats[reason] ?? 0) + 1;
    }
    return stats;
  }

  static Map<String, dynamic> _processQualityMetrics(List metrics) {
    if (metrics.isEmpty) return {};
    
    double totalSuccess = 0;
    double totalQuality = 0;
    int count = 0;

    for (final metric in metrics) {
      final metricMap = metric as Map<String, dynamic>;
      totalSuccess += (metricMap['success_rate'] as num?)?.toDouble() ?? 0;
      totalQuality += (metricMap['quality_score'] as num?)?.toDouble() ?? 0;
      count++;
    }

    return {
      'avg_success_rate': count > 0 ? totalSuccess / count : 0,
      'avg_quality_score': count > 0 ? totalQuality / count : 0,
    };
  }

  /// Get category performance statistics
  static Future<Map<String, dynamic>> getCategoryPerformance() async {
    try {
      final response = await _client
          .from('questions')
          .select('''
            category,
            question_quality_metrics(success_rate, report_count)
          ''');

      final categories = <String, Map<String, dynamic>>{};
      
      for (final item in response as List) {
        final category = item['category'] as String;
        final metrics = item['question_quality_metrics'] as Map<String, dynamic>?;

        if (!categories.containsKey(category)) {
          categories[category] = {
            'total_questions': 0,
            'total_success_rate': 0.0,
            'total_reports': 0,
            'question_count': 0,
          };
        }

        final catData = categories[category]!;
        catData['question_count'] = (catData['question_count'] as int) + 1;
        
        if (metrics != null) {
          catData['total_success_rate'] = (catData['total_success_rate'] as double) + (metrics['success_rate'] ?? 0.0);
          catData['total_reports'] = (catData['total_reports'] as int) + (metrics['report_count'] ?? 0);
        }
      }

      // Calculate averages
      for (final category in categories.keys) {
        final data = categories[category]!;
        final count = data['question_count'] as int;
        if (count > 0) {
          data['avg_success_rate'] = (data['total_success_rate'] as double) / count;
          data['avg_reports'] = (data['total_reports'] as int) / count;
        }
        data.remove('total_success_rate');
        data.remove('total_reports');
        data.remove('question_count');
      }

      return categories;
    } catch (e) {
      return {};
    }
  }

  /// Check if current user has admin privileges
  static Future<bool> isCurrentUserAdmin() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      final profile = await _client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();

      final role = profile['role'] as String?;
      return role == 'admin' || role == 'qa_reviewer';
    } catch (e) {
      return false;
    }
  }
}