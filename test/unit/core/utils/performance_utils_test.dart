import 'package:flutter_test/flutter_test.dart';
import 'package:k53app/src/core/utils/performance_utils.dart';

void main() {
  group('PerformanceUtils', () {
    setUp(() {
      PerformanceUtils.clearMetrics();
    });

    test('startTracking and stopTracking should record metrics', () async {
      const metricName = 'test_operation';
      
      PerformanceUtils.startTracking(metricName);
      await Future.delayed(const Duration(milliseconds: 50));
      PerformanceUtils.stopTracking(metricName, category: 'test');
      
      final metrics = PerformanceUtils.getMetrics();
      expect(metrics.length, 1);
      expect(metrics.first.name, metricName);
      expect(metrics.first.category, 'test');
      expect(metrics.first.durationMs, greaterThan(0));
    });

    test('monitorAsync should track async operations', () async {
      const operationName = 'async_test';
      
      final result = await PerformanceUtils.monitorAsync(
        operationName,
        () async {
          await Future.delayed(const Duration(milliseconds: 30));
          return 'success';
        },
        category: 'async',
      );
      
      expect(result, 'success');
      
      final metrics = PerformanceUtils.getMetrics(category: 'async');
      expect(metrics.length, 1);
      expect(metrics.first.name, operationName);
    });

    test('monitorAsync should handle errors and still track', () async {
      const operationName = 'async_error_test';
      
      expect(
        () async => await PerformanceUtils.monitorAsync(
          operationName,
          () async {
            await Future.delayed(const Duration(milliseconds: 20));
            throw Exception('Test error');
          },
          category: 'async',
        ),
        throwsException,
      );
      
      final metrics = PerformanceUtils.getMetrics(category: 'async');
      expect(metrics.length, 1);
      expect(metrics.first.name, operationName);
    });

    test('trackImageLoad should record image loading metrics', () {
      const imageUrl = 'https://example.com/image.jpg';
      const loadTime = 150;
      
      PerformanceUtils.trackImageLoad(imageUrl, loadTime);
      
      final metrics = PerformanceUtils.getMetrics(category: 'assets');
      expect(metrics.length, 1);
      expect(metrics.first.name, 'image_load');
      expect(metrics.first.durationMs, loadTime);
      expect(metrics.first.metadata?['image_url'], imageUrl);
    });

    test('trackNetworkRequest should record network metrics', () {
      const endpoint = '/api/questions';
      const responseTime = 200;
      const statusCode = 200;
      
      PerformanceUtils.trackNetworkRequest(endpoint, responseTime, statusCode);
      
      final metrics = PerformanceUtils.getMetrics(category: 'network');
      expect(metrics.length, 1);
      expect(metrics.first.name, 'network_request');
      expect(metrics.first.durationMs, responseTime);
      expect(metrics.first.metadata?['endpoint'], endpoint);
      expect(metrics.first.metadata?['status_code'], statusCode);
    });

    test('generatePerformanceReport should create valid report', () {
      // Add some test metrics
      PerformanceUtils.trackNetworkRequest('/test1', 100, 200);
      PerformanceUtils.trackNetworkRequest('/test2', 200, 200);
      PerformanceUtils.trackImageLoad('image1.jpg', 50);
      
      final report = PerformanceUtils.generatePerformanceReport();
      
      expect(report['total_metrics'], 3);
      expect(report['average_network_time'], 150.0);
      expect(report['metrics_by_category']['network']['count'], 2);
      expect(report['metrics_by_category']['assets']['count'], 1);
    });

    test('clearMetrics should remove all metrics', () {
      PerformanceUtils.trackNetworkRequest('/test', 100, 200);
      expect(PerformanceUtils.getMetrics().length, 1);
      
      PerformanceUtils.clearMetrics();
      expect(PerformanceUtils.getMetrics().length, 0);
    });

    test('getMetrics should filter by category', () {
      PerformanceUtils.trackNetworkRequest('/test1', 100, 200);
      PerformanceUtils.trackImageLoad('image1.jpg', 50);
      PerformanceUtils.trackNetworkRequest('/test2', 200, 200);
      
      final networkMetrics = PerformanceUtils.getMetrics(category: 'network');
      expect(networkMetrics.length, 2);
      
      final assetMetrics = PerformanceUtils.getMetrics(category: 'assets');
      expect(assetMetrics.length, 1);
      
      final allMetrics = PerformanceUtils.getMetrics();
      expect(allMetrics.length, 3);
    });

    test('isRunningSmoothly should return true by default', () {
      expect(PerformanceUtils.isRunningSmoothly(), isTrue);
    });

    test('getMemoryUsage should return placeholder data', () async {
      final memoryUsage = await PerformanceUtils.getMemoryUsage();
      
      expect(memoryUsage['used_memory'], 0);
      expect(memoryUsage['total_memory'], 0);
      expect(memoryUsage['percentage'], 0);
    });
  });

  group('PerformanceMetric', () {
    test('toJson should serialize correctly', () {
      final metric = PerformanceMetric(
        name: 'test_metric',
        durationMs: 100,
        category: 'test',
        timestamp: DateTime(2023, 1, 1),
        metadata: {'key': 'value'},
      );
      
      final json = metric.toJson();
      
      expect(json['name'], 'test_metric');
      expect(json['duration_ms'], 100);
      expect(json['category'], 'test');
      expect(json['timestamp'], '2023-01-01T00:00:00.000');
      expect(json['metadata']['key'], 'value');
    });

    test('toJson should handle null metadata', () {
      final metric = PerformanceMetric(
        name: 'test_metric',
        durationMs: 100,
        category: 'test',
        timestamp: DateTime(2023, 1, 1),
      );
      
      final json = metric.toJson();
      
      expect(json['name'], 'test_metric');
      expect(json['duration_ms'], 100);
      expect(json['category'], 'test');
      expect(json.containsKey('metadata'), isFalse);
    });
  });
}