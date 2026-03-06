import 'package:church_analytics/models/update_manifest_parse_exception.dart';

/// A single platform-specific download asset defined within an [UpdateManifest].
///
/// Corresponds to the `platforms.<platform>` object in `update.json`.
/// See `docs/update-contract.md` for the full schema specification.
class PlatformAsset {
  /// HTTPS URL pointing to the installer binary.
  final String downloadUrl;

  /// SHA-256 checksum of the installer, encoded as a 64-character hex string.
  final String sha256;

  const PlatformAsset({required this.downloadUrl, required this.sha256});

  /// Parses a [PlatformAsset] from [json] under the given [platformKey].
  ///
  /// Throws [UpdateManifestParseException] if:
  /// - `download_url` or `sha256` fields are absent or not strings.
  /// - `download_url` does not use the `https://` scheme.
  /// - `sha256` is not a 64-character hex string.
  ///
  /// Unknown additional fields are silently ignored.
  factory PlatformAsset.fromJson(
    Map<String, dynamic> json,
    String platformKey,
  ) {
    final prefix = 'platforms.$platformKey';

    final rawUrl = json['download_url'];
    if (rawUrl == null) {
      throw UpdateManifestParseException(
        'Missing required field',
        field: '$prefix.download_url',
      );
    }
    if (rawUrl is! String) {
      throw UpdateManifestParseException(
        'Expected string',
        field: '$prefix.download_url',
        invalidValue: rawUrl,
      );
    }
    if (!rawUrl.startsWith('https://')) {
      throw UpdateManifestParseException(
        'download_url must use https:// scheme',
        field: '$prefix.download_url',
        invalidValue: rawUrl,
      );
    }

    final rawSha = json['sha256'];
    if (rawSha == null) {
      throw UpdateManifestParseException(
        'Missing required field',
        field: '$prefix.sha256',
      );
    }
    if (rawSha is! String) {
      throw UpdateManifestParseException(
        'Expected string',
        field: '$prefix.sha256',
        invalidValue: rawSha,
      );
    }
    if (!_isValidSha256(rawSha)) {
      throw UpdateManifestParseException(
        'sha256 must be a 64-character hex string',
        field: '$prefix.sha256',
        invalidValue: rawSha,
      );
    }

    return PlatformAsset(downloadUrl: rawUrl, sha256: rawSha);
  }

  /// Returns `true` if [value] is a valid 64-character lowercase or uppercase
  /// hexadecimal string.
  static bool _isValidSha256(String value) =>
      value.length == 64 && RegExp(r'^[0-9a-fA-F]+$').hasMatch(value);

  @override
  String toString() =>
      'PlatformAsset(downloadUrl: $downloadUrl, sha256: $sha256)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlatformAsset &&
          other.downloadUrl == downloadUrl &&
          other.sha256 == sha256);

  @override
  int get hashCode => Object.hash(downloadUrl, sha256);
}

// ---------------------------------------------------------------------------

/// Parsed representation of an `update.json` manifest.
///
/// Use [UpdateManifest.fromJson] to deserialise the manifest document.
/// All validation errors surface as [UpdateManifestParseException].
///
/// See `docs/update-contract.md` for the full schema specification.
class UpdateManifest {
  /// Semantic version of this release (e.g. `"1.2.0"`).
  final String version;

  /// ISO 8601 release date (e.g. `"2026-03-01"`).
  final String releaseDate;

  /// Minimum app version that is eligible to upgrade to this release.
  final String minSupportedVersion;

  /// Markdown-formatted release notes.
  final String releaseNotes;

  /// Per-platform download assets, keyed by platform name
  /// (`"android"`, `"windows"`, `"linux"`, etc.).
  final Map<String, PlatformAsset> platforms;

  const UpdateManifest({
    required this.version,
    required this.releaseDate,
    required this.minSupportedVersion,
    required this.releaseNotes,
    required this.platforms,
  });

