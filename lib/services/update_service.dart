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

  /// Structured classification of the failure.
  ///
  /// Non-null only when the check failed ([isError] is `true`).
  final UpdateErrorType? errorType;

  const UpdateCheckResult._({
    required this.isUpdateAvailable,
    this.latestVersion,
    this.currentVersion,
    this.manifest,
    this.error,
    this.errorType,
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
  ///
  /// [errorType] classifies the root cause.  Defaults to
  /// [UpdateErrorType.networkError] when not specified.
  factory UpdateCheckResult.failure(
    String error, {
    UpdateErrorType errorType = UpdateErrorType.networkError,
  }) => UpdateCheckResult._(
    isUpdateAvailable: false,
    error: error,
    errorType: errorType,
  );

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

    /// Override in tests to pin the cache-buster value.
    int Function()? timestampProvider,
  }) : _client = client ?? http.Client(),
       _manifestUrl = manifestUrl ?? _kDefaultManifestUrl,
       _getPackageInfo = getPackageInfo ?? PackageInfo.fromPlatform,
       _networkTimeout = networkTimeout ?? _kDefaultNetworkTimeout,
       _timestampProvider =
           timestampProvider ?? (() => DateTime.now().millisecondsSinceEpoch);

  final http.Client _client;
  final String _manifestUrl;
  final Future<PackageInfo> Function() _getPackageInfo;
  final Duration _networkTimeout;
  final int Function() _timestampProvider;

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
      // A cache-busting query parameter (?cb=<epoch_ms>) is appended to
      // prevent stale responses on Flutter Web, where browsers and CDNs may
      // aggressively cache the manifest URL (UPDATE-012).
      final response = await _client
          .get(_buildFetchUri())
          .timeout(_networkTimeout);

      if (response.statusCode != 200) {
        return _cache(
          UpdateCheckResult.failure(
            'Server returned HTTP ${response.statusCode}',
            errorType: UpdateErrorType.networkError,
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

      final newer = VersionComparator.isNewer(currentVersion, manifest.version);

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
      return _cache(
        UpdateCheckResult.failure(
          e.message,
          errorType: UpdateErrorType.securityError,
        ),
      );
    } on UpdateManifestParseException catch (e) {
      return _cache(
        UpdateCheckResult.failure(
          e.message,
          errorType: UpdateErrorType.parseError,
        ),
      );
    } on TimeoutException {
      return _cache(
        UpdateCheckResult.failure(
          'Update check timed out after ${_networkTimeout.inSeconds} seconds',
          errorType: UpdateErrorType.networkError,
        ),
      );
    } catch (e) {
      return _cache(
        UpdateCheckResult.failure(
          '$e',
          errorType: UpdateErrorType.networkError,
        ),
      );
    }
  }

  /// Builds the fetch [Uri] from [_manifestUrl] with a cache-busting query
  /// parameter appended.
  ///
  /// The `cb` parameter holds the current epoch in milliseconds, which
  /// guarantees a unique URL on every invocation and prevents browsers, CDNs,
  /// and the Flutter Web service-worker from serving stale cached responses
  /// for `update.json` (UPDATE-012).
  ///
  /// The parameter is harmless on native platforms — GitHub Releases ignores
  /// unknown query parameters — and the session-level [_cachedResult] already
  /// ensures this URI is only fetched once per session (twice after a manual
  /// [resetCache]).
  Uri _buildFetchUri() {
    final base = Uri.parse(_manifestUrl);
    final params = Map<String, String>.from(base.queryParameters)
      ..['cb'] = '${_timestampProvider()}';
    return base.replace(queryParameters: params);
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
