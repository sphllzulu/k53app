import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/question.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../gamification/presentation/providers/gamification_provider.dart';
import '../../data/mock_exam_config.dart';

class ExamState {
  final List<Question> questions;
  final int currentQuestionIndex;
  final bool isLoading;
  final String? error;
  final int? selectedAnswerIndex;
  final bool showExplanation;
  final String? sessionId;
  final int correctAnswers;
  final int totalAnswered;
  final int timeRemainingSeconds;
  final bool isPaused;
  final bool isCompleted;
  final Map<String, int> questionStartTimes; // Track when each question was shown
  final MockExamConfig? mockExamConfig; // Track if this is a mock exam and which config

  ExamState({
    required this.questions,
    required this.currentQuestionIndex,
    required this.isLoading,
    this.error,
    this.selectedAnswerIndex,
    required this.showExplanation,
    this.sessionId,
    required this.correctAnswers,
    required this.totalAnswered,
    required this.timeRemainingSeconds,
    required this.isPaused,
    required this.isCompleted,
    required this.questionStartTimes,
    this.mockExamConfig,
  });

  ExamState copyWith({
    List<Question>? questions,
    int? currentQuestionIndex,
    bool? isLoading,
    String? error,
    int? selectedAnswerIndex,
    bool? showExplanation,
    String? sessionId,
    int? correctAnswers,
    int? totalAnswered,
    int? timeRemainingSeconds,
    bool? isPaused,
    bool? isCompleted,
    Map<String, int>? questionStartTimes,
    MockExamConfig? mockExamConfig,
  }) {
    return ExamState(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedAnswerIndex: selectedAnswerIndex,
      showExplanation: showExplanation ?? this.showExplanation,
      sessionId: sessionId ?? this.sessionId,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalAnswered: totalAnswered ?? this.totalAnswered,
      timeRemainingSeconds: timeRemainingSeconds ?? this.timeRemainingSeconds,
      isPaused: isPaused ?? this.isPaused,
      isCompleted: isCompleted ?? this.isCompleted,
      questionStartTimes: questionStartTimes ?? this.questionStartTimes,
      mockExamConfig: mockExamConfig ?? this.mockExamConfig,
    );
  }

  Question? get currentQuestion {
    if (currentQuestionIndex >= 0 && currentQuestionIndex < questions.length) {
      return questions[currentQuestionIndex];
    }
    return null;
  }

