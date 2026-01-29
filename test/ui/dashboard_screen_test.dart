import 'package:church_analytics/ui/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DashboardScreen', () {
    testWidgets('displays loading indicator initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: DashboardScreen(churchId: 1)),
        ),
      );

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays app bar title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: DashboardScreen(churchId: 1)),
        ),
      );

      // Check app bar title
      expect(find.text('Church Analytics Dashboard'), findsOneWidget);
    });

    testWidgets('displays floating action button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: DashboardScreen(churchId: 1)),
        ),
      );

      // Check for FAB
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('displays refresh button in app bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: DashboardScreen(churchId: 1)),
        ),
      );

      // Check for refresh icon
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });
}
