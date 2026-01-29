import 'dart:convert';
import 'dart:io';

import 'package:church_analytics/models/models.dart';
import 'package:path_provider/path_provider.dart';

/// Result of a backup operation
class BackupResult {
  final bool success;
  final String? filePath;
  final String? error;
  final BackupMetadata? metadata;

  const BackupResult._({
    required this.success,
    this.filePath,
    this.error,
    this.metadata,
  });

  factory BackupResult.success(String filePath, BackupMetadata metadata) {
    return BackupResult._(
      success: true,
      filePath: filePath,
      metadata: metadata,
    );
  }

  factory BackupResult.error(String error) {
    return BackupResult._(success: false, error: error);
  }
}

/// Result of a restore operation
class RestoreResult {
  final bool success;
  final String? error;
  final int churchesRestored;
  final int adminsRestored;
  final int recordsRestored;

  const RestoreResult._({
    required this.success,
    this.error,
    this.churchesRestored = 0,
    this.adminsRestored = 0,
    this.recordsRestored = 0,
  });

  factory RestoreResult.success({
    required int churches,
    required int admins,
    required int records,
  }) {
    return RestoreResult._(
      success: true,
      churchesRestored: churches,
      adminsRestored: admins,
      recordsRestored: records,
    );
  }

  factory RestoreResult.error(String error) {
    return RestoreResult._(success: false, error: error);
  }

  int get totalRestored => churchesRestored + adminsRestored + recordsRestored;
}

/// Metadata about a backup file
class BackupMetadata {
  final String version;
  final DateTime createdAt;
  final String appVersion;
  final int churchCount;
  final int adminCount;
  final int recordCount;

  const BackupMetadata({
    required this.version,
    required this.createdAt,
    required this.appVersion,
    required this.churchCount,
    required this.adminCount,
    required this.recordCount,
  });

  Map<String, dynamic> toJson() => {
    'version': version,
    'createdAt': createdAt.toIso8601String(),
    'appVersion': appVersion,
    'churchCount': churchCount,
    'adminCount': adminCount,
    'recordCount': recordCount,
  };

  factory BackupMetadata.fromJson(Map<String, dynamic> json) {
    return BackupMetadata(
      version: json['version'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      appVersion: json['appVersion'] as String,
      churchCount: json['churchCount'] as int,
      adminCount: json['adminCount'] as int,
      recordCount: json['recordCount'] as int,
    );
  }
}

/// Complete backup data structure
class BackupData {
  final BackupMetadata metadata;
  final List<Map<String, dynamic>> churches;
  final List<Map<String, dynamic>> adminUsers;
  final List<Map<String, dynamic>> weeklyRecords;

  const BackupData({
    required this.metadata,
    required this.churches,
    required this.adminUsers,
    required this.weeklyRecords,
  });

  Map<String, dynamic> toJson() => {
    'metadata': metadata.toJson(),
    'churches': churches,
    'adminUsers': adminUsers,
    'weeklyRecords': weeklyRecords,
  };

  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      metadata: BackupMetadata.fromJson(
        json['metadata'] as Map<String, dynamic>,
      ),
      churches: (json['churches'] as List).cast<Map<String, dynamic>>(),
      adminUsers: (json['adminUsers'] as List).cast<Map<String, dynamic>>(),
      weeklyRecords: (json['weeklyRecords'] as List)
          .cast<Map<String, dynamic>>(),
    );
  }
}

/// Service for creating and restoring JSON backups
class BackupService {
  static const String backupVersion = '1.0';
  static const String appVersion = '1.0.0';

  /// Get the backup directory path
  Future<Directory> getBackupDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${appDir.path}/backups');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  /// Generate a timestamped backup filename
  String generateBackupFilename() {
    final now = DateTime.now();
    final timestamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    return 'church_backup_$timestamp.json';
  }

  /// Convert a Church to JSON map
  Map<String, dynamic> churchToJson(Church church) => {
    'id': church.id,
    'name': church.name,
    'address': church.address,
    'contactEmail': church.contactEmail,
    'contactPhone': church.contactPhone,
    'currency': church.currency,
    'createdAt': church.createdAt.toIso8601String(),
    'updatedAt': church.updatedAt.toIso8601String(),
  };

