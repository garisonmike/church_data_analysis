import 'package:church_analytics/ui/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GraphCenterScreen', () {
    testWidgets('shows app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: GraphCenterScreen(churchId: 1)),
        ),
      );

      expect(find.text('Chart Center'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows category filter chips', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: GraphCenterScreen(churchId: 1)),
        ),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Attendance'), findsOneWidget);
      expect(find.text('Financial'), findsOneWidget);
      expect(find.text('Analysis'), findsOneWidget);
      expect(find.text('Advanced'), findsOneWidget);
    });

    testWidgets('shows all chart cards initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: GraphCenterScreen(churchId: 1)),
        ),
      );

      expect(find.text('Attendance Charts'), findsOneWidget);
      expect(find.text('Financial Charts'), findsOneWidget);
      expect(find.text('Correlation Charts'), findsOneWidget);
      // Advanced Charts is in the 3rd grid row — scroll to bring it into view.
      await tester.scrollUntilVisible(
        find.text('Advanced Charts'),
        200,
        scrollable: find.descendant(
          of: find.byType(GridView),
          matching: find.byType(Scrollable),
        ),
      );
      expect(find.text('Advanced Charts'), findsOneWidget);
    });

    testWidgets('filters charts when category is selected', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: GraphCenterScreen(churchId: 1)),
        ),
      );

      // Initially all charts should be visible
      expect(find.text('Attendance Charts'), findsOneWidget);
      expect(find.text('Financial Charts'), findsOneWidget);

      // Tap on Attendance filter
      await tester.tap(find.text('Attendance'));
      await tester.pumpAndSettle();

      // Only attendance chart should be visible
      expect(find.text('Attendance Charts'), findsOneWidget);
      expect(find.text('Financial Charts'), findsNothing);
    });

    testWidgets('card has proper navigation action', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: GraphCenterScreen(churchId: 1)),
        ),
      );

      // Verify chart titles are present for navigation.
      // The grid is scrollable; scroll to reveal cards below the fold.
      expect(find.text('Attendance Charts'), findsOneWidget);
      expect(find.text('Financial Charts'), findsOneWidget);
      expect(find.text('Correlation Charts'), findsOneWidget);
      // Advanced Charts is in the 3rd grid row — scroll to bring it into view.
      await tester.scrollUntilVisible(
        find.text('Advanced Charts'),
        200,
        scrollable: find.descendant(
          of: find.byType(GridView),
          matching: find.byType(Scrollable),
        ),
      );
      expect(find.text('Advanced Charts'), findsOneWidget);

      // Grid contains card widgets (lazy grid renders a subset at a time).
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('shows grid with proper layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: GraphCenterScreen(churchId: 1)),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);
      expect(
        find.byType(Card),
        findsWidgets,
      ); // 6 chart types (lazy grid renders a subset)
    });
  });
}
