import 'package:church_analytics/database/app_database.dart';
import 'package:church_analytics/ui/screens/screens.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DashboardScreen', () {
    Future<void> pumpDashboard(WidgetTester tester) async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());

      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await database.close();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(database)],
          child: const MaterialApp(home: DashboardScreen(churchId: 1)),
        ),
      );
    }

    testWidgets('displays loading indicator initially', (
      WidgetTester tester,
    ) async {
      await pumpDashboard(tester);

      // Should show loading indicator(s) - dashboard and church selector may both be loading
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('displays app bar title', (WidgetTester tester) async {
      await pumpDashboard(tester);

      // Check app bar title
      expect(find.text('Church Analytics Dashboard'), findsOneWidget);
    });

    testWidgets('displays floating action button', (WidgetTester tester) async {
      await pumpDashboard(tester);

      // Check for FAB
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('displays refresh button in app bar', (
      WidgetTester tester,
    ) async {
      await pumpDashboard(tester);

      // Check for refresh icon
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });
}
