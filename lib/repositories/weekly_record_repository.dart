import 'package:drift/drift.dart';

import 'package:church_analytics/database/app_database.dart';
import 'package:church_analytics/models/models.dart' as domain;

// ignore_for_file: prefer_expression_function_bodies

/// Paginated result returned by [WeeklyRecordRepository.getRecordsPaginated]
/// and [WeeklyRecordRepository.getRecordsPaginatedByAdmin].
class PaginatedWeeklyRecords {
  final List<domain.WeeklyRecord> records;
  final int totalCount;

  const PaginatedWeeklyRecords({
    required this.records,
    required this.totalCount,
  });
}

/// Repository for [domain.WeeklyRecord] — the core Sabbath attendance +
/// finance table.
///
/// All public methods accept and return **domain** [domain.WeeklyRecord]
/// objects, never raw Drift row objects.
///
/// ### Name-conflict resolution
/// Drift auto-generates a row class also called `WeeklyRecord` (from the
/// `WeeklyRecords` table definition).  To prevent the analyser from seeing
/// an ambiguous reference, the domain models barrel is imported under the
/// `domain` prefix, so unqualified `WeeklyRecord` inside this file always
/// refers to the Drift-generated type.
class WeeklyRecordRepository {
  final AppDatabase _db;

  WeeklyRecordRepository(this._db);

  // ── queries ───────────────────────────────────────────────────────────────

  /// Returns all records for [churchId], most recent first.
  Future<List<domain.WeeklyRecord>> getRecordsByChurch(int churchId) async {
    final rows = await (_db.select(_db.weeklyRecords)
          ..where((t) => t.churchId.equals(churchId))
          ..orderBy([(t) => OrderingTerm.desc(t.weekStartDate)]))
        .get();
    return rows.map(_toModel).toList();
  }

  /// Alias for [getRecordsByChurch] used by [WeeklyRecordsNotifier] when
  /// [ChartTimeRange.all] is selected with no admin filter.
  Future<List<domain.WeeklyRecord>> getAllRecords(int churchId) =>
      getRecordsByChurch(churchId);

  /// All records for [churchId] created by [adminId], most recent first.
  Future<List<domain.WeeklyRecord>> getAllRecordsByAdmin(
      int churchId, int adminId) async {
    final rows = await (_db.select(_db.weeklyRecords)
          ..where((t) =>
              t.churchId.equals(churchId) &
              t.createdByAdminId.equals(adminId))
          ..orderBy([(t) => OrderingTerm.desc(t.weekStartDate)]))
        .get();
    return rows.map(_toModel).toList();
  }

  /// Records for [churchId] whose [weekStartDate] falls within the last
  /// [weeks] weeks, most recent first.
  Future<List<domain.WeeklyRecord>> getRecentRecords(
      int churchId, int weeks) async {
    final cutoff = DateTime.now().subtract(Duration(days: weeks * 7));
    final rows = await (_db.select(_db.weeklyRecords)
          ..where((t) =>
              t.churchId.equals(churchId) &
              t.weekStartDate.isBiggerOrEqualValue(cutoff))
          ..orderBy([(t) => OrderingTerm.desc(t.weekStartDate)]))
        .get();
    return rows.map(_toModel).toList();
  }

  /// Recent records filtered to a specific [adminId].
  Future<List<domain.WeeklyRecord>> getRecentRecordsByAdmin(
      int churchId, int adminId, int weeks) async {
    final cutoff = DateTime.now().subtract(Duration(days: weeks * 7));
    final rows = await (_db.select(_db.weeklyRecords)
          ..where((t) =>
              t.churchId.equals(churchId) &
              t.createdByAdminId.equals(adminId) &
              t.weekStartDate.isBiggerOrEqualValue(cutoff))
          ..orderBy([(t) => OrderingTerm.desc(t.weekStartDate)]))
        .get();
    return rows.map(_toModel).toList();
  }

