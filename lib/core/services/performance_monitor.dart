import '../utils/logger.dart';

/// Performance monitoring service for tracking app metrics
class PerformanceMonitor {
  static final _instance = PerformanceMonitor._();

  factory PerformanceMonitor() => _instance;

  PerformanceMonitor._();

  final Map<String, Stopwatch> _timers = {};
  final Map<String, List<int>> _metrics = {};

  /// Start timing a metric
  void start(String label) {
    _timers[label] = Stopwatch()..start();
  }

  /// End timing and log the result
  int end(String label) {
    final timer = _timers[label];
    if (timer != null) {
      timer.stop();
      final elapsed = timer.elapsedMilliseconds;

      // Store metric
      _metrics.putIfAbsent(label, () => []).add(elapsed);

      // Log
      AppLogger.info('⏱️ $label: ${elapsed}ms');

      _timers.remove(label);
      return elapsed;
    }
    return 0;
  }

  /// Get average time for a metric
  double getAverage(String label) {
    final metrics = _metrics[label];
    if (metrics == null || metrics.isEmpty) return 0;
    return metrics.reduce((a, b) => a + b) / metrics.length;
  }

  /// Get max time for a metric
  int getMax(String label) {
    final metrics = _metrics[label];
    if (metrics == null || metrics.isEmpty) return 0;
    return metrics.reduce((a, b) => a > b ? a : b);
  }

  /// Get min time for a metric
  int getMin(String label) {
    final metrics = _metrics[label];
    if (metrics == null || metrics.isEmpty) return 0;
    return metrics.reduce((a, b) => a < b ? a : b);
  }

  /// Get count of measurements
  int getCount(String label) {
    return _metrics[label]?.length ?? 0;
  }

  /// Print all metrics
  void printMetrics() {
    AppLogger.info('=== PERFORMANCE METRICS ===');
    for (final entry in _metrics.entries) {
      final avg = getAverage(entry.key);
      final max = getMax(entry.key);
      final min = getMin(entry.key);
      final count = getCount(entry.key);
      AppLogger.info(
        '${entry.key}: avg=${avg.toStringAsFixed(2)}ms, '
        'min=${min}ms, max=${max}ms, count=$count',
      );
    }
    AppLogger.info('===========================');
  }

  /// Clear all metrics
  void clear() {
    _timers.clear();
    _metrics.clear();
  }
}

/// Global performance monitor instance
final performanceMonitor = PerformanceMonitor();
