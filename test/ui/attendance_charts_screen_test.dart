import 'package:church_analytics/ui/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttendanceChartsScreen', () {
    testWidgets('displays loading indicator initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: AttendanceChartsScreen(churchId: 1)),
        ),
      );

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays app bar title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: AttendanceChartsScreen(churchId: 1)),
        ),
      );

      // Check app bar title
      expect(find.text('Attendance Charts'), findsOneWidget);
    });

    testWidgets('displays refresh button in app bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: AttendanceChartsScreen(churchId: 1)),
        ),
      );

      // Check for refresh icon
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });
}
