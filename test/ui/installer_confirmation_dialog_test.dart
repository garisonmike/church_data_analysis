import 'package:church_analytics/ui/widgets/installer_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Helper: builds a button that opens the dialog and captures the result.
Widget _buildLauncher({void Function(bool?)? onResult}) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (ctx) => ElevatedButton(
          onPressed: () async {
            final result = await InstallerConfirmationDialog.show(ctx);
            onResult?.call(result);
          },
          child: const Text('Open'),
        ),
      ),
    ),
  );
}

void main() {
  // -------------------------------------------------------------------------
  // Widget content
  // -------------------------------------------------------------------------

  group('InstallerConfirmationDialog — widget content', () {
    testWidgets('renders title, body text, and both action buttons', (
      tester,
    ) async {
      await tester.pumpWidget(_buildLauncher());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('installer_confirmation_dialog')),
        findsOneWidget,
      );
      expect(find.text('Install Update'), findsOneWidget);
      expect(
        find.text('The app will close to complete the update.'),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('installer_confirm_cancel_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('installer_confirm_proceed_button')),
        findsOneWidget,
      );
    });

    testWidgets('Cancel button text is "Cancel"', (tester) async {
      await tester.pumpWidget(_buildLauncher());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final cancelButton = find.byKey(
        const ValueKey('installer_confirm_cancel_button'),
      );
      expect(
        find.descendant(of: cancelButton, matching: find.text('Cancel')),
        findsOneWidget,
      );
    });

    testWidgets('Proceed button text is "Install Now"', (tester) async {
      await tester.pumpWidget(_buildLauncher());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final proceedButton = find.byKey(
        const ValueKey('installer_confirm_proceed_button'),
      );
      expect(
        find.descendant(of: proceedButton, matching: find.text('Install Now')),
        findsOneWidget,
      );
    });
  });

  // -------------------------------------------------------------------------
  // Dialog behaviour (via show())
  // -------------------------------------------------------------------------

  group('InstallerConfirmationDialog.show() behaviour', () {
    testWidgets('dialog appears when show() is called', (tester) async {
      await tester.pumpWidget(_buildLauncher());

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('installer_confirmation_dialog')),
        findsOneWidget,
      );
    });

    testWidgets('Cancel button pops the dialog and returns false', (
      tester,
    ) async {
      bool? dialogResult;

      await tester.pumpWidget(
        _buildLauncher(onResult: (r) => dialogResult = r),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('installer_confirm_cancel_button')),
      );
      await tester.pumpAndSettle();

      expect(dialogResult, isFalse);
      expect(
        find.byKey(const ValueKey('installer_confirmation_dialog')),
        findsNothing,
      );
    });

    testWidgets('Install Now button pops the dialog and returns true', (
      tester,
    ) async {
      bool? dialogResult;

      await tester.pumpWidget(
        _buildLauncher(onResult: (r) => dialogResult = r),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('installer_confirm_proceed_button')),
      );
      await tester.pumpAndSettle();

      expect(dialogResult, isTrue);
      expect(
        find.byKey(const ValueKey('installer_confirmation_dialog')),
        findsNothing,
      );
    });

    testWidgets('dialog is not barrierDismissible', (tester) async {
      await tester.pumpWidget(_buildLauncher());

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap the barrier (outside the dialog).
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Dialog must still be visible.
      expect(
        find.byKey(const ValueKey('installer_confirmation_dialog')),
        findsOneWidget,
      );
    });
  });

  // -------------------------------------------------------------------------
  // Integration: AboutUpdatesCard confirmation skip
  // -------------------------------------------------------------------------
  // These integration tests live in update_install_failure_dialog_test.dart
  // (which injects confirmInstall: (_) async => true) and
  // about_updates_card_test.dart.  No additional integration tests are needed
  // here.
}
