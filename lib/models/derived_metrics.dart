import 'package:equatable/equatable.dart';

/// Represents cached derived analytics metrics for performance optimization
class DerivedMetrics extends Equatable {
  final int? id;
  final int churchId;
  final DateTime periodStart;
  final DateTime periodEnd;

  // Cached metrics
  final double averageAttendance;
  final double averageIncome;
  final double growthPercentage;
  final double attendanceToIncomeRatio;
  final double perCapitaGiving;

  // Category percentages
  final double menPercentage;
  final double womenPercentage;
  final double youthPercentage;
  final double childrenPercentage;

  final double tithePercentage;
  final double offeringsPercentage;

  final DateTime calculatedAt;

  const DerivedMetrics({
    this.id,
    required this.churchId,
    required this.periodStart,
    required this.periodEnd,
    required this.averageAttendance,
    required this.averageIncome,
    required this.growthPercentage,
    required this.attendanceToIncomeRatio,
    required this.perCapitaGiving,
    required this.menPercentage,
    required this.womenPercentage,
    required this.youthPercentage,
    required this.childrenPercentage,
    required this.tithePercentage,
    required this.offeringsPercentage,
    required this.calculatedAt,
  });

  /// Creates a copy of this DerivedMetrics with updated fields
  DerivedMetrics copyWith({
    int? id,
    int? churchId,
    DateTime? periodStart,
    DateTime? periodEnd,
    double? averageAttendance,
    double? averageIncome,
    double? growthPercentage,
    double? attendanceToIncomeRatio,
    double? perCapitaGiving,
    double? menPercentage,
    double? womenPercentage,
    double? youthPercentage,
    double? childrenPercentage,
    double? tithePercentage,
    double? offeringsPercentage,
    DateTime? calculatedAt,
  }) {
    return DerivedMetrics(
      id: id ?? this.id,
      churchId: churchId ?? this.churchId,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      averageAttendance: averageAttendance ?? this.averageAttendance,
      averageIncome: averageIncome ?? this.averageIncome,
      growthPercentage: growthPercentage ?? this.growthPercentage,
      attendanceToIncomeRatio:
          attendanceToIncomeRatio ?? this.attendanceToIncomeRatio,
      perCapitaGiving: perCapitaGiving ?? this.perCapitaGiving,
      menPercentage: menPercentage ?? this.menPercentage,
      womenPercentage: womenPercentage ?? this.womenPercentage,
      youthPercentage: youthPercentage ?? this.youthPercentage,
      childrenPercentage: childrenPercentage ?? this.childrenPercentage,
      tithePercentage: tithePercentage ?? this.tithePercentage,
      offeringsPercentage: offeringsPercentage ?? this.offeringsPercentage,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  /// Converts this DerivedMetrics to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'churchId': churchId,
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'averageAttendance': averageAttendance,
      'averageIncome': averageIncome,
      'growthPercentage': growthPercentage,
      'attendanceToIncomeRatio': attendanceToIncomeRatio,
      'perCapitaGiving': perCapitaGiving,
      'menPercentage': menPercentage,
      'womenPercentage': womenPercentage,
      'youthPercentage': youthPercentage,
      'childrenPercentage': childrenPercentage,
      'tithePercentage': tithePercentage,
      'offeringsPercentage': offeringsPercentage,
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }

  /// Creates a DerivedMetrics from a JSON map
  factory DerivedMetrics.fromJson(Map<String, dynamic> json) {
    return DerivedMetrics(
      id: json['id'] as int?,
      churchId: json['churchId'] as int,
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      averageAttendance: (json['averageAttendance'] as num).toDouble(),
      averageIncome: (json['averageIncome'] as num).toDouble(),
      growthPercentage: (json['growthPercentage'] as num).toDouble(),
      attendanceToIncomeRatio: (json['attendanceToIncomeRatio'] as num)
          .toDouble(),
      perCapitaGiving: (json['perCapitaGiving'] as num).toDouble(),
      menPercentage: (json['menPercentage'] as num).toDouble(),
      womenPercentage: (json['womenPercentage'] as num).toDouble(),
      youthPercentage: (json['youthPercentage'] as num).toDouble(),
      childrenPercentage: (json['childrenPercentage'] as num).toDouble(),
      tithePercentage: (json['tithePercentage'] as num).toDouble(),
      offeringsPercentage: (json['offeringsPercentage'] as num).toDouble(),
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
    );
  }

  /// Validates the derived metrics model
  String? validate() {
    if (churchId <= 0) {
      return 'Invalid church ID';
    }
    if (periodEnd.isBefore(periodStart)) {
      return 'Period end must be after period start';
    }
    if (averageAttendance < 0) {
      return 'Average attendance cannot be negative';
    }
    if (averageIncome < 0) {
      return 'Average income cannot be negative';
    }
    return null;
  }

  /// Checks if this derived metrics model is valid
  bool isValid() => validate() == null;

  @override
  List<Object?> get props => [
    id,
    churchId,
    periodStart,
    periodEnd,
    averageAttendance,
    averageIncome,
    growthPercentage,
    attendanceToIncomeRatio,
    perCapitaGiving,
    menPercentage,
    womenPercentage,
    youthPercentage,
    childrenPercentage,
    tithePercentage,
    offeringsPercentage,
    calculatedAt,
  ];
}
