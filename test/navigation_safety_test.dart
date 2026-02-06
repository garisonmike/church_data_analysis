import 'package:church_analytics/ui/screens/not_found_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Navigation Safety', () {
    testWidgets('NotFoundScreen displays correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: NotFoundScreen(attemptedRoute: '/test-route')),
      );

      expect(find.byType(NotFoundScreen), findsOneWidget);
      expect(find.text('Route: /test-route'), findsOneWidget);
      expect(find.text('Go Home'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('NotFoundScreen without route displays correctly', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: NotFoundScreen()));

      expect(find.byType(NotFoundScreen), findsOneWidget);
      expect(find.text('Go Home'), findsOneWidget);
      // Should not display route text when null
      expect(find.textContaining('Route:'), findsNothing);
    });

    testWidgets('NotFoundScreen navigates home on button press', (
      tester,
    ) async {
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const NotFoundScreen(attemptedRoute: '/bad-route'),
        ),
      );

      expect(find.byType(NotFoundScreen), findsOneWidget);

      // Tap go home button
      await tester.tap(find.text('Go Home'));
      await tester.pumpAndSettle();

      // Should navigate to root '/'
      expect(navigatorKey.currentState!.canPop(), isFalse);
    });
  });
}
