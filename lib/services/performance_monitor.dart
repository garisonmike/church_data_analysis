import 'package:flutter/foundation.dart';

/// Utility class for measuring and tracking performance metrics
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Map<String, Stopwatch> _stopwatches = {};
  final Map<String, List<Duration>> _measurements = {};

  /// Start timing an operation
  void startTiming(String operationName) {
    _stopwatches[operationName] = Stopwatch()..start();
  }

  /// Stop timing and record the measurement
  Duration? stopTiming(String operationName) {
    final stopwatch = _stopwatches[operationName];
    if (stopwatch == null) return null;

    stopwatch.stop();
    final elapsed = stopwatch.elapsed;

    _measurements.putIfAbsent(operationName, () => []);
    _measurements[operationName]!.add(elapsed);

    _stopwatches.remove(operationName);

    if (kDebugMode) {
      debugPrint(
        '⏱️ [$operationName] completed in ${elapsed.inMilliseconds}ms',
      );
    }

    return elapsed;
  }

  /// Get the last measurement for an operation
  Duration? getLastMeasurement(String operationName) {
    final measurements = _measurements[operationName];
    if (measurements == null || measurements.isEmpty) return null;
    return measurements.last;
  }

  /// Get average duration for an operation
  Duration? getAverageDuration(String operationName) {
    final measurements = _measurements[operationName];
    if (measurements == null || measurements.isEmpty) return null;

    final totalMs = measurements.fold<int>(
      0,
      (sum, d) => sum + d.inMilliseconds,
    );
    return Duration(milliseconds: totalMs ~/ measurements.length);
  }

  /// Get all measurements for an operation
  List<Duration>? getMeasurements(String operationName) {
    return _measurements[operationName];
  }

  /// Clear all measurements
  void clearMeasurements() {
    _measurements.clear();
    _stopwatches.clear();
  }

  /// Clear measurements for a specific operation
  void clearMeasurementsFor(String operationName) {
    _measurements.remove(operationName);
  }

  /// Get a summary of all measurements
  Map<String, PerformanceStats> getSummary() {
    final summary = <String, PerformanceStats>{};

    for (final entry in _measurements.entries) {
      final measurements = entry.value;
      if (measurements.isEmpty) continue;

      final totalMs = measurements.fold<int>(
        0,
        (sum, d) => sum + d.inMilliseconds,
      );
      final avgMs = totalMs ~/ measurements.length;
      final minMs = measurements
          .map((d) => d.inMilliseconds)
          .reduce((a, b) => a < b ? a : b);
      final maxMs = measurements
          .map((d) => d.inMilliseconds)
          .reduce((a, b) => a > b ? a : b);

      summary[entry.key] = PerformanceStats(
        count: measurements.length,
        averageMs: avgMs,
        minMs: minMs,
        maxMs: maxMs,
        lastMs: measurements.last.inMilliseconds,
      );
    }

    return summary;
  }

  /// Print performance summary to debug console
  void printSummary() {
    if (!kDebugMode) return;

    final summary = getSummary();
    debugPrint('📊 Performance Summary:');
    debugPrint('=' * 60);

    for (final entry in summary.entries) {
      final stats = entry.value;
      debugPrint(
        '${entry.key}: avg=${stats.averageMs}ms, '
        'min=${stats.minMs}ms, max=${stats.maxMs}ms, '
        'count=${stats.count}',
      );
    }
    debugPrint('=' * 60);
  }
}

/// Performance statistics for an operation
class PerformanceStats {
  final int count;
  final int averageMs;
  final int minMs;
  final int maxMs;
  final int lastMs;

  const PerformanceStats({
    required this.count,
    required this.averageMs,
    required this.minMs,
    required this.maxMs,
    required this.lastMs,
  });

  @override
  String toString() {
    return 'PerformanceStats(count: $count, avg: ${averageMs}ms, '
        'min: ${minMs}ms, max: ${maxMs}ms, last: ${lastMs}ms)';
  }
}

/// Convenience extension for timing async operations
extension PerformanceMonitorExtension on PerformanceMonitor {
  /// Time an async operation and return its result
  Future<T> timeAsync<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    startTiming(operationName);
    try {
      return await operation();
    } finally {
      stopTiming(operationName);
    }
  }

  /// Time a sync operation and return its result
  T timeSync<T>(String operationName, T Function() operation) {
    startTiming(operationName);
    try {
      return operation();
    } finally {
      stopTiming(operationName);
    }
  }
}
