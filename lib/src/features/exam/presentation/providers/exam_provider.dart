import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/question.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/exam_timer_service.dart';
import '../../../../core/services/session_persistence_service.dart';
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
  final Map<String, int> userAnswers; // Track user answers for review (questionId -> selectedIndex)

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
    Map<String, int>? userAnswers,
  }) : userAnswers = userAnswers ?? {};

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
    Map<String, int>? userAnswers,
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
      userAnswers: userAnswers ?? this.userAnswers,
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
  ExamTimerService? _timerService;

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
    userAnswers: {},
  ));

  void _setupTimerListener() {
    _timerService?.timerStream.listen((remainingSeconds) {
      state = state.copyWith(timeRemainingSeconds: remainingSeconds);
      
      if (remainingSeconds <= 0 && !state.isCompleted) {
        _completeExam();
      }
    });
  }

  @override
  void dispose() {
    _timerService?.dispose();
    super.dispose();
  }

  Future<void> loadExamQuestions({
    String? category,
    int? learnerCode,
    int questionCount = 30, // Standard K53 exam has 30 questions
    MockExamConfig? mockExamConfig,
  }) async {
    state = state.copyWith(isLoading: true, error: null, mockExamConfig: mockExamConfig);

    // Calculate exam duration based on question count (1.5 minutes per question)
    final examDurationSeconds = (questionCount * 90).clamp(300, 7200); // Min 5 minutes, max 120 minutes

    try {
      final questions = await DatabaseService.getRandomQuestions(
        count: questionCount,
        category: category,
        learnerCode: learnerCode,
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

      // Initialize and start the exam timer
      _timerService?.dispose();
      _timerService = ExamTimerService(totalDurationSeconds: examDurationSeconds);
      _setupTimerListener();
      _timerService!.start();
      
      // Save initial session state
      await saveSessionState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load exam questions: $e',
      );
      _timerService?.dispose(); // Ensure timer is stopped on error
    }
  }

  Future<void> selectAnswer(int answerIndex) async {
    if (state.showExplanation || state.currentQuestion == null || state.isCompleted) return;

    final startTime = state.questionStartTimes[state.currentQuestion!.id] ?? DateTime.now().millisecondsSinceEpoch;
    final elapsedMs = DateTime.now().millisecondsSinceEpoch - startTime;
    final isCorrect = state.currentQuestion!.isAnswerCorrect(answerIndex);
    final newCorrectAnswers = isCorrect ? state.correctAnswers + 1 : state.correctAnswers;

    // Store the user's answer for review
    final newUserAnswers = Map<String, int>.from(state.userAnswers);
    newUserAnswers[state.currentQuestion!.id] = answerIndex;

    state = state.copyWith(
      selectedAnswerIndex: answerIndex,
      showExplanation: true,
      correctAnswers: newCorrectAnswers,
      totalAnswered: state.totalAnswered + 1,
      userAnswers: newUserAnswers,
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
      _timerService?.pause();
    } else {
      _timerService?.resume();
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
    _timerService?.dispose();
    state = state.copyWith(isCompleted: true);

    if (state.sessionId == null) {
      print('Exam completed without session ID - skipping database update');
      return;
    }

    try {
      final timeSpentSeconds = _timerService != null
          ? _timerService!.remainingSeconds > 0
            ? _timerService!.remainingSeconds
            : 0
          : 0;
      
      // Update session completion
      await DatabaseService.updateSession(
        sessionId: state.sessionId!,
        score: state.correctAnswers,
        timeSpentSeconds: timeSpentSeconds,
        isCompleted: true,
      );

      // Clear session persistence
      await SessionPersistenceService.clearExamSession();
      await _timerService?.clearExam();

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
    // Dispose of current timer
    _timerService?.dispose();

    // Recalculate exam duration based on current question count
    final examDurationSeconds = (state.questions.length * 90).clamp(300, 7200);

    state = ExamState(
      questions: state.questions,
      currentQuestionIndex: 0,
      isLoading: false,
      showExplanation: false,
      sessionId: state.sessionId,
      correctAnswers: 0,
      totalAnswered: 0,
      timeRemainingSeconds: examDurationSeconds,
      isPaused: false,
      isCompleted: false,
      questionStartTimes: {state.questions[0].id: DateTime.now().millisecondsSinceEpoch},
      mockExamConfig: state.mockExamConfig,
      userAnswers: {},
    );

    // Initialize and restart timer
    _timerService = ExamTimerService(totalDurationSeconds: examDurationSeconds);
    _setupTimerListener();
    _timerService!.start();

    // Save session state
    await saveSessionState();

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

  // Save current session state for persistence
  Future<void> saveSessionState() async {
    if (state.sessionId == null || state.questions.isEmpty) return;

    final sessionState = SessionState(
      type: SessionType.exam,
      questions: state.questions,
      currentQuestionIndex: state.currentQuestionIndex,
      selectedAnswerIndex: state.selectedAnswerIndex,
      showExplanation: state.showExplanation,
      sessionId: state.sessionId,
      correctAnswers: state.correctAnswers,
      totalAnswered: state.totalAnswered,
      userAnswers: state.userAnswers,
      additionalData: {
        'timeRemainingSeconds': state.timeRemainingSeconds,
        'isPaused': state.isPaused,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    await SessionPersistenceService.saveExamSession(sessionState);
  }

  // Load session state from persistence
  Future<void> loadSessionState(SessionState sessionState) async {
    state = ExamState(
      questions: sessionState.questions,
      currentQuestionIndex: sessionState.currentQuestionIndex,
      isLoading: false,
      selectedAnswerIndex: sessionState.selectedAnswerIndex,
      showExplanation: sessionState.showExplanation,
      sessionId: sessionState.sessionId,
      correctAnswers: sessionState.correctAnswers,
      totalAnswered: sessionState.totalAnswered,
      timeRemainingSeconds: sessionState.additionalData['timeRemainingSeconds'] ?? 45 * 60,
      isPaused: sessionState.additionalData['isPaused'] ?? false,
      isCompleted: false,
      questionStartTimes: {sessionState.questions[sessionState.currentQuestionIndex].id: DateTime.now().millisecondsSinceEpoch},
      mockExamConfig: null,
      userAnswers: sessionState.userAnswers,
    );

    // Initialize timer with remaining time
    final remainingSeconds = sessionState.additionalData['timeRemainingSeconds'] ?? 45 * 60;
    _timerService?.dispose();
    _timerService = ExamTimerService(totalDurationSeconds: remainingSeconds);
    _setupTimerListener();

    if (sessionState.additionalData['isPaused'] != true) {
      _timerService!.start();
    }
  }

  // Load mock exam with specific configuration
  Future<void> loadMockExamQuestions(MockExamConfig config) async {
    await loadExamQuestions(
      category: config.category,
      learnerCode: config.learnerCode,
      questionCount: config.questionCount,
      mockExamConfig: config,
    );
  }
}

final examProvider = StateNotifierProvider<ExamNotifier, ExamState>((ref) {
  return ExamNotifier();
});