  /// Returns a single record by primary key, or `null`.
  Future<domain.WeeklyRecord?> getRecordById(int id) async {
    final row = await (_db.select(_db.weeklyRecords)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  /// Returns the record for a specific church and week start date, or `null`.
  Future<domain.WeeklyRecord?> getRecordByChurchAndDate(
      int churchId, DateTime weekStartDate) async {
    final row = await (_db.select(_db.weeklyRecords)
          ..where((t) =>
              t.churchId.equals(churchId) &
              t.weekStartDate.equals(weekStartDate)))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  /// Returns records for [churchId] whose [weekStartDate] falls within the
  /// inclusive [from]–[to] range, ordered oldest-first.
  ///
  /// Used by [database_test.dart] and any UI that needs a bounded date window
  /// without the rolling-weeks approximation of [getRecentRecords].
  Future<List<domain.WeeklyRecord>> getRecordsByDateRange(
      int churchId, DateTime from, DateTime to) async {
    final rows = await (_db.select(_db.weeklyRecords)
          ..where((t) =>
              t.churchId.equals(churchId) &
              t.weekStartDate.isBiggerOrEqualValue(from) &
              t.weekStartDate.isSmallerOrEqualValue(to))
          ..orderBy([(t) => OrderingTerm.asc(t.weekStartDate)]))
        .get();
    return rows.map(_toModel).toList();
  }

  /// Returns `true` when a record already exists for [churchId] and
  /// [weekStartDate].
  ///
  /// Used by [WeeklyEntryScreen] and [ImportScreen] to detect duplicates
  /// before attempting an insert.
  Future<bool> weekExists(int churchId, DateTime weekStartDate) async {
    final row = await (_db.select(_db.weeklyRecords)
          ..where((t) =>
              t.churchId.equals(churchId) &
              t.weekStartDate.equals(weekStartDate))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  // ── pagination ────────────────────────────────────────────────────────────

  /// Returns a [PaginatedWeeklyRecords] for [churchId].
  ///
  /// [page] is zero-based; [pageSize] defaults to 20. Records are ordered
  /// most-recent first. [PaginatedWeeklyRecords.totalCount] reflects the
  /// full unfiltered row count so callers can compute page indicators.
  Future<PaginatedWeeklyRecords> getRecordsPaginated(
    int churchId, {
    int page = 0,
    int pageSize = 20,
  }) async {
    final countExpr = _db.weeklyRecords.id.count();
    final countQuery = _db.selectOnly(_db.weeklyRecords)
      ..addColumns([countExpr])
      ..where(_db.weeklyRecords.churchId.equals(churchId));
    final totalCount =
        await countQuery.map((r) => r.read(countExpr)!).getSingle();

    final rows = await (_db.select(_db.weeklyRecords)
          ..where((t) => t.churchId.equals(churchId))
          ..orderBy([(t) => OrderingTerm.desc(t.weekStartDate)])
          ..limit(pageSize, offset: page * pageSize))
        .get();

    return PaginatedWeeklyRecords(
      records: rows.map(_toModel).toList(),
      totalCount: totalCount,
    );
  }

  /// Paginated records filtered to a specific [adminId].
  Future<PaginatedWeeklyRecords> getRecordsPaginatedByAdmin(
    int churchId,
    int adminId, {
    int page = 0,
    int pageSize = 20,
  }) async {
    final countExpr = _db.weeklyRecords.id.count();
    final countQuery = _db.selectOnly(_db.weeklyRecords)
      ..addColumns([countExpr])
      ..where(_db.weeklyRecords.churchId.equals(churchId) &
          _db.weeklyRecords.createdByAdminId.equals(adminId));
    final totalCount =
        await countQuery.map((r) => r.read(countExpr)!).getSingle();

    final rows = await (_db.select(_db.weeklyRecords)
          ..where((t) =>
              t.churchId.equals(churchId) &
              t.createdByAdminId.equals(adminId))
          ..orderBy([(t) => OrderingTerm.desc(t.weekStartDate)])
          ..limit(pageSize, offset: page * pageSize))
        .get();

    return PaginatedWeeklyRecords(
      records: rows.map(_toModel).toList(),
      totalCount: totalCount,
    );
  }

  // ── mutations ─────────────────────────────────────────────────────────────

  /// Inserts a new weekly record. Throws if the church+date unique constraint
  /// is violated.
  Future<domain.WeeklyRecord> createRecord(domain.WeeklyRecord record) async {
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
  Future<void> updateRecord(domain.WeeklyRecord record) async {
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

  /// Finds the row matching [record.churchId] + [record.weekStartDate] and
  /// overwrites its fields. Returns `true` on success, `false` when no
  /// matching row exists.
  ///
  /// Used by [ImportScreen]'s "update duplicate" strategy, where the incoming
  /// domain record has no [id] yet.
  Future<bool> updateRecordByWeekStartDate(domain.WeeklyRecord record) async {
    final existing =
        await getRecordByChurchAndDate(record.churchId, record.weekStartDate);
    if (existing == null) return false;
    await updateRecord(record.copyWith(id: existing.id));
    return true;
  }

  // ── FEAT-015 — delete ─────────────────────────────────────────────────────

  /// Permanently deletes a single weekly record by [id].
  Future<void> deleteRecord(int id) async {
    await (_db.delete(_db.weeklyRecords)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  /// Permanently deletes all records whose IDs are in [ids], in a single
  /// transaction.
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

  // [row] is the Drift-generated WeeklyRecord (unqualified); the return type
  // is the domain model (qualified with `domain.`).
  domain.WeeklyRecord _toModel(WeeklyRecord row) => domain.WeeklyRecord(
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
