import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/question.dart';
import '../../../../core/services/qa_service.dart';
import '../providers/study_provider.dart';
import '../../../gamification/presentation/providers/gamification_provider.dart';

class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({super.key});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  final PageController _pageController = PageController();
  String? _selectedCategory;
  int? _selectedLearnerCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuestions();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final notifier = ref.read(studyProvider.notifier);
    await notifier.loadQuestions(
      category: _selectedCategory,
      learnerCode: _selectedLearnerCode,
      limit: 10,
    );
  }

  Future<void> _selectAnswer(int index) async {
    final notifier = ref.read(studyProvider.notifier);
    await notifier.selectAnswer(index);
  }

  void _nextQuestion() {
    final notifier = ref.read(studyProvider.notifier);
    notifier.nextQuestion();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousQuestion() {
    final notifier = ref.read(studyProvider.notifier);
    notifier.previousQuestion();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _retrySession() async {
    final notifier = ref.read(studyProvider.notifier);
    await notifier.retrySession();
    _pageController.jumpToPage(0);
  }

  Future<void> _reportQuestion(Question question) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Question'),
        content: const Text('Would you like to report this question for review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Report'),
          ),
        ],
      ),
    );

    if (result == true) {
      final success = await QAService.reportQuestion(
        questionId: question.id,
        reason: 'other',
        description: 'User reported question during study session',
        severity: 'medium',
      );

      if (!mounted) return;
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      
      if (success) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Question reported successfully')),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Failed to report question')),
        );
      }
    }
  }

  Widget _buildCategorySelector() {
    return AlertDialog(
      title: const Text('Select Study Options'),
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            _loadQuestions();
          },
          child: const Text('Start Studying'),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(Question question, StudyState state) {
    return SingleChildScrollView(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: state.progress,
                backgroundColor: Colors.grey[300],
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              
              // Question text
              Text(
                question.questionText,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Options
              Column(
                children: question.options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  
                  Color? buttonColor;
                  if (state.selectedAnswerIndex == index) {
                    buttonColor = question.isAnswerCorrect(index)
                        ? Colors.green
                        : Colors.red;
                  } else if (state.showExplanation && question.isAnswerCorrect(index)) {
                    buttonColor = Colors.green;
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ElevatedButton(
                      onPressed: state.showExplanation
                          ? null
                          : () async => await _selectAnswer(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: buttonColor != null ? Colors.white : null,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(
                        option.text,
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
                const SizedBox(height: 20),
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
                          question.explanation,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              // Report Question Button
              if (state.showExplanation) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _reportQuestion(question),
                  icon: const Icon(Icons.flag, size: 16),
                  label: const Text('Report Question'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                  ),
                ),
              ],
              
              // Navigation buttons
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: state.isFirstQuestion ? null : _previousQuestion,
                    child: const Text('Previous'),
                  ),
                  ElevatedButton(
                    onPressed: state.showExplanation && !state.isLastQuestion
                        ? _nextQuestion
                        : null,
                    child: const Text('Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults(StudyState state) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.celebration, size: 64, color: Colors.green),
              const SizedBox(height: 16),
              Text(
                'Study Session Complete!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Score: ${state.correctAnswers}/${state.totalAnswered}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                'Accuracy: ${(state.accuracy * 100).toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  // Complete session and track gamification
                  final notifier = ref.read(studyProvider.notifier);
                  await notifier.completeSession();
                  
                  // Track gamification progress
                  if (state.questions.isNotEmpty) {
                    final category = state.questions.first.category;
                    ref.read(gamificationProvider.notifier).trackStudySessionComplete(
                      correctAnswers: state.correctAnswers,
                      totalQuestions: state.totalAnswered,
                      category: category,
                    );
                  }
                  
                  await _retrySession();
                },
                child: const Text('Try Again'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studyProvider);

    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Study Mode')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Study Mode')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(state.error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadQuestions,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Study Mode')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No questions available'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => _buildCategorySelector(),
                  );
                },
                child: const Text('Select Study Options'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Mode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => _buildCategorySelector(),
              );
            },
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.questions.length,
        itemBuilder: (context, index) {
          if (index == state.questions.length - 1 && state.showExplanation) {
            return _buildResults(state);
          }
          return _buildQuestionCard(state.questions[index], state);
        },
      ),
    );
  }
}