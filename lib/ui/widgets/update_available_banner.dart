import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// UpdateAvailableBanner
// ---------------------------------------------------------------------------

/// Non-blocking notification banner displayed at the top of the dashboard
/// body when a background update check finds a newer version (UPDATE-013).
///
/// The banner is intentionally lightweight — it contains a short message,
/// a **Go to Settings** action button, and a dismiss ×.  It does not block
/// any UI interaction.
///
/// ## Keys (for widget testing)
/// - `ValueKey('update_available_banner')` — the banner root
/// - `ValueKey('update_available_banner_dismiss')` — the × dismiss button
/// - `ValueKey('update_available_banner_settings')` — the Settings CTA
///
/// ## Usage
/// ```dart
/// if (_showUpdateBanner)
///   UpdateAvailableBanner(
///     version: _latestUpdateVersion!,
///     onDismiss: () => setState(() => _showUpdateBanner = false),
///     onGoToSettings: _navigateToSettings,
///   ),
/// ```
class UpdateAvailableBanner extends StatelessWidget {
  const UpdateAvailableBanner({
    super.key,
    required this.version,
    required this.onDismiss,
    required this.onGoToSettings,
  });

  /// Latest version string shown in the banner (e.g. `"1.2.0"`).
  final String version;

  /// Called when the user taps the × dismiss button.
  final VoidCallback onDismiss;

  /// Called when the user taps **Go to Settings**.
  final VoidCallback onGoToSettings;

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      key: const ValueKey('update_available_banner'),
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Icon(
              Icons.system_update_outlined,
              size: 20,
              color: colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Update available: v$version',
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              key: const ValueKey('update_available_banner_settings'),
              onPressed: onGoToSettings,
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onPrimaryContainer,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
              ),
              child: const Text('Go to Settings'),
            ),
            IconButton(
              key: const ValueKey('update_available_banner_dismiss'),
              icon: const Icon(Icons.close, size: 18),
              onPressed: onDismiss,
              tooltip: 'Dismiss',
              color: colorScheme.onPrimaryContainer,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    );
  }
}
