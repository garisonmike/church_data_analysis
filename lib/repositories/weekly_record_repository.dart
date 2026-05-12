import 'package:drift/drift.dart';

import 'package:church_analytics/database/app_database.dart';
import 'package:church_analytics/models/models.dart';

// ignore_for_file: prefer_expression_function_bodies

/// Repository for [WeeklyRecord] — the core Sabbath attendance + finance table.
///
/// This is the only layer permitted to touch Drift directly for this table.
/// All methods return domain [WeeklyRecord] models, never raw Drift rows.
class WeeklyRecordRepository {
  final AppDatabase _db;

  WeeklyRecordRepository(this._db);

  // ── queries ───────────────────────────────────────────────────────────────

  /// Returns all records for [churchId], most recent first.
  Future<List<WeeklyRecord>> getRecordsByChurch(int churchId) async {
    final rows = await (_db.select(_db.weeklyRecords)
          ..where((t) => t.churchId.equals(churchId))
          ..orderBy([(t) => OrderingTerm.desc(t.weekStartDate)]))
        .get();
    return rows.map(_toModel).toList();
  }

  /// Returns a single record by primary key, or `null` if not found.
  Future<WeeklyRecord?> getRecordById(int id) async {
    final row = await (_db.select(_db.weeklyRecords)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  /// Returns the record for a specific church and week start date, or `null`.
  Future<WeeklyRecord?> getRecordByChurchAndDate(
      int churchId, DateTime weekStartDate) async {
    final row = await (_db.select(_db.weeklyRecords)
          ..where((t) =>
              t.churchId.equals(churchId) &
              t.weekStartDate.equals(weekStartDate)))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  // ── mutations ─────────────────────────────────────────────────────────────

  /// Inserts a new weekly record. Throws if the church+date combination
  /// already exists (enforced by the unique constraint on the table).
  Future<WeeklyRecord> createRecord(WeeklyRecord record) async {
    final id = await _db.into(_db.weeklyRecords).insert(
          WeeklyRecordsCompanion.insert(
            churchId: record.churchId,
            createdByAdminId: Value(record.createdByAdminId),
            weekStartDate: record.weekStartDate,
            men: Value(record.men),
            women: Value(record.women),
            youth: Value(record.youth),
            children: Value(record.children),
            sundayHomeChurch: Value(record.sundayHomeChurch),
            baptisms: Value(record.baptisms),
            holyCommunion: Value(record.holyCommunion),
            tithe: Value(record.tithe),
            offerings: Value(record.offerings),
            emergencyCollection: Value(record.emergencyCollection),
            plannedCollection: Value(record.plannedCollection),
            sabbathSchoolAttendance: Value(record.sabbathSchoolAttendance),
            visitorsCount: Value(record.visitorsCount),
            missionOffering: Value(record.missionOffering),
            localChurchBudget: Value(record.localChurchBudget),
            createdAt: record.createdAt,
            updatedAt: record.updatedAt,
          ),
        );
    return record.copyWith(id: id);
  }

  /// Replaces an existing weekly record. [record.id] must be non-null.
  Future<void> updateRecord(WeeklyRecord record) async {
    assert(record.id != null, 'updateRecord requires a non-null id');
    await (_db.update(_db.weeklyRecords)
          ..where((t) => t.id.equals(record.id!)))
        .write(
      WeeklyRecordsCompanion(
        churchId: Value(record.churchId),
        createdByAdminId: Value(record.createdByAdminId),
        weekStartDate: Value(record.weekStartDate),
        men: Value(record.men),
        women: Value(record.women),
        youth: Value(record.youth),
        children: Value(record.children),
        sundayHomeChurch: Value(record.sundayHomeChurch),
        baptisms: Value(record.baptisms),
        holyCommunion: Value(record.holyCommunion),
        tithe: Value(record.tithe),
        offerings: Value(record.offerings),
        emergencyCollection: Value(record.emergencyCollection),
        plannedCollection: Value(record.plannedCollection),
        sabbathSchoolAttendance: Value(record.sabbathSchoolAttendance),
        visitorsCount: Value(record.visitorsCount),
        missionOffering: Value(record.missionOffering),
        localChurchBudget: Value(record.localChurchBudget),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ── FEAT-015 — delete ─────────────────────────────────────────────────────

  /// Permanently deletes a single weekly record by [id].
  ///
  /// Weekly records have no child rows in other tables, so a plain delete is
  /// sufficient. Throws if the database operation fails.
  Future<void> deleteRecord(int id) async {
    await (_db.delete(_db.weeklyRecords)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  /// Permanently deletes all records whose IDs are in [ids].
  ///
  /// Runs as a single batch operation inside a transaction for atomicity.
  Future<void> deleteRecords(List<int> ids) async {
    if (ids.isEmpty) return;
    await _db.transaction(() async {
      for (final id in ids) {
        await (_db.delete(_db.weeklyRecords)
              ..where((t) => t.id.equals(id)))
            .go();
      }
    });
  }

  // ── mapping ───────────────────────────────────────────────────────────────

  WeeklyRecord _toModel(db.WeeklyRecord row) => WeeklyRecord(
        id: row.id,
        churchId: row.churchId,
        createdByAdminId: row.createdByAdminId,
        weekStartDate: row.weekStartDate,
        men: row.men,
        women: row.women,
        youth: row.youth,
        children: row.children,
        sundayHomeChurch: row.sundayHomeChurch,
        baptisms: row.baptisms,
        holyCommunion: row.holyCommunion,
        tithe: row.tithe,
        offerings: row.offerings,
        emergencyCollection: row.emergencyCollection,
        plannedCollection: row.plannedCollection,
        sabbathSchoolAttendance: row.sabbathSchoolAttendance,
        visitorsCount: row.visitorsCount,
        missionOffering: row.missionOffering,
        localChurchBudget: row.localChurchBudget,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
}
