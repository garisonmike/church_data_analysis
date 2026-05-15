import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// UpdateDownloadProgressDialog
// ---------------------------------------------------------------------------

/// Modal progress dialog displayed while [UpdateDownloadService] streams an
/// installer file.
///
/// ## Usage
/// ```dart
/// final progressNotifier = ValueNotifier<double>(0.0);
/// final cancelToken = CancelToken();
///
/// // Fire-and-forget — dialog will be closed by the caller via Navigator.pop.
/// unawaited(UpdateDownloadProgressDialog.show(
///   context,
///   progress: progressNotifier,
///   onCancel: () {
///     cancelToken.cancel();
///     Navigator.of(context, rootNavigator: true).pop();
///   },
/// ));
///
/// final result = await service.download(
///   manifest: manifest,
///   destDir: tempDir,
///   onProgress: (p) => progressNotifier.value = p,
///   cancelToken: cancelToken,
/// );
///
/// if (mounted) Navigator.of(context, rootNavigator: true).pop();
/// progressNotifier.dispose();
/// ```
///
/// ## Progress display
/// - When the [progress] notifier value is `<= 0.0` the indicator is
///   **indeterminate** (spinning).
/// - When the value is `> 0.0` a determinate [LinearProgressIndicator] is
///   shown with a percentage label.
///
/// ## Cancellation
/// The "Cancel" button invokes [onCancel].  The **caller** is responsible for
/// popping the dialog; this widget never pops itself.
///
/// The dialog is non-dismissable (`barrierDismissible: false`).
class UpdateDownloadProgressDialog extends StatelessWidget {
  /// Download progress fraction (`0.0`–`1.0`).
  ///
  /// Pass `<= 0.0` to display an indeterminate indicator (e.g. before the
  /// first chunk arrives).
  final ValueListenable<double> progress;

  /// Optional filename displayed as subtitle text below the indicator.
  final String? filename;

  /// Called when the user taps **Cancel**.
  ///
  /// The caller must handle [CancelToken.cancel] and [Navigator.pop] inside
  /// this callback.
  final VoidCallback onCancel;

  /// Called when the user taps **Pause** (FEAT-006).
  ///
  /// When non-null, a Pause button is shown alongside Cancel.  The caller is
  /// responsible for setting [PauseToken.pause] and allowing the download loop
  /// to return [UpdateDownloadResult.paused]; the dialog will be closed by the
  /// caller once that result is received (not by this widget).
  ///
  /// When `null`, no Pause button is shown (e.g. for resumed segments where
  /// the caller opts not to support re-pausing).
  final VoidCallback? onPause;

  const UpdateDownloadProgressDialog._({
    required this.progress,
    required this.onCancel,
    this.filename,
    this.onPause,
  });

  // -------------------------------------------------------------------------
  // Static helper
  // -------------------------------------------------------------------------

  /// Shows the dialog modally.  Returns a future that completes when the
  /// dialog is dismissed (by the caller via [Navigator.pop]).
  ///
  /// The dialog sets `barrierDismissible: false` so the user must tap
  /// **Cancel** to close it.
  static Future<void> show(
    BuildContext context, {
    required ValueListenable<double> progress,
    required VoidCallback onCancel,
    String? filename,
    VoidCallback? onPause, // FEAT-006
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => UpdateDownloadProgressDialog._(
        progress: progress,
        onCancel: onCancel,
        filename: filename,
        onPause: onPause,
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Downloading Update'),
      content: ValueListenableBuilder<double>(
        valueListenable: progress,
        builder: (context, value, _) {
          final hasProgress = value > 0.0;
          final clamped = value.clamp(0.0, 1.0);

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filename subtitle (shown when provided).
              if (filename != null) ...[
                Text(
                  filename!,
                  key: const ValueKey('download_filename_text'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],

              // Determinate or indeterminate progress bar.
              LinearProgressIndicator(
                key: const ValueKey('download_progress_indicator'),
                value: hasProgress ? clamped : null,
              ),
              const SizedBox(height: 8),

              // Percentage label (only when progress is known).
              if (hasProgress)
                Text(
                  key: const ValueKey('download_percentage_text'),
                  '${(clamped * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.bodySmall,
                )
              else
                Text(
                  'Downloading…',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          key: const ValueKey('cancel_download_button'),
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
        // FEAT-006: Pause button — only shown when the caller supports pausing.
        if (onPause != null)
          TextButton(
            key: const ValueKey('pause_download_button'),
            onPressed: onPause,
            child: const Text('Pause'),
          ),
      ],
    );
  }
}