  /// Parses an [UpdateManifest] from a decoded JSON [map].
  ///
  /// The [map] should come from `jsonDecode(responseBody)`.
  ///
  /// Throws [UpdateManifestParseException] if:
  /// - [map] is not a `Map<String, dynamic>`.
  /// - Any required top-level field (`version`, `release_date`,
  ///   `min_supported_version`, `release_notes`, `platforms`) is absent or
  ///   has the wrong type.
  /// - [version] or [minSupportedVersion] does not match semver
  ///   `major.minor.patch`.
  /// - [releaseDate] does not match `YYYY-MM-DD`.
  /// - [platforms] is not a JSON object.
  /// - Any contained [PlatformAsset] fails validation.
  ///
  /// Unknown top-level or platform-level fields are silently ignored.
  factory UpdateManifest.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw UpdateManifestParseException(
        'Manifest must be a JSON object',
        invalidValue: json.runtimeType.toString(),
      );
    }

    // --- version ---
    final rawVersion = json['version'];
    if (rawVersion == null) {
      throw UpdateManifestParseException(
        'Missing required field',
        field: 'version',
      );
    }
    if (rawVersion is! String) {
      throw UpdateManifestParseException(
        'Expected string',
        field: 'version',
        invalidValue: rawVersion,
      );
    }
    if (!_isValidSemver(rawVersion)) {
      throw UpdateManifestParseException(
        'version must follow semver (major.minor.patch)',
        field: 'version',
        invalidValue: rawVersion,
      );
    }

    // --- release_date ---
    final rawDate = json['release_date'];
    if (rawDate == null) {
      throw UpdateManifestParseException(
        'Missing required field',
        field: 'release_date',
      );
    }
    if (rawDate is! String) {
      throw UpdateManifestParseException(
        'Expected string',
        field: 'release_date',
        invalidValue: rawDate,
      );
    }
    if (!_isValidIsoDate(rawDate)) {
      throw UpdateManifestParseException(
        'release_date must be ISO 8601 (YYYY-MM-DD)',
        field: 'release_date',
        invalidValue: rawDate,
      );
    }

    // --- min_supported_version ---
    final rawMinVersion = json['min_supported_version'];
    if (rawMinVersion == null) {
      throw UpdateManifestParseException(
        'Missing required field',
        field: 'min_supported_version',
      );
    }
    if (rawMinVersion is! String) {
      throw UpdateManifestParseException(
        'Expected string',
        field: 'min_supported_version',
        invalidValue: rawMinVersion,
      );
    }
    if (!_isValidSemver(rawMinVersion)) {
      throw UpdateManifestParseException(
        'min_supported_version must follow semver (major.minor.patch)',
        field: 'min_supported_version',
        invalidValue: rawMinVersion,
      );
    }

    // --- release_notes ---
    final rawNotes = json['release_notes'];
    if (rawNotes == null) {
      throw UpdateManifestParseException(
        'Missing required field',
        field: 'release_notes',
      );
    }
    if (rawNotes is! String) {
      throw UpdateManifestParseException(
        'Expected string',
        field: 'release_notes',
        invalidValue: rawNotes,
      );
    }

    // --- platforms ---
    final rawPlatforms = json['platforms'];
    if (rawPlatforms == null) {
      throw UpdateManifestParseException(
        'Missing required field',
        field: 'platforms',
      );
    }
    if (rawPlatforms is! Map<String, dynamic>) {
      throw UpdateManifestParseException(
        'platforms must be a JSON object',
        field: 'platforms',
        invalidValue: rawPlatforms.runtimeType.toString(),
      );
    }

    final platforms = <String, PlatformAsset>{};
    for (final entry in rawPlatforms.entries) {
      final platformKey = entry.key;
      final platformValue = entry.value;
      if (platformValue is! Map<String, dynamic>) {
        throw UpdateManifestParseException(
          'platforms.$platformKey must be a JSON object',
          field: 'platforms.$platformKey',
          invalidValue: platformValue.runtimeType.toString(),
        );
      }
      platforms[platformKey] = PlatformAsset.fromJson(
        platformValue,
        platformKey,
      );
    }

    return UpdateManifest(
      version: rawVersion,
      releaseDate: rawDate,
      minSupportedVersion: rawMinVersion,
      releaseNotes: rawNotes,
      platforms: Map.unmodifiable(platforms),
    );
  }

  /// Returns the [PlatformAsset] for [platformName], or `null` if the platform
  /// is not listed in this manifest.
  PlatformAsset? assetFor(String platformName) => platforms[platformName];

  // ---------------------------------------------------------------------------
  // Validation helpers
  // ---------------------------------------------------------------------------

  static final _semverRegexp = RegExp(r'^\d+\.\d+\.\d+$');
  static final _isoDateRegexp = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  static bool _isValidSemver(String v) => _semverRegexp.hasMatch(v);
  static bool _isValidIsoDate(String d) => _isoDateRegexp.hasMatch(d);

  // ---------------------------------------------------------------------------

  @override
  String toString() =>
      'UpdateManifest(version: $version, releaseDate: $releaseDate, '
      'platforms: ${platforms.keys.toList()})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UpdateManifest &&
          other.version == version &&
          other.releaseDate == releaseDate &&
          other.minSupportedVersion == minSupportedVersion &&
          other.releaseNotes == releaseNotes);

  @override
  int get hashCode =>
      Object.hash(version, releaseDate, minSupportedVersion, releaseNotes);
}
