import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class AppDataPathService {
  static const String dbFileName = 'church_analytics.db';
  static const String legacyDbFileName = 'church_analytics.db';

  /// Returns the app data directory for storing databases and app files.
  static Future<String> getAppDataDirectory() async {
    final dir = await getApplicationSupportDirectory();
    return dir.path;
  }

  /// Returns legacy documents directory path (used by older versions).
  static Future<String> getLegacyDocumentsDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  /// Logs paths for debugging in debug builds only.
  static void debugLogPaths({
    required String appDataPath,
    required String legacyPath,
  }) {
    if (!kDebugMode) return;
    debugPrint('App data path: $appDataPath');
    debugPrint('Legacy documents path: $legacyPath');
  }
}
