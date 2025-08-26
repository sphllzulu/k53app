
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    QADashboardTab(),
    FlaggedQuestionsTab(),
    AnalyticsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Admin Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          )),
        backgroundColor: const Color(0xFF1E40AF),
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.logout, size: 20),
              tooltip: 'Logout',
              onPressed: () {
                final navigator = Navigator.of(context);
                SupabaseService.signOut().then((_) {
                  navigator.pushNamedAndRemoveUntil('/auth/login', (route) => false);
                });
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: _buildMobileDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;
          return isMobile ? _buildMobileLayout() : _buildDesktopLayout();
        },
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Sidebar navigation
        Container(
          width: 240,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(2, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E40AF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.admin_panel_settings,
                          size: 24, color: const Color(0xFF1E40AF)),
                    ),
                    const SizedBox(height: 12),
                    const Text('Admin Portal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        )),
                    const SizedBox(height: 2),
                    Text('Quality Assurance Dashboard',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    _buildNavItem(0, Icons.dashboard_rounded, 'QA Overview'),
                    const SizedBox(height: 8),
                    _buildNavItem(1, Icons.flag_rounded, 'Flagged Questions'),
                    const SizedBox(height: 8),
                    _buildNavItem(2, Icons.analytics_rounded, 'Analytics'),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Main content
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFF8FAFC),
                  const Color(0xFFF1F5F9),
                ],
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _tabs[_selectedIndex],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF8FAFC),
            const Color(0xFFF1F5F9),
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _tabs[_selectedIndex],
        ),
      ),
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E40AF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.admin_panel_settings,
                      size: 24, color: const Color(0xFF1E40AF)),
                ),
                const SizedBox(height: 12),
                const Text('Admin Portal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    )),
                const SizedBox(height: 2),
                Text('Quality Assurance Dashboard',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _buildNavItem(0, Icons.dashboard_rounded, 'QA Overview'),
                const SizedBox(height: 8),
                _buildNavItem(1, Icons.flag_rounded, 'Flagged Questions'),
                const SizedBox(height: 8),
                _buildNavItem(2, Icons.analytics_rounded, 'Analytics'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1E40AF) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? null
            : Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: ListTile(
        leading: Icon(icon,
            size: 22,
            color: isSelected ? Colors.white : const Color(0xFF64748B)),
        title: Text(title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF334155),
            )),
        selected: isSelected,
        onTap: () => setState(() => _selectedIndex = index),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

// QA Overview Tab
class QADashboardTab extends ConsumerStatefulWidget {
  const QADashboardTab({super.key});

  @override
  ConsumerState<QADashboardTab> createState() => _QADashboardTabState();
}

class _QADashboardTabState extends ConsumerState<QADashboardTab> {
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        return Container(
          color: Colors.white,
          child: Padding(
            padding: isMobile ? const EdgeInsets.all(16) : const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QA Dashboard Overview',
                  style: TextStyle(
                    fontSize: isMobile ? 22 : 28,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Monitor content quality and user reports',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: isMobile ? 24 : 32),
                // Metrics cards - responsive layout
                isMobile
                    ? Column(
                        children: [
                          MetricCard(
                            title: 'Critical Issues',
                            value: critical.toString(),
                            color: const Color(0xFFDC2626),
                            icon: Icons.warning_amber_rounded,
                          ),
                          const SizedBox(height: 16),
                          MetricCard(
                            title: 'High Priority',
                            value: high.toString(),
                            color: const Color(0xFFEA580C),
                            icon: Icons.error_outline_rounded,
                          ),
                          const SizedBox(height: 16),
                          MetricCard(
                            title: 'Resolved',
                            value: resolved.toString(),
                            color: const Color(0xFF16A34A),
                            icon: Icons.check_circle_outline_rounded,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              title: 'Critical Issues',
                              value: critical.toString(),
                              color: const Color(0xFFDC2626),
                              icon: Icons.warning_amber_rounded,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MetricCard(
                              title: 'High Priority',
                              value: high.toString(),
                              color: const Color(0xFFEA580C),
                              icon: Icons.error_outline_rounded,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MetricCard(
                              title: 'Resolved',
                              value: resolved.toString(),
                              color: const Color(0xFF16A34A),
                              icon: Icons.check_circle_outline_rounded,
                            ),
                          ),
                        ],
                      ),
                SizedBox(height: isMobile ? 24 : 32),
                // Quick actions
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: Text('Refresh Data', style: TextStyle(fontSize: isMobile ? 13 : 14)),
                      onPressed: _loadAnalytics,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E40AF),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16 : 20,
                          vertical: isMobile ? 12 : 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.summarize_rounded, size: 16),
                      label: Text('Generate Report', style: TextStyle(fontSize: isMobile ? 13 : 14)),
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16 : 20,
                          vertical: isMobile ? 12 : 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.email_rounded, size: 16),
                      label: Text('Email Summary', style: TextStyle(fontSize: isMobile ? 13 : 14)),
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16 : 20,
                          vertical: isMobile ? 12 : 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Flagged Questions Tab
class FlaggedQuestionsTab extends ConsumerStatefulWidget {
  const FlaggedQuestionsTab({super.key});

  @override
  ConsumerState<FlaggedQuestionsTab> createState() => _FlaggedQuestionsTabState();
}

class _FlaggedQuestionsTabState extends ConsumerState<FlaggedQuestionsTab> {
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        
        return Container(
          color: Colors.white,
          child: Padding(
            padding: isMobile ? const EdgeInsets.all(16) : const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Flagged Questions',
                      style: TextStyle(
                        fontSize: isMobile ? 22 : 28,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.refresh_rounded, size: isMobile ? 20 : 22),
                        onPressed: _loadFlaggedQuestions,
                        tooltip: 'Refresh flagged questions',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Review and manage reported content issues',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: isMobile ? 24 : 32),
                Expanded(
                  child: _flaggedQuestions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.flag_rounded, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 20),
                              Text(
                                'No flagged questions found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'All content appears to be in good standing',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _flaggedQuestions.length,
                          itemBuilder: (context, index) {
                            final flag = _flaggedQuestions[index];
                            final question = flag['question'] as Map<String, dynamic>?;
                            final reportCount = flag['report_count'] as int? ?? 0;
                           final severity = flag['severity'] as String? ?? 'unknown';

                           return Container(
                             margin: const EdgeInsets.only(bottom: 16),
                             decoration: BoxDecoration(
                               color: Colors.white,
                               borderRadius: BorderRadius.circular(12),
                               boxShadow: [
                                 BoxShadow(
                                   color: Colors.black.withOpacity(0.05),
                                   blurRadius: 8,
                                   offset: const Offset(0, 2),
                                 ),
                               ],
                               border: Border.all(
                                 color: const Color(0xFFE2E8F0),
                                 width: 1,
                               ),
                             ),
                             child: ListTile(
                               leading: Container(
                                 width: 44,
                                 height: 44,
                                 decoration: BoxDecoration(
                                   color: _getSeverityColor(severity).withOpacity(0.1),
                                   borderRadius: BorderRadius.circular(10),
                                 ),
                                 child: Icon(
                                   Icons.flag_rounded,
                                   color: _getSeverityColor(severity),
                                   size: 20,
                                 ),
                               ),
                               title: Text(
                                 question?['question_text'] as String? ?? 'Unknown Question',
                                 style: const TextStyle(
                                   fontWeight: FontWeight.w600,
                                   fontSize: 15,
                                 ),
                                 maxLines: 2,
                                 overflow: TextOverflow.ellipsis,
                               ),
                               subtitle: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   const SizedBox(height: 6),
                                   Text(
                                     'Category: ${question?['category']}',
                                     style: TextStyle(
                                       fontSize: 13,
                                       color: Colors.grey[600],
                                     ),
                                   ),
                                   const SizedBox(height: 2),
                                   Text(
                                     '$reportCount reports • Priority: ${severity.toUpperCase()}',
                                     style: TextStyle(
                                       fontSize: 13,
                                       color: _getSeverityColor(severity),
                                       fontWeight: FontWeight.w700,
                                     ),
                                   ),
                                 ],
                               ),
                               trailing: Icon(
                                 Icons.arrow_forward_ios_rounded,
                                 size: 16,
                                 color: Colors.grey[500],
                               ),
                               onTap: () {
                                 // Navigate to question review
                               },
                               contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                               shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(12),
                               ),
                             ),
                           );
                         },
                       ),
               ),
             ],
           ),
         ),
       );
     },
   );
 }
}

