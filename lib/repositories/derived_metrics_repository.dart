import 'package:church_analytics/database/app_database.dart' as db;
import 'package:church_analytics/models/models.dart';
import 'package:drift/drift.dart';

/// Repository for caching and retrieving derived analytics metrics
class DerivedMetricsRepository {
  final db.AppDatabase _db;

  /// Default cache validity duration (1 hour)
  static const Duration defaultCacheValidity = Duration(hours: 1);

  DerivedMetricsRepository(this._db);

  /// Save or update cached metrics for a church and period
  Future<int> saveCachedMetrics(DerivedMetrics metrics) async {
    // Check if metrics already exist for this church and period
    final existing = await getCachedMetrics(
      metrics.churchId,
      metrics.periodStart,
      metrics.periodEnd,
    );

    if (existing != null) {
      // Update existing cache
      await (_db.update(
        _db.derivedMetricsList,
      )..where((t) => t.id.equals(existing.id!))).write(
        db.DerivedMetricsListCompanion(
          averageAttendance: Value(metrics.averageAttendance),
          averageIncome: Value(metrics.averageIncome),
          growthPercentage: Value(metrics.growthPercentage),
          attendanceToIncomeRatio: Value(metrics.attendanceToIncomeRatio),
          perCapitaGiving: Value(metrics.perCapitaGiving),
          menPercentage: Value(metrics.menPercentage),
          womenPercentage: Value(metrics.womenPercentage),
          youthPercentage: Value(metrics.youthPercentage),
          childrenPercentage: Value(metrics.childrenPercentage),
          tithePercentage: Value(metrics.tithePercentage),
          offeringsPercentage: Value(metrics.offeringsPercentage),
          calculatedAt: Value(metrics.calculatedAt),
        ),
      );
      return existing.id!;
    } else {
      // Insert new cache entry
      return _db
          .into(_db.derivedMetricsList)
          .insert(
            db.DerivedMetricsListCompanion.insert(
              churchId: metrics.churchId,
              periodStart: metrics.periodStart,
              periodEnd: metrics.periodEnd,
              averageAttendance: metrics.averageAttendance,
              averageIncome: metrics.averageIncome,
              growthPercentage: metrics.growthPercentage,
              attendanceToIncomeRatio: metrics.attendanceToIncomeRatio,
              perCapitaGiving: metrics.perCapitaGiving,
              menPercentage: metrics.menPercentage,
              womenPercentage: metrics.womenPercentage,
              youthPercentage: metrics.youthPercentage,
              childrenPercentage: metrics.childrenPercentage,
              tithePercentage: metrics.tithePercentage,
              offeringsPercentage: metrics.offeringsPercentage,
              calculatedAt: metrics.calculatedAt,
            ),
          );
    }
  }

  /// Get cached metrics for a specific church and period
  Future<DerivedMetrics?> getCachedMetrics(
    int churchId,
    DateTime periodStart,
    DateTime periodEnd,
  ) async {
    final query = _db.select(_db.derivedMetricsList)
      ..where(
        (t) =>
            t.churchId.equals(churchId) &
            t.periodStart.equals(periodStart) &
            t.periodEnd.equals(periodEnd),
      );

    final result = await query.getSingleOrNull();
    return result != null ? _toModel(result) : null;
  }

  /// Get all cached metrics for a church
  Future<List<DerivedMetrics>> getAllCachedMetricsByChurch(int churchId) async {
    final records =
        await (_db.select(_db.derivedMetricsList)
              ..where((t) => t.churchId.equals(churchId))
              ..orderBy([(t) => OrderingTerm.desc(t.calculatedAt)]))
            .get();
    return records.map(_toModel).toList();
  }

  /// Get the most recent cached metrics for a church
  Future<DerivedMetrics?> getMostRecentCachedMetrics(int churchId) async {
    final query = _db.select(_db.derivedMetricsList)
      ..where((t) => t.churchId.equals(churchId))
      ..orderBy([(t) => OrderingTerm.desc(t.calculatedAt)])
      ..limit(1);

    final result = await query.getSingleOrNull();
    return result != null ? _toModel(result) : null;
  }

  /// Check if cached metrics are still valid (not expired)
  bool isCacheValid(DerivedMetrics? cachedMetrics, {Duration? cacheValidity}) {
    if (cachedMetrics == null) return false;

    final validity = cacheValidity ?? defaultCacheValidity;
    final now = DateTime.now();
    final cacheAge = now.difference(cachedMetrics.calculatedAt);

    return cacheAge < validity;
  }

  /// Get valid cached metrics or null if cache is expired/missing
  Future<DerivedMetrics?> getValidCachedMetrics(
    int churchId,
    DateTime periodStart,
    DateTime periodEnd, {
    Duration? cacheValidity,
  }) async {
    final cached = await getCachedMetrics(churchId, periodStart, periodEnd);

    if (isCacheValid(cached, cacheValidity: cacheValidity)) {
      return cached;
    }

    return null;
  }

  /// Invalidate (delete) cached metrics for a church
  /// Call this when weekly records are added, updated, or deleted
  Future<int> invalidateCache(int churchId) async {
    return (_db.delete(
      _db.derivedMetricsList,
    )..where((t) => t.churchId.equals(churchId))).go();
  }

  /// Invalidate cached metrics for a specific period
  Future<int> invalidateCacheForPeriod(
    int churchId,
    DateTime periodStart,
    DateTime periodEnd,
  ) async {
    return (_db.delete(_db.derivedMetricsList)..where(
          (t) =>
              t.churchId.equals(churchId) &
              t.periodStart.equals(periodStart) &
              t.periodEnd.equals(periodEnd),
        ))
        .go();
  }

  /// Delete all cached metrics older than a specified duration
  Future<int> cleanupOldCache({
    Duration maxAge = const Duration(days: 7),
  }) async {
    final cutoffDate = DateTime.now().subtract(maxAge);
    return (_db.delete(
      _db.derivedMetricsList,
    )..where((t) => t.calculatedAt.isSmallerThanValue(cutoffDate))).go();
  }

  /// Delete cached metrics by ID
  Future<int> deleteCachedMetrics(int id) async {
    return (_db.delete(
      _db.derivedMetricsList,
    )..where((t) => t.id.equals(id))).go();
  }

  /// Convert database row to model
  DerivedMetrics _toModel(db.DerivedMetricsListData data) {
    return DerivedMetrics(
      id: data.id,
      churchId: data.churchId,
      periodStart: data.periodStart,
      periodEnd: data.periodEnd,
      averageAttendance: data.averageAttendance,
      averageIncome: data.averageIncome,
      growthPercentage: data.growthPercentage,
      attendanceToIncomeRatio: data.attendanceToIncomeRatio,
      perCapitaGiving: data.perCapitaGiving,
      menPercentage: data.menPercentage,
      womenPercentage: data.womenPercentage,
      youthPercentage: data.youthPercentage,
      childrenPercentage: data.childrenPercentage,
      tithePercentage: data.tithePercentage,
      offeringsPercentage: data.offeringsPercentage,
      calculatedAt: data.calculatedAt,
    );
  }
}
