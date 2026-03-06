import 'dart:async';
import 'dart:convert';

import 'package:church_analytics/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

/// Stable URL where the current update manifest is published.
const _kDefaultManifestUrl =
    'https://github.com/GarisonMike/church_data_analysis'
    '/releases/latest/download/update.json';

/// Default network timeout for fetching the update manifest.
const _kDefaultNetworkTimeout = Duration(seconds: 10);

// ---------------------------------------------------------------------------
// UpdateCheckResult
// ---------------------------------------------------------------------------

/// The result returned by [UpdateService.checkForUpdate].
///
/// Three named factories cover the three possible outcomes:
/// - [UpdateCheckResult.available] — a newer version was found.
/// - [UpdateCheckResult.upToDate] — the installed version is current.
/// - [UpdateCheckResult.failure] — the check could not be completed.
class UpdateCheckResult {
  /// Whether a newer version is available for download.
  final bool isUpdateAvailable;

  /// The version string reported in the remote manifest (e.g. `"1.2.0"`).
  /// Null when the check failed.
  final String? latestVersion;

  /// The version string of the currently installed application.
  /// Null when the check failed.
  final String? currentVersion;

  /// The fully-parsed update manifest.  Null when the check failed.
  final UpdateManifest? manifest;

  /// Human-readable error message; non-null only when the check failed.
  final String? error;

  const UpdateCheckResult._({
    required this.isUpdateAvailable,
    this.latestVersion,
    this.currentVersion,
    this.manifest,
    this.error,
  });

  // -------------------------------------------------------------------------
  // Named factories
  // -------------------------------------------------------------------------

  /// A newer version is available.
  factory UpdateCheckResult.available({
    required String latestVersion,
    required String currentVersion,
    required UpdateManifest manifest,
  }) => UpdateCheckResult._(
    isUpdateAvailable: true,
    latestVersion: latestVersion,
    currentVersion: currentVersion,
    manifest: manifest,
  );

  /// The app is already at the latest version.
  factory UpdateCheckResult.upToDate({
    required String latestVersion,
    required String currentVersion,
    required UpdateManifest manifest,
  }) => UpdateCheckResult._(
    isUpdateAvailable: false,
    latestVersion: latestVersion,
    currentVersion: currentVersion,
    manifest: manifest,
  );

  /// The check failed; [error] describes the problem.
  factory UpdateCheckResult.failure(String error) =>
      UpdateCheckResult._(isUpdateAvailable: false, error: error);

  // -------------------------------------------------------------------------
  // Convenience
  // -------------------------------------------------------------------------

  /// `true` when the check failed and an [error] message is present.
  bool get isError => error != null;

  @override
  String toString() {
    if (isError) return 'UpdateCheckResult.failure($error)';
    return 'UpdateCheckResult('
        'isUpdateAvailable=$isUpdateAvailable, '
        'latestVersion=$latestVersion, '
        'currentVersion=$currentVersion)';
  }
}

// ---------------------------------------------------------------------------
// UpdateService
// ---------------------------------------------------------------------------

/// Fetches and caches the remote [UpdateManifest], then compares the remote
/// version against the currently installed application version.
///
/// All constructor parameters are optional so that the service can be injected
/// with test doubles:
///
/// ```dart
/// final service = UpdateService(
///   client: MockClient((_) async => http.Response(jsonEncode(json), 200)),
///   manifestUrl: 'https://example.com/update.json',
///   getPackageInfo: () async => PackageInfo(version: '1.0.0', ...),
/// );
/// ```
///
/// Obtain the production instance through [updateServiceProvider].
class UpdateService {
  UpdateService({
    http.Client? client,
    String? manifestUrl,
    Future<PackageInfo> Function()? getPackageInfo,
    Duration? networkTimeout,
  }) : _client = client ?? http.Client(),
       _manifestUrl = manifestUrl ?? _kDefaultManifestUrl,
       _getPackageInfo = getPackageInfo ?? PackageInfo.fromPlatform,
       _networkTimeout = networkTimeout ?? _kDefaultNetworkTimeout;

  final http.Client _client;
  final String _manifestUrl;
  final Future<PackageInfo> Function() _getPackageInfo;
  final Duration _networkTimeout;

