import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/exam_provider.dart';
import '../../data/mock_exam_config.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/supabase_service.dart';

class MockExamSelectionScreen extends ConsumerWidget {
  const MockExamSelectionScreen({super.key});

  Widget _buildCategorySection(BuildContext context, WidgetRef ref, String title, List<MockExamConfig> configs, {int userLevel = 1}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...configs.map((config) => _buildExamCard(context, ref, config, userLevel: userLevel)),
          ],
        ),
      ),
    );
  }

  Widget _buildExamCard(BuildContext context, WidgetRef ref, MockExamConfig config, {int userLevel = 1}) {
    final canAccess = config.level <= userLevel;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: canAccess ? null : Colors.grey[100],
      child: ListTile(
        leading: Icon(
          config.level == 1 ? Icons.star_outline : Icons.star,
          color: canAccess
            ? (config.level == 1 ? Colors.green : Colors.blue)
            : Colors.grey,
        ),
        title: Text(
          config.title,
          style: TextStyle(
            color: canAccess ? null : Colors.grey,
          ),
        ),
        subtitle: Text(
          '${config.questionCount} questions • ${config.timeLimitMinutes} minutes • Level ${config.level}',
          style: TextStyle(
            color: canAccess ? Colors.grey : Colors.grey[400],
          ),
        ),
        trailing: canAccess
          ? const Icon(Icons.arrow_forward_ios, size: 16)
          : const Icon(Icons.lock, size: 16, color: Colors.grey),
        onTap: canAccess ? () => _startMockExam(ref, context, config) : null,
      ),
    );
  }

  void _startMockExam(WidgetRef ref, BuildContext context, MockExamConfig config) {
    final notifier = ref.read(examProvider.notifier);
    notifier.loadMockExamQuestions(config);
    context.go('/exam');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = SupabaseService.currentUserId;
    final userLevelFuture = userId != null
      ? DatabaseService.getUserMockExamLevel(userId)
      : Future.value(1);

    return FutureBuilder<int>(
      future: userLevelFuture,
      builder: (context, snapshot) {
        final userLevel = snapshot.data ?? 1;
        final allConfigs = MockExamConfig.allConfigs;
        
        // Group configs by category/type
        final allCategoryConfigs = allConfigs.where((config) => config.category == null).toList();
        final rulesConfigs = allConfigs.where((config) => config.category == 'rules_of_road').toList();
        final signsConfigs = allConfigs.where((config) => config.category == 'road_signs').toList();
        final controlsConfigs = allConfigs.where((config) => config.category == 'vehicle_controls').toList();

        // Filter configs accessible to user
        final accessibleConfigs = MockExamConfig.getConfigsForUserLevel(userLevel);

        return Scaffold(
          appBar: AppBar(
            title: Text(userLevel > 1 ? 'Mock Exams (Level $userLevel)' : 'Level 1 Mock Exams'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/dashboard'),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userLevel > 1 ? 'Choose a Mock Exam' : 'Choose a Level 1 Mock Exam',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  userLevel > 1
                    ? 'Level 2 exams feature medium difficulty questions. Complete Level 1 to unlock Level 2.'
                    : 'Level 1 exams feature easy difficulty questions to help you practice for your K53 learner\'s license test.',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // Level Progress Indicator
                if (userLevel == 1) ...[
                  Card(
                    color: Colors.orange[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_open, color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Complete Level 1 to unlock Level 2 exams with medium difficulty questions',
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // All Categories Section
                if (allCategoryConfigs.isNotEmpty) ...[
                  _buildCategorySection(context, ref, 'All Categories', allCategoryConfigs, userLevel: userLevel),
                  const SizedBox(height: 16),
                ],

                // Rules of the Road Section
                if (rulesConfigs.isNotEmpty) ...[
                  _buildCategorySection(context, ref, 'Rules of the Road', rulesConfigs, userLevel: userLevel),
                  const SizedBox(height: 16),
                ],

                // Road Signs Section
                if (signsConfigs.isNotEmpty) ...[
                  _buildCategorySection(context, ref, 'Road Signs', signsConfigs, userLevel: userLevel),
                  const SizedBox(height: 16),
                ],

                // Vehicle Controls Section
                if (controlsConfigs.isNotEmpty) ...[
                  _buildCategorySection(context, ref, 'Vehicle Controls', controlsConfigs, userLevel: userLevel),
                ],

                const SizedBox(height: 32),
                
                // Exam Information
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exam Information',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow('Passing Score', '70% or higher'),
                        _buildInfoRow('Question Count', '30 questions'),
                        _buildInfoRow('Time Limit', '45 minutes'),
                        _buildInfoRow('Your Current Level', 'Level $userLevel'),
                        if (userLevel == 1) _buildInfoRow('Next Level', 'Complete Level 1 to unlock Level 2'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}