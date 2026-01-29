import 'package:church_analytics/ui/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdvancedChartsScreen', () {
    testWidgets('shows loading indicator initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: AdvancedChartsScreen(churchId: 1)),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: AdvancedChartsScreen(churchId: 1)),
        ),
      );

      expect(find.text('Advanced Charts'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('has refresh button in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: AdvancedChartsScreen(churchId: 1)),
        ),
      );

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('shows empty state or charts', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: AdvancedChartsScreen(churchId: 1)),
        ),
      );

      // Wait a bit for the initial render
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should show either loading, error, or no data message
      final hasLoadingOrContent =
          find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
          find.text('No data available').evaluate().isNotEmpty ||
          find.byType(Card).evaluate().isNotEmpty;

      expect(hasLoadingOrContent, true);
    });
  });
}
