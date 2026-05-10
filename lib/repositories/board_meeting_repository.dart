import 'package:church_analytics/database/app_database.dart' as db;
import 'package:church_analytics/models/models.dart';
import 'package:drift/drift.dart';

class BoardMeetingRepository {
  final db.AppDatabase _db;
  BoardMeetingRepository(this._db);

  Future<List<BoardMeetingRecord>> getByChurch(int churchId) async {
    final rows = await (_db.select(_db.boardMeetingRecords)
          ..where((t) => t.churchId.equals(churchId))
          ..orderBy([(t) => OrderingTerm.desc(t.year), (t) => OrderingTerm.desc(t.month)]))
        .get();
    return rows.map(_toModel).toList();
  }

  Future<List<BoardMeetingRecord>> getByYear(int churchId, int year) async {
    final rows = await (_db.select(_db.boardMeetingRecords)
          ..where((t) => t.churchId.equals(churchId) & t.year.equals(year))
          ..orderBy([(t) => OrderingTerm.asc(t.month)]))
        .get();
    return rows.map(_toModel).toList();
  }

  Future<BoardMeetingRecord?> getByMonthYear(int churchId, int year, int month) async {
    final q = _db.select(_db.boardMeetingRecords)
      ..where((t) => t.churchId.equals(churchId) & t.year.equals(year) & t.month.equals(month));
    final r = await q.getSingleOrNull();
    return r != null ? _toModel(r) : null;
  }

  Future<int> create(BoardMeetingRecord record) async {
    final now = DateTime.now();
    return _db.into(_db.boardMeetingRecords).insert(db.BoardMeetingRecordsCompanion.insert(
      churchId: record.churchId,
      createdByAdminId: Value(record.createdByAdminId),
      meetingDate: record.meetingDate,
      year: record.year, month: record.month,
      actualAttendance: Value(record.actualAttendance),
      expectedAttendance: Value(record.expectedAttendance),
      notes: Value(record.notes),
      createdAt: now, updatedAt: now,
    ));
  }

  Future<bool> update(BoardMeetingRecord record) async {
    if (record.id == null) return false;
    return _db.update(_db.boardMeetingRecords).replace(db.BoardMeetingRecordsCompanion(
      id: Value(record.id!), churchId: Value(record.churchId),
      createdByAdminId: Value(record.createdByAdminId),
      meetingDate: Value(record.meetingDate),
      year: Value(record.year), month: Value(record.month),
      actualAttendance: Value(record.actualAttendance),
      expectedAttendance: Value(record.expectedAttendance),
      notes: Value(record.notes),
      createdAt: Value(record.createdAt), updatedAt: Value(DateTime.now()),
    ));
  }

  Future<int> delete(int id) async =>
      (_db.delete(_db.boardMeetingRecords)..where((t) => t.id.equals(id))).go();

  BoardMeetingRecord _toModel(db.BoardMeetingRecord r) => BoardMeetingRecord(
    id: r.id, churchId: r.churchId, createdByAdminId: r.createdByAdminId,
    meetingDate: r.meetingDate, year: r.year, month: r.month,
    actualAttendance: r.actualAttendance, expectedAttendance: r.expectedAttendance,
    notes: r.notes, createdAt: r.createdAt, updatedAt: r.updatedAt,
  );
}
