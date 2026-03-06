import 'package:church_analytics/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // -------------------------------------------------------------------------
  // SettingsRepository
  // -------------------------------------------------------------------------

  group('SettingsRepository', () {
    late SharedPreferences prefs;
    late SettingsRepository repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      repo = SettingsRepository(prefs);
    });

    test('getDefaultExportPath returns null when not set', () {
      expect(repo.getDefaultExportPath(), isNull);
    });

    test('setDefaultExportPath persists the path', () async {
      await repo.setDefaultExportPath('/custom/exports');
      expect(repo.getDefaultExportPath(), equals('/custom/exports'));
    });

    test('setDefaultExportPath overwrites a previous value', () async {
      await repo.setDefaultExportPath('/first/path');
      await repo.setDefaultExportPath('/second/path');
      expect(repo.getDefaultExportPath(), equals('/second/path'));
    });

    test('clearDefaultExportPath removes the persisted path', () async {
      await repo.setDefaultExportPath('/some/dir');
      await repo.clearDefaultExportPath();
      expect(repo.getDefaultExportPath(), isNull);
    });

    test('clearDefaultExportPath is idempotent when no path is set', () async {
      await expectLater(repo.clearDefaultExportPath(), completes);
      expect(repo.getDefaultExportPath(), isNull);
    });

    test('path persists across separate instances sharing the same prefs',
        () async {
      await repo.setDefaultExportPath('/shared/dir');

      final repo2 = SettingsRepository(prefs);
      expect(repo2.getDefaultExportPath(), equals('/shared/dir'));
    });
  });

  // -------------------------------------------------------------------------
  // DefaultExportPathNotifier
  // -------------------------------------------------------------------------

  group('DefaultExportPathNotifier', () {
    late SharedPreferences prefs;
    late SettingsRepository repo;
    late DefaultExportPathNotifier notifier;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      repo = SettingsRepository(prefs);
      notifier = DefaultExportPathNotifier(repo);
    });

    test('initial state is null when no path is persisted', () {
      expect(notifier.state, isNull);
    });

    test('initial state loads a previously persisted value', () async {
      await prefs.setString('default_export_path', '/existing/path');
      final n = DefaultExportPathNotifier(SettingsRepository(prefs));
      expect(n.state, equals('/existing/path'));
    });

    test('setCustomPath updates state', () async {
      await notifier.setCustomPath('/new/dir');
      expect(notifier.state, equals('/new/dir'));
    });

    test('setCustomPath persists the path to the repository', () async {
      await notifier.setCustomPath('/new/dir');
      expect(repo.getDefaultExportPath(), equals('/new/dir'));
    });

    test('setCustomPath overwrites previous state', () async {
      await notifier.setCustomPath('/first');
      await notifier.setCustomPath('/second');
      expect(notifier.state, equals('/second'));
    });

    test('clearCustomPath resets state to null', () async {
      await notifier.setCustomPath('/a/path');
      await notifier.clearCustomPath();
      expect(notifier.state, isNull);
    });

    test('clearCustomPath removes the persisted value', () async {
      await notifier.setCustomPath('/a/path');
      await notifier.clearCustomPath();
      expect(repo.getDefaultExportPath(), isNull);
    });

    test('clearCustomPath is safe when state is already null', () async {
      await expectLater(notifier.clearCustomPath(), completes);
      expect(notifier.state, isNull);
    });
  });
}
