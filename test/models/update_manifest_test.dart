// Tests for UpdateManifest and PlatformAsset — UPDATE-001
// Covers: valid JSON, unknown fields ignored, missing required fields,
// type errors, format validation, PlatformAsset validation, edge cases.

import 'dart:convert';

import 'package:church_analytics/models/update_manifest.dart';
import 'package:church_analytics/models/update_manifest_parse_exception.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Test data helpers
// ---------------------------------------------------------------------------

const _validAndroid = {
  'download_url':
      'https://github.com/user/repo/releases/download/v1.0.0/app.apk',
  'sha256': 'a3f5d8c9e2b1f4c6a8d9e7f2b5c4a1d8e9f7c2b6a4d1e8f9c7b2a5d4e1f8c9d2',
};

const _validLinux = {
  'download_url':
      'https://github.com/user/repo/releases/download/v1.0.0/app.tar.gz',
  'sha256': 'b4e6d9c0e3b2f5c7a9d0e8f3b6c5a2d9e0f8c3b7a5d2e9f0c8b3a6d5e2f9c0d3',
};

Map<String, dynamic> _validManifest({Map<String, dynamic>? overrides}) {
  final base = <String, dynamic>{
    'version': '1.2.0',
    'release_date': '2026-03-01',
    'min_supported_version': '1.0.0',
    'release_notes': '- Fixed bug',
    'platforms': {
      'android': Map<String, dynamic>.from(_validAndroid),
      'linux': Map<String, dynamic>.from(_validLinux),
    },
  };
  if (overrides != null) base.addAll(overrides);
  return base;
}

// ---------------------------------------------------------------------------
// UpdateManifest.fromJson — valid inputs
// ---------------------------------------------------------------------------

