import 'package:drift/drift.dart';

import 'package:church_analytics/database/app_database.dart';
import 'package:church_analytics/models/models.dart' as domain;

// ignore_for_file: prefer_expression_function_bodies

/// Repository for [domain.BoardMeetingRecord].
///
/// Board meeting records are standalone rows (no child attendance table) —
/// deleting a record requires no cascade handling.
///
/// ### Name-conflict resolution
/// Drift auto-generates a row class also called `BoardMeetingRecord` (from the
/// `BoardMeetingRecords` table definition). To prevent the analyser from seeing
/// an ambiguous reference, the domain models barrel is imported under the
/// `domain` prefix, so unqualified `BoardMeetingRecord` inside this file always
/// refers to the Drift-generated type.
class BoardMeetingRepository {
  final AppDatabase _db;

  BoardMeetingRepository(this._db);

  // ── queries ───────────────────────────────────────────────────────────────

  /// Returns all board meeting records for [churchId], most recent first.
  Future<List<domain.BoardMeetingRecord>> getRecordsByChurch(
      int churchId) async {
    final rows = await (_db.select(_db.boardMeetingRecords)
          ..where((t) => t.churchId.equals(churchId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.year),
            (t) => OrderingTerm.desc(t.month),
          ]))
        .get();
    return rows.map(_toModel).toList();
  }

  /// Alias for [getRecordsByChurch] — used by [boardMeetingRecordsProvider].
  Future<List<domain.BoardMeetingRecord>> getByChurch(int churchId) =>
      getRecordsByChurch(churchId);

  /// Returns a single board meeting record by primary key, or `null`.
  Future<domain.BoardMeetingRecord?> getRecordById(int id) async {
    final row = await (_db.select(_db.boardMeetingRecords)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  /// Returns the record for a given church, year, and month, or `null`.
  Future<domain.BoardMeetingRecord?> getRecordByChurchYearMonth(
      int churchId, int year, int month) async {
    final row = await (_db.select(_db.boardMeetingRecords)
          ..where((t) =>
              t.churchId.equals(churchId) &
              t.year.equals(year) &
              t.month.equals(month)))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  /// Alias for [createRecord] — used by [BoardMeetingEntryScreen].
  Future<domain.BoardMeetingRecord> create(domain.BoardMeetingRecord record) =>
      createRecord(record);

  /// Alias for [updateRecord] — used by [BoardMeetingEntryScreen].
  Future<void> update(domain.BoardMeetingRecord record) => updateRecord(record);

  // ── mutations ─────────────────────────────────────────────────────────────

  /// Inserts a new board meeting record.
  Future<domain.BoardMeetingRecord> createRecord(
      domain.BoardMeetingRecord record) async {
    final id = await _db.into(_db.boardMeetingRecords).insert(
          BoardMeetingRecordsCompanion.insert(
            churchId: record.churchId,
            createdByAdminId: Value(record.createdByAdminId),
            meetingDate: record.meetingDate,
            year: record.year,
            month: record.month,
            actualAttendance: Value(record.actualAttendance),
            expectedAttendance: Value(record.expectedAttendance),
            notes: Value(record.notes),
            createdAt: record.createdAt,
            updatedAt: record.updatedAt,
          ),
        );
    return record.copyWith(id: id);
  }

  /// Updates an existing board meeting record. [record.id] must be non-null.
  Future<void> updateRecord(domain.BoardMeetingRecord record) async {
    assert(record.id != null, 'updateRecord requires a non-null id');
    await (_db.update(_db.boardMeetingRecords)
          ..where((t) => t.id.equals(record.id!)))
        .write(
      BoardMeetingRecordsCompanion(
        churchId: Value(record.churchId),
        createdByAdminId: Value(record.createdByAdminId),
        meetingDate: Value(record.meetingDate),
        year: Value(record.year),
        month: Value(record.month),
        actualAttendance: Value(record.actualAttendance),
        expectedAttendance: Value(record.expectedAttendance),
        notes: Value(record.notes),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Upserts [rows] as the complete set of attendance rows for [eventId].
  ///
  /// Board meeting records are standalone (no child attendance table), so this
  /// is a no-op placeholder that satisfies callers (e.g. the import pipeline)
  /// that call `upsertAttendanceRows` generically across all repository types.
  /// If a child-attendance table is added in a future schema version, implement
  /// the real upsert here.
  Future<void> upsertAttendanceRows(int eventId, List<dynamic> rows) async {
    // Board meeting records have no separate attendance child table.
    // Nothing to upsert.
  }

  // ── FEAT-015 — delete ─────────────────────────────────────────────────────

  /// Permanently deletes a single board meeting record by [id].
  ///
  /// Board meeting records have no child rows — a plain delete is sufficient.
  Future<void> deleteRecord(int id) async {
    await (_db.delete(_db.boardMeetingRecords)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  /// Permanently deletes all records whose IDs are in [ids].
  Future<void> deleteRecords(List<int> ids) async {
    if (ids.isEmpty) return;
    await _db.transaction(() async {
      for (final id in ids) {
        await (_db.delete(_db.boardMeetingRecords)
              ..where((t) => t.id.equals(id)))
            .go();
      }
    });
  }

  // ── mapping ───────────────────────────────────────────────────────────────

  // [row] is the Drift-generated BoardMeetingRecord (unqualified); the return
  // type is the domain model (qualified with `domain.`).
  domain.BoardMeetingRecord _toModel(BoardMeetingRecord row) =>
      domain.BoardMeetingRecord(
        id: row.id,
        churchId: row.churchId,
        createdByAdminId: row.createdByAdminId,
        meetingDate: row.meetingDate,
        year: row.year,
        month: row.month,
        actualAttendance: row.actualAttendance,
        expectedAttendance: row.expectedAttendance,
        notes: row.notes,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
}
