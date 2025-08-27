import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/analytics_service.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  List<Map<String, dynamic>> _examSessions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExamSessions();
    
    // Track progress screen view
    AnalyticsService.trackUserEngagement(
      eventName: 'progress_screen_viewed',
      properties: {},
    );
  }

  Future<void> _loadExamSessions() async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) {
        setState(() {
          _isLoading = false;
          _error = 'User not logged in';
        });
        return;
      }

      final sessions = await DatabaseService.getUserExamSessions(userId);
      setState(() {
        _examSessions = sessions;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load progress data: $e';
      });
    }
  }

  Widget _buildStatsCard(BuildContext context) {
    final totalSessions = _examSessions.length;
    final passedSessions = _examSessions.where((session) {
      final score = session['score'] as int? ?? 0;
      final totalQuestions = session['total_questions'] as int? ?? 1;
      return (score / totalQuestions) >= 0.7;
    }).length;

    final averageScore = totalSessions > 0
        ? _examSessions.fold(0.0, (sum, session) {
            final score = session['score'] as int? ?? 0;
            final totalQuestions = session['total_questions'] as int? ?? 1;
            return sum + (score / totalQuestions * 100);
          }) / totalSessions
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Overall Progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, 'Total Attempts', totalSessions.toString()),
                _buildStatItem(context, 'Passed', '$passedSessions/$totalSessions'),
                _buildStatItem(context, 'Avg Score', '${averageScore.toStringAsFixed(1)}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildSessionList(BuildContext context) {
    if (_examSessions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.assignment, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No exam attempts yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Complete a mock exam to see your progress here',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/exam/select'),
                child: const Text('Take a Mock Exam'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Exam Attempts',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _examSessions.length,
          itemBuilder: (context, index) {
            final session = _examSessions[index];
            return _buildSessionItem(context, session);
          },
        ),
      ],
    );
  }

  Widget _buildSessionItem(BuildContext context, Map<String, dynamic> session) {
    final score = session['score'] as int? ?? 0;
    final totalQuestions = session['total_questions'] as int? ?? 1;
    final percentage = (score / totalQuestions * 100);
    final passed = percentage >= 70;
    final createdAt = session['created_at'] != null
        ? DateTime.parse(session['created_at'] as String)
        : DateTime.now();
    final timeSpent = session['time_spent_seconds'] as int? ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          passed ? Icons.check_circle : Icons.cancel,
          color: passed ? Colors.green : Colors.red,
        ),
        title: Text(
          '${score}/$totalQuestions (${percentage.toStringAsFixed(1)}%)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: passed ? Colors.green : Colors.red,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_formatDate(createdAt)} • ${_formatTime(timeSpent)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (session['category'] != null)
              Text(
                'Category: ${_formatCategory(session['category'] as String)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        trailing: passed
            ? const Icon(Icons.emoji_events, color: Colors.amber)
            : null,
        onTap: () {
          // TODO: Show detailed session view with wrong/right answers
          _showSessionDetails(context, session);
        },
      ),
    );
  }

  void _showSessionDetails(BuildContext context, Map<String, dynamic> session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exam Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Score: ${session['score']}/${session['total_questions']}'),
            Text('Time spent: ${_formatTime(session['time_spent_seconds'] as int? ?? 0)}'),
            if (session['category'] != null)
              Text('Category: ${_formatCategory(session['category'] as String)}'),
            const SizedBox(height: 16),
            const Text('Detailed question review coming soon!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  String _formatCategory(String category) {
    switch (category) {
      case 'rules_of_road':
        return 'Rules of the Road';
      case 'road_signs':
        return 'Road Signs';
      case 'vehicle_controls':
        return 'Vehicle Controls';
      default:
        return 'All Categories';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracking'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsCard(context),
                      const SizedBox(height: 24),
                      _buildSessionList(context),
                      const SizedBox(height: 24),
                      if (_examSessions.isNotEmpty)
                        ElevatedButton(
                          onPressed: _loadExamSessions,
                          child: const Text('Refresh Progress'),
                        ),
                    ],
                  ),
                ),
    );
  }
}