  /// Convert JSON map to Church
  Church churchFromJson(Map<String, dynamic> json) => Church(
    id: json['id'] as int?,
    name: json['name'] as String,
    address: json['address'] as String?,
    contactEmail: json['contactEmail'] as String?,
    contactPhone: json['contactPhone'] as String?,
    currency: json['currency'] as String? ?? 'USD',
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  /// Convert an AdminUser to JSON map
  Map<String, dynamic> adminUserToJson(AdminUser admin) => {
    'id': admin.id,
    'username': admin.username,
    'fullName': admin.fullName,
    'email': admin.email,
    'churchId': admin.churchId,
    'isActive': admin.isActive,
    'createdAt': admin.createdAt.toIso8601String(),
    'lastLoginAt': admin.lastLoginAt.toIso8601String(),
  };

  /// Convert JSON map to AdminUser
  AdminUser adminUserFromJson(Map<String, dynamic> json) => AdminUser(
    id: json['id'] as int?,
    username: json['username'] as String,
    fullName: json['fullName'] as String,
    email: json['email'] as String?,
    churchId: json['churchId'] as int,
    isActive: json['isActive'] as bool? ?? true,
    createdAt: DateTime.parse(json['createdAt'] as String),
    lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
  );

  /// Convert a WeeklyRecord to JSON map
  Map<String, dynamic> weeklyRecordToJson(WeeklyRecord record) => {
    'id': record.id,
    'churchId': record.churchId,
    'createdByAdminId': record.createdByAdminId,
    'weekStartDate': record.weekStartDate.toIso8601String(),
    'men': record.men,
    'women': record.women,
    'youth': record.youth,
    'children': record.children,
    'sundayHomeChurch': record.sundayHomeChurch,
    'tithe': record.tithe,
    'offerings': record.offerings,
    'emergencyCollection': record.emergencyCollection,
    'plannedCollection': record.plannedCollection,
    'createdAt': record.createdAt.toIso8601String(),
    'updatedAt': record.updatedAt.toIso8601String(),
  };

  /// Convert JSON map to WeeklyRecord
  WeeklyRecord weeklyRecordFromJson(Map<String, dynamic> json) => WeeklyRecord(
    id: json['id'] as int?,
    churchId: json['churchId'] as int,
    createdByAdminId: json['createdByAdminId'] as int?,
    weekStartDate: DateTime.parse(json['weekStartDate'] as String),
    men: json['men'] as int,
    women: json['women'] as int,
    youth: json['youth'] as int,
    children: json['children'] as int,
    sundayHomeChurch: json['sundayHomeChurch'] as int,
    tithe: (json['tithe'] as num).toDouble(),
    offerings: (json['offerings'] as num).toDouble(),
    emergencyCollection: (json['emergencyCollection'] as num).toDouble(),
    plannedCollection: (json['plannedCollection'] as num).toDouble(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  /// Create a full JSON backup of all data
  Future<BackupResult> createBackup({
    required List<Church> churches,
    required List<AdminUser> admins,
    required List<WeeklyRecord> records,
    String? customPath,
  }) async {
    try {
      final metadata = BackupMetadata(
        version: backupVersion,
        createdAt: DateTime.now(),
        appVersion: appVersion,
        churchCount: churches.length,
        adminCount: admins.length,
        recordCount: records.length,
      );

      final backupData = BackupData(
        metadata: metadata,
        churches: churches.map(churchToJson).toList(),
        adminUsers: admins.map(adminUserToJson).toList(),
        weeklyRecords: records.map(weeklyRecordToJson).toList(),
      );

      final filePath = customPath ?? await _getDefaultBackupPath();
      final file = File(filePath);

      final jsonString = const JsonEncoder.withIndent(
        '  ',
      ).convert(backupData.toJson());
      await file.writeAsString(jsonString, encoding: utf8);

      return BackupResult.success(filePath, metadata);
    } catch (e) {
      return BackupResult.error('Failed to create backup: $e');
    }
  }

  /// Read and parse a backup file
  Future<BackupData?> readBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return null;
      }

      final content = await file.readAsString(encoding: utf8);
      final json = jsonDecode(content) as Map<String, dynamic>;
      return BackupData.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Validate a backup file structure
  Future<bool> validateBackup(String filePath) async {
    try {
      final backupData = await readBackup(filePath);
      if (backupData == null) return false;

      // Check metadata
      if (backupData.metadata.version.isEmpty) return false;

      // Validate church data
      for (final church in backupData.churches) {
        if (!church.containsKey('name') || !church.containsKey('createdAt')) {
          return false;
        }
      }

      // Validate admin data
      for (final admin in backupData.adminUsers) {
        if (!admin.containsKey('username') ||
            !admin.containsKey('fullName') ||
            !admin.containsKey('churchId')) {
          return false;
        }
      }

      // Validate weekly record data
      for (final record in backupData.weeklyRecords) {
        if (!record.containsKey('churchId') ||
            !record.containsKey('weekStartDate') ||
            !record.containsKey('men')) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Parse churches from backup data
  List<Church> parseChurches(BackupData backupData) {
    return backupData.churches.map(churchFromJson).toList();
  }

  /// Parse admin users from backup data
  List<AdminUser> parseAdminUsers(BackupData backupData) {
    return backupData.adminUsers.map(adminUserFromJson).toList();
  }

  /// Parse weekly records from backup data
  List<WeeklyRecord> parseWeeklyRecords(BackupData backupData) {
    return backupData.weeklyRecords.map(weeklyRecordFromJson).toList();
  }

  /// Restore data from a backup file
  /// Returns parsed data that can be used by repositories to persist
  Future<RestoreResult> restoreFromBackup(String filePath) async {
    try {
      // Validate backup first
      if (!await validateBackup(filePath)) {
        return RestoreResult.error('Invalid backup file format');
      }

      final backupData = await readBackup(filePath);
      if (backupData == null) {
        return RestoreResult.error('Could not read backup file');
      }

      // Parse all data
      final churches = parseChurches(backupData);
      final admins = parseAdminUsers(backupData);
      final records = parseWeeklyRecords(backupData);

      return RestoreResult.success(
        churches: churches.length,
        admins: admins.length,
        records: records.length,
      );
    } catch (e) {
      return RestoreResult.error('Failed to restore from backup: $e');
    }
  }

  /// Get parsed restore data (churches, admins, records) from backup
  Future<
    ({
      List<Church> churches,
      List<AdminUser> admins,
      List<WeeklyRecord> records,
    })?
  >
  getRestoreData(String filePath) async {
    try {
      final backupData = await readBackup(filePath);
      if (backupData == null) return null;

      return (
        churches: parseChurches(backupData),
        admins: parseAdminUsers(backupData),
        records: parseWeeklyRecords(backupData),
      );
    } catch (e) {
      return null;
    }
  }

  /// Verify backup integrity by checking file exists and is valid JSON
  Future<bool> verifyBackupIntegrity(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      final content = await file.readAsString();
      if (content.isEmpty) return false;

      // Try to parse as JSON
      final json = jsonDecode(content);
      if (json is! Map<String, dynamic>) return false;

      // Check required top-level keys
      if (!json.containsKey('metadata') ||
          !json.containsKey('churches') ||
          !json.containsKey('adminUsers') ||
          !json.containsKey('weeklyRecords')) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get default backup file path
  Future<String> _getDefaultBackupPath() async {
    final backupDir = await getBackupDirectory();
    return '${backupDir.path}/${generateBackupFilename()}';
  }

  /// Compare two backups for data consistency
  Future<bool> compareBackups(String path1, String path2) async {
    try {
      final backup1 = await readBackup(path1);
      final backup2 = await readBackup(path2);

      if (backup1 == null || backup2 == null) return false;

      return backup1.metadata.churchCount == backup2.metadata.churchCount &&
          backup1.metadata.adminCount == backup2.metadata.adminCount &&
          backup1.metadata.recordCount == backup2.metadata.recordCount;
    } catch (e) {
      return false;
    }
  }
}