// Analytics Tab
class AnalyticsTab extends ConsumerStatefulWidget {
 const AnalyticsTab({super.key});

 @override
 ConsumerState<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends ConsumerState<AnalyticsTab> {
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

   return LayoutBuilder(
     builder: (context, constraints) {
       final isMobile = constraints.maxWidth < 768;
       
       return Container(
         color: Colors.white,
         child: Padding(
           padding: isMobile ? const EdgeInsets.all(16) : const EdgeInsets.all(24),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Row(
                 children: [
                   Text(
                     'Content Quality Analytics',
                     style: TextStyle(
                       fontSize: isMobile ? 22 : 28,
                       fontWeight: FontWeight.w700,
                       color: const Color(0xFF1E293B),
                       letterSpacing: -0.5,
                     ),
                   ),
                   const Spacer(),
                   Container(
                     decoration: BoxDecoration(
                       color: const Color(0xFFF1F5F9),
                       borderRadius: BorderRadius.circular(10),
                     ),
                     child: IconButton(
                       icon: Icon(Icons.refresh_rounded, size: isMobile ? 20 : 22),
                       onPressed: _loadAnalytics,
                       tooltip: 'Refresh analytics',
                       style: IconButton.styleFrom(
                         backgroundColor: Colors.transparent,
                         foregroundColor: const Color(0xFF475569),
                       ),
                     ),
                   ),
                 ],
               ),
               const SizedBox(height: 8),
               Text(
                 'Track performance metrics and content quality trends',
                 style: TextStyle(
                   fontSize: isMobile ? 14 : 16,
                   color: Colors.grey[600],
                   fontWeight: FontWeight.w500,
                 ),
               ),
               SizedBox(height: isMobile ? 24 : 32),
               // Analytics cards - responsive layout
               isMobile
                   ? Column(
                       children: [
                         AnalyticsCard(
                           title: 'Avg Success Rate',
                           value: '${avgSuccessRate.toStringAsFixed(1)}%',
                           trend: avgSuccessRate > 75 ? '+5%' : '-2%',
                         ),
                         const SizedBox(height: 16),
                         AnalyticsCard(
                           title: 'Quality Score',
                           value: '${avgQualityScore.toStringAsFixed(1)}%',
                           trend: avgQualityScore > 70 ? '+3%' : '-1%',
                         ),
                       ],
                     )
                   : Row(
                       children: [
                         Expanded(
                           child: AnalyticsCard(
                             title: 'Avg Success Rate',
                             value: '${avgSuccessRate.toStringAsFixed(1)}%',
                             trend: avgSuccessRate > 75 ? '+5%' : '-2%',
                           ),
                         ),
                         SizedBox(width: isMobile ? 12 : 20),
                         Expanded(
                           child: AnalyticsCard(
                             title: 'Quality Score',
                             value: '${avgQualityScore.toStringAsFixed(1)}%',
                             trend: avgQualityScore > 70 ? '+3%' : '-1%',
                           ),
                         ),
                       ],
                     ),
               SizedBox(height: isMobile ? 32 : 40),
               Text(
                 'Flag Statistics',
                 style: TextStyle(
                   fontSize: isMobile ? 18 : 20,
                   fontWeight: FontWeight.w700,
                   color: const Color(0xFF1E293B),
                 ),
               ),
               SizedBox(height: isMobile ? 12 : 16),
               // Flag statistics
               if (_analytics?['flag_stats'] != null)
                 _buildFlagStatistics(_analytics!['flag_stats'] as Map<String, dynamic>),
             ],
           ),
         ),
       );
     },
   );
 }

 Widget _buildFlagStatistics(Map<String, dynamic> flagStats) {
   final bySeverity = flagStats['by_severity'] as Map<String, dynamic>? ?? {};
   final byStatus = flagStats['by_status'] as Map<String, dynamic>? ?? {};

   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       Text('By Severity:',
           style: TextStyle(
             fontSize: 16,
             fontWeight: FontWeight.w600,
             color: const Color(0xFF374151),
           )),
       const SizedBox(height: 8),
       ...bySeverity.entries.map((entry) => Padding(
         padding: const EdgeInsets.only(left: 16, bottom: 4),
         child: Text('• ${entry.key}: ${entry.value}',
             style: TextStyle(
               fontSize: 14,
               color: Colors.grey[700],
             )),
       )),
       const SizedBox(height: 16),
       Text('By Status:',
           style: TextStyle(
             fontSize: 16,
             fontWeight: FontWeight.w600,
             color: const Color(0xFF374151),
           )),
       const SizedBox(height: 8),
       ...byStatus.entries.map((entry) => Padding(
         padding: const EdgeInsets.only(left: 16, bottom: 4),
         child: Text('• ${entry.key}: ${entry.value}',
             style: TextStyle(
               fontSize: 14,
               color: Colors.grey[700],
             )),
       )),
     ],
   );
 }
}

