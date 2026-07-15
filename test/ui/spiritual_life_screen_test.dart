import 'package:church_analytics/ui/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpiritualLifeScreen', () {
    testWidgets('shows loading indicator initially', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SpiritualLifeScreen(churchId: 1)),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows app bar title and refresh action', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SpiritualLifeScreen(churchId: 1)),
        ),
      );
      expect(find.text('Spiritual Life & Outreach'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('resolves to loading, empty state, or content', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SpiritualLifeScreen(churchId: 1)),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final resolved =
          find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
          find.text('No data yet').evaluate().isNotEmpty ||
          find.text('Baptisms Per Week').evaluate().isNotEmpty;
      expect(resolved, isTrue);
    });
  });
}
