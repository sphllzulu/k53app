import '../models/user_profile.dart';
import '../models/question.dart';
import '../models/achievement.dart';
import '../models/referral.dart';
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
    String? difficulty,
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

      // Filter by difficulty if specified
      if (difficulty != null) {
        int? level;
        switch (difficulty) {
          case 'easy':
            level = 1;
            break;
          case 'medium':
            level = 2;
            break;
          case 'hard':
            level = 3;
            break;
          default:
            level = null;
        }
        if (level != null) {
          questions = questions.where((q) => q.difficultyLevel == level).toList();
        }
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

  // Gamification Operations
  static Future<List<Achievement>> getAchievementsByType(AchievementType type) async {
    try {
      final response = await _client
          .from('achievements')
          .select()
          .eq('type', type.toString().split('.').last);

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((item) => Achievement.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<UserAchievement?> getUserAchievement({
    required String userId,
    required String achievementId,
  }) async {
    try {
      final response = await _client
          .from('user_achievements')
          .select()
          .eq('user_id', userId)
          .eq('achievement_id', achievementId)
          .single();

      return UserAchievement.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  static Future<Achievement?> getAchievementById(String achievementId) async {
    try {
      final response = await _client
          .from('achievements')
          .select()
          .eq('id', achievementId)
          .single();

      return Achievement.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error getting achievement by ID: $e');
      return null;
    }
  }

  static Future<void> unlockAchievement({
    required String userId,
    required String achievementId,
    required int progress,
  }) async {
    try {
      final achievementData = {
        'user_id': userId,
        'achievement_id': achievementId,
        'progress': progress,
        'unlocked': true,
        'unlocked_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client
          .from('user_achievements')
          .upsert(achievementData, onConflict: 'user_id,achievement_id');
    } catch (e) {
      print('Error unlocking achievement: $e');
    }
  }

  static Future<void> updateAchievementProgress({
    required String userId,
    required String achievementId,
    required int progress,
  }) async {
    try {
      await _client
          .from('user_achievements')
          .update({
            'progress': progress,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('achievement_id', achievementId);
    } catch (e) {
      print('Error updating achievement progress: $e');
    }
  }

  static Future<void> trackAchievementUnlocked({
    required String userId,
    required String achievementId,
  }) async {
    try {
      await _client
          .from('achievement_events')
          .insert({
            'user_id': userId,
            'achievement_id': achievementId,
            'unlocked_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      print('Error tracking achievement unlock: $e');
    }
  }

  static Future<DateTime?> getLastLogin(String userId) async {
    try {
      final response = await _client
          .from('login_events')
          .select('login_time')
          .eq('user_id', userId)
          .order('login_time', ascending: false)
          .limit(1)
          .single();

      return DateTime.parse((response as Map<String, dynamic>)['login_time']);
    } catch (e) {
      return null;
    }
  }

  static Future<int> getLoginStreak(String userId) async {
    try {
      final response = await _client
          .from('user_stats')
          .select('login_streak')
          .eq('user_id', userId)
          .single();

      return (response as Map<String, dynamic>)['login_streak'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  static Future<void> updateLoginStreak(String userId, int streak) async {
    try {
      await _client
          .from('user_stats')
          .upsert({
            'user_id': userId,
            'login_streak': streak,
            'last_login': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'user_id');
    } catch (e) {
      print('Error updating login streak: $e');
      }
    }
  
    // Referral Operations
    static Future<void> trackReferralShare(String userId) async {
      try {
        await _client
            .from('referral_events')
            .insert({
              'user_id': userId,
              'event_type': 'share',
              'created_at': DateTime.now().toIso8601String(),
            });
      } catch (e) {
        print('Error tracking referral share: $e');
      }
    }
  
    static Future<void> trackShareEvent({
      required String userId,
      required String platform,
      required String contentType,
      required bool success,
    }) async {
      try {
        await _client
            .from('share_events')
            .insert({
              'user_id': userId,
              'platform': platform,
              'content_type': contentType,
              'success': success,
              'created_at': DateTime.now().toIso8601String(),
            });
      } catch (e) {
        print('Error tracking share event: $e');
      }
    }
  
    static Future<Referral?> createReferral({
      required String referrerId,
      required String referredEmail,
    }) async {
      try {
        final referralData = {
          'referrer_id': referrerId,
          'referred_email': referredEmail,
          'status': 'pending',
          'created_at': DateTime.now().toIso8601String(),
        };
  
        final response = await _client
            .from('referrals')
            .insert(referralData)
            .select()
            .single();
  
        return Referral.fromJson(response as Map<String, dynamic>);
      } catch (e) {
        print('Error creating referral: $e');
        return null;
      }
    }
  
    static Future<void> trackReferralCompletion(String referralId) async {
      try {
        await _client
            .from('referrals')
            .update({
              'status': 'completed',
              'completed_at': DateTime.now().toIso8601String(),
              'points_awarded': 50, // 50 points for successful referral
            })
            .eq('id', referralId);
      } catch (e) {
        print('Error tracking referral completion: $e');
      }
    }
  
    static Future<Map<String, dynamic>> getReferralStats(String userId) async {
      try {
        // Get total referrals - handle case where referrer_id column might not exist
        List<dynamic> referrals = [];
        try {
          final referralsResponse = await _client
              .from('referrals')
              .select()
              .eq('referrer_id', userId);

          referrals = referralsResponse as List<dynamic>;
        } catch (e) {
          // Column might not exist, return empty stats
          print('Referral column error (referrer_id might not exist): $e');
          return {
            'totalReferrals': 0,
            'completedReferrals': 0,
            'pendingReferrals': 0,
            'totalPoints': 0,
          };
        }

        final totalReferrals = referrals.length;
        final completedReferrals = referrals
            .where((ref) => (ref as Map<String, dynamic>)['status'] == 'completed')
            .length;

        // Get total points from referrals
        final totalPoints = referrals.fold(0, (sum, ref) {
          final points = (ref as Map<String, dynamic>)['points_awarded'] as int? ?? 0;
          return sum + points;
        });

        return {
          'totalReferrals': totalReferrals,
          'completedReferrals': completedReferrals,
          'pendingReferrals': totalReferrals - completedReferrals,
          'totalPoints': totalPoints,
        };
      } catch (e) {
        print('Error getting referral stats: $e');
        return {
          'totalReferrals': 0,
          'completedReferrals': 0,
          'pendingReferrals': 0,
          'totalPoints': 0,
        };
      }
    }
  
    static Future<List<Referral>> getUserReferrals(String userId) async {
      try {
        List<dynamic> data = [];
        try {
          final response = await _client
              .from('referrals')
              .select()
              .eq('referrer_id', userId)
              .order('created_at', ascending: false);

          data = response as List<dynamic>;
        } catch (e) {
          // Column might not exist, return empty list
          print('Referral column error (referrer_id might not exist): $e');
          return [];
        }
        
        return data
            .map((item) => Referral.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print('Error getting user referrals: $e');
        return [];
      }
    }

  static Future<List<UserAchievement>> getUserAchievements(String userId) async {
    try {
      final response = await _client
          .from('user_achievements')
          .select('*, achievements(*)')
          .eq('user_id', userId);

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((item) => UserAchievement.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}