// Metric Card Component
class MetricCard extends StatelessWidget {
 final String title;
 final String value;
 final Color color;
 final IconData icon;

 const MetricCard({
   super.key,
   required this.title,
   required this.value,
   required this.color,
   required this.icon,
 });

 @override
 Widget build(BuildContext context) {
   return Container(
     decoration: BoxDecoration(
       color: Colors.white,
       borderRadius: BorderRadius.circular(16),
       boxShadow: [
         BoxShadow(
           color: Colors.black.withOpacity(0.05),
           blurRadius: 12,
           offset: const Offset(0, 4),
         ),
       ],
       border: Border.all(
         color: const Color(0xFFE2E8F0),
         width: 1,
       ),
     ),
     child: Padding(
       padding: const EdgeInsets.all(24),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Container(
             width: 48,
             height: 48,
             decoration: BoxDecoration(
               color: color.withOpacity(0.1),
               borderRadius: BorderRadius.circular(12),
             ),
             child: Icon(icon, size: 24, color: color),
           ),
           const SizedBox(height: 16),
           Text(
             value,
             style: TextStyle(
               fontSize: 28,
               fontWeight: FontWeight.w700,
               color: const Color(0xFF1E293B),
             ),
           ),
           const SizedBox(height: 4),
           Text(
             title,
             style: TextStyle(
               fontSize: 14,
               color: Colors.grey[600],
               fontWeight: FontWeight.w500,
             ),
           ),
         ],
       ),
     ),
   );
 }
}

