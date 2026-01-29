import 'package:church_analytics/ui/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeeklyEntryScreen', () {
    testWidgets('displays all required form fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: WeeklyEntryScreen())),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Check that the title is displayed
      expect(find.text('New Weekly Entry'), findsOneWidget);

      // Check attendance section header
      expect(find.text('Attendance'), findsOneWidget);

      // Check attendance fields
      expect(find.text('Men'), findsOneWidget);
      expect(find.text('Women'), findsOneWidget);
      expect(find.text('Youth'), findsOneWidget);
      expect(find.text('Children'), findsOneWidget);
      expect(find.text('Sunday Home Church'), findsOneWidget);

      // Check financial section header
      expect(find.text('Financial Data'), findsOneWidget);

      // Check financial fields
      expect(find.text('Tithe'), findsOneWidget);
      expect(find.text('Offerings'), findsOneWidget);
      expect(find.text('Emergency Collection'), findsOneWidget);
      expect(find.text('Planned Collection'), findsOneWidget);

      // Check date picker
      expect(find.text('Week Start Date'), findsOneWidget);

      // Check save button exists
      expect(find.text('Save Record'), findsOneWidget);
    });

    testWidgets('form fields accept numeric input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: WeeklyEntryScreen())),
      );

      await tester.pumpAndSettle();

      // Enter text in men field
      final menField = find.widgetWithText(TextFormField, 'Men');
      await tester.enterText(menField, '50');
      await tester.pumpAndSettle();

      // Verify the text was entered
      expect(find.text('50'), findsOneWidget);

      // Scroll to and test financial fields
      await tester.ensureVisible(find.widgetWithText(TextFormField, 'Tithe'));
      await tester.pumpAndSettle();

      final titheField = find.widgetWithText(TextFormField, 'Tithe');
      await tester.enterText(titheField, '1000.50');
      await tester.pumpAndSettle();

      // Verify the text was entered
      expect(find.text('1000.50'), findsOneWidget);
    });
  });
}
