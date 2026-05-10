import 'package:church_analytics/database/app_database.dart' as db;
import 'package:church_analytics/models/models.dart';
import 'package:drift/drift.dart';

class BusinessMeetingRepository {
  final db.AppDatabase _db;
  BusinessMeetingRepository(this._db);

  Future<List<BusinessMeetingEvent>> getByChurch(int churchId) async {
    final events = await (_db.select(_db.businessMeetingEvents)
          ..where((t) => t.churchId.equals(churchId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.year),
            (t) => OrderingTerm.desc(t.quarter),
            (t) => OrderingTerm.desc(t.meetingNumber),
          ]))
        .get();
    final result = <BusinessMeetingEvent>[];
    for (final e in events) {
      final rows = await _getAttendanceRows(e.id);
      result.add(_toModel(e, rows));
    }
    return result;
  }

  Future<BusinessMeetingEvent?> getByQuarterAndNumber(
      int churchId, int year, int quarter, int meetingNumber) async {
    final q = _db.select(_db.businessMeetingEvents)
      ..where((t) =>
          t.churchId.equals(churchId) &
          t.year.equals(year) &
          t.quarter.equals(quarter) &
          t.meetingNumber.equals(meetingNumber));
    final e = await q.getSingleOrNull();
    if (e == null) return null;
    final rows = await _getAttendanceRows(e.id);
    return _toModel(e, rows);
  }

  Future<int> createEvent(BusinessMeetingEvent event) async {
    final now = DateTime.now();
    return _db.into(_db.businessMeetingEvents).insert(
      db.BusinessMeetingEventsCompanion.insert(
        churchId: event.churchId,
        createdByAdminId: Value(event.createdByAdminId),
        eventDate: event.eventDate,
        year: event.year, quarter: event.quarter,
        meetingNumber: Value(event.meetingNumber),
        totalExpectedAtKcc: Value(event.totalExpectedAtKcc),
        notes: Value(event.notes),
        createdAt: now, updatedAt: now,
      ),
    );
  }

  Future<void> upsertAttendanceRows(
      int eventId, List<BusinessMeetingAttendanceRow> rows) async {
    await (_db.delete(_db.businessMeetingAttendance)
          ..where((t) => t.eventId.equals(eventId)))
        .go();
    for (final row in rows) {
      await _db.into(_db.businessMeetingAttendance).insert(
        db.BusinessMeetingAttendanceCompanion.insert(
          eventId: eventId,
          homeChurchId: row.homeChurchId,
          actualAttendance: Value(row.actualAttendance),
          expectedAtHc: Value(row.expectedAtHc),
        ),
      );
    }
  }

  Future<bool> updateEvent(BusinessMeetingEvent event) async {
    if (event.id == null) return false;
    return _db.update(_db.businessMeetingEvents).replace(
      db.BusinessMeetingEventsCompanion(
        id: Value(event.id!), churchId: Value(event.churchId),
        createdByAdminId: Value(event.createdByAdminId),
        eventDate: Value(event.eventDate),
        year: Value(event.year), quarter: Value(event.quarter),
        meetingNumber: Value(event.meetingNumber),
        totalExpectedAtKcc: Value(event.totalExpectedAtKcc),
        notes: Value(event.notes),
        createdAt: Value(event.createdAt), updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deleteEvent(int id) async {
    await (_db.delete(_db.businessMeetingAttendance)
          ..where((t) => t.eventId.equals(id)))
        .go();
    return (_db.delete(_db.businessMeetingEvents)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  Future<List<db.BusinessMeetingAttendanceData>> _getAttendanceRows(int eventId) =>
      (_db.select(_db.businessMeetingAttendance)
            ..where((t) => t.eventId.equals(eventId)))
          .get();

  BusinessMeetingEvent _toModel(
      db.BusinessMeetingEvent e, List<db.BusinessMeetingAttendanceData> rows) =>
    BusinessMeetingEvent(
      id: e.id, churchId: e.churchId, createdByAdminId: e.createdByAdminId,
      eventDate: e.eventDate, year: e.year, quarter: e.quarter,
      meetingNumber: e.meetingNumber,
      totalExpectedAtKcc: e.totalExpectedAtKcc, notes: e.notes,
      attendance: rows.map((r) => BusinessMeetingAttendanceRow(
        id: r.id, eventId: r.eventId, homeChurchId: r.homeChurchId,
        homeChurchName: '',
        actualAttendance: r.actualAttendance, expectedAtHc: r.expectedAtHc,
      )).toList(),
      createdAt: e.createdAt, updatedAt: e.updatedAt,
    );
}
