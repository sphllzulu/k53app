import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/exam_provider.dart';
import '../../../gamification/presentation/providers/gamification_provider.dart';
import '../../../../core/services/analytics_service.dart';

class ExamScreen extends ConsumerStatefulWidget {
  const ExamScreen({super.key});

  @override
  ConsumerState<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends ConsumerState<ExamScreen> {
  String? _selectedCategory;
  int? _selectedLearnerCode;
  String? _selectedDifficulty;
  int _questionCount = 30;
  bool _isStarting = false;
  bool _hasNavigatedToReview = false;

  @override
  void initState() {
    super.initState();
    // Track exam screen view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService.trackUserEngagement(
        eventName: 'exam_screen_viewed',
        properties: {
          'category': _selectedCategory,
          'learner_code': _selectedLearnerCode,
          'difficulty': _selectedDifficulty,
          'question_count': _questionCount,
        },
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen for exam completion and navigate to review screen
    final examState = ref.watch(examProvider);
    if (examState.isCompleted && !_hasNavigatedToReview) {
      _hasNavigatedToReview = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/exam/review');
        }
      });
    }
  }

  Future<void> _startExam() async {
    if (_isStarting) return;

    setState(() => _isStarting = true);
    
    final notifier = ref.read(examProvider.notifier);
    await notifier.loadExamQuestions(
      category: _selectedCategory,
      learnerCode: _selectedLearnerCode,
      difficulty: _selectedDifficulty,
      questionCount: _questionCount,
    );

    if (!mounted) return;
    setState(() => _isStarting = false);

    final examState = ref.read(examProvider);
    if (examState.error == null) {
      // Track exam start with selected options
      AnalyticsService.trackUserEngagement(
        eventName: 'exam_started',
        properties: {
          'category': _selectedCategory,
          'learner_code': _selectedLearnerCode,
          'difficulty': _selectedDifficulty,
          'question_count': _questionCount,
        },
      );
    }
  }

  Widget _buildCategorySelector() {
    return AlertDialog(
      title: const Text('Exam Options'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('All Categories')),
              DropdownMenuItem(value: 'rules_of_road', child: Text('Rules of the Road')),
              DropdownMenuItem(value: 'road_signs', child: Text('Road Signs')),
              DropdownMenuItem(value: 'vehicle_controls', child: Text('Vehicle Controls')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _selectedLearnerCode,
            decoration: const InputDecoration(
              labelText: 'Learner Code',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('All Codes')),
              DropdownMenuItem(value: 1, child: Text('Code 1 (Motorcycles)')),
              DropdownMenuItem(value: 2, child: Text('Code 2 (Light Vehicles)')),
              DropdownMenuItem(value: 3, child: Text('Code 3 (Heavy Vehicles)')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedLearnerCode = value;
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedDifficulty,
            decoration: const InputDecoration(
              labelText: 'Difficulty Level',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('All Levels')),
              DropdownMenuItem(value: 'easy', child: Text('Easy')),
              DropdownMenuItem(value: 'medium', child: Text('Medium')),
              DropdownMenuItem(value: 'hard', child: Text('Hard')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedDifficulty = value;
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _questionCount,
            decoration: const InputDecoration(
              labelText: 'Number of Questions',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 10, child: Text('10 Questions')),
              DropdownMenuItem(value: 20, child: Text('20 Questions')),
              DropdownMenuItem(value: 30, child: Text('30 Questions (Standard)')),
              DropdownMenuItem(value: 50, child: Text('50 Questions')),
              DropdownMenuItem(value: 100, child: Text('100 Questions')),
            ],
            onChanged: (value) {
              setState(() {
                _questionCount = value ?? 30;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            _startExam();
          },
          child: const Text('Start Exam'),
        ),
      ],
    );
  }

  Widget _buildExamInProgress(ExamState state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mock Exam'),
        actions: [
          IconButton(
            icon: Icon(state.isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: () => ref.read(examProvider.notifier).togglePause(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Timer and progress
            // Timer display - more prominent
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue),
              ),
              child: Column(
                children: [
                  Text(
                    'Time Remaining',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.formattedTime,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: state.timeRemainingSeconds < 300 ? Colors.red : Colors.blue[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Score and progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Score display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Score',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.green[800],
                        ),
                      ),
                      Text(
                        '${state.correctAnswers}/${state.totalAnswered}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Question progress
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Question',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.orange[800],
                        ),
                      ),
                      Text(
                        '${state.currentQuestionIndex + 1}/${state.questions.length}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.orange[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Progress bar
            LinearProgressIndicator(
              value: state.progress,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 24),

            // Current question
            if (state.currentQuestion != null) ...[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.currentQuestion!.questionText,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Options
                      Column(
                        children: state.currentQuestion!.options.asMap().entries.map((entry) {
                          final index = entry.key;
                          final option = entry.value;

                          Color? buttonColor;
                          if (state.selectedAnswerIndex == index) {
                            buttonColor = state.currentQuestion!.isAnswerCorrect(index)
                                ? Colors.green
                                : Colors.red;
                          } else if (state.showExplanation && state.currentQuestion!.isAnswerCorrect(index)) {
                            buttonColor = Colors.green;
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: ElevatedButton(
                              onPressed: state.showExplanation || state.isCompleted
                                  ? null
                                  : () async => ref.read(examProvider.notifier).selectAnswer(index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonColor,
                                foregroundColor: buttonColor != null ? Colors.white : null,
                                minimumSize: const Size(double.infinity, 60),
                              ),
                              child: Text(
                                '${String.fromCharCode(65 + index)}. ${option.text}',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      // Explanation
                      if (state.showExplanation) ...[
                        const SizedBox(height: 24),
                        Card(
                          color: Colors.blue[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Explanation:',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.blue[800],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  state.currentQuestion!.explanation,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            // Navigation buttons
            if (!state.isCompleted) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: state.isFirstQuestion ? null : () => ref.read(examProvider.notifier).previousQuestion(),
                    child: const Text('Previous'),
                  ),
                  ElevatedButton(
                    onPressed: state.showExplanation && !state.isLastQuestion
                        ? () => ref.read(examProvider.notifier).nextQuestion()
                        : null,
                    child: const Text('Next'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExamStart() {
    return Scaffold(
      appBar: AppBar(title: const Text('Mock Exam')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz, size: 64, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'K53 Mock Exam',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              '45 minutes • $_questionCount questions • 70% to pass',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Select options for customized exam',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => _buildCategorySelector(),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Exam'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final examState = ref.watch(examProvider);

    if (examState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mock Exam')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (examState.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mock Exam')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(examState.error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _startExam,
                child: const Text('Retry'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      );
    }

    if (examState.questions.isNotEmpty) {
      return _buildExamInProgress(examState);
    }

    return _buildExamStart();
  }
}