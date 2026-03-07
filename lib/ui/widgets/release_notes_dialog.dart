import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// ---------------------------------------------------------------------------
// ReleaseNotesDialog
// ---------------------------------------------------------------------------

/// Modal dialog that renders the `release_notes` field from an
/// [UpdateManifest] as formatted Markdown text.
///
/// ## Usage
/// ```dart
/// await ReleaseNotesDialog.show(
///   context,
///   version: '1.2.0',
///   releaseNotes: manifest.releaseNotes,
///   onDownloadUpdate: () => _startDownload(),
/// );
/// ```
///
/// ## Layout
/// The dialog is height-constrained to **75% of the screen height** via
/// [ConstrainedBox] so that very long release notes scroll internally rather
/// than overflowing.  A [SingleChildScrollView] wraps the [MarkdownBody] to
/// allow scrolling.
///
/// ## Actions
/// - **"Download Update"** — calls [onDownloadUpdate] then closes the dialog.
///   Hidden when [onDownloadUpdate] is `null`.
/// - **"Dismiss"** — closes the dialog with no action.
class ReleaseNotesDialog extends StatelessWidget {
  /// The version string used in the dialog title (e.g. `"1.2.0"`).
  final String version;

  /// Markdown-formatted release notes from [UpdateManifest.releaseNotes].
  ///
  /// Supports: headings, bullet lists, bold, italic, and inline code.
  final String releaseNotes;

  /// Callback invoked when the user taps "Download Update".
  ///
  /// Pass `null` to hide the button (e.g. when the download flow is not yet
  /// available on the current platform).
  final VoidCallback? onDownloadUpdate;

  const ReleaseNotesDialog._({
    required this.version,
    required this.releaseNotes,
    this.onDownloadUpdate,
  });

  // -------------------------------------------------------------------------
  // Static helper
  // -------------------------------------------------------------------------

  /// Shows the [ReleaseNotesDialog] as a [showDialog] call.
  ///
  /// Returns a [Future] that completes when the dialog is dismissed.
  static Future<void> show(
    BuildContext context, {
    required String version,
    required String releaseNotes,
    VoidCallback? onDownloadUpdate,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => ReleaseNotesDialog._(
        version: version,
        releaseNotes: releaseNotes,
        onDownloadUpdate: onDownloadUpdate,
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('What\'s new in v$version'),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.75),
        child: releaseNotes.trim().isEmpty
            ? Text(
                'No release notes available.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            : SingleChildScrollView(
                child: MarkdownBody(
                  data: releaseNotes,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                    p: theme.textTheme.bodyMedium,
                    // Ensure code blocks use a monospace style.
                    code: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
      ),
      actions: [
        // "Dismiss" always present — closes the dialog with no side-effect.
        TextButton(
          key: const ValueKey('release_notes_dismiss_button'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Dismiss'),
        ),
        // "Download Update" only rendered when a callback is provided.
        if (onDownloadUpdate != null)
          FilledButton.icon(
            key: const ValueKey('release_notes_download_button'),
            onPressed: () {
              Navigator.of(context).pop();
              onDownloadUpdate!();
            },
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Download Update'),
          ),
      ],
    );
  }
}
