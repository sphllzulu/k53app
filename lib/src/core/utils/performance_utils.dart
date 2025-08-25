import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PerformanceUtils {
  static final Map<String, Stopwatch> _timers = {};
  static final List<PerformanceMetric> _metrics = [];

  // Start tracking a performance metric
  static void startTracking(String metricName) {
    if (_timers.containsKey(metricName)) {
      _timers[metricName]!.reset();
    } else {
      _timers[metricName] = Stopwatch();
    }
    _timers[metricName]!.start();
  }

  // Stop tracking and record the metric
  static void stopTracking(String metricName, {String? category}) {
    if (_timers.containsKey(metricName)) {
      _timers[metricName]!.stop();
      final duration = _timers[metricName]!.elapsedMilliseconds;
      
      _metrics.add(PerformanceMetric(
        name: metricName,
        durationMs: duration,
        category: category ?? 'general',
        timestamp: DateTime.now(),
      ));

      // Log performance metrics in development
      if (kDebugMode) {
        debugPrint('Performance: $metricName took ${duration}ms');
      }
    }
  }

  // Get performance metrics for analysis
  static List<PerformanceMetric> getMetrics({String? category}) {
    if (category != null) {
      return _metrics.where((metric) => metric.category == category).toList();
    }
    return _metrics.toList();
  }

  // Clear all performance metrics
  static void clearMetrics() {
    _metrics.clear();
  }

  // Monitor widget build performance
  static T monitorBuild<T>(String widgetName, T Function() builder) {
    startTracking('build_$widgetName');
    final result = builder();
    stopTracking('build_$widgetName', category: 'rendering');
    return result;
  }

  // Monitor async operation performance
  static Future<T> monitorAsync<T>(
    String operationName,
    Future<T> Function() operation, {
    String category = 'async',
  }) async {
    startTracking(operationName);
    try {
      final result = await operation();
      stopTracking(operationName, category: category);
      return result;
    } catch (e) {
      stopTracking(operationName, category: category);
      rethrow;
    }
  }

  // Check if app is running smoothly (FPS monitoring)
  static bool isRunningSmoothly() {
    // This would typically integrate with Flutter's performance overlay
    // For now, we'll return true and implement proper FPS monitoring later
    return true;
  }

  // Get memory usage information
  static Future<Map<String, dynamic>> getMemoryUsage() async {
    // Placeholder for memory usage monitoring
    // In production, this would use platform channels to get actual memory usage
    return {
      'used_memory': 0,
      'total_memory': 0,
      'percentage': 0,
    };
  }

  // Monitor image loading performance
  static void trackImageLoad(String imageUrl, int loadTimeMs) {
    _metrics.add(PerformanceMetric(
      name: 'image_load',
      durationMs: loadTimeMs,
      category: 'assets',
      timestamp: DateTime.now(),
      metadata: {'image_url': imageUrl},
    ));
  }

  // Monitor network request performance
  static void trackNetworkRequest(String endpoint, int responseTimeMs, int statusCode) {
    _metrics.add(PerformanceMetric(
      name: 'network_request',
      durationMs: responseTimeMs,
      category: 'network',
      timestamp: DateTime.now(),
      metadata: {
        'endpoint': endpoint,
        'status_code': statusCode,
      },
    ));
  }

  // Generate performance report
  static Map<String, dynamic> generatePerformanceReport() {
    final report = <String, dynamic>{
      'total_metrics': _metrics.length,
      'average_build_time': _calculateAverage('rendering'),
      'average_async_time': _calculateAverage('async'),
      'average_network_time': _calculateAverage('network'),
      'metrics_by_category': _groupByCategory(),
    };

    return report;
  }

  static double _calculateAverage(String category) {
    final categoryMetrics = _metrics.where((m) => m.category == category);
    if (categoryMetrics.isEmpty) return 0;
    
    final total = categoryMetrics.fold(0, (sum, metric) => sum + metric.durationMs);
    return total / categoryMetrics.length;
  }

  static Map<String, dynamic> _groupByCategory() {
    final grouped = <String, List<PerformanceMetric>>{};
    
    for (final metric in _metrics) {
      if (!grouped.containsKey(metric.category)) {
        grouped[metric.category] = [];
      }
      grouped[metric.category]!.add(metric);
    }

    return grouped.map((key, value) => MapEntry(key, {
      'count': value.length,
      'average_time': value.fold(0, (sum, m) => sum + m.durationMs) / value.length,
    }));
  }
}

class PerformanceMetric {
  final String name;
  final int durationMs;
  final String category;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  PerformanceMetric({
    required this.name,
    required this.durationMs,
    required this.category,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'duration_ms': durationMs,
      'category': category,
      'timestamp': timestamp.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }
}