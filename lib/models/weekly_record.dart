import 'package:equatable/equatable.dart';

/// Represents weekly attendance and financial data for a church
class WeeklyRecord extends Equatable {
  final int? id;
  final int churchId;
  final DateTime weekStartDate;

  // Attendance fields
  final int men;
  final int women;
  final int youth;
  final int children;
  final int sundayHomeChurch;

  // Finance fields
  final double tithe;
  final double offerings;
  final double emergencyCollection;
  final double plannedCollection;

  final DateTime createdAt;
  final DateTime updatedAt;

  const WeeklyRecord({
    this.id,
    required this.churchId,
    required this.weekStartDate,
    required this.men,
    required this.women,
    required this.youth,
    required this.children,
    required this.sundayHomeChurch,
    required this.tithe,
    required this.offerings,
    required this.emergencyCollection,
    required this.plannedCollection,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculates total attendance
  int get totalAttendance => men + women + youth + children + sundayHomeChurch;

  /// Calculates total income
  double get totalIncome =>
      tithe + offerings + emergencyCollection + plannedCollection;

  /// Creates a copy of this WeeklyRecord with updated fields
  WeeklyRecord copyWith({
    int? id,
    int? churchId,
    DateTime? weekStartDate,
    int? men,
    int? women,
    int? youth,
    int? children,
    int? sundayHomeChurch,
    double? tithe,
    double? offerings,
    double? emergencyCollection,
    double? plannedCollection,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeeklyRecord(
      id: id ?? this.id,
      churchId: churchId ?? this.churchId,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      men: men ?? this.men,
      women: women ?? this.women,
      youth: youth ?? this.youth,
      children: children ?? this.children,
      sundayHomeChurch: sundayHomeChurch ?? this.sundayHomeChurch,
      tithe: tithe ?? this.tithe,
      offerings: offerings ?? this.offerings,
      emergencyCollection: emergencyCollection ?? this.emergencyCollection,
      plannedCollection: plannedCollection ?? this.plannedCollection,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts this WeeklyRecord to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'churchId': churchId,
      'weekStartDate': weekStartDate.toIso8601String(),
      'men': men,
      'women': women,
      'youth': youth,
      'children': children,
      'sundayHomeChurch': sundayHomeChurch,
      'tithe': tithe,
      'offerings': offerings,
      'emergencyCollection': emergencyCollection,
      'plannedCollection': plannedCollection,
      'totalAttendance': totalAttendance,
      'totalIncome': totalIncome,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates a WeeklyRecord from a JSON map
  factory WeeklyRecord.fromJson(Map<String, dynamic> json) {
    return WeeklyRecord(
      id: json['id'] as int?,
      churchId: json['churchId'] as int,
      weekStartDate: DateTime.parse(json['weekStartDate'] as String),
      men: json['men'] as int,
      women: json['women'] as int,
      youth: json['youth'] as int,
      children: json['children'] as int,
      sundayHomeChurch: json['sundayHomeChurch'] as int,
      tithe: (json['tithe'] as num).toDouble(),
      offerings: (json['offerings'] as num).toDouble(),
      emergencyCollection: (json['emergencyCollection'] as num).toDouble(),
      plannedCollection: (json['plannedCollection'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Validates the weekly record model
  String? validate() {
    if (churchId <= 0) {
      return 'Invalid church ID';
    }

    // Validate attendance (all must be >= 0)
    if (men < 0) return 'Men count cannot be negative';
    if (women < 0) return 'Women count cannot be negative';
    if (youth < 0) return 'Youth count cannot be negative';
    if (children < 0) return 'Children count cannot be negative';
    if (sundayHomeChurch < 0) {
      return 'Sunday Home Church count cannot be negative';
    }

    // Validate finance (all must be >= 0)
    if (tithe < 0) return 'Tithe cannot be negative';
    if (offerings < 0) return 'Offerings cannot be negative';
    if (emergencyCollection < 0) {
      return 'Emergency collection cannot be negative';
    }
    if (plannedCollection < 0) return 'Planned collection cannot be negative';

    // Week start date validation
    if (weekStartDate.isAfter(DateTime.now())) {
      return 'Week start date cannot be in the future';
    }

    return null;
  }

  /// Checks if this weekly record model is valid
  bool isValid() => validate() == null;

  @override
  List<Object?> get props => [
    id,
    churchId,
    weekStartDate,
    men,
    women,
    youth,
    children,
    sundayHomeChurch,
    tithe,
    offerings,
    emergencyCollection,
    plannedCollection,
    createdAt,
    updatedAt,
  ];
}
