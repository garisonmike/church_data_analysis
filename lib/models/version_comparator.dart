import 'version.dart';

/// Utility class for semantic version comparison.
///
/// All methods are static; this class cannot be instantiated.
///
/// ## Example
/// ```dart
/// VersionComparator.isNewer('1.0.0', '1.1.0'); // true
/// VersionComparator.isNewer('1.0.0', '1.0.0'); // false
/// VersionComparator.isNewer('1.0.0', '0.9.0'); // false
///
/// // Pre-release is treated as older than the equivalent release.
/// VersionComparator.isNewer('1.2.0-beta', '1.2.0'); // true
///
/// // Malformed strings never crash — they return false.
/// VersionComparator.isNewer('not-a-version', '1.0.0'); // false
/// ```
class VersionComparator {
  // Prevent instantiation.
  VersionComparator._();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns `true` when [remote] is strictly newer than [current] according
  /// to semantic versioning rules.
  ///
  /// Both strings are parsed with [Version.tryParse].  If either string is
  /// malformed, this method returns `false` and does **not** throw.
  ///
  /// Pre-release versions (e.g. `"1.2.0-beta"`) are treated as lower than the
  /// corresponding stable release (`"1.2.0"`), so:
  /// ```dart
  /// isNewer('1.2.0-beta', '1.2.0') == true
  /// isNewer('1.2.0', '1.2.0-beta') == false
  /// ```
  static bool isNewer(String current, String remote) {
    final c = Version.tryParse(current);
    final r = Version.tryParse(remote);

    if (c == null || r == null) {
      // One or both strings are malformed — treat as "not newer".
      return false;
    }

    return r > c;
  }

  /// Parses [version] into a [Version] object.
  ///
  /// This is a thin convenience wrapper around [Version.parse].  Throws a
  /// [FormatException] when the string is not a valid semantic version.
  ///
  /// Use [Version.tryParse] directly when you need a null-safe variant that
  /// does not throw.
  static Version parse(String version) => Version.parse(version);
}
