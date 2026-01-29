import 'package:church_analytics/database/app_database.dart' as db;
import 'package:church_analytics/models/models.dart';
import 'package:drift/drift.dart';

/// Repository for managing WeeklyRecord data
class WeeklyRecordRepository {
  final db.AppDatabase _db;

  WeeklyRecordRepository(this._db);

  /// Get all weekly records for a church
  Future<List<WeeklyRecord>> getRecordsByChurch(int churchId) async {
    final records =
        await (_db.select(_db.weeklyRecords)
              ..where((t) => t.churchId.equals(churchId))
              ..orderBy([(t) => OrderingTerm.desc(t.weekStartDate)]))
            .get();
    return records.map(_toModel).toList();
  }

  /// Get weekly record by ID
  Future<WeeklyRecord?> getRecordById(int id) async {
    final query = _db.select(_db.weeklyRecords)..where((t) => t.id.equals(id));
    final result = await query.getSingleOrNull();
    return result != null ? _toModel(result) : null;
  }

  /// Get records within a date range
  Future<List<WeeklyRecord>> getRecordsByDateRange(
    int churchId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final records =
        await (_db.select(_db.weeklyRecords)
              ..where(
                (t) =>
                    t.churchId.equals(churchId) &
                    t.weekStartDate.isBiggerOrEqualValue(startDate) &
                    t.weekStartDate.isSmallerOrEqualValue(endDate),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.weekStartDate)]))
            .get();
    return records.map(_toModel).toList();
  }

  /// Get the most recent N records
  Future<List<WeeklyRecord>> getRecentRecords(int churchId, int limit) async {
    final records =
        await (_db.select(_db.weeklyRecords)
              ..where((t) => t.churchId.equals(churchId))
              ..orderBy([(t) => OrderingTerm.desc(t.weekStartDate)])
              ..limit(limit))
            .get();
    return records.map(_toModel).toList();
  }

  /// Get records created by a specific admin
  Future<List<WeeklyRecord>> getRecordsByAdmin(
    int churchId,
    int adminId,
  ) async {
    final records =
        await (_db.select(_db.weeklyRecords)
              ..where(
                (t) =>
                    t.churchId.equals(churchId) &
                    t.createdByAdminId.equals(adminId),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.weekStartDate)]))
            .get();
    return records.map(_toModel).toList();
  }

  /// Get recent records created by a specific admin
  Future<List<WeeklyRecord>> getRecentRecordsByAdmin(
    int churchId,
    int adminId,
    int limit,
  ) async {
    final records =
        await (_db.select(_db.weeklyRecords)
              ..where(
                (t) =>
                    t.churchId.equals(churchId) &
                    t.createdByAdminId.equals(adminId),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.weekStartDate)])
              ..limit(limit))
            .get();
    return records.map(_toModel).toList();
  }

  /// Check if a week already exists for a church
  Future<bool> weekExists(int churchId, DateTime weekStartDate) async {
    final query = _db.select(_db.weeklyRecords)
      ..where(
        (t) =>
            t.churchId.equals(churchId) & t.weekStartDate.equals(weekStartDate),
      );
    final result = await query.getSingleOrNull();
    return result != null;
  }

  /// Create a new weekly record
  Future<int> createRecord(WeeklyRecord record) async {
    return await _db
        .into(_db.weeklyRecords)
        .insert(
          db.WeeklyRecordsCompanion.insert(
            churchId: record.churchId,
            createdByAdminId: Value(record.createdByAdminId),
            weekStartDate: record.weekStartDate,
            men: Value(record.men),
            women: Value(record.women),
            youth: Value(record.youth),
            children: Value(record.children),
            sundayHomeChurch: Value(record.sundayHomeChurch),
            tithe: Value(record.tithe),
            offerings: Value(record.offerings),
            emergencyCollection: Value(record.emergencyCollection),
            plannedCollection: Value(record.plannedCollection),
            createdAt: record.createdAt,
            updatedAt: record.updatedAt,
          ),
        );
  }

  /// Update an existing weekly record
  Future<bool> updateRecord(WeeklyRecord record) async {
    if (record.id == null) return false;

    return await _db
        .update(_db.weeklyRecords)
        .replace(
          db.WeeklyRecordsCompanion(
            id: Value(record.id!),
            churchId: Value(record.churchId),
            createdByAdminId: Value(record.createdByAdminId),
            weekStartDate: Value(record.weekStartDate),
            men: Value(record.men),
            women: Value(record.women),
            youth: Value(record.youth),
            children: Value(record.children),
            sundayHomeChurch: Value(record.sundayHomeChurch),
            tithe: Value(record.tithe),
            offerings: Value(record.offerings),
            emergencyCollection: Value(record.emergencyCollection),
            plannedCollection: Value(record.plannedCollection),
            createdAt: Value(record.createdAt),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  /// Delete a weekly record
  Future<int> deleteRecord(int id) async {
    return await (_db.delete(
      _db.weeklyRecords,
    )..where((t) => t.id.equals(id))).go();
  }

  /// Get total count of records for a church
  Future<int> getRecordCount(int churchId) async {
    final query = _db.selectOnly(_db.weeklyRecords)
      ..addColumns([_db.weeklyRecords.id.count()])
      ..where(_db.weeklyRecords.churchId.equals(churchId));
    final result = await query.getSingle();
    return result.read(_db.weeklyRecords.id.count()) ?? 0;
  }

  /// Convert database model to domain model
  WeeklyRecord _toModel(db.WeeklyRecord data) {
    return WeeklyRecord(
      id: data.id,
      churchId: data.churchId,
      createdByAdminId: data.createdByAdminId,
      weekStartDate: data.weekStartDate,
      men: data.men,
      women: data.women,
      youth: data.youth,
      children: data.children,
      sundayHomeChurch: data.sundayHomeChurch,
      tithe: data.tithe,
      offerings: data.offerings,
      emergencyCollection: data.emergencyCollection,
      plannedCollection: data.plannedCollection,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }
}
