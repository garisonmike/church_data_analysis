import 'package:church_analytics/database/app_database.dart' as db;
import 'package:church_analytics/models/models.dart';
import 'package:drift/drift.dart';

class HolyCommunionRepository {
  final db.AppDatabase _db;
  HolyCommunionRepository(this._db);

  Future<List<HolyCommunionEvent>> getByChurch(int churchId) async {
    final events = await (_db.select(_db.holyCommunionEvents)
          ..where((t) => t.churchId.equals(churchId))
          ..orderBy([(t) => OrderingTerm.desc(t.year), (t) => OrderingTerm.desc(t.quarter)]))
        .get();
    final result = <HolyCommunionEvent>[];
    for (final e in events) {
      final rows = await _getAttendanceRows(e.id);
      result.add(_toModel(e, rows));
    }
    return result;
  }

  Future<HolyCommunionEvent?> getByQuarter(int churchId, int year, int quarter) async {
    final q = _db.select(_db.holyCommunionEvents)
      ..where((t) => t.churchId.equals(churchId) & t.year.equals(year) & t.quarter.equals(quarter));
    final e = await q.getSingleOrNull();
    if (e == null) return null;
    final rows = await _getAttendanceRows(e.id);
    return _toModel(e, rows);
  }

  Future<int> createEvent(HolyCommunionEvent event) async {
    final now = DateTime.now();
    return _db.into(_db.holyCommunionEvents).insert(
      db.HolyCommunionEventsCompanion.insert(
        churchId: event.churchId,
        createdByAdminId: Value(event.createdByAdminId),
        eventDate: event.eventDate,
        year: event.year, quarter: event.quarter,
        totalExpectedAtKcc: Value(event.totalExpectedAtKcc),
        notes: Value(event.notes),
        createdAt: now, updatedAt: now,
      ),
    );
  }

  Future<void> upsertAttendanceRows(
      int eventId, List<HolyCommunionAttendanceRow> rows) async {
    await (_db.delete(_db.holyCommunionAttendance)
          ..where((t) => t.eventId.equals(eventId)))
        .go();
    for (final row in rows) {
      await _db.into(_db.holyCommunionAttendance).insert(
        db.HolyCommunionAttendanceCompanion.insert(
          eventId: eventId,
          homeChurchId: row.homeChurchId,
          actualAttendance: Value(row.actualAttendance),
          expectedAtHc: Value(row.expectedAtHc),
        ),
      );
    }
  }

  Future<bool> updateEvent(HolyCommunionEvent event) async {
    if (event.id == null) return false;
    return _db.update(_db.holyCommunionEvents).replace(
      db.HolyCommunionEventsCompanion(
        id: Value(event.id!), churchId: Value(event.churchId),
        createdByAdminId: Value(event.createdByAdminId),
        eventDate: Value(event.eventDate),
        year: Value(event.year), quarter: Value(event.quarter),
        totalExpectedAtKcc: Value(event.totalExpectedAtKcc),
        notes: Value(event.notes),
        createdAt: Value(event.createdAt), updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deleteEvent(int id) async {
    await (_db.delete(_db.holyCommunionAttendance)..where((t) => t.eventId.equals(id))).go();
    return (_db.delete(_db.holyCommunionEvents)..where((t) => t.id.equals(id))).go();
  }

  Future<List<db.HolyCommunionAttendanceData>> _getAttendanceRows(int eventId) =>
      (_db.select(_db.holyCommunionAttendance)
            ..where((t) => t.eventId.equals(eventId)))
          .get();

  HolyCommunionEvent _toModel(
      db.HolyCommunionEvent e, List<db.HolyCommunionAttendanceData> rows) =>
    HolyCommunionEvent(
      id: e.id, churchId: e.churchId, createdByAdminId: e.createdByAdminId,
      eventDate: e.eventDate, year: e.year, quarter: e.quarter,
      totalExpectedAtKcc: e.totalExpectedAtKcc, notes: e.notes,
      attendance: rows.map((r) => HolyCommunionAttendanceRow(
        id: r.id, eventId: r.eventId, homeChurchId: r.homeChurchId,
        homeChurchName: '', // populated by service layer
        actualAttendance: r.actualAttendance, expectedAtHc: r.expectedAtHc,
      )).toList(),
      createdAt: e.createdAt, updatedAt: e.updatedAt,
    );
}
