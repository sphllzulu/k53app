import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k53app/src/core/models/question_report.dart';
import 'package:k53app/src/core/services/question_report_service.dart';

final reportSubmissionProvider =
    StateNotifierProvider<ReportSubmissionNotifier, AsyncValue<bool>>(
  (ref) => ReportSubmissionNotifier(),
);

class ReportSubmissionNotifier extends StateNotifier<AsyncValue<bool>> {
  ReportSubmissionNotifier() : super(const AsyncValue.data(false));

  Future<void> submitReport({
    required String questionId,
    required ReportReason reason,
    String? comment,
    String? sessionId,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final success = await QuestionReportService.reportQuestion(
        questionId: questionId,
        reason: reason,
        comment: comment,
        sessionId: sessionId,
      );
      
      state = AsyncValue.data(success);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void reset() {
    state = const AsyncValue.data(false);
  }
}

// Provider for checking if user has reached daily limit
final dailyReportLimitProvider = FutureProvider<bool>((ref) async {
  return await QuestionReportService.hasReachedDailyLimit();
});

// Provider for remaining daily reports
final remainingDailyReportsProvider = FutureProvider<int>((ref) async {
  return await QuestionReportService.getRemainingDailyReports();
});

// Provider for checking if a specific question has been reported
final questionReportedProvider = FutureProvider.family<bool, String>((ref, questionId) async {
  return await QuestionReportService.hasUserReportedQuestion(questionId);
});

// Provider for getting user's report history
final userReportsProvider = FutureProvider<List<QuestionReport>>((ref) async {
  return await QuestionReportService.getUserReports();
});

// Provider for getting report statistics for a question
final questionReportStatsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, questionId) async {
  return await QuestionReportService.getQuestionReportStats(questionId);
});