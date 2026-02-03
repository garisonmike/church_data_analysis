import 'dart:io';

import 'package:church_analytics/services/app_data_path_service.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final appDataPath = await AppDataPathService.getAppDataDirectory();
    final legacyPath = await AppDataPathService.getLegacyDocumentsDirectory();
    AppDataPathService.debugLogPaths(
      appDataPath: appDataPath,
      legacyPath: legacyPath,
    );

    final newDbFile = File(p.join(appDataPath, AppDataPathService.dbFileName));
    final legacyDbFile = File(
      p.join(legacyPath, AppDataPathService.legacyDbFileName),
    );

    if (!await newDbFile.exists() && await legacyDbFile.exists()) {
      await legacyDbFile.copy(newDbFile.path);
    }

    final file = newDbFile;
    return NativeDatabase(file);
  });
}
