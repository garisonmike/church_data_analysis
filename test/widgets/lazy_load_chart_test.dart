import 'package:church_analytics/ui/widgets/lazy_load_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LazyLoadChart', () {
    testWidgets('should show placeholder initially when not visible', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Large spacer to push lazy chart off screen
                  const SizedBox(height: 2000),
                  LazyLoadChart(
                    placeholderHeight: 300,
                    child: Container(
                      key: const Key('actual_chart'),
                      height: 300,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // The actual chart should not be rendered yet
      expect(find.byKey(const Key('actual_chart')), findsNothing);
      // Placeholder text should be visible
      expect(find.text('Loading chart...'), findsOneWidget);
    });

    testWidgets('should show chart when visible', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: LazyLoadChart(
                placeholderHeight: 300,
                child: Container(
                  key: const Key('actual_chart'),
                  height: 300,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Chart should be visible since it's in view
      expect(find.byKey(const Key('actual_chart')), findsOneWidget);
    });

    testWidgets('should use custom placeholder when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 2000),
                  LazyLoadChart(
                    placeholderHeight: 300,
                    placeholder: const Text('Custom Placeholder'),
                    child: Container(height: 300, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Custom Placeholder'), findsOneWidget);
    });

    testWidgets('should respect placeholderHeight', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 2000),
                  LazyLoadChart(
                    placeholderHeight: 400,
                    child: Container(height: 300, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Find the SizedBox with height 400
      final sizedBox = tester.widget<SizedBox>(
        find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.height == 400,
        ),
      );
      expect(sizedBox.height, equals(400));
    });
  });

  group('LazyChart', () {
    testWidgets('should build chart when in viewport', (tester) async {
      var buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: LazyChart(
                height: 300,
                childBuilder: (context) {
                  buildCount++;
                  return Container(
                    key: const Key('lazy_chart_content'),
                    color: Colors.green,
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('lazy_chart_content')), findsOneWidget);
      expect(buildCount, greaterThan(0));
    });

    testWidgets('should show loading indicator while not loaded', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 2000),
                  LazyChart(
                    height: 300,
                    childBuilder: (context) => Container(color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Should show loading text
      expect(find.text('Chart loading...'), findsOneWidget);
    });

    testWidgets('should respect height parameter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LazyChart(
              height: 500,
              childBuilder: (context) => Container(color: Colors.green),
            ),
          ),
        ),
      );

      await tester.pump();

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.height, equals(500));
    });
  });
}