void main() {
  group('UpdateManifest.fromJson — valid manifest', () {
    test('parses all required fields correctly', () {
      final m = UpdateManifest.fromJson(_validManifest());
      expect(m.version, equals('1.2.0'));
      expect(m.releaseDate, equals('2026-03-01'));
      expect(m.minSupportedVersion, equals('1.0.0'));
      expect(m.releaseNotes, equals('- Fixed bug'));
    });

    test('parses android platform asset', () {
      final m = UpdateManifest.fromJson(_validManifest());
      final asset = m.assetFor('android');
      expect(asset, isNotNull);
      expect(asset!.downloadUrl, equals(_validAndroid['download_url']));
      expect(asset.sha256, equals(_validAndroid['sha256']));
    });

    test('parses multiple platform assets', () {
      final m = UpdateManifest.fromJson(_validManifest());
      expect(m.platforms.keys, containsAll(['android', 'linux']));
    });

    test('assetFor returns null for absent platform', () {
      final m = UpdateManifest.fromJson(_validManifest());
      expect(m.assetFor('ios'), isNull);
      expect(m.assetFor('windows'), isNull);
    });

    test('platforms map is unmodifiable', () {
      final m = UpdateManifest.fromJson(_validManifest());
      expect(
        () => m.platforms['new'] = PlatformAsset(
          downloadUrl: 'https://example.com/app',
          sha256: 'a' * 64,
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('unknown top-level fields are ignored', () {
      final json = _validManifest()..['future_field'] = 'ignored';
      expect(() => UpdateManifest.fromJson(json), returnsNormally);
    });

    test('unknown platform fields are ignored', () {
      final json = _validManifest();
      (json['platforms'] as Map)['android']['signature'] = 'future_sig';
      expect(() => UpdateManifest.fromJson(json), returnsNormally);
    });

    test('parses manifest with empty platforms map', () {
      final json = _validManifest(
        overrides: {'platforms': <String, dynamic>{}},
      );
      final m = UpdateManifest.fromJson(json);
      expect(m.platforms, isEmpty);
    });

    test('round-trips through JSON encoding', () {
      final raw = jsonEncode(_validManifest());
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      expect(() => UpdateManifest.fromJson(decoded), returnsNormally);
    });
  });

  // -------------------------------------------------------------------------
  // Version field validation
  // -------------------------------------------------------------------------

  group('UpdateManifest.fromJson — version validation', () {
    test('throws when version is missing', () {
      final json = _validManifest()..remove('version');
      expect(
        () => UpdateManifest.fromJson(json),
        throwsA(
          isA<UpdateManifestParseException>().having(
            (e) => e.field,
            'field',
            'version',
          ),
        ),
      );
    });

    test('throws when version is not a string', () {
      final json = _validManifest(overrides: {'version': 123});
      expect(
        () => UpdateManifest.fromJson(json),
        throwsA(isA<UpdateManifestParseException>()),
      );
    });

    test('throws when version is not semver (missing patch)', () {
      final json = _validManifest(overrides: {'version': '1.2'});
      expect(
        () => UpdateManifest.fromJson(json),
        throwsA(
          isA<UpdateManifestParseException>().having(
            (e) => e.field,
            'field',
            'version',
          ),
        ),
      );
    });

    test('throws when version contains pre-release suffix', () {
      // Schema only allows major.minor.patch — no pre-release
      final json = _validManifest(overrides: {'version': '1.2.0-beta'});
      expect(
        () => UpdateManifest.fromJson(json),
        throwsA(isA<UpdateManifestParseException>()),
      );
    });

    test('accepts multi-digit version components', () {
      final json = _validManifest(overrides: {'version': '10.20.300'});
      expect(() => UpdateManifest.fromJson(json), returnsNormally);
    });
  });

  // -------------------------------------------------------------------------
  // release_date validation
  // -------------------------------------------------------------------------

  group('UpdateManifest.fromJson — release_date validation', () {
    test('throws when release_date is missing', () {
      final json = _validManifest()..remove('release_date');
      expect(
        () => UpdateManifest.fromJson(json),
        throwsA(
          isA<UpdateManifestParseException>().having(
            (e) => e.field,
            'field',
            'release_date',
          ),
        ),
      );
    });

    test('throws when release_date format is wrong (slash-delimited)', () {
      final json = _validManifest(overrides: {'release_date': '2026/03/01'});
      expect(
        () => UpdateManifest.fromJson(json),
        throwsA(isA<UpdateManifestParseException>()),
      );
    });

    test('throws when release_date is not a string', () {
      final json = _validManifest(overrides: {'release_date': 20260301});
      expect(
        () => UpdateManifest.fromJson(json),
        throwsA(isA<UpdateManifestParseException>()),
      );
    });

    test('accepts valid ISO 8601 date', () {
      final json = _validManifest(overrides: {'release_date': '2025-12-31'});
      expect(() => UpdateManifest.fromJson(json), returnsNormally);
    });
  });

  // -------------------------------------------------------------------------
  // min_supported_version validation
  // -------------------------------------------------------------------------

  group('UpdateManifest.fromJson — min_supported_version validation', () {
    test('throws when min_supported_version is missing', () {
      final json = _validManifest()..remove('min_supported_version');
      expect(
        () => UpdateManifest.fromJson(json),
        throwsA(
          isA<UpdateManifestParseException>().having(
            (e) => e.field,
            'field',
            'min_supported_version',
          ),
        ),
      );
    });

    test('throws when min_supported_version is not semver', () {
      final json = _validManifest(
        overrides: {'min_supported_version': 'latest'},
      );
      expect(
        () => UpdateManifest.fromJson(json),
        throwsA(isA<UpdateManifestParseException>()),
      );
    });
  });

  // -------------------------------------------------------------------------
  // release_notes validation
  // -------------------------------------------------------------------------

  group('UpdateManifest.fromJson — release_notes validation', () {
    test('throws when release_notes is missing', () {
      final json = _validManifest()..remove('release_notes');
      expect(
        () => UpdateManifest.fromJson(json),
        throwsA(
          isA<UpdateManifestParseException>().having(
            (e) => e.field,
            'field',
            'release_notes',
          ),
        ),
      );
    });

    test('accepts empty string release_notes', () {
      final json = _validManifest(overrides: {'release_notes': ''});
      expect(() => UpdateManifest.fromJson(json), returnsNormally);
    });

    test('accepts markdown release_notes with newlines', () {
      const notes = '## 1.2.0\n\n- Fix A\n- Fix B';
      final json = _validManifest(overrides: {'release_notes': notes});
      final m = UpdateManifest.fromJson(json);
      expect(m.releaseNotes, equals(notes));
    });
  });

  // -------------------------------------------------------------------------
  // platforms validation
  // -------------------------------------------------------------------------

  group('UpdateManifest.fromJson — platforms validation', () {
    test('throws when platforms is missing', () {
      final json = _validManifest()..remove('platforms');
      expect(
        () => UpdateManifest.fromJson(json),
        throwsA(
          isA<UpdateManifestParseException>().having(
            (e) => e.field,
            'field',
            'platforms',
          ),
        ),
      );
    });

    test('throws when platforms is not a JSON object (is a list)', () {
      final json = _validManifest(overrides: {'platforms': []});
      expect(
        () => UpdateManifest.fromJson(json),
        throwsA(isA<UpdateManifestParseException>()),
      );
    });

    test('throws when platform entry is not an object', () {
      final json = _validManifest();
      // Replace the typed platforms map with a dynamic one that can hold
      // a non-object value, simulating a malformed JSON payload.
      json['platforms'] = <String, dynamic>{
        'android': 'not-an-object',
        'linux': Map<String, dynamic>.from(_validLinux),
      };
      expect(
        () => UpdateManifest.fromJson(json),
        throwsA(
          isA<UpdateManifestParseException>().having(
            (e) => e.field,
            'field',
            'platforms.android',
          ),
        ),
      );
    });
  });

  // -------------------------------------------------------------------------
  // Top-level structural errors
  // -------------------------------------------------------------------------

  group('UpdateManifest.fromJson — structural errors', () {
    test('throws when input is null', () {
      expect(
        () => UpdateManifest.fromJson(null),
        throwsA(isA<UpdateManifestParseException>()),
      );
    });

    test('throws when input is a list, not an object', () {
      expect(
        () => UpdateManifest.fromJson([]),
        throwsA(isA<UpdateManifestParseException>()),
      );
    });

    test('throws when input is a string', () {
      expect(
        () => UpdateManifest.fromJson('{"version":"1.0.0"}'),
        throwsA(isA<UpdateManifestParseException>()),
      );
    });
  });

  // -------------------------------------------------------------------------
  // PlatformAsset.fromJson validation
  // -------------------------------------------------------------------------

  group('PlatformAsset.fromJson', () {
    test('throws when download_url is missing', () {
      final json = Map<String, dynamic>.from(_validAndroid)
        ..remove('download_url');
      expect(
        () => PlatformAsset.fromJson(json, 'android'),
        throwsA(
          isA<UpdateManifestParseException>().having(
            (e) => e.field,
            'field',
            'platforms.android.download_url',
          ),
        ),
      );
    });

    test('throws when download_url uses http (not https)', () {
      final json = Map<String, dynamic>.from(_validAndroid)
        ..['download_url'] =
            'http://github.com/user/repo/releases/download/v1.0.0/app.apk';
      expect(
        () => PlatformAsset.fromJson(json, 'android'),
        throwsA(isA<UpdateManifestParseException>()),
      );
    });

    test('throws when sha256 is missing', () {
      final json = Map<String, dynamic>.from(_validAndroid)..remove('sha256');
      expect(
        () => PlatformAsset.fromJson(json, 'android'),
        throwsA(
          isA<UpdateManifestParseException>().having(
            (e) => e.field,
            'field',
            'platforms.android.sha256',
          ),
        ),
      );
    });

    test('throws when sha256 is not 64 hex chars (too short)', () {
      final json = Map<String, dynamic>.from(_validAndroid)
        ..['sha256'] = 'abc123';
      expect(
        () => PlatformAsset.fromJson(json, 'android'),
        throwsA(isA<UpdateManifestParseException>()),
      );
    });

    test('throws when sha256 contains non-hex characters', () {
      final json = Map<String, dynamic>.from(_validAndroid)
        ..['sha256'] = 'z' * 64;
      expect(
        () => PlatformAsset.fromJson(json, 'android'),
        throwsA(isA<UpdateManifestParseException>()),
      );
    });

    test('accepts uppercase hex sha256', () {
      final json = Map<String, dynamic>.from(_validAndroid)
        ..['sha256'] = 'A' * 64;
      expect(() => PlatformAsset.fromJson(json, 'android'), returnsNormally);
    });

    test('unknown extra fields are ignored', () {
      final json = Map<String, dynamic>.from(_validAndroid)
        ..['signature'] = 'future-value';
      expect(() => PlatformAsset.fromJson(json, 'android'), returnsNormally);
    });
  });

  // -------------------------------------------------------------------------
  // UpdateManifestParseException
  // -------------------------------------------------------------------------

  group('UpdateManifestParseException', () {
    test('toString includes message', () {
      final e = UpdateManifestParseException('bad field');
      expect(e.toString(), contains('bad field'));
    });

    test('toString includes field when provided', () {
      final e = UpdateManifestParseException('bad', field: 'version');
      expect(e.toString(), contains('version'));
    });

    test('toString includes invalidValue when provided', () {
      final e = UpdateManifestParseException(
        'bad',
        field: 'version',
        invalidValue: 42,
      );
      expect(e.toString(), contains('42'));
    });

    test('is an Exception', () {
      final e = UpdateManifestParseException('test');
      expect(e, isA<Exception>());
    });
  });
}
