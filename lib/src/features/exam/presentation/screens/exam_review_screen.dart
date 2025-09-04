import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/exam_provider.dart';
import '../../../../core/models/question.dart';
import '../../../../core/services/analytics_service.dart';

class ExamReviewScreen extends ConsumerStatefulWidget {
  const ExamReviewScreen({super.key});

  @override
  ConsumerState<ExamReviewScreen> createState() => _ExamReviewScreenState();
}

class _ExamReviewScreenState extends ConsumerState<ExamReviewScreen> {
  @override
  void initState() {
    super.initState();
    // Track review screen view in analytics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final examState = ref.read(examProvider);
      AnalyticsService.trackUserEngagement(
        eventName: 'exam_review_viewed',
        properties: {
          'score': examState.correctAnswers,
          'total_questions': examState.questions.length,
          'passed': examState.hasPassed,
        },
      );
    });
  }

  Widget _buildQuestionReviewCard(
    BuildContext context,
    Question question,
    int questionIndex,
    int? selectedAnswerIndex,
  ) {
    final isCorrect = selectedAnswerIndex == question.correctIndex;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header with number and correctness indicator
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCorrect ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${questionIndex + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Question ${questionIndex + 1}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Question text
            Text(
              question.questionText,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),

            // Options with correctness indicators
            Column(
              children: question.options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                final isSelected = selectedAnswerIndex == index;
                final isCorrectOption = index == question.correctIndex;

                Color backgroundColor = Colors.transparent;
                Color textColor = Colors.black;
                IconData? icon;

                if (isCorrectOption) {
                  backgroundColor = Colors.green.withOpacity(0.1);
                  textColor = Colors.green;
                  icon = Icons.check_circle;
                } else if (isSelected && !isCorrectOption) {
                  backgroundColor = Colors.red.withOpacity(0.1);
                  textColor = Colors.red;
                  icon = Icons.cancel;
                }

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8.0),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: isSelected || isCorrectOption
                          ? textColor
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        if (icon != null)
                          Icon(
                            icon,
                            color: textColor,
                            size: 20,
                          )
                        else
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey),
                            ),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${String.fromCharCode(65 + index)}. ${option.text}',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: isSelected || isCorrectOption
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),

            // Explanation
            if (question.explanation.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Explanation:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    question.explanation,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSummary(BuildContext context, ExamState examState) {
    final correctAnswers = examState.correctAnswers;
    final totalQuestions = examState.questions.length;
    final percentage = (correctAnswers / totalQuestions) * 100;
    final hasPassed = percentage >= 70;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryItem(
                  context,
                  'Correct',
                  '$correctAnswers',
                  Colors.green,
                ),
                _buildSummaryItem(
                  context,
                  'Incorrect',
                  '${totalQuestions - correctAnswers}',
                  Colors.red,
                ),
                _buildSummaryItem(
                  context,
                  'Accuracy',
                  '${percentage.toStringAsFixed(1)}%',
                  hasPassed ? Colors.green : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              hasPassed ? '🎉 Congratulations! You passed!' : 'Keep practicing!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: hasPassed ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String title,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final examState = ref.watch(examProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Review'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Performance Summary
          _buildPerformanceSummary(context, examState),
          
          // Review List Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Icon(Icons.list, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Question Review',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          
          // Questions Review List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: examState.questions.length,
              itemBuilder: (context, index) {
                final question = examState.questions[index];
                final selectedAnswerIndex = examState.userAnswers[question.id];
                
                return _buildQuestionReviewCard(
                  context,
                  question,
                  index,
                  selectedAnswerIndex,
                );
              },
            ),
          ),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go('/dashboard'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Back to Dashboard'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(examProvider.notifier).retryExam();
                      context.go('/exam');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Try Again'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}