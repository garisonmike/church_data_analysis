import 'package:drift/drift.dart';

import 'package:church_analytics/database/app_database.dart';
import 'package:church_analytics/models/models.dart' as domain;

// ignore_for_file: prefer_expression_function_bodies

/// Repository for [domain.HolyCommunionEvent] and its child
/// [domain.HolyCommunionAttendanceRow] rows.
///
/// Delete operations manually delete child attendance rows first to remain
/// safe whether or not ON DELETE CASCADE is set on the foreign key.
///
/// ### Name-conflict resolution
/// Drift auto-generates a row class also called `HolyCommunionEvent` (from the
/// `HolyCommunionEvents` table definition). To prevent the analyser from seeing
/// an ambiguous reference, the domain models barrel is imported under the
/// `domain` prefix, so unqualified `HolyCommunionEvent` inside this file always
/// refers to the Drift-generated type.
class HolyCommunionRepository {
  final AppDatabase _db;

  HolyCommunionRepository(this._db);

  // ── queries ───────────────────────────────────────────────────────────────

  /// Returns all Holy Communion events for [churchId], most recent first.
  Future<List<domain.HolyCommunionEvent>> getEventsByChurch(
      int churchId) async {
    final rows = await (_db.select(_db.holyCommunionEvents)
          ..where((t) => t.churchId.equals(churchId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.year),
            (t) => OrderingTerm.desc(t.quarter),
          ]))
        .get();
    return rows.map(_toModel).toList();
  }

  /// Alias for [getEventsByChurch] — used by [holyCommunionEventsProvider].
  Future<List<domain.HolyCommunionEvent>> getByChurch(int churchId) =>
      getEventsByChurch(churchId);

  /// Returns a single event by primary key, or `null`.
  Future<domain.HolyCommunionEvent?> getEventById(int id) async {
    final row = await (_db.select(_db.holyCommunionEvents)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  /// Returns the event for a given church, year, and quarter, or `null`.
  Future<domain.HolyCommunionEvent?> getEventByChurchYearQuarter(
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

  /// Inserts a new Holy Communion event header and returns the new row's id.
  Future<int> createEvent(domain.HolyCommunionEvent event) async {
    final id = await _db.into(_db.holyCommunionEvents).insert(
          HolyCommunionEventsCompanion.insert(
            churchId: event.churchId,
            createdByAdminId: Value(event.createdByAdminId),
            eventDate: event.eventDate,
            year: event.year,
            quarter: event.quarter,
            totalExpectedAtKcc: Value(event.totalExpectedAtKcc),
            notes: Value(event.notes),
            createdAt: event.createdAt,
            updatedAt: event.updatedAt,
          ),
        );
    return id;
  }

  /// Updates an existing event header. [event.id] must be non-null.
  Future<void> updateEvent(domain.HolyCommunionEvent event) async {
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

  /// Upserts [rows] as the complete set of per-home-church attendance rows for
  /// [eventId], replacing any previously stored rows for that event.
  ///
  /// Each element of [rows] must be a [domain.HolyCommunionAttendanceRow].
  /// The operation runs inside a single transaction:
  ///   1. Delete all existing [HolyCommunionAttendance] rows for [eventId].
  ///   2. Insert the new [rows].
  ///
  /// Callers that have already created the event header (via [createEvent] or
  /// [updateEvent]) should pass the resolved [eventId] returned by the DB.
  Future<void> upsertAttendanceRows(
    int eventId,
    List<domain.HolyCommunionAttendanceRow> rows,
  ) async {
    await _db.transaction(() async {
      // 1. Remove stale rows
      await (_db.delete(_db.holyCommunionAttendance)
            ..where((t) => t.eventId.equals(eventId)))
          .go();

      // 2. Insert the new set
      for (final row in rows) {
        await _db.into(_db.holyCommunionAttendance).insert(
              HolyCommunionAttendanceCompanion.insert(
                eventId: eventId,
                homeChurchId: row.homeChurchId,
                actualAttendance: Value(row.actualAttendance),
                expectedAtHc: Value(row.expectedAtHc),
              ),
            );
      }
    });
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

  // [row] is the Drift-generated HolyCommunionEvent (unqualified); the return
  // type is the domain model (qualified with `domain.`).
  domain.HolyCommunionEvent _toModel(HolyCommunionEvent row) =>
      domain.HolyCommunionEvent(
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
        // attendance rows are not eagerly loaded here; callers that need them
        // should issue a separate query or call upsertAttendanceRows.
      );
}
