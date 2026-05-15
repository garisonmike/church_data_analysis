import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Ensures the app has permission to install unknown APKs on Android 8+.
///
/// Returns `true` immediately on any non-Android platform (no permission
/// concept exists there).
///
/// On Android, checks the runtime status of [Permission.requestInstallPackages]:
///
/// - **Granted** → returns `true` immediately, no UI shown.
/// - **Denied** → shows an [AlertDialog] explaining why the permission is
///   needed.  If the user agrees, opens the system Settings screen via
///   [openAppSettings] and re-checks on return.  If they still decline, or if
///   they cancelled the dialog, returns `false`.
///
/// ## Call site
/// Call this inside [AboutUpdatesCard._onDownloadUpdate] before starting the
/// download.  If it returns `false`, return early without downloading.
///
/// ```dart
/// if (Platform.isAndroid) {
///   final hasPermission = await ensureInstallPermissionGranted(context);
///   if (!hasPermission) return;
/// }
/// ```
///
/// ## Why not in PlatformInstallerLaunchService?
/// The permission check must happen *before* the download so the user is not
/// kept waiting for a large file to complete only to be told at install time
/// that permission is missing.  The install service runs *after* the download;
/// placing the proactive check in the download-trigger call site keeps the two
/// concerns separate and preserves the install service's existing reactive
/// fallback as a safety net.
Future<bool> ensureInstallPermissionGranted(BuildContext context) async {
  // Non-Android platforms don't have this permission model.
  if (!Platform.isAndroid) return true;

  final status = await Permission.requestInstallPackages.status;
  if (status.isGranted) return true;

  // Guard: dialog requires a live context.
  if (!context.mounted) return false;

  final agreed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('Permission Required'),
      content: const Text(
        'To install updates directly, Church Analytics needs permission to '
        'install apps from unknown sources.\n\n'
        'You will be taken to the system settings to enable this. '
        'Return here once the permission is granted.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Open Settings'),
        ),
      ],
    ),
  );

  if (agreed != true) return false;

  // Open the system settings page for this app's install-unknown-apps toggle.
  await openAppSettings();

  // Re-check after the user returns from Settings.
  return (await Permission.requestInstallPackages.status).isGranted;
}
