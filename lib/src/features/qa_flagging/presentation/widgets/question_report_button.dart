import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k53app/src/core/services/question_report_service.dart';
import 'question_report_bottom_sheet.dart';

final reportedQuestionsProvider = StateProvider<Set<String>>((ref) => {});

class QuestionReportButton extends ConsumerWidget {
  final String questionId;
  final String sessionId;
  final bool showLabel;

  const QuestionReportButton({
    Key? key,
    required this.questionId,
    required this.sessionId,
    this.showLabel = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportedQuestions = ref.watch(reportedQuestionsProvider);
    final isReported = reportedQuestions.contains(questionId);

    return FutureBuilder<bool>(
      future: QuestionReportService.hasUserReportedQuestion(questionId),
      builder: (context, snapshot) {
        final hasReported = snapshot.data ?? false || isReported;
        
        return IconButton(
          icon: Icon(
            hasReported ? Icons.flag : Icons.flag_outlined,
            color: hasReported ? Colors.orange : Colors.grey,
            size: 20,
          ),
          onPressed: hasReported
              ? null
              : () => _showReportDialog(context, ref),
          tooltip: hasReported ? 'Already reported' : 'Report question',
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(),
          splashRadius: 16,
        );
      },
    );
  }

  void _showReportDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: QuestionReportBottomSheet(
          questionId: questionId,
          sessionId: sessionId,
        ),
      ),
    ).then((value) {
      // Mark as reported if the report was successful
      if (value == true) {
        ref.read(reportedQuestionsProvider.notifier).update((state) {
          return {...state, questionId};
        });
      }
    });
  }
}

// Compact version for use in question cards
class CompactReportButton extends ConsumerWidget {
  final String questionId;
  final String sessionId;

  const CompactReportButton({
    Key? key,
    required this.questionId,
    required this.sessionId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportedQuestions = ref.watch(reportedQuestionsProvider);
    final isReported = reportedQuestions.contains(questionId);

    return FutureBuilder<bool>(
      future: QuestionReportService.hasUserReportedQuestion(questionId),
      builder: (context, snapshot) {
        final hasReported = snapshot.data ?? false || isReported;
        
        return Tooltip(
          message: hasReported ? 'Already reported' : 'Report question',
          child: InkWell(
            onTap: hasReported
                ? null
                : () => _showReportDialog(context, ref),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                hasReported ? Icons.flag : Icons.flag_outlined,
                color: hasReported ? Colors.orange : Colors.grey,
                size: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showReportDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: QuestionReportBottomSheet(
          questionId: questionId,
          sessionId: sessionId,
        ),
      ),
    ).then((value) {
      if (value == true) {
        ref.read(reportedQuestionsProvider.notifier).update((state) {
          return {...state, questionId};
        });
      }
    });
  }
}

// Text button version for accessibility
class ReportQuestionTextButton extends ConsumerWidget {
  final String questionId;
  final String sessionId;

  const ReportQuestionTextButton({
    Key? key,
    required this.questionId,
    required this.sessionId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportedQuestions = ref.watch(reportedQuestionsProvider);
    final isReported = reportedQuestions.contains(questionId);

    return FutureBuilder<bool>(
      future: QuestionReportService.hasUserReportedQuestion(questionId),
      builder: (context, snapshot) {
        final hasReported = snapshot.data ?? false || isReported;
        
        return TextButton.icon(
          onPressed: hasReported
              ? null
              : () => _showReportDialog(context, ref),
          icon: Icon(
            hasReported ? Icons.flag : Icons.flag_outlined,
            color: hasReported ? Colors.orange : Colors.grey,
            size: 16,
          ),
          label: Text(
            hasReported ? 'Reported' : 'Report Question',
            style: TextStyle(
              color: hasReported ? Colors.orange : Colors.grey,
              fontSize: 12,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: const Size(0, 0),
          ),
        );
      },
    );
  }

  void _showReportDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: QuestionReportBottomSheet(
          questionId: questionId,
          sessionId: sessionId,
        ),
      ),
    ).then((value) {
      if (value == true) {
        ref.read(reportedQuestionsProvider.notifier).update((state) {
          return {...state, questionId};
        });
      }
    });
  }
}