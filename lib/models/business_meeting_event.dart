import 'package:equatable/equatable.dart';

class BusinessMeetingAttendanceRow extends Equatable {
  final int? id;
  final int eventId;
  final int homeChurchId;
  final String homeChurchName;
  final int actualAttendance;
  final int expectedAtHc;

  const BusinessMeetingAttendanceRow({
    this.id,
    required this.eventId,
    required this.homeChurchId,
    required this.homeChurchName,
    required this.actualAttendance,
    required this.expectedAtHc,
  });

  double get attendanceRate =>
      expectedAtHc > 0 ? (actualAttendance / expectedAtHc) * 100.0 : 0.0;

  BusinessMeetingAttendanceRow copyWith({
    int? id, int? eventId, int? homeChurchId, String? homeChurchName,
    int? actualAttendance, int? expectedAtHc,
  }) => BusinessMeetingAttendanceRow(
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

  factory BusinessMeetingAttendanceRow.fromJson(Map<String, dynamic> j) =>
      BusinessMeetingAttendanceRow(
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

class BusinessMeetingEvent extends Equatable {
  final int? id;
  final int churchId;
  final int? createdByAdminId;
  final DateTime eventDate;
  final int year;
  final int quarter; // 1–4
  final int meetingNumber; // 1–3 (up to 3 per quarter)
  final int totalExpectedAtKcc;
  final String? notes;
  final List<BusinessMeetingAttendanceRow> attendance;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BusinessMeetingEvent({
    this.id,
    required this.churchId,
    this.createdByAdminId,
    required this.eventDate,
    required this.year,
    required this.quarter,
    this.meetingNumber = 1,
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

  String get meetingLabel {
    final suffix = meetingNumber == 1 ? 'st' : meetingNumber == 2 ? 'nd' : 'rd';
    return '${meetingNumber}$suffix Business Meeting — Q$quarter $year';
  }

  BusinessMeetingEvent copyWith({
    int? id, int? churchId, int? createdByAdminId, DateTime? eventDate,
    int? year, int? quarter, int? meetingNumber, int? totalExpectedAtKcc,
    String? notes, List<BusinessMeetingAttendanceRow>? attendance,
    DateTime? createdAt, DateTime? updatedAt,
  }) => BusinessMeetingEvent(
    id: id ?? this.id, churchId: churchId ?? this.churchId,
    createdByAdminId: createdByAdminId ?? this.createdByAdminId,
    eventDate: eventDate ?? this.eventDate,
    year: year ?? this.year, quarter: quarter ?? this.quarter,
    meetingNumber: meetingNumber ?? this.meetingNumber,
    totalExpectedAtKcc: totalExpectedAtKcc ?? this.totalExpectedAtKcc,
    notes: notes ?? this.notes,
    attendance: attendance ?? this.attendance,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'churchId': churchId, 'createdByAdminId': createdByAdminId,
    'eventDate': eventDate.toIso8601String(),
    'year': year, 'quarter': quarter, 'meetingNumber': meetingNumber,
    'totalExpectedAtKcc': totalExpectedAtKcc, 'notes': notes,
    'attendance': attendance.map((r) => r.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(), 'updatedAt': updatedAt.toIso8601String(),
  };

  factory BusinessMeetingEvent.fromJson(Map<String, dynamic> j) =>
      BusinessMeetingEvent(
        id: j['id'] as int?, churchId: j['churchId'] as int,
        createdByAdminId: j['createdByAdminId'] as int?,
        eventDate: DateTime.parse(j['eventDate'] as String),
        year: j['year'] as int, quarter: j['quarter'] as int,
        meetingNumber: j['meetingNumber'] as int? ?? 1,
        totalExpectedAtKcc: j['totalExpectedAtKcc'] as int,
        notes: j['notes'] as String?,
        attendance: (j['attendance'] as List<dynamic>? ?? [])
            .map((e) => BusinessMeetingAttendanceRow.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(j['createdAt'] as String),
        updatedAt: DateTime.parse(j['updatedAt'] as String),
      );

  String? validate() {
    if (quarter < 1 || quarter > 4) return 'Quarter must be between 1 and 4';
    if (meetingNumber < 1 || meetingNumber > 3)
      return 'Meeting number must be between 1 and 3';
    if (year < 2000 || year > 2100) return 'Invalid year';
    if (totalExpectedAtKcc < 0) return 'Expected attendance cannot be negative';
    return null;
  }

  bool get isValid => validate() == null;

  @override
  List<Object?> get props => [id, churchId, createdByAdminId, eventDate,
    year, quarter, meetingNumber, totalExpectedAtKcc, notes, attendance,
    createdAt, updatedAt];
}
