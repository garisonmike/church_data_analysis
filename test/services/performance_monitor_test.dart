import 'package:church_analytics/services/performance_monitor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PerformanceMonitor', () {
    late PerformanceMonitor monitor;

    setUp(() {
      monitor = PerformanceMonitor();
      monitor.clearMeasurements();
    });

    group('timing operations', () {
      test('should start and stop timing', () async {
        monitor.startTiming('test_operation');
        await Future.delayed(const Duration(milliseconds: 50));
        final duration = monitor.stopTiming('test_operation');

        expect(duration, isNotNull);
        expect(duration!.inMilliseconds, greaterThanOrEqualTo(50));
      });

      test('should return null when stopping non-existent timer', () {
        final duration = monitor.stopTiming('non_existent');
        expect(duration, isNull);
      });

      test('should record multiple measurements', () async {
        for (var i = 0; i < 3; i++) {
          monitor.startTiming('repeated_op');
          await Future.delayed(const Duration(milliseconds: 10));
          monitor.stopTiming('repeated_op');
        }

        final measurements = monitor.getMeasurements('repeated_op');
        expect(measurements, isNotNull);
        expect(measurements!.length, equals(3));
      });
    });

    group('measurement retrieval', () {
      test('should get last measurement', () async {
        monitor.startTiming('op1');
        await Future.delayed(const Duration(milliseconds: 20));
        monitor.stopTiming('op1');

        monitor.startTiming('op1');
        await Future.delayed(const Duration(milliseconds: 30));
        monitor.stopTiming('op1');

        final last = monitor.getLastMeasurement('op1');
        expect(last, isNotNull);
        expect(last!.inMilliseconds, greaterThanOrEqualTo(30));
      });

      test('should return null for non-existent operation', () {
        final last = monitor.getLastMeasurement('non_existent');
        expect(last, isNull);
      });
    });

    group('average duration', () {
      test('should calculate average duration', () async {
        // Run 3 operations of similar duration
        for (var i = 0; i < 3; i++) {
          monitor.startTiming('avg_test');
          await Future.delayed(const Duration(milliseconds: 20));
          monitor.stopTiming('avg_test');
        }

        final avg = monitor.getAverageDuration('avg_test');
        expect(avg, isNotNull);
        expect(avg!.inMilliseconds, greaterThanOrEqualTo(20));
      });

      test('should return null for non-existent operation', () {
        final avg = monitor.getAverageDuration('non_existent');
        expect(avg, isNull);
      });
    });

    group('clear measurements', () {
      test('should clear all measurements', () async {
        monitor.startTiming('op1');
        await Future.delayed(const Duration(milliseconds: 10));
        monitor.stopTiming('op1');

        monitor.startTiming('op2');
        await Future.delayed(const Duration(milliseconds: 10));
        monitor.stopTiming('op2');

        monitor.clearMeasurements();

        expect(monitor.getMeasurements('op1'), isNull);
        expect(monitor.getMeasurements('op2'), isNull);
      });

      test('should clear specific operation measurements', () async {
        monitor.startTiming('op1');
        await Future.delayed(const Duration(milliseconds: 10));
        monitor.stopTiming('op1');

        monitor.startTiming('op2');
        await Future.delayed(const Duration(milliseconds: 10));
        monitor.stopTiming('op2');

        monitor.clearMeasurementsFor('op1');

        expect(monitor.getMeasurements('op1'), isNull);
        expect(monitor.getMeasurements('op2'), isNotNull);
      });
    });

    group('summary', () {
      test('should generate performance summary', () async {
        monitor.startTiming('summary_op');
        await Future.delayed(const Duration(milliseconds: 25));
        monitor.stopTiming('summary_op');

        final summary = monitor.getSummary();

        expect(summary.containsKey('summary_op'), isTrue);
        expect(summary['summary_op']!.count, equals(1));
        expect(summary['summary_op']!.averageMs, greaterThanOrEqualTo(25));
      });
    });

    group('extension methods', () {
      test('timeAsync should time async operations', () async {
        final result = await monitor.timeAsync('async_op', () async {
          await Future.delayed(const Duration(milliseconds: 30));
          return 'result';
        });

        expect(result, equals('result'));

        final last = monitor.getLastMeasurement('async_op');
        expect(last, isNotNull);
        expect(last!.inMilliseconds, greaterThanOrEqualTo(30));
      });

      test('timeSync should time sync operations', () {
        final result = monitor.timeSync('sync_op', () {
          var sum = 0;
          for (var i = 0; i < 1000; i++) {
            sum += i;
          }
          return sum;
        });

        expect(result, equals(499500));

        final last = monitor.getLastMeasurement('sync_op');
        expect(last, isNotNull);
      });
    });
  });

  group('PerformanceStats', () {
    test('should create stats with correct values', () {
      const stats = PerformanceStats(
        count: 5,
        averageMs: 100,
        minMs: 50,
        maxMs: 150,
        lastMs: 120,
      );

      expect(stats.count, equals(5));
      expect(stats.averageMs, equals(100));
      expect(stats.minMs, equals(50));
      expect(stats.maxMs, equals(150));
      expect(stats.lastMs, equals(120));
    });

    test('toString should return formatted string', () {
      const stats = PerformanceStats(
        count: 3,
        averageMs: 100,
        minMs: 80,
        maxMs: 120,
        lastMs: 110,
      );

      final str = stats.toString();

      expect(str, contains('count: 3'));
      expect(str, contains('avg: 100ms'));
      expect(str, contains('min: 80ms'));
      expect(str, contains('max: 120ms'));
      expect(str, contains('last: 110ms'));
    });
  });
}
