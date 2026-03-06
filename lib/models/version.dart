/// A parsed semantic version following the [semver 2.0.0](https://semver.org/)
/// specification with three numeric components and an optional pre-release
/// identifier.
///
/// Build-metadata suffixes (`+<metadata>`) are stripped and ignored during
/// parsing and comparison, as required by the semver spec.
///
/// ## Ordering rules
/// * Release versions (`1.2.0`) are ordered higher than the equivalent
///   pre-release version (`1.2.0-beta`).
/// * When both versions carry a pre-release identifier, the pre-release
///   strings are compared lexicographically.
/// * Malformed version strings are handled gracefully via [Version.tryParse],
///   which returns `null` instead of throwing.
///
/// ## Example
/// ```dart
/// final a = Version.parse('1.9.0');
/// final b = Version.parse('1.10.0');
/// print(b > a); // true
///
/// final pre = Version.parse('1.2.0-beta');
/// final rel = Version.parse('1.2.0');
/// print(rel > pre); // true
/// ```
class Version implements Comparable<Version> {
  /// Major version number (the `X` in `X.Y.Z`).
  final int major;

  /// Minor version number (the `Y` in `X.Y.Z`).
  final int minor;

  /// Patch version number (the `Z` in `X.Y.Z`).
  final int patch;

  /// Pre-release identifier, or `null` for a stable release.
  ///
  /// E.g. `"beta"` for `"1.2.0-beta"`, `"rc.1"` for `"1.2.0-rc.1"`.
  final String? preRelease;

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  /// Creates a [Version] with the given components.
  ///
  /// [preRelease] is optional; pass `null` (default) for a stable release.
  const Version(this.major, this.minor, this.patch, {this.preRelease});

  // ---------------------------------------------------------------------------
  // Factories
  // ---------------------------------------------------------------------------

  /// Parses [version] into a [Version] object.
  ///
  /// Accepts the formats:
  /// ```
  /// major.minor.patch
  /// major.minor.patch-preRelease
  /// major.minor.patch-preRelease+buildMetadata
  /// major.minor.patch+buildMetadata
  /// ```
  ///
  /// Build-metadata is silently discarded.
  ///
  /// Throws [FormatException] when the string does not conform to the expected
  /// format (non-integer components, wrong segment count, etc.).
  static Version parse(String version) {
    // Strip build metadata ("+…") first.
    final withoutBuild = version.split('+').first;

    // Split on the first '-' to isolate the pre-release identifier.
    final dashIndex = withoutBuild.indexOf('-');
    final versionCore = dashIndex == -1
        ? withoutBuild
        : withoutBuild.substring(0, dashIndex);
    final preReleasePart = dashIndex == -1
        ? null
        : withoutBuild.substring(dashIndex + 1);

    final segments = versionCore.split('.');
    if (segments.length != 3) {
      throw FormatException(
        'Version must have exactly three dot-separated segments; '
        'got: "$version"',
      );
    }

    final parsedSegments = segments.map((s) {
      final n = int.tryParse(s);
      if (n == null || n < 0) {
        throw FormatException(
          'Version segment "$s" is not a non-negative integer '
          'in version string: "$version"',
        );
      }
      return n;
    }).toList();

    return Version(
      parsedSegments[0],
      parsedSegments[1],
      parsedSegments[2],
      preRelease: (preReleasePart?.isEmpty ?? true) ? null : preReleasePart,
    );
  }

  /// Attempts to parse [version]; returns `null` on any parse failure instead
  /// of throwing.
  ///
  /// This is the safe variant intended for use in error-tolerant contexts such
  /// as [VersionComparator.isNewer].
  static Version? tryParse(String version) {
    try {
      return parse(version);
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Comparable / operators
  // ---------------------------------------------------------------------------

  /// Compares this version to [other] according to semver ordering rules.
  ///
  /// Returns a negative value when `this < other`, zero when equal, and a
  /// positive value when `this > other`.
  @override
  int compareTo(Version other) {
    // Compare numeric components first.
    final majorCmp = major.compareTo(other.major);
    if (majorCmp != 0) return majorCmp;

    final minorCmp = minor.compareTo(other.minor);
    if (minorCmp != 0) return minorCmp;

    final patchCmp = patch.compareTo(other.patch);
    if (patchCmp != 0) return patchCmp;

    // Numeric core is equal — apply pre-release rules.
    // Semver §9: a pre-release version has lower precedence than the
    // associated normal version.
    if (preRelease == null && other.preRelease == null) return 0;
    if (preRelease == null) return 1; // this is release; other is pre-release
    if (other.preRelease == null)
      return -1; // this is pre-release; other is release

    // Both carry pre-release identifiers — compare lexicographically.
    return preRelease!.compareTo(other.preRelease!);
  }

  /// Returns `true` when this version is strictly greater than [other].
  bool operator >(Version other) => compareTo(other) > 0;

  /// Returns `true` when this version is strictly less than [other].
  bool operator <(Version other) => compareTo(other) < 0;

  /// Returns `true` when this version is greater than or equal to [other].
  bool operator >=(Version other) => compareTo(other) >= 0;

  /// Returns `true` when this version is less than or equal to [other].
  bool operator <=(Version other) => compareTo(other) <= 0;

  // ---------------------------------------------------------------------------
  // Equality / hash / string
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Version &&
          major == other.major &&
          minor == other.minor &&
          patch == other.patch &&
          preRelease == other.preRelease;

  @override
  int get hashCode => Object.hash(major, minor, patch, preRelease);

  /// Returns the canonical string representation (`"major.minor.patch"` or
  /// `"major.minor.patch-preRelease"`).
  @override
  String toString() {
    final buffer = StringBuffer('$major.$minor.$patch');
    if (preRelease != null) buffer.write('-$preRelease');
    return buffer.toString();
  }
}
