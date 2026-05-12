import 'package:drift/drift.dart';

import 'package:church_analytics/database/app_database.dart';
import 'package:church_analytics/models/models.dart';

// ignore_for_file: prefer_expression_function_bodies

/// Repository for [HolyCommunionEvent] and its child [HolyCommunionAttendance]
/// rows.
///
/// Delete operations manually delete child attendance rows first to remain
/// safe whether or not ON DELETE CASCADE is set on the foreign key.
class HolyCommunionRepository {
  final AppDatabase _db;

  HolyCommunionRepository(this._db);

  // ── queries ───────────────────────────────────────────────────────────────

  /// Returns all Holy Communion events for [churchId], most recent first.
  Future<List<HolyCommunionEvent>> getEventsByChurch(int churchId) async {
    final rows = await (_db.select(_db.holyCommunionEvents)
          ..where((t) => t.churchId.equals(churchId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.year),
            (t) => OrderingTerm.desc(t.quarter),
          ]))
        .get();
    return rows.map(_toModel).toList();
  }

  /// Returns a single event by primary key, or `null`.
  Future<HolyCommunionEvent?> getEventById(int id) async {
    final row = await (_db.select(_db.holyCommunionEvents)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  /// Returns the event for a given church, year, and quarter, or `null`.
  Future<HolyCommunionEvent?> getEventByChurchYearQuarter(
      int churchId, int year, int quarter) async {
    final row = await (_db.select(_db.holyCommunionEvents)
          ..where((t) =>
              t.churchId.equals(churchId) &
              t.year.equals(year) &
              t.quarter.equals(quarter)))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  // ── mutations ─────────────────────────────────────────────────────────────

  /// Inserts a new Holy Communion event header.
  Future<HolyCommunionEvent> createEvent(HolyCommunionEvent event) async {
    final id = await _db.into(_db.holyCommunionEvents).insert(
          HolyCommunionEventsCompanion.insert(
            churchId: event.churchId,
            createdByAdminId: Value(event.createdByAdminId),
            eventDate: event.eventDate,
            year: event.year,
            quarter: event.quarter,
            totalExpectedAtKcc: event.totalExpectedAtKcc,
            notes: Value(event.notes),
            createdAt: event.createdAt,
            updatedAt: event.updatedAt,
          ),
        );
    return event.copyWith(id: id);
  }

  /// Updates an existing event header. [event.id] must be non-null.
  Future<void> updateEvent(HolyCommunionEvent event) async {
    assert(event.id != null, 'updateEvent requires a non-null id');
    await (_db.update(_db.holyCommunionEvents)
          ..where((t) => t.id.equals(event.id!)))
        .write(
      HolyCommunionEventsCompanion(
        churchId: Value(event.churchId),
        createdByAdminId: Value(event.createdByAdminId),
        eventDate: Value(event.eventDate),
        year: Value(event.year),
        quarter: Value(event.quarter),
        totalExpectedAtKcc: Value(event.totalExpectedAtKcc),
        notes: Value(event.notes),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ── FEAT-015 — delete ─────────────────────────────────────────────────────

  /// Permanently deletes a Holy Communion event and all of its child
  /// attendance rows, wrapped in a transaction.
  ///
  /// Attendance rows are deleted first to avoid any FK constraint violation
  /// regardless of whether ON DELETE CASCADE is set on the schema.
  Future<void> deleteEvent(int id) async {
    await _db.transaction(() async {
      // 1. Delete child attendance rows
      await (_db.delete(_db.holyCommunionAttendance)
            ..where((t) => t.eventId.equals(id)))
          .go();

      // 2. Delete the event header
      await (_db.delete(_db.holyCommunionEvents)
            ..where((t) => t.id.equals(id)))
          .go();
    });
  }

  /// Permanently deletes multiple events and their attendance rows.
  Future<void> deleteEvents(List<int> ids) async {
    if (ids.isEmpty) return;
    await _db.transaction(() async {
      for (final id in ids) {
        await (_db.delete(_db.holyCommunionAttendance)
              ..where((t) => t.eventId.equals(id)))
            .go();
        await (_db.delete(_db.holyCommunionEvents)
              ..where((t) => t.id.equals(id)))
            .go();
      }
    });
  }

  // ── mapping ───────────────────────────────────────────────────────────────

  HolyCommunionEvent _toModel(db.HolyCommunionEvent row) => HolyCommunionEvent(
        id: row.id,
        churchId: row.churchId,
        createdByAdminId: row.createdByAdminId,
        eventDate: row.eventDate,
        year: row.year,
        quarter: row.quarter,
        totalExpectedAtKcc: row.totalExpectedAtKcc,
        notes: row.notes,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
}
