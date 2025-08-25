import '../models/user_profile.dart';
import '../models/question.dart';
import './supabase_service.dart';

class DatabaseService {
  static final _client = SupabaseService.client;

  // User Profile Operations
  static Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromSupabase(response as Map<String, dynamic>);
    } catch (e) {
      // Profile might not exist yet, return null
      return null;
    }
  }

  static Future<void> updateUserProfile(UserProfile profile) async {
    await _client
        .from('profiles')
        .upsert(profile.toSupabase());
  }

  // Question Operations
  static Future<List<Question>> getQuestions({
    String? category,
    int? learnerCode,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // For simplicity, we'll use a basic query and filter in code
      // In production, you might want to use RPC functions or more advanced queries
      final response = await _client
          .from('questions')
          .select()
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final List<dynamic> data = response as List<dynamic>;
      List<Question> questions = data
          .map((item) => Question.fromSupabase(item as Map<String, dynamic>))
          .toList();

      // Filter in code for now (not ideal for large datasets)
      if (category != null) {
        questions = questions.where((q) => q.category == category).toList();
      }
      
      if (learnerCode != null) {
        questions = questions.where((q) => q.learnerCode == learnerCode).toList();
      }

      return questions.where((q) => q.isActive).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<Question?> getQuestionById(String questionId) async {
    try {
      final response = await _client
          .from('questions')
          .select()
          .eq('id', questionId)
          .eq('is_active', true)
          .single();

      return Question.fromSupabase(response as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  static Future<List<Question>> getRandomQuestions({
    required int count,
    String? category,
    int? learnerCode,
  }) async {
    try {
      // Get all questions and then shuffle (not ideal for production)
      final response = await _client
          .from('questions')
          .select();

      final List<dynamic> data = response as List<dynamic>;
      List<Question> questions = data
          .map((item) => Question.fromSupabase(item as Map<String, dynamic>))
          .toList();

      // Filter active questions
      questions = questions.where((q) => q.isActive).toList();

      // Apply filters
      if (category != null) {
        questions = questions.where((q) => q.category == category).toList();
      }
      
      if (learnerCode != null) {
        questions = questions.where((q) => q.learnerCode == learnerCode).toList();
      }

      // Shuffle and take requested count
      questions.shuffle();
      return questions.take(count).toList();
    } catch (e) {
      return [];
    }
  }

  // Session Operations
  static Future<Map<String, dynamic>?> createSession({
    required String userId,
    required String mode,
    String? category,
    int? totalQuestions,
  }) async {
    try {
      final sessionData = {
        'user_id': userId,
        'mode': mode,
        if (category != null) 'category': category,
        if (totalQuestions != null) 'total_questions': totalQuestions,
        'started_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('sessions')
          .insert(sessionData)
          .select()
          .single();

      return response as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateSession({
    required String sessionId,
    int? score,
    int? timeSpentSeconds,
    bool? isCompleted,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (score != null) updateData['score'] = score;
      if (timeSpentSeconds != null) {
        updateData['time_spent_seconds'] = timeSpentSeconds;
      }
      if (isCompleted != null) {
        updateData['is_completed'] = isCompleted;
        if (isCompleted) {
          updateData['completed_at'] = DateTime.now().toIso8601String();
        }
      }

      if (updateData.isNotEmpty) {
        await _client
            .from('sessions')
            .update(updateData)
            .eq('id', sessionId);
      }
    } catch (e) {
      // Handle error
    }
  }

  // Answer Operations
  static Future<void> recordAnswer({
    required String sessionId,
    required String questionId,
    required int chosenIndex,
    required bool isCorrect,
    required int elapsedMs,
    int hintsUsed = 0,
  }) async {
    try {
      final answerData = {
        'session_id': sessionId,
        'question_id': questionId,
        'chosen_index': chosenIndex,
        'is_correct': isCorrect,
        'elapsed_ms': elapsedMs,
        'hints_used': hintsUsed,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _client
          .from('answers')
          .insert(answerData);
    } catch (e) {
      // Handle error
    }
  }

  // Analytics and Statistics
  static Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      // Get total questions answered
      final answersResponse = await _client
          .from('answers')
          .select('is_correct')
          .eq('session_id.user_id', userId);

      int totalAnswers = 0;
      int correctAnswers = 0;

      final List<dynamic> answers = answersResponse as List<dynamic>;
      totalAnswers = answers.length;
      correctAnswers = answers
          .where((answer) => (answer as Map<String, dynamic>)['is_correct'] == true)
          .length;

      // Get total sessions
      final sessionsResponse = await _client
          .from('sessions')
          .select()
          .eq('user_id', userId);

      int totalSessions = (sessionsResponse as List<dynamic>).length;

      return {
        'totalAnswers': totalAnswers,
        'correctAnswers': correctAnswers,
        'accuracy': totalAnswers > 0 ? (correctAnswers / totalAnswers) * 100 : 0,
        'totalSessions': totalSessions,
      };
    } catch (e) {
      return {
        'totalAnswers': 0,
        'correctAnswers': 0,
        'accuracy': 0,
        'totalSessions': 0,
      };
    }
  }
}