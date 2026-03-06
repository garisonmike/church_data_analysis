import 'dart:io';

import 'package:church_analytics/services/file_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Maximum characters displayed for an export path before truncation.
const _kPathMaxLength = 60;

/// Builds and shows [SnackBar]s for export/import results.
///
/// Usage — success:
/// ```dart
/// ExportResultSnackBar.show(context, result);
/// ```
///
/// Usage — without a result object (e.g. import failure):
/// ```dart
/// ExportResultSnackBar.showError(context, errorType: ExportErrorType.unknown);
/// ```
class ExportResultSnackBar {
  ExportResultSnackBar._();

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Shows a [SnackBar] appropriate for [result].
  ///
  /// On success: displays the filename and (truncated) path, with an
  /// "Open folder" action button on Android and desktop, and a copy icon
  /// on desktop.
  ///
  /// On failure: displays a human-readable classification of the error and
  /// a suggested remediation action.
  ///
  /// This is the primary entry point for all call sites.
  static void show(BuildContext context, ExportResult result) {
    if (result.success) {
      _showSuccess(context, result);
    } else {
      _showFailure(context, result.error ?? 'Export failed.', result.errorType);
    }
  }

  /// Shows a generic import failure [SnackBar].
  ///
  /// Pass [errorMessage] (raw) and optionally [errorType] for classification.
  static void showImportError(
    BuildContext context, {
    String errorMessage = 'Import failed.',
    ExportErrorType errorType = ExportErrorType.unknown,
  }) {
    _showFailure(context, errorMessage, errorType);
  }

  /// Shows a success [SnackBar] for an import operation.
  static void showImportSuccess(BuildContext context, String filename) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white, fontSize: 14),
                children: [
                  const TextSpan(text: 'Imported: '),
                  TextSpan(
                    text: filename,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.green.shade700,
      duration: const Duration(seconds: 5),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  static void _showSuccess(BuildContext context, ExportResult result) {
    final filePath = result.filePath ?? '';
    final filename = result.filename ?? _basename(filePath);
    final dirPath = _dirname(filePath);
    final displayPath = _truncatePath(filePath);

    final canOpenFolder = _canOpenFolder && filePath.isNotEmpty;
    final canCopyPath = _isDesktop && filePath.isNotEmpty;

    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    children: [
                      const TextSpan(text: 'Saved: '),
                      TextSpan(
                        text: filename,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                if (displayPath.isNotEmpty && !kIsWeb) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayPath,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (canCopyPath)
                        _CopyIconButton(text: filePath, tooltip: 'Copy path'),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.green.shade700,
      duration: const Duration(seconds: 6),
      action: canOpenFolder
          ? SnackBarAction(
              label: 'Open folder',
              textColor: Colors.white,
              onPressed: () => _openFolder(dirPath),
            )
          : null,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void _showFailure(
    BuildContext context,
    String rawError,
    ExportErrorType? errorType,
  ) {
    final type = errorType ?? ExportErrorType.unknown;
    final title = _errorTitle(type);
    final remediation = _errorRemediation(type);

    final snackBar = SnackBar(
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.error_outline, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  remediation,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.red.shade700,
      duration: const Duration(seconds: 8),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  // -------------------------------------------------------------------------
  // Platform helpers
  // -------------------------------------------------------------------------

  /// Whether the device supports an "Open folder" action.
  ///
  /// True on Android and native desktop; false on Web and iOS.
  static bool get _canOpenFolder {
    if (kIsWeb) return false;
    return !Platform.isIOS;
  }

  /// Whether the device is a native desktop.
  static bool get _isDesktop {
    if (kIsWeb) return false;
    return Platform.isLinux || Platform.isWindows || Platform.isMacOS;
  }

  /// Opens the file manager at [dirPath] using the OS default handler.
  static Future<void> _openFolder(String dirPath) async {
    if (kIsWeb || dirPath.isEmpty) return;
    try {
      if (Platform.isLinux) {
        await Process.run('xdg-open', [dirPath]);
      } else if (Platform.isWindows) {
        await Process.run('explorer', [dirPath]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [dirPath]);
      } else if (Platform.isAndroid) {
        // On Android, no reliable intent can be fired from pure Dart.
        // The button is shown, but graceful no-op is acceptable.
        if (kDebugMode) {
          debugPrint('[ExportResultSnackBar] Open folder: $dirPath');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ExportResultSnackBar] Could not open folder: $e');
      }
    }
  }

  // -------------------------------------------------------------------------
  // String helpers
  // -------------------------------------------------------------------------

  /// Truncates [path] to at most [_kPathMaxLength] characters.
  static String _truncatePath(String path) {
    if (path.isEmpty || path.length <= _kPathMaxLength) return path;
    final half = (_kPathMaxLength ~/ 2) - 2;
    return '${path.substring(0, half)}…${path.substring(path.length - half)}';
  }

  static String _basename(String path) {
    if (path.isEmpty) return '';
    // Handle both / and \ separators.
    final parts = path.split(RegExp(r'[/\\]'));
    return parts.lastWhere((p) => p.isNotEmpty, orElse: () => path);
  }

  static String _dirname(String path) {
    if (path.isEmpty) return '';
    final sep = path.contains('/') ? '/' : r'\';
    final idx = path.lastIndexOf(sep);
    return idx > 0 ? path.substring(0, idx) : path;
  }

  // -------------------------------------------------------------------------
  // Error message helpers
  // -------------------------------------------------------------------------

  static String _errorTitle(ExportErrorType type) {
    switch (type) {
      case ExportErrorType.permissionDenied:
        return 'Permission denied';
      case ExportErrorType.invalidPath:
        return 'Invalid save location';
      case ExportErrorType.storageFull:
        return 'Not enough storage';
      case ExportErrorType.platformError:
        return 'Platform error';
      case ExportErrorType.unknown:
        return 'Export failed';
    }
  }

  static String _errorRemediation(ExportErrorType type) {
    switch (type) {
      case ExportErrorType.permissionDenied:
        return 'Check storage permissions in device Settings.';
      case ExportErrorType.invalidPath:
        return 'Try selecting a different save location.';
      case ExportErrorType.storageFull:
        return 'Free up storage space and try again.';
      case ExportErrorType.platformError:
        return 'The platform did not complete the save. Try again.';
      case ExportErrorType.unknown:
        return 'Please try again or contact support.';
    }
  }
}

// -------------------------------------------------------------------------
// _CopyIconButton — small icon that copies text to clipboard.
// Only rendered on desktop; invisible on other platforms.
// -------------------------------------------------------------------------

class _CopyIconButton extends StatefulWidget {
  final String text;
  final String tooltip;

  const _CopyIconButton({required this.text, this.tooltip = 'Copy'});

  @override
  State<_CopyIconButton> createState() => _CopyIconButtonState();
}

class _CopyIconButtonState extends State<_CopyIconButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _copied ? 'Copied!' : widget.tooltip,
      child: GestureDetector(
        onTap: _copy,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            _copied ? Icons.check : Icons.copy,
            color: Colors.white70,
            size: 14,
          ),
        ),
      ),
    );
  }
}
