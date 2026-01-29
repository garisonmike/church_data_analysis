import 'package:equatable/equatable.dart';

/// Represents the history of exports (graphs/reports) for tracking purposes
class ExportHistory extends Equatable {
  final int? id;
  final int churchId;
  final String exportType; // 'graph', 'pdf_report', 'csv'
  final String exportName;
  final String? filePath;
  final String? graphType; // e.g., 'attendance_trend', 'income_pie', etc.
  final DateTime exportedAt;
  final int recordCount; // Number of records included in export

  const ExportHistory({
    this.id,
    required this.churchId,
    required this.exportType,
    required this.exportName,
    this.filePath,
    this.graphType,
    required this.exportedAt,
    this.recordCount = 0,
  });

  /// Creates a copy of this ExportHistory with updated fields
  ExportHistory copyWith({
    int? id,
    int? churchId,
    String? exportType,
    String? exportName,
    String? filePath,
    String? graphType,
    DateTime? exportedAt,
    int? recordCount,
  }) {
    return ExportHistory(
      id: id ?? this.id,
      churchId: churchId ?? this.churchId,
      exportType: exportType ?? this.exportType,
      exportName: exportName ?? this.exportName,
      filePath: filePath ?? this.filePath,
      graphType: graphType ?? this.graphType,
      exportedAt: exportedAt ?? this.exportedAt,
      recordCount: recordCount ?? this.recordCount,
    );
  }

  /// Converts this ExportHistory to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'churchId': churchId,
      'exportType': exportType,
      'exportName': exportName,
      'filePath': filePath,
      'graphType': graphType,
      'exportedAt': exportedAt.toIso8601String(),
      'recordCount': recordCount,
    };
  }

  /// Creates an ExportHistory from a JSON map
  factory ExportHistory.fromJson(Map<String, dynamic> json) {
    return ExportHistory(
      id: json['id'] as int?,
      churchId: json['churchId'] as int,
      exportType: json['exportType'] as String,
      exportName: json['exportName'] as String,
      filePath: json['filePath'] as String?,
      graphType: json['graphType'] as String?,
      exportedAt: DateTime.parse(json['exportedAt'] as String),
      recordCount: json['recordCount'] as int? ?? 0,
    );
  }

  /// Validates the export history model
  String? validate() {
    if (churchId <= 0) {
      return 'Invalid church ID';
    }
    if (exportType.trim().isEmpty) {
      return 'Export type cannot be empty';
    }
    final validTypes = ['graph', 'pdf_report', 'csv'];
    if (!validTypes.contains(exportType)) {
      return 'Export type must be one of: ${validTypes.join(", ")}';
    }
    if (exportName.trim().isEmpty) {
      return 'Export name cannot be empty';
    }
    if (exportName.length > 200) {
      return 'Export name cannot exceed 200 characters';
    }
    if (recordCount < 0) {
      return 'Record count cannot be negative';
    }
    return null;
  }

  /// Checks if this export history model is valid
  bool isValid() => validate() == null;

  @override
  List<Object?> get props => [
    id,
    churchId,
    exportType,
    exportName,
    filePath,
    graphType,
    exportedAt,
    recordCount,
  ];
}
