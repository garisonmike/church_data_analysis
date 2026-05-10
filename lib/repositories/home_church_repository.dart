import 'package:church_analytics/database/app_database.dart' as db;
import 'package:church_analytics/models/models.dart';
import 'package:drift/drift.dart';

class HomeChurchRepository {
  final db.AppDatabase _db;
  HomeChurchRepository(this._db);

  Future<List<HomeChurch>> getByChurch(int churchId, {bool activeOnly = true}) async {
    final q = _db.select(_db.homeChurches)
      ..where((t) => t.churchId.equals(churchId));
    if (activeOnly) q.where((t) => t.isActive.equals(true));
    q.orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.name)]);
    return (await q.get()).map(_toModel).toList();
  }

  Future<HomeChurch?> getById(int id) async {
    final q = _db.select(_db.homeChurches)..where((t) => t.id.equals(id));
    final r = await q.getSingleOrNull();
    return r != null ? _toModel(r) : null;
  }

  Future<int> create(HomeChurch hc) async {
    final now = DateTime.now();
    return _db.into(_db.homeChurches).insert(db.HomeChurchesCompanion.insert(
      churchId: hc.churchId, name: hc.name,
      category: Value(hc.category.name),
      expectedMembership: Value(hc.expectedMembership),
      expectedAtKcc: Value(hc.expectedAtKcc),
      isActive: Value(hc.isActive), sortOrder: Value(hc.sortOrder),
      createdAt: now, updatedAt: now,
    ));
  }

  Future<bool> update(HomeChurch hc) async {
    if (hc.id == null) return false;
    return _db.update(_db.homeChurches).replace(db.HomeChurchesCompanion(
      id: Value(hc.id!), churchId: Value(hc.churchId), name: Value(hc.name),
      category: Value(hc.category.name),
      expectedMembership: Value(hc.expectedMembership),
      expectedAtKcc: Value(hc.expectedAtKcc),
      isActive: Value(hc.isActive), sortOrder: Value(hc.sortOrder),
      createdAt: Value(hc.createdAt), updatedAt: Value(DateTime.now()),
    ));
  }

  Future<int> delete(int id) async =>
      (_db.delete(_db.homeChurches)..where((t) => t.id.equals(id))).go();

  HomeChurch _toModel(db.HomeChurche r) => HomeChurch(
    id: r.id, churchId: r.churchId, name: r.name,
    category: HomeChurchCategoryX.fromString(r.category),
    expectedMembership: r.expectedMembership,
    expectedAtKcc: r.expectedAtKcc,
    isActive: r.isActive, sortOrder: r.sortOrder,
    createdAt: r.createdAt, updatedAt: r.updatedAt,
  );
}
