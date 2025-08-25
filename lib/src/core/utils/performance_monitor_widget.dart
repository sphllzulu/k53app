import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'performance_utils.dart';
import 'accessibility_utils.dart';

class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final bool showOverlay;
  final bool trackBuildPerformance;

  const PerformanceMonitor({
    Key? key,
    required this.child,
    this.showOverlay = false,
    this.trackBuildPerformance = true,
  }) : super(key: key);

  @override
  _PerformanceMonitorState createState() => _PerformanceMonitorState();

  static _PerformanceMonitorState? of(BuildContext context) {
    return context.findAncestorStateOfType<_PerformanceMonitorState>();
  }
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  final List<PerformanceMetric> _recentMetrics = [];
  final int _maxRecentMetrics = 50;
  bool _showPerformanceOverlay = false;

  @override
  void initState() {
    super.initState();
    _showPerformanceOverlay = widget.showOverlay;
  }

  void toggleOverlay() {
    setState(() {
      _showPerformanceOverlay = !_showPerformanceOverlay;
    });
  }

  void addMetric(PerformanceMetric metric) {
    setState(() {
      _recentMetrics.insert(0, metric);
      if (_recentMetrics.length > _maxRecentMetrics) {
        _recentMetrics.removeLast();
      }
    });
  }

  List<PerformanceMetric> getRecentMetrics({String? category}) {
    if (category != null) {
      return _recentMetrics.where((m) => m.category == category).toList();
    }
    return _recentMetrics.toList();
  }

  void clearMetrics() {
    setState(() {
      _recentMetrics.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PerformanceMonitorInheritedWidget(
      state: this,
      child: Builder(
        builder: (context) {
          if (widget.trackBuildPerformance) {
            return PerformanceUtils.monitorBuild(
              'PerformanceMonitor',
              () => _buildContent(context),
            );
          }
          return _buildContent(context);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showPerformanceOverlay) _buildPerformanceOverlay(),
      ],
    );
  }

  Widget _buildPerformanceOverlay() {
    return Positioned(
      top: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildMetricsSummary(),
              const SizedBox(height: 12),
              _buildRecentMetrics(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Performance Monitor',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 20),
          onPressed: toggleOverlay,
          tooltip: 'Close performance monitor',
        ),
      ],
    );
  }

  Widget _buildMetricsSummary() {
    final report = PerformanceUtils.generatePerformanceReport();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        _buildMetricRow('Total Metrics', report['total_metrics'].toString()),
        _buildMetricRow('Avg Build Time', '${report['average_build_time']?.toStringAsFixed(1) ?? '0'}ms'),
        _buildMetricRow('Avg Async Time', '${report['average_async_time']?.toStringAsFixed(1) ?? '0'}ms'),
        _buildMetricRow('Avg Network Time', '${report['average_network_time']?.toStringAsFixed(1) ?? '0'}ms'),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            value,
            style: TextStyle(
              color: _getValueColor(value),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getValueColor(String value) {
    if (value.contains('ms')) {
      final time = double.tryParse(value.replaceAll('ms', '')) ?? 0;
      if (time > 100) return Colors.red;
      if (time > 50) return Colors.orange;
      return Colors.green;
    }
    return Colors.white;
  }

  Widget _buildRecentMetrics() {
    if (_recentMetrics.isEmpty) {
      return Text(
        'No recent metrics',
        style: TextStyle(color: Colors.white70, fontSize: 12),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Metrics',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          child: ListView.builder(
            itemCount: _recentMetrics.length,
            itemBuilder: (context, index) {
              final metric = _recentMetrics[index];
              return _buildMetricItem(metric);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(PerformanceMetric metric) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              metric.name,
              style: TextStyle(color: Colors.white70, fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${metric.durationMs}ms',
              style: TextStyle(
                color: _getDurationColor(metric.durationMs),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDurationColor(int durationMs) {
    if (durationMs > 100) return Colors.red;
    if (durationMs > 50) return Colors.orange;
    return Colors.green;
  }
}

class PerformanceMonitorInheritedWidget extends InheritedWidget {
  final _PerformanceMonitorState state;

  const PerformanceMonitorInheritedWidget({
    Key? key,
    required this.state,
    required Widget child,
  }) : super(key: key, child: child);

  static _PerformanceMonitorState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PerformanceMonitorInheritedWidget>()?.state;
  }

  @override
  bool updateShouldNotify(PerformanceMonitorInheritedWidget oldWidget) {
    return oldWidget.state != state;
  }
}

// Performance-aware widget builder
class PerformanceAwareBuilder extends StatelessWidget {
  final String widgetName;
  final Widget Function(BuildContext) builder;

  const PerformanceAwareBuilder({
    Key? key,
    required this.widgetName,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PerformanceUtils.monitorBuild(
      widgetName,
      () => builder(context),
    );
  }
}

// Performance monitoring mixin for stateful widgets
mixin PerformanceMonitoring<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    PerformanceUtils.startTracking('${T.toString()}_init');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    PerformanceUtils.startTracking('${T.toString()}_dependencies');
  }

  @override
  void dispose() {
    PerformanceUtils.stopTracking('${T.toString()}_init', category: 'lifecycle');
    PerformanceUtils.stopTracking('${T.toString()}_dependencies', category: 'lifecycle');
    super.dispose();
  }

  @protected
  Widget buildWithPerformanceMonitoring(Widget Function() builder) {
    return PerformanceUtils.monitorBuild(
      '${T.toString()}_build',
      builder,
    );
  }
}