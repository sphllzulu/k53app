import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k53app/src/core/models/question_report.dart';
import 'package:k53app/src/core/services/question_report_service.dart';
import 'package:k53app/src/core/services/analytics_service.dart';

class QuestionReportBottomSheet extends ConsumerStatefulWidget {
  final String questionId;
  final String sessionId;
  final String? questionCategory;

  const QuestionReportBottomSheet({
    Key? key,
    required this.questionId,
    required this.sessionId,
    this.questionCategory,
  }) : super(key: key);

  @override
  ConsumerState<QuestionReportBottomSheet> createState() =>
      _QuestionReportBottomSheetState();
}

class _QuestionReportBottomSheetState
    extends ConsumerState<QuestionReportBottomSheet> {
  ReportReason? _selectedReason;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  bool _hasReported = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_selectedReason == null) return;

    setState(() => _isSubmitting = true);

    try {
      final success = await QuestionReportService.reportQuestion(
        questionId: widget.questionId,
        reason: _selectedReason!,
        comment: _commentController.text.isNotEmpty
            ? _commentController.text
            : null,
        sessionId: widget.sessionId,
      );

      if (success) {
        // Track analytics
        AnalyticsService.trackUserEngagement(
          eventName: 'question_reported',
          properties: {
            'question_id': widget.questionId,
            'reason': _selectedReason!.value,
            'session_id': widget.sessionId,
            'question_category': widget.questionCategory,
          },
        );

        setState(() => _hasReported = true);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted - thank you!'),
            duration: Duration(seconds: 2),
          ),
        );

        // Close after delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.of(context).pop();
        });
      } else {
        // Already reported
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have already reported this question'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit report. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Report Question',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Why are you reporting this question?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (_hasReported)
            _buildSuccessState()
          else
            _buildReportForm(),
        ],
      ),
    );
  }

  Widget _buildReportForm() {
    return Column(
      children: [
        ...ReportReason.selectableReasons.map((reason) {
          return RadioListTile<ReportReason>(
            title: Text(reason.displayText),
            value: reason,
            groupValue: _selectedReason,
            onChanged: _isSubmitting
                ? null
                : (value) {
                    setState(() => _selectedReason = value);
                  },
          );
        }),
        const SizedBox(height: 16),
        if (_selectedReason == ReportReason.other ||
            _selectedReason == ReportReason.confusingQuestion ||
            _selectedReason == ReportReason.incorrectAnswer)
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Additional details (optional)',
              border: OutlineInputBorder(),
              hintText: 'Please provide more information...',
            ),
            maxLines: 3,
            enabled: !_isSubmitting,
          ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _selectedReason == null || _isSubmitting
                    ? null
                    : _submitReport,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Report'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 48),
        const SizedBox(height: 16),
        Text(
          'Thank you for your feedback!',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'We\'ll review this question and make improvements if needed.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}