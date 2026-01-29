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
            createdAt: Value(church.createdAt),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  /// Delete a church
  Future<int> deleteChurch(int id) async {
    return await (_db.delete(_db.churches)..where((t) => t.id.equals(id))).go();
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
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }
}
