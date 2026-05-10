import 'package:equatable/equatable.dart';

/// A single home-church attendance row within a Holy Communion event.
class HolyCommunionAttendanceRow extends Equatable {
  final int? id;
  final int eventId;
  final int homeChurchId;
  final String homeChurchName; // denormalised for display
  final int actualAttendance;
  final int expectedAtHc;

  const HolyCommunionAttendanceRow({
    this.id,
    required this.eventId,
    required this.homeChurchId,
    required this.homeChurchName,
    required this.actualAttendance,
    required this.expectedAtHc,
  });

  double get attendanceRate =>
      expectedAtHc > 0 ? (actualAttendance / expectedAtHc) * 100.0 : 0.0;

  HolyCommunionAttendanceRow copyWith({
    int? id, int? eventId, int? homeChurchId, String? homeChurchName,
    int? actualAttendance, int? expectedAtHc,
  }) => HolyCommunionAttendanceRow(
    id: id ?? this.id, eventId: eventId ?? this.eventId,
    homeChurchId: homeChurchId ?? this.homeChurchId,
    homeChurchName: homeChurchName ?? this.homeChurchName,
    actualAttendance: actualAttendance ?? this.actualAttendance,
    expectedAtHc: expectedAtHc ?? this.expectedAtHc,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'eventId': eventId, 'homeChurchId': homeChurchId,
    'homeChurchName': homeChurchName,
    'actualAttendance': actualAttendance, 'expectedAtHc': expectedAtHc,
  };

  factory HolyCommunionAttendanceRow.fromJson(Map<String, dynamic> j) =>
      HolyCommunionAttendanceRow(
        id: j['id'] as int?, eventId: j['eventId'] as int,
        homeChurchId: j['homeChurchId'] as int,
        homeChurchName: j['homeChurchName'] as String? ?? '',
        actualAttendance: j['actualAttendance'] as int,
        expectedAtHc: j['expectedAtHc'] as int,
      );

  @override
  List<Object?> get props =>
      [id, eventId, homeChurchId, homeChurchName, actualAttendance, expectedAtHc];
}

/// Holy Communion event header + all per-home-church attendance rows.
class HolyCommunionEvent extends Equatable {
  final int? id;
  final int churchId;
  final int? createdByAdminId;
  final DateTime eventDate;
  final int year;
  final int quarter; // 1–4
  final int totalExpectedAtKcc;
  final String? notes;
  final List<HolyCommunionAttendanceRow> attendance;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HolyCommunionEvent({
    this.id,
    required this.churchId,
    this.createdByAdminId,
    required this.eventDate,
    required this.year,
    required this.quarter,
    required this.totalExpectedAtKcc,
    this.notes,
    this.attendance = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  int get totalActual =>
      attendance.fold(0, (sum, r) => sum + r.actualAttendance);

  double get overallRate =>
      totalExpectedAtKcc > 0 ? (totalActual / totalExpectedAtKcc) * 100.0 : 0.0;

  String get quarterLabel => 'Q$quarter $year';

  HolyCommunionEvent copyWith({
    int? id, int? churchId, int? createdByAdminId, DateTime? eventDate,
    int? year, int? quarter, int? totalExpectedAtKcc, String? notes,
    List<HolyCommunionAttendanceRow>? attendance,
    DateTime? createdAt, DateTime? updatedAt,
  }) => HolyCommunionEvent(
    id: id ?? this.id, churchId: churchId ?? this.churchId,
    createdByAdminId: createdByAdminId ?? this.createdByAdminId,
    eventDate: eventDate ?? this.eventDate,
    year: year ?? this.year, quarter: quarter ?? this.quarter,
    totalExpectedAtKcc: totalExpectedAtKcc ?? this.totalExpectedAtKcc,
    notes: notes ?? this.notes,
    attendance: attendance ?? this.attendance,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'churchId': churchId, 'createdByAdminId': createdByAdminId,
    'eventDate': eventDate.toIso8601String(),
    'year': year, 'quarter': quarter,
    'totalExpectedAtKcc': totalExpectedAtKcc, 'notes': notes,
    'attendance': attendance.map((r) => r.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(), 'updatedAt': updatedAt.toIso8601String(),
  };

  factory HolyCommunionEvent.fromJson(Map<String, dynamic> j) =>
      HolyCommunionEvent(
        id: j['id'] as int?, churchId: j['churchId'] as int,
        createdByAdminId: j['createdByAdminId'] as int?,
        eventDate: DateTime.parse(j['eventDate'] as String),
        year: j['year'] as int, quarter: j['quarter'] as int,
        totalExpectedAtKcc: j['totalExpectedAtKcc'] as int,
        notes: j['notes'] as String?,
        attendance: (j['attendance'] as List<dynamic>? ?? [])
            .map((e) => HolyCommunionAttendanceRow.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(j['createdAt'] as String),
        updatedAt: DateTime.parse(j['updatedAt'] as String),
      );

  String? validate() {
    if (quarter < 1 || quarter > 4) return 'Quarter must be between 1 and 4';
    if (year < 2000 || year > 2100) return 'Invalid year';
    if (totalExpectedAtKcc < 0) return 'Expected attendance cannot be negative';
    return null;
  }

  bool get isValid => validate() == null;

  @override
  List<Object?> get props => [id, churchId, createdByAdminId, eventDate,
    year, quarter, totalExpectedAtKcc, notes, attendance, createdAt, updatedAt];
}
