import 'package:equatable/equatable.dart';

/// Represents weekly attendance and financial data for a church
class WeeklyRecord extends Equatable {
  final int? id;
  final int churchId;
  final int? createdByAdminId;
  final DateTime weekStartDate;

  // Attendance fields
  final int men;
  final int women;
  final int youth;
  final int children;
  final int sundayHomeChurch;

  // Event tracking
  final int? baptisms;
  final int? holyCommunion;

  // Finance fields
  final double tithe;
  final double offerings;
  final double emergencyCollection;
  final double plannedCollection;

  // Phase 1 additions
  final int? sabbathSchoolAttendance;
  final int? visitorsCount;
  final double? missionOffering;
  final double? localChurchBudget;

  final DateTime createdAt;
  final DateTime updatedAt;

  const WeeklyRecord({
    this.id,
    required this.churchId,
    this.createdByAdminId,
    required this.weekStartDate,
    required this.men,
    required this.women,
    required this.youth,
    required this.children,
    required this.sundayHomeChurch,
    this.baptisms,
    this.holyCommunion,
    required this.tithe,
    required this.offerings,
    required this.emergencyCollection,
    required this.plannedCollection,
    this.sabbathSchoolAttendance,
    this.visitorsCount,
    this.missionOffering,
    this.localChurchBudget,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Total service attendance (men + women + youth + children + home church)
  int get totalAttendance => men + women + youth + children + sundayHomeChurch;

  /// Total income including all giving streams
  double get totalIncome =>
      tithe + offerings + emergencyCollection + plannedCollection +
      (missionOffering ?? 0.0) + (localChurchBudget ?? 0.0);

  /// Income excluding mission and local budget (original 4 streams)
  double get coreIncome =>
      tithe + offerings + emergencyCollection + plannedCollection;

  WeeklyRecord copyWith({
    int? id, int? churchId, int? createdByAdminId, DateTime? weekStartDate,
    int? men, int? women, int? youth, int? children, int? sundayHomeChurch,
    int? baptisms, int? holyCommunion,
    double? tithe, double? offerings, double? emergencyCollection,
    double? plannedCollection,
    int? sabbathSchoolAttendance, int? visitorsCount,
    double? missionOffering, double? localChurchBudget,
    DateTime? createdAt, DateTime? updatedAt,
  }) => WeeklyRecord(
    id: id ?? this.id, churchId: churchId ?? this.churchId,
    createdByAdminId: createdByAdminId ?? this.createdByAdminId,
    weekStartDate: weekStartDate ?? this.weekStartDate,
    men: men ?? this.men, women: women ?? this.women,
    youth: youth ?? this.youth, children: children ?? this.children,
    sundayHomeChurch: sundayHomeChurch ?? this.sundayHomeChurch,
    baptisms: baptisms ?? this.baptisms,
    holyCommunion: holyCommunion ?? this.holyCommunion,
    tithe: tithe ?? this.tithe, offerings: offerings ?? this.offerings,
    emergencyCollection: emergencyCollection ?? this.emergencyCollection,
    plannedCollection: plannedCollection ?? this.plannedCollection,
    sabbathSchoolAttendance: sabbathSchoolAttendance ?? this.sabbathSchoolAttendance,
    visitorsCount: visitorsCount ?? this.visitorsCount,
    missionOffering: missionOffering ?? this.missionOffering,
    localChurchBudget: localChurchBudget ?? this.localChurchBudget,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'churchId': churchId, 'createdByAdminId': createdByAdminId,
    'weekStartDate': weekStartDate.toIso8601String(),
    'men': men, 'women': women, 'youth': youth, 'children': children,
    'sundayHomeChurch': sundayHomeChurch,
    'baptisms': baptisms, 'holyCommunion': holyCommunion,
    'tithe': tithe, 'offerings': offerings,
    'emergencyCollection': emergencyCollection,
    'plannedCollection': plannedCollection,
    'sabbathSchoolAttendance': sabbathSchoolAttendance,
    'visitorsCount': visitorsCount,
    'missionOffering': missionOffering,
    'localChurchBudget': localChurchBudget,
    'totalAttendance': totalAttendance, 'totalIncome': totalIncome,
    'createdAt': createdAt.toIso8601String(), 'updatedAt': updatedAt.toIso8601String(),
  };

  factory WeeklyRecord.fromJson(Map<String, dynamic> j) => WeeklyRecord(
    id: j['id'] as int?, churchId: j['churchId'] as int,
    createdByAdminId: j['createdByAdminId'] as int?,
    weekStartDate: DateTime.parse(j['weekStartDate'] as String),
    men: j['men'] as int, women: j['women'] as int,
    youth: j['youth'] as int, children: j['children'] as int,
    sundayHomeChurch: j['sundayHomeChurch'] as int,
    baptisms: j['baptisms'] as int?, holyCommunion: j['holyCommunion'] as int?,
    tithe: (j['tithe'] as num).toDouble(),
    offerings: (j['offerings'] as num).toDouble(),
    emergencyCollection: (j['emergencyCollection'] as num).toDouble(),
    plannedCollection: (j['plannedCollection'] as num).toDouble(),
    sabbathSchoolAttendance: j['sabbathSchoolAttendance'] as int?,
    visitorsCount: j['visitorsCount'] as int?,
    missionOffering: j['missionOffering'] != null
        ? (j['missionOffering'] as num).toDouble() : null,
    localChurchBudget: j['localChurchBudget'] != null
        ? (j['localChurchBudget'] as num).toDouble() : null,
    createdAt: DateTime.parse(j['createdAt'] as String),
    updatedAt: DateTime.parse(j['updatedAt'] as String),
  );

  String? validate() {
    if (churchId <= 0) return 'Invalid church ID';
    if (men < 0) return 'Men count cannot be negative';
    if (women < 0) return 'Women count cannot be negative';
    if (youth < 0) return 'Youth count cannot be negative';
    if (children < 0) return 'Children count cannot be negative';
    if (sundayHomeChurch < 0) return 'Sunday Home Church count cannot be negative';
    if (baptisms != null && baptisms! < 0) return 'Baptisms cannot be negative';
    if (holyCommunion != null && holyCommunion! < 0) return 'Holy Communion count cannot be negative';
    if (tithe < 0) return 'Tithe cannot be negative';
    if (offerings < 0) return 'Offerings cannot be negative';
    if (emergencyCollection < 0) return 'Emergency collection cannot be negative';
    if (plannedCollection < 0) return 'Planned collection cannot be negative';
    if (sabbathSchoolAttendance != null && sabbathSchoolAttendance! < 0)
      return 'Sabbath school attendance cannot be negative';
    if (visitorsCount != null && visitorsCount! < 0)
      return 'Visitors count cannot be negative';
    if (missionOffering != null && missionOffering! < 0)
      return 'Mission offering cannot be negative';
    if (localChurchBudget != null && localChurchBudget! < 0)
      return 'Local church budget cannot be negative';
    final allowedFuture = DateTime.now().add(const Duration(days: 2));
    if (weekStartDate.isAfter(allowedFuture))
      return 'Week start date cannot be more than 2 days in the future';
    return null;
  }

  bool isValid() => validate() == null;

  @override
  List<Object?> get props => [
    id, churchId, createdByAdminId, weekStartDate, men, women, youth,
    children, sundayHomeChurch, baptisms, holyCommunion, tithe, offerings,
    emergencyCollection, plannedCollection, sabbathSchoolAttendance,
    visitorsCount, missionOffering, localChurchBudget, createdAt, updatedAt,
  ];
}
