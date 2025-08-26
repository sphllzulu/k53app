import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/question.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../gamification/presentation/providers/gamification_provider.dart';

class StudyState {
  final List<Question> questions;
  final int currentQuestionIndex;
  final bool isLoading;
  final String? error;
  final int? selectedAnswerIndex;
  final bool showExplanation;
  final String? sessionId;
  final int correctAnswers;
  final int totalAnswered;

  StudyState({
    required this.questions,
    required this.currentQuestionIndex,
    required this.isLoading,
    this.error,
    this.selectedAnswerIndex,
    required this.showExplanation,
    this.sessionId,
    required this.correctAnswers,
    required this.totalAnswered,
  });

  StudyState copyWith({
    List<Question>? questions,
    int? currentQuestionIndex,
    bool? isLoading,
    String? error,
    int? selectedAnswerIndex,
    bool? showExplanation,
    String? sessionId,
    int? correctAnswers,
    int? totalAnswered,
  }) {
    return StudyState(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedAnswerIndex: selectedAnswerIndex,
      showExplanation: showExplanation ?? this.showExplanation,
      sessionId: sessionId ?? this.sessionId,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalAnswered: totalAnswered ?? this.totalAnswered,
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
}

class StudyNotifier extends StateNotifier<StudyState> {
  StudyNotifier() : super(StudyState(
    questions: [],
    currentQuestionIndex: 0,
    isLoading: false,
    showExplanation: false,
    correctAnswers: 0,
    totalAnswered: 0,
  ));

  Future<void> loadQuestions({
    String? category,
    int? learnerCode,
    int limit = 10,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final questions = await DatabaseService.getRandomQuestions(
        count: limit,
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

      // Create a new study session
      final userId = SupabaseService.currentUserId;
      if (userId != null) {
        final session = await DatabaseService.createSession(
          userId: userId,
          mode: 'study',
          category: category,
          totalQuestions: questions.length,
        );

        if (session != null) {
          // Track session start in analytics
          await AnalyticsService.trackStudySessionStart(
            sessionId: session['id'],
            category: category ?? 'all',
            questionCount: questions.length,
          );
        }

        state = state.copyWith(
          questions: questions,
          isLoading: false,
          sessionId: session?['id'],
        );
      } else {
        state = state.copyWith(
          questions: questions,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load questions: $e',
      );
    }
  }

  Future<void> completeSession() async {
    if (state.sessionId == null || state.questions.isEmpty) return;

    try {
      // Update session completion in database
      await DatabaseService.updateSession(
        sessionId: state.sessionId!,
        score: state.correctAnswers,
        timeSpentSeconds: 0, // TODO: Implement timing
        isCompleted: true,
      );

      // Track gamification progress - this will be handled by the study screen
      // since we don't have access to the ref here
    } catch (e) {
      print('Error completing session: $e');
    }
  }

  Future<void> selectAnswer(int answerIndex) async {
    if (state.showExplanation || state.currentQuestion == null) return;

    final isCorrect = state.currentQuestion!.isAnswerCorrect(answerIndex);
    final newCorrectAnswers = isCorrect ? state.correctAnswers + 1 : state.correctAnswers;

    state = state.copyWith(
      selectedAnswerIndex: answerIndex,
      showExplanation: true,
      correctAnswers: newCorrectAnswers,
      totalAnswered: state.totalAnswered + 1,
    );

    // Record the answer in the database
    _recordAnswer(answerIndex, isCorrect);
    
    // Track in analytics
    if (state.sessionId != null && state.currentQuestion != null) {
      await AnalyticsService.trackQuestionAnswered(
        sessionId: state.sessionId!,
        questionId: state.currentQuestion!.id,
        isCorrect: isCorrect,
        elapsedMs: 0, // TODO: Implement timing
        hintsUsed: 0,
      );
    }
  }

  Future<void> _recordAnswer(int answerIndex, bool isCorrect) async {
    if (state.sessionId == null || state.currentQuestion == null) return;

    try {
      await DatabaseService.recordAnswer(
        sessionId: state.sessionId!,
        questionId: state.currentQuestion!.id,
        chosenIndex: answerIndex,
        isCorrect: isCorrect,
        elapsedMs: 0, // TODO: Implement timing
        hintsUsed: 0,
      );
    } catch (e) {
      // Silently fail - we don't want to disrupt the user experience
      print('Failed to record answer: $e');
    }
  }

  void nextQuestion() {
    if (state.isLastQuestion) return;

    state = state.copyWith(
      currentQuestionIndex: state.currentQuestionIndex + 1,
      selectedAnswerIndex: null,
      showExplanation: false,
    );
  }

  void previousQuestion() {
    if (state.isFirstQuestion) return;

    state = state.copyWith(
      currentQuestionIndex: state.currentQuestionIndex - 1,
      selectedAnswerIndex: null,
      showExplanation: false,
    );
  }

  void toggleExplanation() {
    state = state.copyWith(
      showExplanation: !state.showExplanation,
    );
  }

  Future<void> retrySession() async {
    state = StudyState(
      questions: state.questions,
      currentQuestionIndex: 0,
      isLoading: false,
      showExplanation: false,
      sessionId: state.sessionId,
      correctAnswers: 0,
      totalAnswered: 0,
    );
    
    // Track session retry
    await AnalyticsService.trackUserEngagement(
      eventName: 'study_session_retry',
      properties: {'question_count': state.questions.length},
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final studyProvider = StateNotifierProvider<StudyNotifier, StudyState>((ref) {
  return StudyNotifier();
});