  bool get isLastQuestion => currentQuestionIndex == questions.length - 1;
  bool get isFirstQuestion => currentQuestionIndex == 0;
  double get progress => questions.isEmpty ? 0 : (currentQuestionIndex + 1) / questions.length;
  double get accuracy => totalAnswered == 0 ? 0 : correctAnswers / totalAnswered;
  bool get hasPassed => accuracy >= 0.7; // K53 passing threshold (70%)
  String get formattedTime {
    final minutes = (timeRemainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (timeRemainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class ExamNotifier extends StateNotifier<ExamState> {
  Timer? _timer;
  int _examDurationSeconds = 45 * 60; // Default 45 minutes for 30 questions
  DateTime? _examStartTime;
  DateTime? _lastPauseTime;
  int _totalPausedDuration = 0;

  ExamNotifier() : super(ExamState(
    questions: [],
    currentQuestionIndex: 0,
    isLoading: false,
    showExplanation: false,
    correctAnswers: 0,
    totalAnswered: 0,
    timeRemainingSeconds: 45 * 60,
    isPaused: false,
    isCompleted: false,
    questionStartTimes: {},
    mockExamConfig: null,
  ));

  void _startTimer() {
    _timer?.cancel();
    _examStartTime ??= DateTime.now();
    
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!state.isPaused && !state.isCompleted) {
        final elapsed = DateTime.now().difference(_examStartTime!).inSeconds - _totalPausedDuration;
        final remaining = _examDurationSeconds - elapsed;
        
        if (remaining <= 0) {
          state = state.copyWith(timeRemainingSeconds: 0);
          _completeExam();
          _stopTimer();
        } else if (state.timeRemainingSeconds != remaining) {
          state = state.copyWith(timeRemainingSeconds: remaining);
        }
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _updatePauseState() {
    if (state.isPaused) {
      _lastPauseTime = DateTime.now();
    } else if (_lastPauseTime != null) {
      _totalPausedDuration += DateTime.now().difference(_lastPauseTime!).inSeconds;
      _lastPauseTime = null;
    }
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  Future<void> loadExamQuestions({
    String? category,
    int? learnerCode,
    String? difficulty,
    int questionCount = 30, // Standard K53 exam has 30 questions
    MockExamConfig? mockExamConfig,
  }) async {
    state = state.copyWith(isLoading: true, error: null, mockExamConfig: mockExamConfig);

    // Calculate exam duration based on question count (1.5 minutes per question)
    _examDurationSeconds = (questionCount * 90).clamp(300, 7200); // Min 5 minutes, max 120 minutes

    try {
      final questions = await DatabaseService.getRandomQuestions(
        count: questionCount,
        category: category,
        learnerCode: learnerCode,
        difficulty: difficulty,
      );

      if (questions.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'No questions available for the selected criteria',
        );
        return;
      }

      // Create a new exam session
      final userId = SupabaseService.currentUserId;
      if (userId != null) {
        final session = await DatabaseService.createSession(
          userId: userId,
          mode: 'mock_exam',
          category: category,
          totalQuestions: questions.length,
        );

        if (session != null) {
          await AnalyticsService.trackExamSessionStart(
            sessionId: session['id'],
            category: category ?? 'all',
            timeLimitMinutes: 45, // K53 exam is 45 minutes
          );
        }

        state = state.copyWith(
          questions: questions,
          isLoading: false,
          sessionId: session?['id'],
          questionStartTimes: {questions[0].id: DateTime.now().millisecondsSinceEpoch},
        );
      } else {
        state = state.copyWith(
          questions: questions,
          isLoading: false,
          questionStartTimes: {questions[0].id: DateTime.now().millisecondsSinceEpoch},
        );
      }

      // Start the exam timer
      _startTimer();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load exam questions: $e',
      );
      _stopTimer(); // Ensure timer is stopped on error
    }
  }

  Future<void> selectAnswer(int answerIndex) async {
    if (state.showExplanation || state.currentQuestion == null || state.isCompleted) return;

    final startTime = state.questionStartTimes[state.currentQuestion!.id] ?? DateTime.now().millisecondsSinceEpoch;
    final elapsedMs = DateTime.now().millisecondsSinceEpoch - startTime;
    final isCorrect = state.currentQuestion!.isAnswerCorrect(answerIndex);
    final newCorrectAnswers = isCorrect ? state.correctAnswers + 1 : state.correctAnswers;

    state = state.copyWith(
      selectedAnswerIndex: answerIndex,
      showExplanation: true,
      correctAnswers: newCorrectAnswers,
      totalAnswered: state.totalAnswered + 1,
    );

    // Record the answer with timing
    await _recordAnswer(answerIndex, isCorrect, elapsedMs);
    
    // Track in analytics
    if (state.sessionId != null && state.currentQuestion != null) {
      await AnalyticsService.trackQuestionAnswered(
        sessionId: state.sessionId!,
        questionId: state.currentQuestion!.id,
        isCorrect: isCorrect,
        elapsedMs: elapsedMs,
        hintsUsed: 0,
      );
    }

    // Auto-advance to next question after 2 seconds for exam flow
    if (!state.isLastQuestion) {
      await Future.delayed(const Duration(seconds: 2));
      nextQuestion();
    } else {
      // Last question answered, complete the exam
      await _completeExam();
    }
  }

  Future<void> _recordAnswer(int answerIndex, bool isCorrect, int elapsedMs) async {
    if (state.sessionId == null || state.currentQuestion == null) return;

    try {
      await DatabaseService.recordAnswer(
        sessionId: state.sessionId!,
        questionId: state.currentQuestion!.id,
        chosenIndex: answerIndex,
        isCorrect: isCorrect,
        elapsedMs: elapsedMs,
        hintsUsed: 0,
      );
    } catch (e) {
      print('Failed to record answer: $e');
      // Optionally, we could retry or store locally for later sync
    }
  }

  void nextQuestion() {
    if (state.isLastQuestion || state.isCompleted) return;

    final newIndex = state.currentQuestionIndex + 1;
    final newQuestion = state.questions[newIndex];
    
    state = state.copyWith(
      currentQuestionIndex: newIndex,
      selectedAnswerIndex: null,
      showExplanation: false,
      questionStartTimes: {
        ...state.questionStartTimes,
        newQuestion.id: DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  void previousQuestion() {
    if (state.isFirstQuestion || state.isCompleted) return;

    final newIndex = state.currentQuestionIndex - 1;
    final newQuestion = state.questions[newIndex];
    
    state = state.copyWith(
      currentQuestionIndex: newIndex,
      selectedAnswerIndex: null,
      showExplanation: false,
      questionStartTimes: {
        ...state.questionStartTimes,
        newQuestion.id: DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  void togglePause() {
    if (state.isCompleted) return;

    final newPausedState = !state.isPaused;
    state = state.copyWith(isPaused: newPausedState);

    if (newPausedState) {
      _stopTimer();
      _lastPauseTime = DateTime.now();
    } else {
      if (_lastPauseTime != null) {
        _totalPausedDuration += DateTime.now().difference(_lastPauseTime!).inSeconds;
        _lastPauseTime = null;
      }
      _startTimer();
    }

    // Track pause/resume event
    AnalyticsService.trackUserEngagement(
      eventName: newPausedState ? 'exam_paused' : 'exam_resumed',
      properties: {
        'session_id': state.sessionId,
        'time_remaining': state.timeRemainingSeconds,
      },
    );
  }

  Future<void> _completeExam() async {
    if (state.isCompleted) return;
    
    // Stop timer immediately to prevent further state changes
    _stopTimer();
    state = state.copyWith(isCompleted: true);

    if (state.sessionId == null) {
      print('Exam completed without session ID - skipping database update');
      return;
    }

    try {
      final timeSpentSeconds = _examDurationSeconds - state.timeRemainingSeconds;
      
      // Update session completion
      await DatabaseService.updateSession(
        sessionId: state.sessionId!,
        score: state.correctAnswers,
        timeSpentSeconds: timeSpentSeconds,
        isCompleted: true,
      );

      // Track exam completion in analytics
      await AnalyticsService.trackExamSessionComplete(
        sessionId: state.sessionId!,
        score: state.correctAnswers,
        totalQuestions: state.questions.length,
        passed: state.hasPassed,
        timeSpentSeconds: timeSpentSeconds,
      );

      // Track gamification progress
      if (state.questions.isNotEmpty) {
        final category = state.questions.first.category;
        // This will be handled by the exam screen using the ref
      }
    } catch (e) {
      print('Error completing exam: $e');
      // Even if database update fails, we keep the state as completed
      // to prevent multiple submissions
    }
  }

  Future<void> retryExam() async {
    // Reset timer-related variables
    _examStartTime = null;
    _lastPauseTime = null;
    _totalPausedDuration = 0;

    // Recalculate exam duration based on current question count
    _examDurationSeconds = (state.questions.length * 90).clamp(300, 7200);

    state = ExamState(
      questions: state.questions,
      currentQuestionIndex: 0,
      isLoading: false,
      showExplanation: false,
      sessionId: state.sessionId,
      correctAnswers: 0,
      totalAnswered: 0,
      timeRemainingSeconds: _examDurationSeconds,
      isPaused: false,
      isCompleted: false,
      questionStartTimes: {state.questions[0].id: DateTime.now().millisecondsSinceEpoch},
      mockExamConfig: state.mockExamConfig,
    );

    // Restart timer
    _stopTimer();
    _startTimer();

    await AnalyticsService.trackUserEngagement(
      eventName: 'exam_retry',
      properties: {'question_count': state.questions.length},
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // Handle app lifecycle events (e.g., when app goes to background)
  void onPause() {
    if (!state.isPaused && !state.isCompleted) {
      togglePause();
    }
  }

  void onResume() {
    if (state.isPaused && !state.isCompleted) {
      togglePause();
    }
  }

  // Load mock exam with specific configuration
  Future<void> loadMockExamQuestions(MockExamConfig config) async {
    await loadExamQuestions(
      category: config.category,
      learnerCode: config.learnerCode,
      difficulty: 'easy', // Level 1 uses easy difficulty
      questionCount: config.questionCount,
      mockExamConfig: config,
    );
  }
}

final examProvider = StateNotifierProvider<ExamNotifier, ExamState>((ref) {
  return ExamNotifier();
});