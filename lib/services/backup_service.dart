import 'dart:convert';

import 'package:church_analytics/database/app_database.dart' as db;
import 'package:church_analytics/models/models.dart';
import 'package:church_analytics/platform/file_storage_interface.dart';
import 'package:church_analytics/repositories/repositories.dart';
import 'package:church_analytics/services/file_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
  // Phase 1 additions
  final List<Map<String, dynamic>> homeChurches;
  final List<Map<String, dynamic>> boardMeetingRecords;
  final List<Map<String, dynamic>> holyCommunionEvents;
  final List<Map<String, dynamic>> businessMeetingEvents;

  const BackupData({
    required this.metadata,
    required this.churches,
    required this.adminUsers,
    required this.weeklyRecords,
    this.homeChurches = const [],
    this.boardMeetingRecords = const [],
    this.holyCommunionEvents = const [],
    this.businessMeetingEvents = const [],
  });

  Map<String, dynamic> toJson() => {
    'metadata': metadata.toJson(),
    'churches': churches,
    'adminUsers': adminUsers,
    'weeklyRecords': weeklyRecords,
    'homeChurches': homeChurches,
    'boardMeetingRecords': boardMeetingRecords,
    'holyCommunionEvents': holyCommunionEvents,
    'businessMeetingEvents': businessMeetingEvents,
  };

  factory BackupData.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> castList(dynamic v) =>
        v == null ? [] : (v as List).cast<Map<String, dynamic>>();
    return BackupData(
      metadata: BackupMetadata.fromJson(
        json['metadata'] as Map<String, dynamic>,
      ),
      churches: castList(json['churches']),
      adminUsers: castList(json['adminUsers']),
      weeklyRecords: castList(json['weeklyRecords']),
      homeChurches: castList(json['homeChurches']),
      boardMeetingRecords: castList(json['boardMeetingRecords']),
      holyCommunionEvents: castList(json['holyCommunionEvents']),
      businessMeetingEvents: castList(json['businessMeetingEvents']),
    );
  }
}

/// Service for creating and restoring JSON backups
class BackupService {
  static const String backupVersion = '1.0';
  final FileService _fileService;
  final Future<PackageInfo> Function() _getPackageInfo;

  BackupService({
    FileService? fileService,
    // Injectable for tests, same pattern as UpdateService.
    Future<PackageInfo> Function()? getPackageInfo,
  }) : _fileService = fileService ?? FileService(),
       _getPackageInfo = getPackageInfo ?? PackageInfo.fromPlatform;

