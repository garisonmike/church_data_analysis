import 'package:church_analytics/models/update_error_type.dart';

/// Centralised, user-readable strings for every [UpdateErrorType].
///
/// ## Usage
/// ```dart
/// final message = UpdateErrorMessages.messageFor(result.errorType!);
/// final action  = UpdateErrorMessages.actionFor(result.errorType!);
/// // Always offer:
/// launchUrl(Uri.parse(UpdateErrorMessages.fallbackUrl));
/// ```
abstract final class UpdateErrorMessages {
  UpdateErrorMessages._();

  // -------------------------------------------------------------------------
  // Constants
  // -------------------------------------------------------------------------

  /// GitHub Releases page — always offered as the ultimate fallback action.
  static const String fallbackUrl =
      'https://github.com/GarisonMike/church_data_analysis/releases';

  /// Human-readable label for the fallback action button.
  static const String fallbackLabel = 'Open GitHub Releases';

  // -------------------------------------------------------------------------
  // Per-type messages
  // -------------------------------------------------------------------------

  /// Returns a short, user-facing description of [type].
  ///
  /// Each message is distinct and describes what went wrong without
  /// exposing internal technical details.
  static String messageFor(UpdateErrorType type) {
    return switch (type) {
      UpdateErrorType.networkError =>
        'Unable to reach the update server. '
            'Please check your internet connection and try again.',
      UpdateErrorType.parseError =>
        'The update information could not be read. '
            'The file may be corrupt or in an unrecognised format.',
      UpdateErrorType.downloadError =>
        'The update file could not be downloaded. '
            'Please try again or download it manually from GitHub Releases.',
      UpdateErrorType.checksumMismatch =>
        'Security warning: the downloaded file does not match the expected '
            'checksum. Do not install this file — please download a fresh copy.',
      UpdateErrorType.installError =>
        'The installer could not be launched. '
            'Please download and run it manually from GitHub Releases.',
      UpdateErrorType.unsupportedPlatform =>
        'Automatic updates are not supported on this platform. '
            'Please download the latest version from GitHub Releases.',
    };
  }

  /// Returns a short action label that tells the user what to do about [type].
  static String actionFor(UpdateErrorType type) {
    return switch (type) {
      UpdateErrorType.networkError => 'Check connection and retry',
      UpdateErrorType.parseError =>
        'Try again later or download manually from GitHub Releases',
      UpdateErrorType.downloadError =>
        'Retry the download or get the installer from GitHub Releases',
      UpdateErrorType.checksumMismatch =>
        'Re-download from GitHub Releases to get a verified copy',
      UpdateErrorType.installError =>
        'Download and install manually from GitHub Releases',
      UpdateErrorType.unsupportedPlatform =>
        'Download the latest version from GitHub Releases',
    };
  }
}
