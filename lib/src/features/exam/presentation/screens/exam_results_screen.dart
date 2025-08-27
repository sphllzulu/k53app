import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/exam_provider.dart';
import '../../../gamification/presentation/providers/gamification_provider.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/share_service.dart';
import '../../../../core/models/referral.dart';
import '../../../../core/services/gamification_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/supabase_service.dart';

class ExamResultsScreen extends ConsumerStatefulWidget {
  const ExamResultsScreen({super.key});

  @override
  ConsumerState<ExamResultsScreen> createState() => _ExamResultsScreenState();
}

class _ExamResultsScreenState extends ConsumerState<ExamResultsScreen> {
  List<Map<String, dynamic>> _newAchievements = [];
  bool _showLevelUp = false;
  int _newLevel = 0;

  @override
  void initState() {
    super.initState();
    // Track results view in analytics and check for new achievements
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final examState = ref.read(examProvider);
      AnalyticsService.trackUserEngagement(
        eventName: 'exam_results_viewed',
        properties: {
          'score': examState.correctAnswers,
          'total_questions': examState.questions.length,
          'passed': examState.hasPassed,
          'accuracy': examState.accuracy,
        },
      );
      
      // Track gamification and check for new achievements
      _trackGamification(ref, examState);
      _checkForNewAchievements();
      _checkForLevelUp();
    });
  }

  Future<void> _checkForNewAchievements() async {
    try {
      final gamificationService = GamificationService();
      final userAchievements = await gamificationService.getUserAchievements();
      
      // Get only newly unlocked achievements (unlocked in the last few minutes)
      final now = DateTime.now();
      final newAchievements = userAchievements
          .where((ua) => ua.unlocked && ua.unlockedAt != null)
          .where((ua) => now.difference(ua.unlockedAt!).inMinutes < 5)
          .toList();

      if (newAchievements.isNotEmpty) {
        // Get achievement details
        final achievementDetails = <Map<String, dynamic>>[];
        for (final userAchievement in newAchievements) {
          final achievement = await DatabaseService.getAchievementById(userAchievement.achievementId);
          if (achievement != null) {
            achievementDetails.add({
              'name': achievement.name,
              'description': achievement.description,
              'points': achievement.points,
            });
          }
        }
        
        setState(() {
          _newAchievements = achievementDetails;
        });
      }
    } catch (e) {
      print('Error checking for new achievements: $e');
    }
  }

  Future<void> _checkForLevelUp() async {
    try {
      final gamificationService = GamificationService();
      final stats = await gamificationService.getUserStats();
      final currentLevel = stats['level'] as int;
      
      // Check if user leveled up recently
      final userProfile = await DatabaseService.getUserProfile(SupabaseService.currentUserId!);
      if (userProfile != null && userProfile.mockExamLevel > 1) {
        setState(() {
          _showLevelUp = true;
          _newLevel = userProfile.mockExamLevel;
        });
      }
    } catch (e) {
      print('Error checking for level up: $e');
    }
  }

  void _trackGamification(WidgetRef ref, ExamState examState) {
    final gamificationNotifier = ref.read(gamificationProvider.notifier);
    
    if (examState.questions.isNotEmpty) {
      final category = examState.questions.first.category;
      final hasPassed = examState.hasPassed;
      
      // Track exam completion for gamification
      gamificationNotifier.trackExamSessionComplete(
        correctAnswers: examState.correctAnswers,
        totalQuestions: examState.questions.length,
        category: category,
        passed: hasPassed,
      );
    }
  }

  Widget _buildScoreCard(BuildContext context, String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedBreakdown(BuildContext context, ExamState examState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow(context, 'Total Questions', examState.questions.length.toString()),
            _buildStatRow(context, 'Correct Answers', examState.correctAnswers.toString()),
            _buildStatRow(context, 'Incorrect Answers', (examState.questions.length - examState.correctAnswers).toString()),
            _buildStatRow(context, 'Accuracy', '${(examState.accuracy * 100).toStringAsFixed(1)}%'),
            _buildStatRow(context, 'Time Spent', _formatTime(45 * 60 - examState.timeRemainingSeconds)),
            _buildStatRow(context, 'Average Time per Question', _formatTime(examState.totalAnswered > 0 ? ((45 * 60 - examState.timeRemainingSeconds) / examState.totalAnswered).round() : 0)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  void _shareResults(BuildContext context, int score, int totalQuestions, double percentage) {
    final shareService = ShareService();
    final message = 'I scored $score/$totalQuestions (${percentage.toStringAsFixed(1)}%) on my K53 mock exam! '
                   'Download the app to practice for your learner\'s license.';
    
    final content = ShareContent(
      title: 'K53 Exam Results',
      message: message,
      deepLink: 'https://k53app.com/download?utm_source=exam_results&utm_medium=whatsapp',
    );
    
    shareService.shareViaWhatsApp(content);
  }

  @override
  Widget build(BuildContext context) {
    final examState = ref.watch(examProvider);

    // Calculate score and percentage
    final score = examState.correctAnswers;
    final totalQuestions = examState.questions.length;
    final percentage = (score / totalQuestions) * 100;
    final hasPassed = percentage >= 70; // K53 passing threshold

    // Determine result message and color
    final String resultMessage;
    final Color resultColor;
    
    if (hasPassed) {
      resultMessage = 'Congratulations! You passed!';
      resultColor = Colors.green;
    } else {
      resultMessage = 'Try again. You need 70% to pass.';
      resultColor = Colors.orange;
    }

    // Check if this was a mock exam with level progression
    final isMockExam = examState.mockExamConfig != null;
    final examLevel = examState.mockExamConfig?.level ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Results'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Result Icon
            Icon(
              hasPassed ? Icons.celebration : Icons.sentiment_dissatisfied,
              size: 80,
              color: resultColor,
            ),
            const SizedBox(height: 24),
            
            // Result Message
            Text(
              resultMessage,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: resultColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Score Display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildScoreCard(
                  context,
                  'Score',
                  '$score/$totalQuestions',
                  Colors.blue,
                ),
                _buildScoreCard(
                  context,
                  'Percentage',
                  '${percentage.toStringAsFixed(1)}%',
                  Colors.purple,
                ),
                _buildScoreCard(
                  context,
                  'Time',
                  _formatTime(examState.timeRemainingSeconds),
                  Colors.teal,
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Level Up Banner (if applicable)
            if (_showLevelUp && _newLevel > 1) ...[
              _buildLevelUpBanner(context),
              const SizedBox(height: 16),
            ],

            // New Achievements (if any)
            if (_newAchievements.isNotEmpty) ...[
              _buildAchievementsSection(context),
              const SizedBox(height: 16),
            ],

            // Detailed Breakdown
            _buildDetailedBreakdown(context, examState),
            const SizedBox(height: 32),
            
            // Level Progression Info for Mock Exams
            if (isMockExam && examLevel == 1 && hasPassed) ...[
              _buildLevelProgressionInfo(context),
              const SizedBox(height: 16),
            ],

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    ref.read(examProvider.notifier).retryExam();
                    context.go('/exam');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Try Again'),
                ),
                ElevatedButton(
                  onPressed: () => context.go('/dashboard'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Back to Dashboard'),
                ),
              ],
            ),
            
            // Share Button
            if (hasPassed) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  _shareResults(context, score, totalQuestions, percentage);
                },
                icon: const Icon(Icons.share),
                label: const Text('Share Results'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLevelUpBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, size: 40, color: Colors.amber),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level Up!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You\'ve advanced to Level $_newLevel! New mock exams are now available.',
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Achievements Unlocked!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._newAchievements.map((achievement) => ListTile(
              leading: const Icon(Icons.emoji_events, color: Colors.amber),
              title: Text(achievement['name']),
              subtitle: Text(achievement['description']),
              trailing: Chip(
                label: Text('+${achievement['points']} pts'),
                backgroundColor: Colors.green[100],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelProgressionInfo(BuildContext context) {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lock_open, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Level 1 Completed!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'You can now access Level 2 mock exams with medium difficulty questions. '
              'Keep practicing to improve your skills!',
              style: TextStyle(color: Colors.green[700]),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go('/exam/select'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Level 2 Exams'),
            ),
          ],
        ),
      ),
    );
  }
}