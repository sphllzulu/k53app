import '../models/achievement.dart';
import './database_service.dart';
import './supabase_service.dart';

class GamificationService {
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();

  // Track user progress for different achievement types
  Future<void> trackProgress({
    required AchievementType type,
    required int value,
    String? userId,
  }) async {
    final currentUserId = userId ?? SupabaseService.currentUserId;
    if (currentUserId == null) return;

    try {
      // Get all achievements of this type
      final achievements = await DatabaseService.getAchievementsByType(type);
      
      for (final achievement in achievements) {
        // Check if user already has this achievement
        final userAchievement = await DatabaseService.getUserAchievement(
          userId: currentUserId,
          achievementId: achievement.id,
        );

        if (userAchievement != null && userAchievement.unlocked) {
          continue; // Already unlocked
        }

        // Calculate new progress
        final newProgress = (userAchievement?.progress ?? 0) + value;
        
        if (newProgress >= achievement.targetValue) {
          // Unlock achievement
          await DatabaseService.unlockAchievement(
            userId: currentUserId,
            achievementId: achievement.id,
            progress: achievement.targetValue,
          );
          
          // Track achievement unlock in analytics
          await DatabaseService.trackAchievementUnlocked(
            userId: currentUserId,
            achievementId: achievement.id,
          );
        } else {
          // Update progress
          await DatabaseService.updateAchievementProgress(
            userId: currentUserId,
            achievementId: achievement.id,
            progress: newProgress,
          );
        }
      }
    } catch (e) {
      print('Error tracking progress: $e');
    }
  }

  // Track study session completion
  Future<void> trackStudySessionComplete({
    required int correctAnswers,
    required int totalQuestions,
    required String category,
  }) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    try {
      // Track accuracy achievement
      final accuracy = totalQuestions > 0 ? correctAnswers / totalQuestions : 0;
      if (accuracy >= 0.8) {
        await trackProgress(
          type: AchievementType.accuracy,
          value: 1,
          userId: userId,
        );
      }

      // Track completion achievement (every session counts)
      await trackProgress(
        type: AchievementType.completion,
        value: 1,
        userId: userId,
      );

      // Track category-specific achievements
      if (category.isNotEmpty && category != 'all') {
        await trackProgress(
          type: AchievementType.completion,
          value: 1,
          userId: userId,
        );
      }
    } catch (e) {
      print('Error tracking study session: $e');
    }
  }

  // Track daily login streak
  Future<void> trackDailyLogin() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    try {
      final lastLogin = await DatabaseService.getLastLogin(userId);
      final now = DateTime.now();
      
      if (lastLogin == null || 
          now.difference(lastLogin).inHours >= 20) { // Allow 4-hour grace period
        // Reset or increment streak
        final currentStreak = await DatabaseService.getLoginStreak(userId);
        final newStreak = (lastLogin != null && 
                          now.difference(lastLogin).inHours <= 28) 
            ? currentStreak + 1 
            : 1;
        
        await DatabaseService.updateLoginStreak(userId, newStreak);
        
        // Track streak achievements
        await trackProgress(
          type: AchievementType.streak,
          value: newStreak,
          userId: userId,
        );
      }
    } catch (e) {
      print('Error tracking daily login: $e');
    }
  }

  // Get user achievements
  Future<List<UserAchievement>> getUserAchievements() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return [];

    try {
      return await DatabaseService.getUserAchievements(userId);
    } catch (e) {
      print('Error getting user achievements: $e');
      return [];
    }
  }

  // Get user points and level
  Future<Map<String, dynamic>> getUserStats() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return {'points': 0, 'level': 1};

    try {
      final userAchievements = await getUserAchievements();
      // We need to fetch the actual achievements to get their point values
      final unlockedAchievements = userAchievements.where((ua) => ua.unlocked);
      
      // For now, return basic stats - we'll implement proper point calculation later
      // when we have the actual achievement data
      final totalPoints = unlockedAchievements.length * 10; // Placeholder
      
      final level = _calculateLevel(totalPoints);
      
      return {
        'points': totalPoints,
        'level': level,
        'next_level_points': _pointsForLevel(level + 1),
        'unlocked_achievements': unlockedAchievements.length,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return {'points': 0, 'level': 1, 'unlocked_achievements': 0};
    }
  }

  int _calculateLevel(int points) {
    if (points < 100) return 1;
    if (points < 300) return 2;
    if (points < 600) return 3;
    if (points < 1000) return 4;
    if (points < 1500) return 5;
    if (points < 2100) return 6;
    if (points < 2800) return 7;
    if (points < 3600) return 8;
    if (points < 4500) return 9;
    return 10;
  }

  int _pointsForLevel(int level) {
    return level * (level + 1) * 50; // Quadratic progression
  }
}