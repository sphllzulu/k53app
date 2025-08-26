import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:k53app/src/core/services/admin_qa_service.dart';
import 'package:k53app/src/core/services/supabase_service.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _tabs = [
    _QADashboardTab(),
    _FlaggedQuestionsTab(),
    _AnalyticsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await SupabaseService.signOut();
              context.go('/auth/login');
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar navigation
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('QA Overview'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.flag),
                label: Text('Flagged Questions'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics),
                label: Text('Analytics'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main content
          Expanded(
            child: _tabs[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

// QA Overview Tab
class _QADashboardTab extends ConsumerStatefulWidget {
  const _QADashboardTab();

  @override
  ConsumerState<_QADashboardTab> createState() => _QADashboardTabState();
}

class _QADashboardTabState extends ConsumerState<_QADashboardTab> {
  Map<String, dynamic>? _analytics;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final analytics = await AdminQAService.getQAAnalytics();
    setState(() => _analytics = analytics);
  }

  @override
  Widget build(BuildContext context) {
    final flagStats = _analytics?['flag_stats'] as Map<String, dynamic>? ?? {};
    final critical = flagStats['by_severity']?['critical'] as int? ?? 0;
    final high = flagStats['by_severity']?['high'] as int? ?? 0;
    final resolved = flagStats['by_status']?['resolved'] as int? ?? 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'QA Dashboard Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Metrics cards
          Row(
            children: [
              _MetricCard(
                title: 'Critical Issues',
                value: critical.toString(),
                color: Colors.red,
                icon: Icons.warning,
              ),
              const SizedBox(width: 16),
              _MetricCard(
                title: 'High Priority',
                value: high.toString(),
                color: Colors.orange,
                icon: Icons.error,
              ),
              const SizedBox(width: 16),
              _MetricCard(
                title: 'Resolved',
                value: resolved.toString(),
                color: Colors.green,
                icon: Icons.check_circle,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Quick actions
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ActionChip(
                avatar: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh Data'),
                onPressed: _loadAnalytics,
              ),
              ActionChip(
                avatar: const Icon(Icons.notifications, size: 16),
                label: const Text('Send QA Report'),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Flagged Questions Tab
class _FlaggedQuestionsTab extends ConsumerStatefulWidget {
  const _FlaggedQuestionsTab();

  @override
  ConsumerState<_FlaggedQuestionsTab> createState() => _FlaggedQuestionsTabState();
}

class _FlaggedQuestionsTabState extends ConsumerState<_FlaggedQuestionsTab> {
  List<Map<String, dynamic>> _flaggedQuestions = [];

  @override
  void initState() {
    super.initState();
    _loadFlaggedQuestions();
  }

  Future<void> _loadFlaggedQuestions() async {
    final questions = await AdminQAService.getFlaggedQuestions();
    setState(() => _flaggedQuestions = questions);
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Flagged Questions',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadFlaggedQuestions,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _flaggedQuestions.isEmpty
                ? const Center(child: Text('No flagged questions found'))
                : ListView.builder(
                    itemCount: _flaggedQuestions.length,
                    itemBuilder: (context, index) {
                      final flag = _flaggedQuestions[index];
                      final question = flag['question'] as Map<String, dynamic>?;
                      final reportCount = flag['report_count'] as int? ?? 0;
                      final severity = flag['severity'] as String? ?? 'unknown';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            Icons.flag,
                            color: _getSeverityColor(severity),
                          ),
                          title: Text(question?['question_text'] as String? ?? 'Unknown Question'),
                          subtitle: Text(
                            'Category: ${question?['category']} • $reportCount reports • Priority: ${severity.toUpperCase()}',
                          ),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () {
                            // Navigate to question review
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Analytics Tab
class _AnalyticsTab extends ConsumerStatefulWidget {
  const _AnalyticsTab();

  @override
  ConsumerState<_AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends ConsumerState<_AnalyticsTab> {
  Map<String, dynamic>? _analytics;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final analytics = await AdminQAService.getQAAnalytics();
    setState(() => _analytics = analytics);
  }

  @override
  Widget build(BuildContext context) {
    final qualityMetrics = _analytics?['quality_metrics'] as Map<String, dynamic>? ?? {};
    final avgSuccessRate = qualityMetrics['avg_success_rate'] as double? ?? 0;
    final avgQualityScore = qualityMetrics['avg_quality_score'] as double? ?? 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Content Quality Analytics',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadAnalytics,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Analytics cards
          Row(
            children: [
              _AnalyticsCard(
                title: 'Avg Success Rate',
                value: '${avgSuccessRate.toStringAsFixed(1)}%',
                trend: avgSuccessRate > 75 ? '+5%' : '-2%',
              ),
              const SizedBox(width: 16),
              _AnalyticsCard(
                title: 'Quality Score',
                value: '${avgQualityScore.toStringAsFixed(1)}%',
                trend: avgQualityScore > 70 ? '+3%' : '-1%',
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Flag Statistics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // Flag statistics
          if (_analytics?['flag_stats'] != null)
            _buildFlagStatistics(_analytics!['flag_stats'] as Map<String, dynamic>),
        ],
      ),
    );
  }

  Widget _buildFlagStatistics(Map<String, dynamic> flagStats) {
    final bySeverity = flagStats['by_severity'] as Map<String, dynamic>? ?? {};
    final byStatus = flagStats['by_status'] as Map<String, dynamic>? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('By Severity:', style: TextStyle(fontWeight: FontWeight.bold)),
        ...bySeverity.entries.map((entry) => Text('  ${entry.key}: ${entry.value}')),
        const SizedBox(height: 12),
        const Text('By Status:', style: TextStyle(fontWeight: FontWeight.bold)),
        ...byStatus.entries.map((entry) => Text('  ${entry.key}: ${entry.value}')),
      ],
    );
  }
}

// Metric Card Component
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Analytics Card Component
class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = trend.startsWith('+');
    
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    trend,
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}