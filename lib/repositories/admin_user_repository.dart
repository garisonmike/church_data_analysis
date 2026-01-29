import 'package:church_analytics/database/app_database.dart' as db;
import 'package:church_analytics/models/models.dart';
import 'package:drift/drift.dart';

/// Repository for managing AdminUser data
class AdminUserRepository {
  final db.AppDatabase _db;

  AdminUserRepository(this._db);

  /// Get all admin users for a church
  Future<List<AdminUser>> getUsersByChurch(int churchId) async {
    final users = await (_db.select(
      _db.adminUsers,
    )..where((t) => t.churchId.equals(churchId))).get();
    return users.map(_toModel).toList();
  }

  /// Get admin user by ID
  Future<AdminUser?> getUserById(int id) async {
    final query = _db.select(_db.adminUsers)..where((t) => t.id.equals(id));
    final result = await query.getSingleOrNull();
    return result != null ? _toModel(result) : null;
  }

  /// Get admin user by username
  Future<AdminUser?> getUserByUsername(String username) async {
    final query = _db.select(_db.adminUsers)
      ..where((t) => t.username.equals(username));
    final result = await query.getSingleOrNull();
    return result != null ? _toModel(result) : null;
  }

  /// Get all active admin users for a church
  Future<List<AdminUser>> getActiveUsersByChurch(int churchId) async {
    final users =
        await (_db.select(_db.adminUsers)..where(
              (t) => t.churchId.equals(churchId) & t.isActive.equals(true),
            ))
            .get();
    return users.map(_toModel).toList();
  }

  /// Create a new admin user
  Future<int> createUser(AdminUser user) async {
    return await _db
        .into(_db.adminUsers)
        .insert(
          db.AdminUsersCompanion.insert(
            username: user.username,
            fullName: user.fullName,
            email: Value(user.email),
            churchId: user.churchId,
            isActive: Value(user.isActive),
            createdAt: user.createdAt,
            lastLoginAt: user.lastLoginAt,
          ),
        );
  }

  /// Update an existing admin user
  Future<bool> updateUser(AdminUser user) async {
    if (user.id == null) return false;

    return await _db
        .update(_db.adminUsers)
        .replace(
          db.AdminUsersCompanion(
            id: Value(user.id!),
            username: Value(user.username),
            fullName: Value(user.fullName),
            email: Value(user.email),
            churchId: Value(user.churchId),
            isActive: Value(user.isActive),
            createdAt: Value(user.createdAt),
            lastLoginAt: Value(user.lastLoginAt),
          ),
        );
  }

  /// Update last login time for a user
  Future<bool> updateLastLogin(int userId) async {
    final user = await getUserById(userId);
    if (user == null) return false;

    return await updateUser(user.copyWith(lastLoginAt: DateTime.now()));
  }

  /// Deactivate a user (soft delete)
  Future<bool> deactivateUser(int userId) async {
    final user = await getUserById(userId);
    if (user == null) return false;

    return await updateUser(user.copyWith(isActive: false));
  }

  /// Activate a user
  Future<bool> activateUser(int userId) async {
    final user = await getUserById(userId);
    if (user == null) return false;

    return await updateUser(user.copyWith(isActive: true));
  }

  /// Delete an admin user (hard delete)
  Future<int> deleteUser(int id) async {
    return await (_db.delete(
      _db.adminUsers,
    )..where((t) => t.id.equals(id))).go();
  }

  /// Convert database model to domain model
  AdminUser _toModel(db.AdminUser data) {
    return AdminUser(
      id: data.id,
      username: data.username,
      fullName: data.fullName,
      email: data.email,
      churchId: data.churchId,
      isActive: data.isActive,
      createdAt: data.createdAt,
      lastLoginAt: data.lastLoginAt,
    );
  }
}
