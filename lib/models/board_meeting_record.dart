import 'package:equatable/equatable.dart';

class BoardMeetingRecord extends Equatable {
  final int? id;
  final int churchId;
  final int? createdByAdminId;
  final DateTime meetingDate;
  final int year;
  final int month; // 1–12
  final int actualAttendance;
  final int expectedAttendance;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BoardMeetingRecord({
    this.id,
    required this.churchId,
    this.createdByAdminId,
    required this.meetingDate,
    required this.year,
    required this.month,
    required this.actualAttendance,
    required this.expectedAttendance,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Attendance rate as a percentage (0.0–100.0)
  double get attendanceRate => expectedAttendance > 0
      ? (actualAttendance / expectedAttendance) * 100.0
      : 0.0;

  /// Absent count
  int get absentCount => (expectedAttendance - actualAttendance).clamp(0, expectedAttendance);

  String get monthName {
    const months = ['', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month.clamp(1, 12)];
  }

  String get displayLabel => '$monthName $year';

  BoardMeetingRecord copyWith({
    int? id, int? churchId, int? createdByAdminId, DateTime? meetingDate,
    int? year, int? month, int? actualAttendance, int? expectedAttendance,
    String? notes, DateTime? createdAt, DateTime? updatedAt,
  }) => BoardMeetingRecord(
    id: id ?? this.id, churchId: churchId ?? this.churchId,
    createdByAdminId: createdByAdminId ?? this.createdByAdminId,
    meetingDate: meetingDate ?? this.meetingDate,
    year: year ?? this.year, month: month ?? this.month,
    actualAttendance: actualAttendance ?? this.actualAttendance,
    expectedAttendance: expectedAttendance ?? this.expectedAttendance,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'churchId': churchId, 'createdByAdminId': createdByAdminId,
    'meetingDate': meetingDate.toIso8601String(),
    'year': year, 'month': month,
    'actualAttendance': actualAttendance, 'expectedAttendance': expectedAttendance,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(), 'updatedAt': updatedAt.toIso8601String(),
  };

  factory BoardMeetingRecord.fromJson(Map<String, dynamic> j) => BoardMeetingRecord(
    id: j['id'] as int?,
    churchId: j['churchId'] as int,
    createdByAdminId: j['createdByAdminId'] as int?,
    meetingDate: DateTime.parse(j['meetingDate'] as String),
    year: j['year'] as int, month: j['month'] as int,
    actualAttendance: j['actualAttendance'] as int,
    expectedAttendance: j['expectedAttendance'] as int,
    notes: j['notes'] as String?,
    createdAt: DateTime.parse(j['createdAt'] as String),
    updatedAt: DateTime.parse(j['updatedAt'] as String),
  );

  String? validate() {
    if (month < 1 || month > 12) return 'Month must be between 1 and 12';
    if (year < 2000 || year > 2100) return 'Invalid year';
    if (actualAttendance < 0) return 'Actual attendance cannot be negative';
    if (expectedAttendance < 0) return 'Expected attendance cannot be negative';
    return null;
  }

  bool get isValid => validate() == null;

  @override
  List<Object?> get props => [id, churchId, createdByAdminId, meetingDate,
    year, month, actualAttendance, expectedAttendance, notes, createdAt, updatedAt];
}
