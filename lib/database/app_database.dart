import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Churches table definition
class Churches extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get address => text().nullable()();
  TextColumn get contactEmail => text().nullable()();
  TextColumn get contactPhone => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('USD'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// Admin users table definition
class AdminUsers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().withLength(min: 3, max: 50)();
  TextColumn get fullName => text().withLength(min: 1, max: 100)();
  TextColumn get email => text().nullable()();
  IntColumn get churchId => integer().references(Churches, #id)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastLoginAt => dateTime()();
}

/// Weekly records table definition
class WeeklyRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get churchId => integer().references(Churches, #id)();
  DateTimeColumn get weekStartDate => dateTime()();

  // Attendance fields
  IntColumn get men => integer().withDefault(const Constant(0))();
  IntColumn get women => integer().withDefault(const Constant(0))();
  IntColumn get youth => integer().withDefault(const Constant(0))();
  IntColumn get children => integer().withDefault(const Constant(0))();
  IntColumn get sundayHomeChurch => integer().withDefault(const Constant(0))();

  // Finance fields
  RealColumn get tithe => real().withDefault(const Constant(0.0))();
  RealColumn get offerings => real().withDefault(const Constant(0.0))();
  RealColumn get emergencyCollection =>
      real().withDefault(const Constant(0.0))();
  RealColumn get plannedCollection => real().withDefault(const Constant(0.0))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column>>? get uniqueKeys => [
    {churchId, weekStartDate}, // Prevent duplicate weeks per church
  ];
}

/// Derived metrics table definition
class DerivedMetricsList extends Table {
  @override
  String get tableName => 'derived_metrics';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get churchId => integer().references(Churches, #id)();
  DateTimeColumn get periodStart => dateTime()();
  DateTimeColumn get periodEnd => dateTime()();

  // Cached metrics
  RealColumn get averageAttendance => real()();
  RealColumn get averageIncome => real()();
  RealColumn get growthPercentage => real()();
  RealColumn get attendanceToIncomeRatio => real()();
  RealColumn get perCapitaGiving => real()();

  // Category percentages
  RealColumn get menPercentage => real()();
  RealColumn get womenPercentage => real()();
  RealColumn get youthPercentage => real()();
  RealColumn get childrenPercentage => real()();

  RealColumn get tithePercentage => real()();
  RealColumn get offeringsPercentage => real()();

  DateTimeColumn get calculatedAt => dateTime()();
}

/// Export history table definition
class ExportHistoryList extends Table {
  @override
  String get tableName => 'export_history';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get churchId => integer().references(Churches, #id)();
  TextColumn get exportType => text()(); // 'graph', 'pdf_report', 'csv'
  TextColumn get exportName => text().withLength(min: 1, max: 200)();
  TextColumn get filePath => text().nullable()();
  TextColumn get graphType => text().nullable()();
  DateTimeColumn get exportedAt => dateTime()();
  IntColumn get recordCount => integer().withDefault(const Constant(0))();
}

@DriftDatabase(
  tables: [
    Churches,
    AdminUsers,
    WeeklyRecords,
    DerivedMetricsList,
    ExportHistoryList,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Test constructor for in-memory database
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Future migrations will go here
    },
    beforeOpen: (details) async {
      // Enable foreign keys
      await customStatement('PRAGMA foreign_keys = ON');

      // Optional: Add seed data if database is empty
      if (details.wasCreated) {
        await _insertSeedData();
      }
    },
  );

  /// Insert optional seed data for testing
  Future<void> _insertSeedData() async {
    // Insert a default church
    final churchId = await into(churches).insert(
      ChurchesCompanion.insert(
        name: 'Sample Church',
        address: const Value('123 Main Street'),
        contactEmail: const Value('contact@samplechurch.org'),
        currency: const Value('USD'),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    // Insert a default admin user
    await into(adminUsers).insert(
      AdminUsersCompanion.insert(
        username: 'admin',
        fullName: 'Admin User',
        email: const Value('admin@samplechurch.org'),
        churchId: churchId,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      ),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'church_analytics.db'));
    return NativeDatabase(file);
  });
}
