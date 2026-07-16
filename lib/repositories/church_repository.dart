import 'package:church_analytics/database/app_database.dart' as db;
import 'package:church_analytics/models/models.dart';
import 'package:drift/drift.dart';

/// Repository for managing Church data
class ChurchRepository {
  final db.AppDatabase _db;

  ChurchRepository(this._db);

  /// Get all churches
  Future<List<Church>> getAllChurches() async {
    final churches = await _db.select(_db.churches).get();
    return churches.map(_toModel).toList();
  }

  /// Get church by ID
  Future<Church?> getChurchById(int id) async {
    final query = _db.select(_db.churches)..where((t) => t.id.equals(id));
    final result = await query.getSingleOrNull();
    return result != null ? _toModel(result) : null;
  }

  /// Create a new church
  Future<int> createChurch(Church church) async {
    return await _db
        .into(_db.churches)
        .insert(
          db.ChurchesCompanion.insert(
            name: church.name,
            address: Value(church.address),
            contactEmail: Value(church.contactEmail),
            contactPhone: Value(church.contactPhone),
            currency: Value(church.currency),
            boardMemberCount: Value(church.boardMemberCount),
            createdAt: church.createdAt,
            updatedAt: church.updatedAt,
          ),
        );
  }

  /// Update an existing church
  Future<bool> updateChurch(Church church) async {
    if (church.id == null) return false;

    return await _db
        .update(_db.churches)
        .replace(
          db.ChurchesCompanion(
            id: Value(church.id!),
            name: Value(church.name),
            address: Value(church.address),
            contactEmail: Value(church.contactEmail),
            contactPhone: Value(church.contactPhone),
            currency: Value(church.currency),
            boardMemberCount: Value(church.boardMemberCount),
            createdAt: Value(church.createdAt),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  /// Delete a church
  Future<int> deleteChurch(int id) async {
    return await (_db.delete(_db.churches)..where((t) => t.id.equals(id))).go();
  }

  /// Delete a church and every row that depends on it, in FK-safe order,
  /// inside a single transaction.
  ///
  /// The schema declares its foreign keys with no `ON DELETE` action and runs
  /// with `PRAGMA foreign_keys = ON`, so a bare [deleteChurch] on a church
  /// that has any admins, weekly records, or events fails with a constraint
  /// error. This removes the dependent rows first (children before parents)
  /// so orphaned/duplicate churches — which may already have admin accounts
  /// and events attached — can be removed cleanly, all-or-nothing.
  Future<void> deleteChurchCascade(int id) async {
    await _db.transaction(() async {
      // Event headers owned by this church; their per-home-church attendance
      // rows must go first.
      final hcEventIds = (await (_db.select(_db.holyCommunionEvents)
                ..where((t) => t.churchId.equals(id)))
              .get())
          .map((e) => e.id)
          .toList();
      final bmEventIds = (await (_db.select(_db.businessMeetingEvents)
                ..where((t) => t.churchId.equals(id)))
              .get())
          .map((e) => e.id)
          .toList();

      if (hcEventIds.isNotEmpty) {
        await (_db.delete(_db.holyCommunionAttendance)
              ..where((t) => t.eventId.isIn(hcEventIds)))
            .go();
      }
      if (bmEventIds.isNotEmpty) {
        await (_db.delete(_db.businessMeetingAttendance)
              ..where((t) => t.eventId.isIn(bmEventIds)))
            .go();
      }

      // Event headers and every other table that references the church.
      await (_db.delete(_db.holyCommunionEvents)
            ..where((t) => t.churchId.equals(id)))
          .go();
      await (_db.delete(_db.businessMeetingEvents)
            ..where((t) => t.churchId.equals(id)))
          .go();
      await (_db.delete(_db.boardMeetingRecords)
            ..where((t) => t.churchId.equals(id)))
          .go();
      await (_db.delete(_db.homeChurches)
            ..where((t) => t.churchId.equals(id)))
          .go();
      await (_db.delete(_db.weeklyRecords)
            ..where((t) => t.churchId.equals(id)))
          .go();
      await (_db.delete(_db.derivedMetricsList)
            ..where((t) => t.churchId.equals(id)))
          .go();
      await (_db.delete(_db.exportHistoryList)
            ..where((t) => t.churchId.equals(id)))
          .go();

      // Admins are referenced by the records/events just removed, so they
      // come after them and immediately before the church itself.
      await (_db.delete(_db.adminUsers)..where((t) => t.churchId.equals(id)))
          .go();
      await (_db.delete(_db.churches)..where((t) => t.id.equals(id))).go();
    });
  }

  /// Search churches by name
  Future<List<Church>> searchChurchesByName(String query) async {
    final churches = await (_db.select(
      _db.churches,
    )..where((t) => t.name.like('%$query%'))).get();
    return churches.map(_toModel).toList();
  }

  /// Convert database model to domain model
  Church _toModel(db.Churche data) {
    return Church(
      id: data.id,
      name: data.name,
      address: data.address,
      contactEmail: data.contactEmail,
      contactPhone: data.contactPhone,
      currency: data.currency,
      boardMemberCount: data.boardMemberCount,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }
}