  /// Resolves the real app version for backup metadata; previously this was
  /// a hardcoded '1.0.0' stamped into every backup regardless of the version
  /// that actually created it.
  Future<String> _resolveAppVersion() async {
    try {
      final info = await _getPackageInfo();
      return info.version;
    } catch (_) {
      // Platform channel unavailable (e.g. bare unit tests).
      return 'unknown';
    }
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
    'baptisms': record.baptisms,
    'holyCommunion': record.holyCommunion,
    'sabbathSchoolAttendance': record.sabbathSchoolAttendance,
    'visitorsCount': record.visitorsCount,
    'missionOffering': record.missionOffering,
    'localChurchBudget': record.localChurchBudget,
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
    // Nullable extras — absent in backups created before they were added
    // to the serializer, so parse leniently.
    baptisms: json['baptisms'] as int?,
    holyCommunion: json['holyCommunion'] as int?,
    sabbathSchoolAttendance: json['sabbathSchoolAttendance'] as int?,
    visitorsCount: json['visitorsCount'] as int?,
    missionOffering: (json['missionOffering'] as num?)?.toDouble(),
    localChurchBudget: (json['localChurchBudget'] as num?)?.toDouble(),
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
    List<HomeChurch> homeChurches = const [],
    List<BoardMeetingRecord> boardMeetingRecords = const [],
    List<HolyCommunionEvent> holyCommunionEvents = const [],
    List<BusinessMeetingEvent> businessMeetingEvents = const [],
    String? customPath,
  }) async {
    try {
      final metadata = BackupMetadata(
        version: backupVersion,
        createdAt: DateTime.now(),
        appVersion: await _resolveAppVersion(),
        churchCount: churches.length,
        adminCount: admins.length,
        recordCount: records.length,
      );

      final backupData = BackupData(
        metadata: metadata,
        churches: churches.map(churchToJson).toList(),
        adminUsers: admins.map(adminUserToJson).toList(),
        weeklyRecords: records.map(weeklyRecordToJson).toList(),
        homeChurches: homeChurches.map((e) => e.toJson()).toList(),
        boardMeetingRecords: boardMeetingRecords.map((e) => e.toJson()).toList(),
        holyCommunionEvents: holyCommunionEvents.map((e) => e.toJson()).toList(),
        businessMeetingEvents: businessMeetingEvents.map((e) => e.toJson()).toList(),
      );

      String fileName;
      String? fullPath;
      if (customPath != null) {
        final normalized = customPath.replaceAll('\\', '/');
        final hasPath = normalized.contains('/');
        fileName = hasPath ? normalized.split('/').last : normalized;
        if (!fileName.endsWith('.json')) fileName += '.json';
        if (hasPath) {
          fullPath = normalized.endsWith('.json')
              ? normalized
              : '$normalized.json';
        }
      } else {
        fileName = generateBackupFilename();
      }

      final jsonString = const JsonEncoder.withIndent(
        '  ',
      ).convert(backupData.toJson());

      final result = await _fileService.exportFile(
        filename: fileName,
        content: jsonString,
        forcedPath: fullPath,
      );

      if (!result.success) {
        return BackupResult.error(result.error ?? 'Failed to save backup file');
      }

      return BackupResult.success(result.filePath!, metadata);
    } catch (e) {
      return BackupResult.error('Failed to create backup: $e');
    }
  }

  /// Read and parse a backup file
  Future<BackupData?> readBackup(PlatformFileResult file) async {
    try {
      final content = await _fileService.readFileAsString(file);
      final json = jsonDecode(content) as Map<String, dynamic>;
      return BackupData.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Validate a backup file structure
  Future<bool> validateBackup(PlatformFileResult file) async {
    try {
      final backupData = await readBackup(file);
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
  /// Validates [file], parses it, and writes its contents into [database].
  ///
  /// This used to be a stub that parsed the file, counted its contents, and
  /// reported success without writing a single row — a restore button that
  /// lied. It now performs the same atomic restore as the first-launch
  /// import screen via [restoreBackupData].
  Future<RestoreResult> restoreFromBackup(
    PlatformFileResult file,
    db.AppDatabase database,
  ) async {
    try {
      if (!await validateBackup(file)) {
        return RestoreResult.error('Invalid backup file format');
      }

      final backupData = await readBackup(file);
      if (backupData == null) {
        return RestoreResult.error('Could not read backup file');
      }

      return await restoreBackupData(database, backupData);
    } catch (e) {
      return RestoreResult.error('Failed to restore from backup: $e');
    }
  }

  /// Restores [backupData] into [database] atomically.
  ///
  /// The single shared restore implementation (also used by the first-launch
  /// import screen). Semantics:
  ///
  /// - **Additive**: the backup's churches are inserted as new rows; nothing
  ///   is merged with or overwritten in existing data. Old IDs are remapped
  ///   to the freshly-inserted ones for admins and records.
  /// - **Orphaned admin references become null**: if a record's
  ///   `createdByAdminId` isn't among the restored admins (e.g. a backup
  ///   exported with no admins), the reference is dropped rather than
  ///   reusing a stale ID that would violate the FK constraint.
  /// - **Atomic**: everything runs in one transaction — any failure rolls
  ///   back all of it, so a failed restore really does change nothing.
  Future<RestoreResult> restoreBackupData(
    db.AppDatabase database,
    BackupData backupData,
  ) async {
    final churchRepo = ChurchRepository(database);
    final adminRepo = AdminUserRepository(database);
    final recordRepo = WeeklyRecordRepository(database);

    var churchCount = 0;
    var adminCount = 0;
    var recordCount = 0;

    try {
      await database.transaction(() async {
        // 1. Churches — track old ID → new ID for FK remapping.
        final Map<int, int> churchIdMap = {};
        for (final churchJson in backupData.churches) {
          final church = churchFromJson(churchJson);
          final oldId = church.id;
          final newId = await churchRepo.createChurch(church);
          if (oldId != null) churchIdMap[oldId] = newId;
          churchCount++;
        }

        // 2. Admin users — remap churchId; track old ID → new ID.
        final Map<int, int> adminIdMap = {};
        for (final adminJson in backupData.adminUsers) {
          final admin = adminUserFromJson(adminJson);
          final oldId = admin.id;
          final remappedChurchId =
              churchIdMap[admin.churchId] ?? admin.churchId;
          final newId = await adminRepo.createUser(
            AdminUser(
              username: admin.username,
              fullName: admin.fullName,
              email: admin.email,
              churchId: remappedChurchId,
              isActive: admin.isActive,
              createdAt: admin.createdAt,
              lastLoginAt: admin.lastLoginAt,
            ),
          );
          if (oldId != null) adminIdMap[oldId] = newId;
          adminCount++;
        }

        // 3. Weekly records — remap churchId and createdByAdminId.
        for (final recordJson in backupData.weeklyRecords) {
          final record = weeklyRecordFromJson(recordJson);
          final remappedChurchId =
              churchIdMap[record.churchId] ?? record.churchId;
          final remappedAdminId = record.createdByAdminId != null
              ? adminIdMap[record.createdByAdminId!]
              : null;
          await recordRepo.createRecord(
            WeeklyRecord(
              churchId: remappedChurchId,
              createdByAdminId: remappedAdminId,
              weekStartDate: record.weekStartDate,
              men: record.men,
              women: record.women,
              youth: record.youth,
              children: record.children,
              sundayHomeChurch: record.sundayHomeChurch,
              baptisms: record.baptisms,
              holyCommunion: record.holyCommunion,
              sabbathSchoolAttendance: record.sabbathSchoolAttendance,
              visitorsCount: record.visitorsCount,
              missionOffering: record.missionOffering,
              localChurchBudget: record.localChurchBudget,
              tithe: record.tithe,
              offerings: record.offerings,
              emergencyCollection: record.emergencyCollection,
              plannedCollection: record.plannedCollection,
              createdAt: record.createdAt,
              updatedAt: record.updatedAt,
            ),
          );
          recordCount++;
        }
      });

      return RestoreResult.success(
        churches: churchCount,
        admins: adminCount,
        records: recordCount,
      );
    } catch (e) {
      return RestoreResult.error(
        'Restore failed: $e. No data was changed.',
      );
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
  getRestoreData(PlatformFileResult file) async {
    try {
      final backupData = await readBackup(file);
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
  Future<bool> verifyBackupIntegrity(PlatformFileResult file) async {
    try {
      final content = await _fileService.readFileAsString(file);

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
}
