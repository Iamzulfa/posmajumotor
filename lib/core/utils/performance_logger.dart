import 'logger.dart';

/// Performance Logger untuk track operation duration
class PerformanceLogger {
  static final _stopwatches = <String, Stopwatch>{};
  static final _thresholds = <String, int>{
    'api_call': 1000, // 1 second
    'screen_transition': 500, // 500ms
    'filter_apply': 1000, // 1 second
    'pdf_generation': 2000, // 2 seconds
    'list_scroll': 100, // 100ms per frame
    'modal_show': 500, // 500ms
  };

  /// Start tracking operation
  static void start(String label) {
    _stopwatches[label] = Stopwatch()..start();
  }

  /// End tracking and log result
  static int end(String label) {
    final stopwatch = _stopwatches[label];
    if (stopwatch == null) {
      AppLogger.warning('PerformanceLogger: No stopwatch found for "$label"');
      return 0;
    }

    stopwatch.stop();
    final ms = stopwatch.elapsedMilliseconds;
    final threshold = _thresholds[label] ?? 1000;
    final isSlowOperation = ms > threshold;

    // Log dengan warning jika melebihi threshold
    if (isSlowOperation) {
      AppLogger.warning(
        '⚠️ SLOW: $label took ${ms}ms (threshold: ${threshold}ms)',
      );
    } else {
      AppLogger.debug('✓ $label: ${ms}ms');
    }

    _stopwatches.remove(label);
    return ms;
  }

  /// Get duration tanpa stop (untuk monitoring)
  static int getDuration(String label) {
    final stopwatch = _stopwatches[label];
    return stopwatch?.elapsedMilliseconds ?? 0;
  }

  /// Clear all stopwatches
  static void clearAll() {
    _stopwatches.clear();
  }

  /// Get all active operations
  static Map<String, int> getActiveOperations() {
    return {
      for (final entry in _stopwatches.entries)
        entry.key: entry.value.elapsedMilliseconds,
    };
  }
}
