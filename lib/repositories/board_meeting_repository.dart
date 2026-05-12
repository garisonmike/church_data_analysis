import 'package:drift/drift.dart';

import 'package:church_analytics/database/app_database.dart';
import 'package:church_analytics/models/models.dart';

// ignore_for_file: prefer_expression_function_bodies

/// Repository for [BoardMeetingRecord].
///
/// Board meeting records are standalone rows (no child attendance table) —
/// deleting a record requires no cascade handling.
class BoardMeetingRepository {
  final AppDatabase _db;

  BoardMeetingRepository(this._db);

  // ── queries ───────────────────────────────────────────────────────────────

  /// Returns all board meeting records for [churchId], most recent first.
  Future<List<BoardMeetingRecord>> getRecordsByChurch(int churchId) async {
    final rows = await (_db.select(_db.boardMeetingRecords)
          ..where((t) => t.churchId.equals(churchId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.year),
            (t) => OrderingTerm.desc(t.month),
          ]))
        .get();
    return rows.map(_toModel).toList();
  }

  /// Returns a single board meeting record by primary key, or `null`.
  Future<BoardMeetingRecord?> getRecordById(int id) async {
    final row = await (_db.select(_db.boardMeetingRecords)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  /// Returns the record for a given church, year, and month, or `null`.
  Future<BoardMeetingRecord?> getRecordByChurchYearMonth(
      int churchId, int year, int month) async {
    final row = await (_db.select(_db.boardMeetingRecords)
          ..where((t) =>
              t.churchId.equals(churchId) &
              t.year.equals(year) &
              t.month.equals(month)))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  // ── mutations ─────────────────────────────────────────────────────────────

  /// Inserts a new board meeting record.
  Future<BoardMeetingRecord> createRecord(BoardMeetingRecord record) async {
    final id = await _db.into(_db.boardMeetingRecords).insert(
          BoardMeetingRecordsCompanion.insert(
            churchId: record.churchId,
            createdByAdminId: Value(record.createdByAdminId),
            meetingDate: record.meetingDate,
            year: record.year,
            month: record.month,
            actualAttendance: record.actualAttendance,
            expectedAttendance: record.expectedAttendance,
            notes: Value(record.notes),
            createdAt: record.createdAt,
            updatedAt: record.updatedAt,
          ),
        );
    return record.copyWith(id: id);
  }

  /// Updates an existing board meeting record. [record.id] must be non-null.
  Future<void> updateRecord(BoardMeetingRecord record) async {
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

  BoardMeetingRecord _toModel(db.BoardMeetingRecord row) => BoardMeetingRecord(
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
