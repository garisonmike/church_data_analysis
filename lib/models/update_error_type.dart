/// Enumerates the distinct failure modes across all stages of the update flow.
///
/// Each value maps to a user-readable message in [UpdateErrorMessages].
enum UpdateErrorType {
  /// The device is offline or the update server is unreachable.
  networkError,

  /// An update source URL failed HTTPS security validation.
  ///
  /// This indicates a misconfigured or potentially tampered manifest URL,
  /// not a network connectivity problem.
  securityError,

  /// The update manifest could not be decoded or failed schema validation.
  parseError,

  /// The installer file could not be downloaded from the remote server.
  downloadError,

  /// There is not enough free disk space to download and save the installer.
  ///
  /// The user must free up storage before retrying the download.
  insufficientDiskSpace,

  /// The downloaded installer's SHA-256 hash does not match the manifest.
  ///
  /// This is a security-level failure and must never be silently ignored.
  checksumMismatch,

  /// The installer could not be launched or executed on the current platform.
  installError,

  /// Automatic installation is not supported on the current platform.
  unsupportedPlatform,
}