// Analytics Card Component
class AnalyticsCard extends StatelessWidget {
 final String title;
 final String value;
 final String trend;

 const AnalyticsCard({
   super.key,
   required this.title,
   required this.value,
   required this.trend,
 });

 @override
 Widget build(BuildContext context) {
   final isPositive = trend.startsWith('+');
   
   return Container(
     decoration: BoxDecoration(
       color: Colors.white,
       borderRadius: BorderRadius.circular(16),
       boxShadow: [
         BoxShadow(
           color: Colors.black.withOpacity(0.05),
           blurRadius: 12,
           offset: const Offset(0, 4),
         ),
       ],
       border: Border.all(
         color: const Color(0xFFE2E8F0),
         width: 1,
       ),
     ),
     child: Padding(
       padding: const EdgeInsets.all(24),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text(
             title,
             style: TextStyle(
               fontSize: 16,
               fontWeight: FontWeight.w600,
               color: const Color(0xFF374151),
             ),
           ),
           const SizedBox(height: 12),
           Row(
             children: [
               Text(
                 value,
                 style: TextStyle(
                   fontSize: 28,
                   fontWeight: FontWeight.w700,
                   color: const Color(0xFF1E293B),
                 ),
               ),
               const SizedBox(width: 12),
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                 decoration: BoxDecoration(
                   color: isPositive ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                   borderRadius: BorderRadius.circular(6),
                 ),
                 child: Text(
                   trend,
                   style: TextStyle(
                     fontSize: 14,
                     fontWeight: FontWeight.w600,
                     color: isPositive ? const Color(0xFF065F46) : const Color(0xFFB91C1C),
                   ),
                 ),
               ),
             ],
           ),
         ],
       ),
     ),
   );
 }
}