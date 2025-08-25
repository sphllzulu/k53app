import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k53app/src/core/services/gamification_service.dart';

class GamificationState {
  final int points;
  final int level;
  final int nextLevelPoints;
  final int unlockedAchievements;
  final bool isLoading;
  final String? error;

  GamificationState({
    required this.points,
    required this.level,
    required this.nextLevelPoints,
    required this.unlockedAchievements,
    required this.isLoading,
    this.error,
  });

  GamificationState copyWith({
    int? points,
    int? level,
    int? nextLevelPoints,
    int? unlockedAchievements,
    bool? isLoading,
    String? error,
  }) {
    return GamificationState(
      points: points ?? this.points,
      level: level ?? this.level,
      nextLevelPoints: nextLevelPoints ?? this.nextLevelPoints,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class GamificationNotifier extends StateNotifier<GamificationState> {
  GamificationNotifier() : super(GamificationState(
    points: 0,
    level: 1,
    nextLevelPoints: 100,
    unlockedAchievements: 0,
    isLoading: false,
  ));

  Future<void> loadUserStats() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final stats = await GamificationService().getUserStats();
      
      state = state.copyWith(
        points: stats['points'] ?? 0,
        level: stats['level'] ?? 1,
        nextLevelPoints: stats['next_level_points'] ?? 100,
        unlockedAchievements: stats['unlocked_achievements'] ?? 0,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load gamification stats: $e',
      );
    }
  }

  Future<void> trackStudySessionComplete({
    required int correctAnswers,
    required int totalQuestions,
    required String category,
  }) async {
    try {
      await GamificationService().trackStudySessionComplete(
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        category: category,
      );
      
      // Reload stats after tracking
      await loadUserStats();
    } catch (e) {
      print('Error tracking study session: $e');
    }
  }

  Future<void> trackDailyLogin() async {
    try {
      await GamificationService().trackDailyLogin();
      await loadUserStats();
    } catch (e) {
      print('Error tracking daily login: $e');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final gamificationProvider = StateNotifierProvider<GamificationNotifier, GamificationState>((ref) {
  return GamificationNotifier();
});