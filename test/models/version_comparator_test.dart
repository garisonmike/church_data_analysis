import 'package:church_analytics/models/version.dart';
import 'package:church_analytics/models/version_comparator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Version.parse
  // ---------------------------------------------------------------------------

  group('Version.parse', () {
    test('parses a standard three-component version', () {
      final v = Version.parse('1.2.3');
      expect(v.major, 1);
      expect(v.minor, 2);
      expect(v.patch, 3);
      expect(v.preRelease, isNull);
    });

    test('parses a version with a simple pre-release identifier', () {
      final v = Version.parse('1.2.0-beta');
      expect(v.major, 1);
      expect(v.minor, 2);
      expect(v.patch, 0);
      expect(v.preRelease, 'beta');
    });

    test('parses a version with a dotted pre-release identifier', () {
      final v = Version.parse('2.0.0-rc.1');
      expect(v.preRelease, 'rc.1');
    });

    test('strips build metadata and returns stable version', () {
      final v = Version.parse('1.0.0+build.5');
      expect(v.preRelease, isNull);
      expect(v.major, 1);
    });

    test('strips build metadata when pre-release is also present', () {
      final v = Version.parse('1.2.0-beta+exp.sha.5114f85');
      expect(v.preRelease, 'beta');
      expect(v.patch, 0);
    });

    test('parses a zero-component version', () {
      final v = Version.parse('0.0.0');
      expect(v.major, 0);
      expect(v.minor, 0);
      expect(v.patch, 0);
    });

    test('parses large version numbers', () {
      final v = Version.parse('100.200.300');
      expect(v.major, 100);
      expect(v.minor, 200);
      expect(v.patch, 300);
    });

    test('throws FormatException for too few segments', () {
      expect(() => Version.parse('1.2'), throwsFormatException);
    });

    test('throws FormatException for too many segments', () {
      expect(() => Version.parse('1.2.3.4'), throwsFormatException);
    });

    test('throws FormatException for non-integer segment', () {
      expect(() => Version.parse('1.x.0'), throwsFormatException);
    });

    test('throws FormatException for empty string', () {
      expect(() => Version.parse(''), throwsFormatException);
    });

    test('throws FormatException for completely invalid string', () {
      expect(() => Version.parse('not-a-version'), throwsFormatException);
    });
  });

  // ---------------------------------------------------------------------------
  // Version.tryParse
  // ---------------------------------------------------------------------------

  group('Version.tryParse', () {
    test('returns a Version for a valid string', () {
      expect(Version.tryParse('1.0.0'), isNotNull);
    });

    test('returns null for a malformed string (too few segments)', () {
      expect(Version.tryParse('1.0'), isNull);
    });

    test('returns null for a completely invalid string', () {
      expect(Version.tryParse('garbage'), isNull);
    });

    test('returns null for an empty string', () {
      expect(Version.tryParse(''), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Version.toString
  // ---------------------------------------------------------------------------

  group('Version.toString', () {
    test('renders a stable version without pre-release suffix', () {
      expect(Version.parse('1.2.3').toString(), '1.2.3');
    });

    test('renders a pre-release version with suffix', () {
      expect(Version.parse('1.2.0-beta').toString(), '1.2.0-beta');
    });

    test('omits stripped build metadata in toString', () {
      // Build metadata is discarded during parsing.
      expect(Version.parse('1.0.0+meta').toString(), '1.0.0');
    });
  });

  // ---------------------------------------------------------------------------
  // Version equality & hashCode
  // ---------------------------------------------------------------------------

  group('Version equality and hashCode', () {
    test('two identical versions are equal', () {
      expect(Version.parse('1.0.0'), equals(Version.parse('1.0.0')));
    });

    test('versions with different patch are not equal', () {
      expect(Version.parse('1.0.0'), isNot(equals(Version.parse('1.0.1'))));
    });

    test('release and pre-release are not equal', () {
      expect(
        Version.parse('1.0.0'),
        isNot(equals(Version.parse('1.0.0-beta'))),
      );
    });

    test('equal versions have equal hashCodes', () {
      expect(
        Version.parse('2.3.4').hashCode,
        equals(Version.parse('2.3.4').hashCode),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Version ordering (compareTo / operators)
  // ---------------------------------------------------------------------------

  group('Version ordering', () {
    // AC: 1.10.0 is correctly identified as newer than 1.9.0
    test('1.10.0 > 1.9.0 (integer minor comparison, not lexicographic)', () {
      expect(Version.parse('1.10.0') > Version.parse('1.9.0'), isTrue);
      expect(Version.parse('1.9.0') < Version.parse('1.10.0'), isTrue);
    });

    // AC: 1.2.0 is not identified as newer than 1.2.0
    test('1.2.0 is not newer than 1.2.0 (equal versions)', () {
      final a = Version.parse('1.2.0');
      final b = Version.parse('1.2.0');
      expect(a > b, isFalse);
      expect(a < b, isFalse);
      expect(a.compareTo(b), 0);
    });

    // AC: 1.2.1 is identified as newer than 1.2.0
    test('1.2.1 > 1.2.0 (patch bump)', () {
      expect(Version.parse('1.2.1') > Version.parse('1.2.0'), isTrue);
    });

    // AC: 1.2.0-beta is identified as older than 1.2.0
    test('1.2.0-beta < 1.2.0 (pre-release is older than release)', () {
      expect(Version.parse('1.2.0-beta') < Version.parse('1.2.0'), isTrue);
      expect(Version.parse('1.2.0') > Version.parse('1.2.0-beta'), isTrue);
    });

    test('major version bump: 2.0.0 > 1.9.9', () {
      expect(Version.parse('2.0.0') > Version.parse('1.9.9'), isTrue);
    });

    test('minor version bump: 1.1.0 > 1.0.9', () {
      expect(Version.parse('1.1.0') > Version.parse('1.0.9'), isTrue);
    });

    test('>= returns true for equal versions', () {
      expect(Version.parse('1.0.0') >= Version.parse('1.0.0'), isTrue);
    });

    test('<= returns true for equal versions', () {
      expect(Version.parse('1.0.0') <= Version.parse('1.0.0'), isTrue);
    });

    test(
      'two different pre-release identifiers compared lexicographically',
      () {
        // "alpha" < "beta" lexicographically.
        expect(
          Version.parse('1.0.0-alpha') < Version.parse('1.0.0-beta'),
          isTrue,
        );
      },
    );

    test('rc.1 pre-release is older than the release', () {
      expect(Version.parse('1.0.0-rc.1') < Version.parse('1.0.0'), isTrue);
    });

    test('compareTo returns negative when this < other', () {
      expect(
        Version.parse('1.0.0').compareTo(Version.parse('2.0.0')),
        isNegative,
      );
    });

    test('compareTo returns positive when this > other', () {
      expect(
        Version.parse('2.0.0').compareTo(Version.parse('1.0.0')),
        isPositive,
      );
    });

    test('compareTo returns 0 for equal versions including pre-release', () {
      expect(
        Version.parse('1.0.0-beta').compareTo(Version.parse('1.0.0-beta')),
        0,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // VersionComparator.isNewer
  // ---------------------------------------------------------------------------

  group('VersionComparator.isNewer', () {
    // Acceptance criteria
    test('1.10.0 is newer than 1.9.0', () {
      expect(VersionComparator.isNewer('1.9.0', '1.10.0'), isTrue);
    });

    test('1.2.0 is not newer than 1.2.0', () {
      expect(VersionComparator.isNewer('1.2.0', '1.2.0'), isFalse);
    });

    test('1.2.1 is newer than 1.2.0', () {
      expect(VersionComparator.isNewer('1.2.0', '1.2.1'), isTrue);
    });

    test('1.2.0-beta is NOT newer than 1.2.0 (pre-release < release)', () {
      // The pre-release is the *remote*; the installed version is 1.2.0.
      // So current=1.2.0, remote=1.2.0-beta → NOT newer.
      expect(VersionComparator.isNewer('1.2.0', '1.2.0-beta'), isFalse);
    });

    test('1.2.0 IS newer than 1.2.0-beta (upgrade from pre-release)', () {
      // current=1.2.0-beta (older pre-release), remote=1.2.0 (stable release)
      expect(VersionComparator.isNewer('1.2.0-beta', '1.2.0'), isTrue);
    });

    // AC: malformed version returns false without crashing
    test('malformed current version returns false without throwing', () {
      expect(VersionComparator.isNewer('not-valid', '1.0.0'), isFalse);
    });

    test('malformed remote version returns false without throwing', () {
      expect(VersionComparator.isNewer('1.0.0', 'bad!!'), isFalse);
    });

    test('both malformed returns false without throwing', () {
      expect(VersionComparator.isNewer('abc', 'xyz'), isFalse);
    });

    // Additional edge cases
    test('older remote returns false (downgrade scenario)', () {
      expect(VersionComparator.isNewer('1.0.0', '0.9.0'), isFalse);
    });

    test('major bump is detected', () {
      expect(VersionComparator.isNewer('1.9.9', '2.0.0'), isTrue);
    });

    test('empty string for current returns false', () {
      expect(VersionComparator.isNewer('', '1.0.0'), isFalse);
    });

    test('empty string for remote returns false', () {
      expect(VersionComparator.isNewer('1.0.0', ''), isFalse);
    });

    test('version with build metadata is parsed correctly', () {
      // Build metadata is stripped; comparison is purely numeric.
      expect(
        VersionComparator.isNewer('1.0.0+build.1', '1.1.0+build.2'),
        isTrue,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // VersionComparator.parse
  // ---------------------------------------------------------------------------

  group('VersionComparator.parse', () {
    test('delegates to Version.parse and returns correct object', () {
      final v = VersionComparator.parse('3.2.1');
      expect(v.major, 3);
      expect(v.minor, 2);
      expect(v.patch, 1);
    });

    test('throws FormatException for invalid input', () {
      expect(() => VersionComparator.parse('bad'), throwsFormatException);
    });
  });
}
