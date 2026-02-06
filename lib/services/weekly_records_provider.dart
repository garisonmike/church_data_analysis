import 'package:church_analytics/database/app_database.dart';
import 'package:church_analytics/models/models.dart' as models;
import 'package:church_analytics/repositories/repositories.dart';
import 'package:church_analytics/services/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum for different time range options for charts
enum ChartTimeRange {
  fourWeeks(4, 'Last 4 Weeks'),
  twelveWeeks(12, 'Last 12 Weeks'),
  sixMonths(26, 'Last 6 Months'),
  oneYear(52, 'Last Year'),
  all(0, 'All Time');

  const ChartTimeRange(this.weeks, this.displayName);

  /// Number of weeks to fetch (0 means all records)
  final int weeks;

  /// Display name for UI
  final String displayName;
}

/// Parameters for fetching weekly records
class WeeklyRecordsParams {
  final int churchId;
  final ChartTimeRange timeRange;
  final int? adminId;

  const WeeklyRecordsParams({
    required this.churchId,
    required this.timeRange,
    this.adminId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyRecordsParams &&
          runtimeType == other.runtimeType &&
          churchId == other.churchId &&
          timeRange == other.timeRange &&
          adminId == other.adminId;

  @override
  int get hashCode => Object.hash(churchId, timeRange, adminId);
}

/// State class for weekly records with loading/error states
class WeeklyRecordsState {
  final List<models.WeeklyRecord> records;
  final bool isLoading;
  final String? error;

  const WeeklyRecordsState({
    this.records = const [],
    this.isLoading = false,
    this.error,
  });

  WeeklyRecordsState copyWith({
    List<models.WeeklyRecord>? records,
    bool? isLoading,
    String? error,
  }) {
    return WeeklyRecordsState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Provider for current chart time range selection
final chartTimeRangeProvider = StateProvider<ChartTimeRange>((ref) {
  return ChartTimeRange.twelveWeeks; // Default to 12 weeks
});

/// Provider for current admin ID (for filtering records)
final currentAdminIdProvider = FutureProvider<int?>((ref) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final adminDb = ref.watch(databaseProvider);
    final adminRepo = AdminUserRepository(adminDb);
    final profileService = AdminProfileService(adminRepo, prefs);
    final currentAdminId = profileService.getCurrentProfileId();
    return currentAdminId;
  } catch (e) {
    return null;
  }
});

/// Provider for weekly records based on church ID and time range
final weeklyRecordsProvider =
    StateNotifierProvider.family<
      WeeklyRecordsNotifier,
      WeeklyRecordsState,
      WeeklyRecordsParams
    >((ref, params) {
      final database = ref.watch(databaseProvider);
      return WeeklyRecordsNotifier(params, database);
    });

/// Convenience provider that combines church ID and current time range
final weeklyRecordsForChurchProvider =
    Provider.family<AsyncValue<List<models.WeeklyRecord>>, int>((
      ref,
      churchId,
    ) {
      final timeRange = ref.watch(chartTimeRangeProvider);
      final adminIdAsync = ref.watch(currentAdminIdProvider);

      return adminIdAsync.when(
        loading: () => const AsyncValue.loading(),
        error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
        data: (adminId) {
          final params = WeeklyRecordsParams(
            churchId: churchId,
            timeRange: timeRange,
            adminId: adminId,
          );

          final recordsState = ref.watch(weeklyRecordsProvider(params));

          if (recordsState.isLoading) {
            return const AsyncValue.loading();
          } else if (recordsState.error != null) {
            return AsyncValue.error(recordsState.error!, StackTrace.current);
          } else {
            return AsyncValue.data(recordsState.records);
          }
        },
      );
    });

/// State notifier for managing weekly records
class WeeklyRecordsNotifier extends StateNotifier<WeeklyRecordsState> {
  final WeeklyRecordsParams params;
  final AppDatabase database;

  WeeklyRecordsNotifier(this.params, this.database)
    : super(const WeeklyRecordsState()) {
    _loadData();
  }

  /// Load weekly records from the database
  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = WeeklyRecordRepository(database);

      List<models.WeeklyRecord> records;

      if (params.timeRange == ChartTimeRange.all) {
        // Get all records
        if (params.adminId != null) {
          records = await repository.getAllRecordsByAdmin(
            params.churchId,
            params.adminId!,
          );
        } else {
          records = await repository.getAllRecords(params.churchId);
        }
      } else {
        // Get recent records for specified weeks
        if (params.adminId != null) {
          records = await repository.getRecentRecordsByAdmin(
            params.churchId,
            params.adminId!,
            params.timeRange.weeks,
          );
        } else {
          records = await repository.getRecentRecords(
            params.churchId,
            params.timeRange.weeks,
          );
        }
      }

      state = state.copyWith(records: records, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error loading data: ${e.toString()}',
      );
    }
  }

  /// Refresh the data
  Future<void> refresh() async {
    await _loadData();
  }

  /// Update time range and reload data
  Future<void> updateTimeRange(ChartTimeRange newTimeRange) async {
    if (params.timeRange != newTimeRange) {
      // This will trigger a new provider instance, so we don't need to do anything here
      // The calling code should watch a new provider with updated params
    }
  }
}