  /// In-memory session cache; non-null once a successful or failed check has
  /// been completed.
  UpdateCheckResult? _cachedResult;

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Returns the cached [UpdateCheckResult] when one exists for this session;
  /// otherwise performs a network fetch, parses the manifest, and caches the
  /// result.
  ///
  /// Never throws — all error paths return [UpdateCheckResult.failure].
  Future<UpdateCheckResult> checkForUpdate() async {
    if (_cachedResult != null) return _cachedResult!;

    try {
      // Security: validate that the URL uses HTTPS before fetching.
      UpdateUrlValidator.validateHttpsUrl(_manifestUrl);

      // Fetch the manifest with the configured timeout.
      final response = await _client
          .get(Uri.parse(_manifestUrl))
          .timeout(_networkTimeout);

      if (response.statusCode != 200) {
        return _cache(
          UpdateCheckResult.failure(
            'Server returned HTTP ${response.statusCode}',
          ),
        );
      }

      // Parse and validate the manifest.  Throws UpdateManifestParseException
      // on any structural or value violation.
      final Object? json = jsonDecode(response.body);
      final manifest = UpdateManifest.fromJson(json);

      // Obtain the installed version from the platform.
      final packageInfo = await _getPackageInfo();
      final currentVersion = packageInfo.version;

      final newer = _isRemoteNewer(
        current: currentVersion,
        remote: manifest.version,
      );

      return _cache(
        newer
            ? UpdateCheckResult.available(
                latestVersion: manifest.version,
                currentVersion: currentVersion,
                manifest: manifest,
              )
            : UpdateCheckResult.upToDate(
                latestVersion: manifest.version,
                currentVersion: currentVersion,
                manifest: manifest,
              ),
      );
    } on UpdateSecurityException catch (e) {
      return _cache(UpdateCheckResult.failure(e.message));
    } on UpdateManifestParseException catch (e) {
      return _cache(UpdateCheckResult.failure(e.message));
    } on TimeoutException {
      return _cache(
        UpdateCheckResult.failure(
          'Update check timed out after ${_networkTimeout.inSeconds} seconds',
        ),
      );
    } catch (e) {
      return _cache(UpdateCheckResult.failure('$e'));
    }
  }

  /// Clears the in-memory cache so that the next [checkForUpdate] call
  /// performs a fresh network fetch.
  ///
  /// Useful after the user manually triggers a re-check (e.g. "Check again"
  /// button) or when the app returns to the foreground.
  void resetCache() => _cachedResult = null;

  // -------------------------------------------------------------------------
  // Internals
  // -------------------------------------------------------------------------

  UpdateCheckResult _cache(UpdateCheckResult result) {
    _cachedResult = result;
    return result;
  }

  /// Lightweight semver comparison (major.minor.patch as integers).
  ///
  /// Returns `true` only when [remote] is strictly greater than [current].
  /// Pre-release / build suffixes are stripped before comparison.
  ///
  /// NOTE: UPDATE-003 will replace this inline logic with the dedicated
  /// [VersionComparator] class once that issue is implemented.
  bool _isRemoteNewer({required String current, required String remote}) {
    try {
      final c = _parseVersion(current);
      final r = _parseVersion(remote);
      for (var i = 0; i < 3; i++) {
        if (r[i] > c[i]) return true;
        if (r[i] < c[i]) return false;
      }
      return false; // equal — not newer
    } catch (_) {
      return false; // malformed version → treat as "not newer"
    }
  }

  /// Parses `"major.minor.patch[-prerelease][+build]"` into `[major, minor,
  /// patch]` as integers.  Throws [FormatException] on invalid input.
  List<int> _parseVersion(String version) {
    // Strip pre-release / build metadata (e.g. "1.2.0-beta+1" → "1.2.0").
    final clean = version.split(RegExp(r'[-+]')).first;
    final parts = clean.split('.');
    if (parts.length != 3) {
      throw FormatException('Not a valid semver string: $version');
    }
    return parts.map(int.parse).toList();
  }
}

// ---------------------------------------------------------------------------
// Riverpod providers
// ---------------------------------------------------------------------------

/// Riverpod [Provider] for the application-wide [UpdateService] singleton.
///
/// The production instance uses the real [http.Client] and
/// [PackageInfo.fromPlatform].  Override in tests with
/// [ProviderContainer.overrides].
final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService();
});

/// Riverpod [AsyncNotifier] that exposes the [UpdateCheckResult] to the UI.
///
/// The first call to [build] triggers [UpdateService.checkForUpdate].
/// Call [refresh] to force a re-check (e.g. from a "Check again" button).
///
/// ```dart
/// // In a ConsumerWidget:
/// final update = ref.watch(updateCheckProvider);
/// update.when(
///   data: (result) => result.isUpdateAvailable
///       ? const UpdateBanner()
///       : const SizedBox.shrink(),
///   loading: () => const CircularProgressIndicator(),
///   error: (e, _) => Text('Update check failed: $e'),
/// );
/// ```
class UpdateCheckNotifier extends AsyncNotifier<UpdateCheckResult> {
  @override
  Future<UpdateCheckResult> build() {
    return ref.read(updateServiceProvider).checkForUpdate();
  }

  /// Forces a re-check by resetting the service cache and rebuilding.
  Future<void> refresh() async {
    ref.read(updateServiceProvider).resetCache();
    ref.invalidateSelf();
    await future;
  }
}

/// Riverpod [AsyncNotifierProvider] for the update-check result.
///
/// Consume with [ref.watch] to rebuild the widget when the check completes
/// or is refreshed.
final updateCheckProvider =
    AsyncNotifierProvider<UpdateCheckNotifier, UpdateCheckResult>(
      UpdateCheckNotifier.new,
    );
