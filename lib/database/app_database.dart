import 'package:church_analytics/database/connection/connection.dart';
import 'package:drift/drift.dart';

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
  IntColumn get createdByAdminId =>
      integer().references(AdminUsers, #id).nullable()();
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
  AppDatabase() : super(openConnection());

  // Test constructor for in-memory database
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Add createdByAdminId column to WeeklyRecords
        await m.addColumn(weeklyRecords, weeklyRecords.createdByAdminId);
      }
    },
    beforeOpen: (details) async {
      // Enable foreign keys
      await customStatement('PRAGMA foreign_keys = ON');

      // Optional: Add seed data if database is empty
      if (details.wasCreated) {
        await _insertSeedData();
      } else {
        await _ensureDemoData();
      }
    },
  );

  /// Insert optional seed data for testing
  Future<void> _insertSeedData() async {
    // Insert a default Kenyan church
    final now = DateTime.now();
    final churchId = await into(churches).insert(
      ChurchesCompanion.insert(
        name: 'Nairobi Central Church',
        address: const Value('Kenyatta Ave, Nairobi'),
        contactEmail: const Value('info@nairobi-central.org'),
        contactPhone: const Value('+254712345678'),
        currency: const Value('KES'),
        createdAt: now,
        updatedAt: now,
      ),
    );

    // Insert a default admin user
    final adminId = await into(adminUsers).insert(
      AdminUsersCompanion.insert(
        username: 'admin',
        fullName: 'Admin User',
        email: const Value('admin@nairobi-central.org'),
        churchId: churchId,
        createdAt: now,
        lastLoginAt: now,
      ),
    );

    await _insertDemoWeeklyRecords(churchId, adminId);
  }

  Future<void> _ensureDemoData() async {
    final existingChurches = await select(churches).get();
    if (existingChurches.isEmpty) {
      await _insertSeedData();
      return;
    }

    final existingRecords = await select(weeklyRecords).get();
    if (existingRecords.isNotEmpty) return;

    final admins = await select(adminUsers).get();
    final adminId = admins.isNotEmpty ? admins.first.id : null;

    await _insertDemoWeeklyRecords(existingChurches.first.id, adminId);
  }

  Future<void> _insertDemoWeeklyRecords(int churchId, int? adminId) async {
    final now = DateTime.now();
    final demoData = [
      _DemoWeek(52, 68, 34, 28, 20, 54000, 23000, 2000, 6000),
      _DemoWeek(49, 65, 31, 26, 18, 51000, 22000, 1500, 5500),
      _DemoWeek(55, 70, 36, 29, 21, 56500, 24000, 1800, 6200),
      _DemoWeek(58, 73, 38, 30, 22, 59000, 25000, 2000, 6500),
      _DemoWeek(60, 76, 40, 32, 24, 62000, 26000, 2200, 6800),
      _DemoWeek(57, 72, 37, 31, 23, 60500, 25500, 1900, 6600),
      _DemoWeek(62, 79, 41, 33, 25, 64000, 27000, 2300, 7000),
      _DemoWeek(65, 82, 43, 35, 26, 68000, 28000, 2400, 7200),
      _DemoWeek(63, 80, 42, 34, 25, 66000, 27500, 2100, 7100),
      _DemoWeek(67, 85, 45, 36, 27, 70500, 29000, 2500, 7400),
      _DemoWeek(70, 88, 47, 38, 29, 74000, 30500, 2600, 7800),
      _DemoWeek(72, 90, 48, 39, 30, 76000, 31500, 2700, 8000),
    ];

    for (var i = 0; i < demoData.length; i++) {
      final weekStartDate = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 7 * (demoData.length - 1 - i)));
      final data = demoData[i];

      await into(weeklyRecords).insert(
        WeeklyRecordsCompanion(
          churchId: Value(churchId),
          createdByAdminId: adminId == null
              ? const Value.absent()
              : Value(adminId),
          weekStartDate: Value(weekStartDate),
          men: Value(data.men),
          women: Value(data.women),
          youth: Value(data.youth),
          children: Value(data.children),
          sundayHomeChurch: Value(data.sundayHomeChurch),
          tithe: Value(data.tithe),
          offerings: Value(data.offerings),
          emergencyCollection: Value(data.emergencyCollection),
          plannedCollection: Value(data.plannedCollection),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    }
  }
}

class _DemoWeek {
  final int men;
  final int women;
  final int youth;
  final int children;
  final int sundayHomeChurch;
  final double tithe;
  final double offerings;
  final double emergencyCollection;
  final double plannedCollection;

  const _DemoWeek(
    this.men,
    this.women,
    this.youth,
    this.children,
    this.sundayHomeChurch,
    this.tithe,
    this.offerings,
    this.emergencyCollection,
    this.plannedCollection,
  );
}
