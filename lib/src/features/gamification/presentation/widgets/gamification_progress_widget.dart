import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/gamification_provider.dart';

class GamificationProgressWidget extends ConsumerWidget {
  const GamificationProgressWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gamificationProvider);
    
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.read(gamificationProvider.notifier).loadUserStats(),
                  iconSize: 18,
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Level and Points
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  icon: Icons.star,
                  value: 'Level ${state.level}',
                  label: 'Current Level',
                ),
                _buildStatItem(
                  context,
                  icon: Icons.emoji_events,
                  value: '${state.points}',
                  label: 'Points',
                ),
                _buildStatItem(
                  context,
                  icon: Icons.verified,
                  value: '${state.unlockedAchievements}',
                  label: 'Achievements',
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Progress to next level
            Text(
              'Progress to Level ${state.level + 1}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: state.nextLevelPoints > 0 
                  ? state.points / state.nextLevelPoints 
                  : 0,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
            ),
            const SizedBox(height: 4),
            Text(
              '${state.points}/${state.nextLevelPoints} points',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}