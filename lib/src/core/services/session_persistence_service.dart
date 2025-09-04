import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question.dart';

enum SessionType { study, exam }

class SessionState {
  final SessionType type;
  final List<Question> questions;
  final int currentQuestionIndex;
  final int? selectedAnswerIndex;
  final bool showExplanation;
  final String? sessionId;
  final int correctAnswers;
  final int totalAnswered;
  final Map<String, int> userAnswers;
  final Map<String, dynamic> additionalData;

  SessionState({
    required this.type,
    required this.questions,
    required this.currentQuestionIndex,
    this.selectedAnswerIndex,
    required this.showExplanation,
    this.sessionId,
    required this.correctAnswers,
    required this.totalAnswered,
    required this.userAnswers,
    this.additionalData = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'questions': questions.map((q) => q.toJson()).toList(),
      'currentQuestionIndex': currentQuestionIndex,
      'selectedAnswerIndex': selectedAnswerIndex,
      'showExplanation': showExplanation,
      'sessionId': sessionId,
      'correctAnswers': correctAnswers,
      'totalAnswered': totalAnswered,
      'userAnswers': userAnswers,
      'additionalData': additionalData,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory SessionState.fromJson(Map<String, dynamic> json) {
    return SessionState(
      type: SessionType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => SessionType.study,
      ),
      questions: (json['questions'] as List)
          .map((q) => Question.fromSupabase(q))
          .toList(),
      currentQuestionIndex: json['currentQuestionIndex'] ?? 0,
      selectedAnswerIndex: json['selectedAnswerIndex'],
      showExplanation: json['showExplanation'] ?? false,
      sessionId: json['sessionId'],
      correctAnswers: json['correctAnswers'] ?? 0,
      totalAnswered: json['totalAnswered'] ?? 0,
      userAnswers: Map<String, int>.from(json['userAnswers'] ?? {}),
      additionalData: Map<String, dynamic>.from(json['additionalData'] ?? {}),
    );
  }
}

class SessionPersistenceService {
  static const String _studySessionKey = 'active_study_session';
  static const String _examSessionKey = 'active_exam_session';

  static Future<void> saveStudySession(SessionState state) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(state.toJson());
    await prefs.setString(_studySessionKey, jsonString);
  }

  static Future<void> saveExamSession(SessionState state) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(state.toJson());
    await prefs.setString(_examSessionKey, jsonString);
  }

  static Future<SessionState?> loadStudySession() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_studySessionKey);
    
    if (jsonString != null) {
      try {
        final jsonData = json.decode(jsonString) as Map<String, dynamic>;
        return SessionState.fromJson(jsonData);
      } catch (e) {
        print('Error loading study session: $e');
        await clearStudySession();
      }
    }
    return null;
  }

  static Future<SessionState?> loadExamSession() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_examSessionKey);
    
    if (jsonString != null) {
      try {
        final jsonData = json.decode(jsonString) as Map<String, dynamic>;
        return SessionState.fromJson(jsonData);
      } catch (e) {
        print('Error loading exam session: $e');
        await clearExamSession();
      }
    }
    return null;
  }

  static Future<void> clearStudySession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_studySessionKey);
  }

  static Future<void> clearExamSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_examSessionKey);
  }

  static Future<bool> hasActiveStudySession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_studySessionKey);
  }

  static Future<bool> hasActiveExamSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_examSessionKey);
  }

  static Future<SessionState?> getActiveSession() async {
    final studySession = await loadStudySession();
    if (studySession != null) return studySession;
    
    final examSession = await loadExamSession();
    if (examSession != null) return examSession;
    
    return null;
  }

  static Future<bool> hasAnyActiveSession() async {
    return await hasActiveStudySession() || await hasActiveExamSession();
  }

  // Check if session is still valid (not too old)
  static bool isSessionValid(SessionState session) {
    final timestamp = session.additionalData['timestamp'];
    if (timestamp == null) return true;
    
    final sessionTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(sessionTime);
    
    // Consider session valid for up to 24 hours
    return difference.inHours < 24;
  }

  // Session metadata for recovery dialog
  static Map<String, dynamic> getSessionMetadata(SessionState session) {
    return {
      'type': session.type,
      'progress': session.currentQuestionIndex + 1,
      'totalQuestions': session.questions.length,
      'score': '${session.correctAnswers}/${session.totalAnswered}',
      'category': session.questions.isNotEmpty ? session.questions.first.category : 'Unknown',
      'timestamp': session.additionalData['timestamp'],
    };
  }
}