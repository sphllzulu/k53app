import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/exam_provider.dart';
import '../../data/mock_exam_config.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/supabase_service.dart';

class MockExamSelectionScreen extends ConsumerWidget {
  const MockExamSelectionScreen({super.key});

  Widget _buildCategorySection(BuildContext context, WidgetRef ref, String title, List<MockExamConfig> configs) {
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
            ...configs.map((config) => _buildExamCard(context, ref, config)),
          ],
        ),
      ),
    );
  }

  Widget _buildExamCard(BuildContext context, WidgetRef ref, MockExamConfig config) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.quiz, color: Colors.blue),
        title: Text(config.title),
        subtitle: Text(
          '${config.questionCount} questions • ${config.timeLimitMinutes} minutes',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _startMockExam(ref, context, config),
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
    final allConfigs = MockExamConfig.allConfigs;
    
    // Group configs by category/type
    final allCategoryConfigs = allConfigs.where((config) => config.category == null).toList();
    final rulesConfigs = allConfigs.where((config) => config.category == 'rules_of_road').toList();
    final signsConfigs = allConfigs.where((config) => config.category == 'road_signs').toList();
    final controlsConfigs = allConfigs.where((config) => config.category == 'vehicle_controls').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mock Exams'),
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
            const Text(
              'Choose a Mock Exam',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Practice for your K53 learner\'s license test with realistic exam simulations.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // All Categories Section
            if (allCategoryConfigs.isNotEmpty) ...[
              _buildCategorySection(context, ref, 'All Categories', allCategoryConfigs),
              const SizedBox(height: 16),
            ],

            // Rules of the Road Section
            if (rulesConfigs.isNotEmpty) ...[
              _buildCategorySection(context, ref, 'Rules of the Road', rulesConfigs),
              const SizedBox(height: 16),
            ],

            // Road Signs Section
            if (signsConfigs.isNotEmpty) ...[
              _buildCategorySection(context, ref, 'Road Signs', signsConfigs),
              const SizedBox(height: 16),
            ],

            // Vehicle Controls Section
            if (controlsConfigs.isNotEmpty) ...[
              _buildCategorySection(context, ref, 'Vehicle Controls', controlsConfigs),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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