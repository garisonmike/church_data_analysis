import 'package:drift/drift.dart';

import 'package:church_analytics/database/app_database.dart';
import 'package:church_analytics/models/models.dart';

// ignore_for_file: prefer_expression_function_bodies

/// Repository for [BusinessMeetingEvent] and its child
/// [BusinessMeetingAttendance] rows.
///
/// Delete operations manually delete child attendance rows first to remain
/// safe whether or not ON DELETE CASCADE is set on the foreign key.
class BusinessMeetingRepository {
  final AppDatabase _db;

  BusinessMeetingRepository(this._db);

  // ── queries ───────────────────────────────────────────────────────────────

  /// Returns all Business Meeting events for [churchId], most recent first.
  Future<List<BusinessMeetingEvent>> getEventsByChurch(int churchId) async {
    final rows = await (_db.select(_db.businessMeetingEvents)
          ..where((t) => t.churchId.equals(churchId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.year),
            (t) => OrderingTerm.desc(t.quarter),
            (t) => OrderingTerm.desc(t.meetingNumber),
          ]))
        .get();
    return rows.map(_toModel).toList();
  }

  /// Returns a single event by primary key, or `null`.
  Future<BusinessMeetingEvent?> getEventById(int id) async {
    final row = await (_db.select(_db.businessMeetingEvents)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  /// Returns the event for a given church, year, quarter, and meeting number,
  /// or `null`.
  Future<BusinessMeetingEvent?> getEventByChurchYearQuarterNumber(
      int churchId, int year, int quarter, int meetingNumber) async {
    final row = await (_db.select(_db.businessMeetingEvents)
          ..where((t) =>
              t.churchId.equals(churchId) &
              t.year.equals(year) &
              t.quarter.equals(quarter) &
              t.meetingNumber.equals(meetingNumber)))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  // ── mutations ─────────────────────────────────────────────────────────────

  /// Inserts a new Business Meeting event header.
  Future<BusinessMeetingEvent> createEvent(BusinessMeetingEvent event) async {
    final id = await _db.into(_db.businessMeetingEvents).insert(
          BusinessMeetingEventsCompanion.insert(
            churchId: event.churchId,
            createdByAdminId: Value(event.createdByAdminId),
            eventDate: event.eventDate,
            year: event.year,
            quarter: event.quarter,
            meetingNumber: event.meetingNumber,
            totalExpectedAtKcc: event.totalExpectedAtKcc,
            notes: Value(event.notes),
            createdAt: event.createdAt,
            updatedAt: event.updatedAt,
          ),
        );
    return event.copyWith(id: id);
  }

  /// Updates an existing event header. [event.id] must be non-null.
  Future<void> updateEvent(BusinessMeetingEvent event) async {
    assert(event.id != null, 'updateEvent requires a non-null id');
    await (_db.update(_db.businessMeetingEvents)
          ..where((t) => t.id.equals(event.id!)))
        .write(
      BusinessMeetingEventsCompanion(
        churchId: Value(event.churchId),
        createdByAdminId: Value(event.createdByAdminId),
        eventDate: Value(event.eventDate),
        year: Value(event.year),
        quarter: Value(event.quarter),
        meetingNumber: Value(event.meetingNumber),
        totalExpectedAtKcc: Value(event.totalExpectedAtKcc),
        notes: Value(event.notes),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ── FEAT-015 — delete ─────────────────────────────────────────────────────

  /// Permanently deletes a Business Meeting event and all of its child
  /// attendance rows, wrapped in a transaction.
  Future<void> deleteEvent(int id) async {
    await _db.transaction(() async {
      // 1. Delete child attendance rows
      await (_db.delete(_db.businessMeetingAttendance)
            ..where((t) => t.eventId.equals(id)))
          .go();

      // 2. Delete the event header
      await (_db.delete(_db.businessMeetingEvents)
            ..where((t) => t.id.equals(id)))
          .go();
    });
  }

  /// Permanently deletes multiple events and their attendance rows.
  Future<void> deleteEvents(List<int> ids) async {
    if (ids.isEmpty) return;
    await _db.transaction(() async {
      for (final id in ids) {
        await (_db.delete(_db.businessMeetingAttendance)
              ..where((t) => t.eventId.equals(id)))
            .go();
        await (_db.delete(_db.businessMeetingEvents)
              ..where((t) => t.id.equals(id)))
            .go();
      }
    });
  }

  // ── mapping ───────────────────────────────────────────────────────────────

  BusinessMeetingEvent _toModel(db.BusinessMeetingEvent row) =>
      BusinessMeetingEvent(
        id: row.id,
        churchId: row.churchId,
        createdByAdminId: row.createdByAdminId,
        eventDate: row.eventDate,
        year: row.year,
        quarter: row.quarter,
        meetingNumber: row.meetingNumber,
        totalExpectedAtKcc: row.totalExpectedAtKcc,
        notes: row.notes,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
}
