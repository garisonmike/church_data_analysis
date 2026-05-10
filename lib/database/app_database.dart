import 'package:church_analytics/database/connection/connection.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_database.g.dart';

const bool _kDemoMode = false;

// Single shared instance — prevents Drift's "multiple instances" warning
// when the provider is re-read across widget rebuilds or test containers.
AppDatabase? _appDatabaseInstance;

final databaseProvider = Provider<AppDatabase>((ref) {
  _appDatabaseInstance ??= AppDatabase();
  final database = _appDatabaseInstance!;
  ref.onDispose(() {
    database.close();
    _appDatabaseInstance = null;
  });
  return database;
});

// ─────────────────────────────────────────────────────────────────────────────
// EXISTING TABLES
// ─────────────────────────────────────────────────────────────────────────────

class Churches extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get address => text().nullable()();
  TextColumn get contactEmail => text().nullable()();
  TextColumn get contactPhone => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('USD'))();
  // Phase 1 additions
  TextColumn get website => text().nullable()();
  IntColumn get boardMemberCount => integer().withDefault(const Constant(0))();
  IntColumn get totalMembership => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

class AdminUsers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().withLength(min: 3, max: 50)();
  TextColumn get fullName => text().withLength(min: 1, max: 100)();
  TextColumn get email => text().nullable()();
  IntColumn get churchId => integer().references(Churches, #id)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastLoginAt => dateTime()();
  TextColumn get pinHash => text().nullable()();
}

class WeeklyRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get churchId => integer().references(Churches, #id)();
  IntColumn get createdByAdminId =>
      integer().references(AdminUsers, #id).nullable()();
  DateTimeColumn get weekStartDate => dateTime()();

  // Attendance
  IntColumn get men => integer().withDefault(const Constant(0))();
  IntColumn get women => integer().withDefault(const Constant(0))();
  IntColumn get youth => integer().withDefault(const Constant(0))();
  IntColumn get children => integer().withDefault(const Constant(0))();
  IntColumn get sundayHomeChurch => integer().withDefault(const Constant(0))();

  // Event tracking
  IntColumn get baptisms => integer().nullable()();
  IntColumn get holyCommunion => integer().nullable()();

  // Finance
  RealColumn get tithe => real().withDefault(const Constant(0.0))();
  RealColumn get offerings => real().withDefault(const Constant(0.0))();
  RealColumn get emergencyCollection =>
      real().withDefault(const Constant(0.0))();
  RealColumn get plannedCollection => real().withDefault(const Constant(0.0))();

  // Phase 1 additions
  IntColumn get sabbathSchoolAttendance => integer().nullable()();
  IntColumn get visitorsCount => integer().nullable()();
  RealColumn get missionOffering => real().nullable()();
  RealColumn get localChurchBudget => real().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column>>? get uniqueKeys => [
    {churchId, weekStartDate},
  ];
}

class DerivedMetricsList extends Table {
  @override
  String get tableName => 'derived_metrics';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get churchId => integer().references(Churches, #id)();
  DateTimeColumn get periodStart => dateTime()();
  DateTimeColumn get periodEnd => dateTime()();
  RealColumn get averageAttendance => real()();
  RealColumn get averageIncome => real()();
  RealColumn get growthPercentage => real()();
  RealColumn get attendanceToIncomeRatio => real()();
  RealColumn get perCapitaGiving => real()();
  RealColumn get menPercentage => real()();
  RealColumn get womenPercentage => real()();
  RealColumn get youthPercentage => real()();
  RealColumn get childrenPercentage => real()();
  RealColumn get tithePercentage => real()();
  RealColumn get offeringsPercentage => real()();
  DateTimeColumn get calculatedAt => dateTime()();
}

class ExportHistoryList extends Table {
  @override
  String get tableName => 'export_history';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get churchId => integer().references(Churches, #id)();
  TextColumn get exportType => text()();
  TextColumn get exportName => text().withLength(min: 1, max: 200)();
  TextColumn get filePath => text().nullable()();
  TextColumn get graphType => text().nullable()();
  DateTimeColumn get exportedAt => dateTime()();
  IntColumn get recordCount => integer().withDefault(const Constant(0))();
}

// ─────────────────────────────────────────────────────────────────────────────
// NEW TABLES — Phase 1
// ─────────────────────────────────────────────────────────────────────────────

/// Home Churches — sub-congregations / ministry groups under a church.
/// All 23 KCC home churches are rows here, managed by the clerk.
class HomeChurches extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get churchId => integer().references(Churches, #id)();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  /// geographical | ministry | special
  TextColumn get category =>
      text().withDefault(const Constant('geographical'))();
  /// Expected membership registered at this home church
  IntColumn get expectedMembership => integer().withDefault(const Constant(0))();
  /// Expected count to appear at KCC (main church) events
  IntColumn get expectedAtKcc => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// Board Meeting records — one row per monthly board meeting.
class BoardMeetingRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get churchId => integer().references(Churches, #id)();
  IntColumn get createdByAdminId =>
      integer().references(AdminUsers, #id).nullable()();
  DateTimeColumn get meetingDate => dateTime()();
  IntColumn get year => integer()();
  IntColumn get month => integer()(); // 1–12
  IntColumn get actualAttendance => integer().withDefault(const Constant(0))();
  /// Snapshot of Churches.boardMemberCount at time of recording
  IntColumn get expectedAttendance =>
      integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column>>? get uniqueKeys => [
    {churchId, year, month},
  ];
}

/// Holy Communion event header — one row per quarterly event.
class HolyCommunionEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get churchId => integer().references(Churches, #id)();
  IntColumn get createdByAdminId =>
      integer().references(AdminUsers, #id).nullable()();
  DateTimeColumn get eventDate => dateTime()();
  IntColumn get year => integer()();
  IntColumn get quarter => integer()(); // 1–4
  /// Snapshot of the KCC-wide expected total at time of recording
  IntColumn get totalExpectedAtKcc =>
      integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column>>? get uniqueKeys => [
    {churchId, year, quarter},
  ];
}

/// Holy Communion attendance per home church — child rows of HolyCommunionEvents.
class HolyCommunionAttendance extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get eventId =>
      integer().references(HolyCommunionEvents, #id)();
  IntColumn get homeChurchId => integer().references(HomeChurches, #id)();
  IntColumn get actualAttendance => integer().withDefault(const Constant(0))();
  /// Snapshot of HomeChurch.expectedMembership at recording time
  IntColumn get expectedAtHc => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column>>? get uniqueKeys => [
    {eventId, homeChurchId},
  ];
}

/// Business Meeting event header — one row per quarterly meeting instance.
class BusinessMeetingEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get churchId => integer().references(Churches, #id)();
  IntColumn get createdByAdminId =>
      integer().references(AdminUsers, #id).nullable()();
  DateTimeColumn get eventDate => dateTime()();
  IntColumn get year => integer()();
  IntColumn get quarter => integer()(); // 1–4
  IntColumn get meetingNumber => integer().withDefault(const Constant(1))(); // 1–3
  IntColumn get totalExpectedAtKcc =>
      integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column>>? get uniqueKeys => [
    {churchId, year, quarter, meetingNumber},
  ];
}

/// Business Meeting attendance per home church.
class BusinessMeetingAttendance extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get eventId =>
      integer().references(BusinessMeetingEvents, #id)();
  IntColumn get homeChurchId => integer().references(HomeChurches, #id)();
  IntColumn get actualAttendance => integer().withDefault(const Constant(0))();
  IntColumn get expectedAtHc => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column>>? get uniqueKeys => [
    {eventId, homeChurchId},
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// DATABASE CLASS
// ─────────────────────────────────────────────────────────────────────────────

@DriftDatabase(
  tables: [
    Churches,
    AdminUsers,
    WeeklyRecords,
    DerivedMetricsList,
    ExportHistoryList,
    // New Phase 1 tables
    HomeChurches,
    BoardMeetingRecords,
    HolyCommunionEvents,
    HolyCommunionAttendance,
    BusinessMeetingEvents,
    BusinessMeetingAttendance,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.addColumn(weeklyRecords, weeklyRecords.createdByAdminId);
      }
      if (from < 3) {
        await m.addColumn(weeklyRecords, weeklyRecords.baptisms);
      }
      if (from < 4) {
        await m.addColumn(weeklyRecords, weeklyRecords.holyCommunion);
      }
      if (from < 5) {
        await m.addColumn(adminUsers, adminUsers.pinHash);
      }
      if (from < 6) {
        // Extend Churches table
        await m.addColumn(churches, churches.website);
        await m.addColumn(churches, churches.boardMemberCount);
        await m.addColumn(churches, churches.totalMembership);
        // Extend WeeklyRecords table
        await m.addColumn(weeklyRecords, weeklyRecords.sabbathSchoolAttendance);
        await m.addColumn(weeklyRecords, weeklyRecords.visitorsCount);
        await m.addColumn(weeklyRecords, weeklyRecords.missionOffering);
        await m.addColumn(weeklyRecords, weeklyRecords.localChurchBudget);
        // Create all new tables
        await m.createTable(homeChurches);
        await m.createTable(boardMeetingRecords);
        await m.createTable(holyCommunionEvents);
        await m.createTable(holyCommunionAttendance);
        await m.createTable(businessMeetingEvents);
        await m.createTable(businessMeetingAttendance);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      if (_kDemoMode && details.wasCreated) {
        await _insertSeedData();
      }
    },
  );

  Future<void> _insertSeedData() async {
    if (!_kDemoMode) return;
    final now = DateTime.now();
    final churchId = await into(churches).insert(
      ChurchesCompanion.insert(
        name: 'Kisii Central SDA Church',
        address: const Value('P.O. Box 2076, Kisii'),
        contactEmail: const Value('info@kisiicentralsdachurch.org'),
        contactPhone: const Value('+254700000000'),
        currency: const Value('KES'),
        website: const Value('kisiicentralsdachurch.org'),
        boardMemberCount: const Value(56),
        totalMembership: const Value(1650),
        createdAt: now,
        updatedAt: now,
      ),
    );
    final adminId = await into(adminUsers).insert(
      AdminUsersCompanion.insert(
        username: 'clerk',
        fullName: 'Church Clerk',
        churchId: churchId,
        createdAt: now,
        lastLoginAt: now,
      ),
    );
    await _insertDemoWeeklyRecords(churchId, adminId);
  }

  Future<void> _insertDemoWeeklyRecords(int churchId, int? adminId) async {
    final now = DateTime.now();
    final demoData = [
      _DemoWeek(52, 68, 34, 28, 20, 54000, 23000, 2000, 6000, baptisms: 3, holyCommunion: 120),
      _DemoWeek(49, 65, 31, 26, 18, 51000, 22000, 1500, 5500, baptisms: 2, holyCommunion: 108),
      _DemoWeek(55, 70, 36, 29, 21, 56500, 24000, 1800, 6200, baptisms: 4, holyCommunion: 130),
      _DemoWeek(58, 73, 38, 30, 22, 59000, 25000, 2000, 6500, baptisms: 1, holyCommunion: 141),
      _DemoWeek(60, 76, 40, 32, 24, 62000, 26000, 2200, 6800, baptisms: 5, holyCommunion: 152),
      _DemoWeek(57, 72, 37, 31, 23, 60500, 25500, 1900, 6600, baptisms: 2, holyCommunion: 143),
      _DemoWeek(62, 79, 41, 33, 25, 64000, 27000, 2300, 7000, baptisms: 6, holyCommunion: 160),
      _DemoWeek(65, 82, 43, 35, 26, 68000, 28000, 2400, 7200, baptisms: 3, holyCommunion: 169),
      _DemoWeek(63, 80, 42, 34, 25, 66000, 27500, 2100, 7100, baptisms: 4, holyCommunion: 164),
      _DemoWeek(67, 85, 45, 36, 27, 70500, 29000, 2500, 7400, baptisms: 7, holyCommunion: 176),
      _DemoWeek(70, 88, 47, 38, 29, 74000, 30500, 2600, 7800, baptisms: 5, holyCommunion: 185),
      _DemoWeek(72, 90, 48, 39, 30, 76000, 31500, 2700, 8000, baptisms: 8, holyCommunion: 190),
    ];
    for (var i = 0; i < demoData.length; i++) {
      final weekStartDate = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: 7 * (demoData.length - 1 - i)));
      final data = demoData[i];
      await into(weeklyRecords).insert(
        WeeklyRecordsCompanion(
          churchId: Value(churchId),
          createdByAdminId:
              adminId == null ? const Value.absent() : Value(adminId),
          weekStartDate: Value(weekStartDate),
          men: Value(data.men),
          women: Value(data.women),
          youth: Value(data.youth),
          children: Value(data.children),
          sundayHomeChurch: Value(data.sundayHomeChurch),
          baptisms: data.baptisms != null ? Value(data.baptisms) : const Value.absent(),
          holyCommunion: data.holyCommunion != null ? Value(data.holyCommunion) : const Value.absent(),
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
  final int men, women, youth, children, sundayHomeChurch;
  final double tithe, offerings, emergencyCollection, plannedCollection;
  final int? baptisms, holyCommunion;
  const _DemoWeek(this.men, this.women, this.youth, this.children,
      this.sundayHomeChurch, this.tithe, this.offerings,
      this.emergencyCollection, this.plannedCollection,
      {this.baptisms, this.holyCommunion});
}
