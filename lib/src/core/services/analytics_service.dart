import 'package:k53app/src/core/services/database_service.dart';
import 'package:k53app/src/core/services/supabase_service.dart';
import '../config/environment_config.dart';

class AnalyticsService {
  // Track study session start
  static Future<void> trackStudySessionStart({
    required String sessionId,
    required String category,
    required int questionCount,
  }) async {
    // This would integrate with your analytics service
    // For now, we'll just print for debugging
    if (EnvironmentConfig.enableAnalytics) {
      print('Analytics: Study session started - '
          'Session: $sessionId, '
          'Category: $category, '
          'Questions: $questionCount');
    }
  }

  // Track question answered
  static Future<void> trackQuestionAnswered({
    required String sessionId,
    required String questionId,
    required bool isCorrect,
    required int elapsedMs,
    required int hintsUsed,
  }) async {
    if (EnvironmentConfig.enableAnalytics) {
      print('Analytics: Question answered - '
          'Session: $sessionId, '
          'Correct: $isCorrect, '
          'Time: ${elapsedMs}ms, '
          'Hints: $hintsUsed');
    }
  }

  // Track study session completion
  static Future<void> trackStudySessionComplete({
    required String sessionId,
    required int totalQuestions,
    required int correctAnswers,
    required int totalTimeSeconds,
  }) async {
    if (EnvironmentConfig.enableAnalytics) {
      final accuracy = totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;
      
      print('Analytics: Study session completed - '
          'Session: $sessionId, '
          'Score: $correctAnswers/$totalQuestions, '
          'Accuracy: ${accuracy.toStringAsFixed(1)}%, '
          'Time: ${totalTimeSeconds}s');
    }
  }

  // Track exam session start
  static Future<void> trackExamSessionStart({
    required String sessionId,
    required String category,
    required int timeLimitMinutes,
  }) async {
    if (EnvironmentConfig.enableAnalytics) {
      print('Analytics: Exam session started - '
          'Session: $sessionId, '
          'Category: $category, '
          'Time Limit: ${timeLimitMinutes}min');
    }
  }

  // Track exam session completion
  static Future<void> trackExamSessionComplete({
    required String sessionId,
    required int score,
    required int totalQuestions,
    required bool passed,
    required int timeSpentSeconds,
  }) async {
    if (EnvironmentConfig.enableAnalytics) {
      print('Analytics: Exam session completed - '
          'Session: $sessionId, '
          'Score: $score/$totalQuestions, '
          'Passed: $passed, '
          'Time: ${timeSpentSeconds}s');
    }
  }

  // Track user engagement
  static Future<void> trackUserEngagement({
    required String eventName,
    Map<String, dynamic>? properties,
  }) async {
    if (EnvironmentConfig.enableAnalytics) {
      final props = properties?.entries
          .map((e) => '${e.key}: ${e.value}')
          .join(', ') ?? 'none';
      
      print('Analytics: User engagement - '
          'Event: $eventName, '
          'Properties: $props');
    }
  }

  // Get user study statistics
  static Future<Map<String, dynamic>> getUserStudyStats() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return {};

    try {
      return await DatabaseService.getUserStats(userId);
    } catch (e) {
      print('Error getting user stats: $e');
      return {};
    }
  }

  // Get category-wise performance
  static Future<Map<String, dynamic>> getCategoryPerformance() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return {};

    try {
      // This would be implemented with more specific database queries
      // For now, return empty map as placeholder
      return {};
    } catch (e) {
      print('Error getting category performance: $e');
      return {};
    }
  }

  // Get daily streak information
  static Future<Map<String, dynamic>> getDailyStreak() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return {};

    try {
      // Query for consecutive days with study activity
      // This would require additional database structure
      return {
        'currentStreak': 0,
        'longestStreak': 0,
        'lastActivity': null,
      };
    } catch (e) {
      print('Error getting daily streak: $e');
      return {};
    }
  }

  // Track app usage time
  static Future<void> trackAppUsageTime(Duration duration) async {
    if (EnvironmentConfig.enableAnalytics) {
      print('Analytics: App usage time - '
          'Duration: ${duration.inMinutes} minutes');
    }
  }

  // Track feature usage
  static Future<void> trackFeatureUsage(String featureName) async {
    if (EnvironmentConfig.enableAnalytics) {
      print('Analytics: Feature used - $featureName');
    }
  }

  // Track error events
  static Future<void> trackError({
    required String errorType,
    required String errorMessage,
    String? context,
  }) async {
    if (EnvironmentConfig.enableAnalytics) {
      print('Analytics: Error occurred - '
          'Type: $errorType, '
          'Message: $errorMessage, '
          'Context: $context');
    }
  }

  // Track user achievement
  static Future<void> trackAchievement({
    required String achievementName,
    required String achievementType,
  }) async {
    if (EnvironmentConfig.enableAnalytics) {
      print('Analytics: Achievement unlocked - '
          'Name: $achievementName, '
          'Type: $achievementType');
    }
  }
}