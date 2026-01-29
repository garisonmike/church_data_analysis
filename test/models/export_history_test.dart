import 'package:church_analytics/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExportHistory Model Tests', () {
    final now = DateTime.now();

    ExportHistory createValidExportHistory({
      int? id,
      int churchId = 1,
      String exportType = 'graph',
      String exportName = 'Attendance Chart Export',
      String? filePath,
      String? graphType,
      int recordCount = 10,
    }) {
      return ExportHistory(
        id: id,
        churchId: churchId,
        exportType: exportType,
        exportName: exportName,
        filePath: filePath,
        graphType: graphType,
        exportedAt: now,
        recordCount: recordCount,
      );
    }

    test('ExportHistory model should be created with valid data', () {
      final export = createValidExportHistory(
        id: 1,
        filePath: '/exports/chart.png',
        graphType: 'attendance_trend',
      );

      expect(export.id, 1);
      expect(export.churchId, 1);
      expect(export.exportType, 'graph');
      expect(export.exportName, 'Attendance Chart Export');
      expect(export.filePath, '/exports/chart.png');
      expect(export.graphType, 'attendance_trend');
      expect(export.recordCount, 10);
    });

    test('ExportHistory should validate successfully with valid data', () {
      final export = createValidExportHistory();

      expect(export.isValid(), true);
      expect(export.validate(), null);
    });

    test('ExportHistory should validate with pdf_report type', () {
      final export = createValidExportHistory(
        exportType: 'pdf_report',
        exportName: 'Monthly Report',
      );

      expect(export.isValid(), true);
    });

    test('ExportHistory should validate with csv type', () {
      final export = createValidExportHistory(
        exportType: 'csv',
        exportName: 'Data Export',
      );

      expect(export.isValid(), true);
    });

    test('ExportHistory should fail validation with invalid church ID', () {
      final export = createValidExportHistory(churchId: 0);

      expect(export.isValid(), false);
      expect(export.validate(), 'Invalid church ID');
    });

    test('ExportHistory should fail validation with empty export type', () {
      final export = createValidExportHistory(exportType: '');

      expect(export.isValid(), false);
      expect(export.validate(), 'Export type cannot be empty');
    });

    test('ExportHistory should fail validation with invalid export type', () {
      final export = createValidExportHistory(exportType: 'invalid_type');

      expect(export.isValid(), false);
      expect(
        export.validate(),
        'Export type must be one of: graph, pdf_report, csv',
      );
    });

    test('ExportHistory should fail validation with empty export name', () {
      final export = createValidExportHistory(exportName: '');

      expect(export.isValid(), false);
      expect(export.validate(), 'Export name cannot be empty');
    });

    test('ExportHistory should fail validation with long export name', () {
      final export = createValidExportHistory(exportName: 'A' * 201);

      expect(export.isValid(), false);
      expect(export.validate(), 'Export name cannot exceed 200 characters');
    });

    test('ExportHistory should fail validation with negative record count', () {
      final export = createValidExportHistory(recordCount: -1);

      expect(export.isValid(), false);
      expect(export.validate(), 'Record count cannot be negative');
    });

    test('ExportHistory should convert to and from JSON', () {
      final export = createValidExportHistory(
        id: 1,
        filePath: '/exports/chart.png',
        graphType: 'attendance_trend',
      );

      final json = export.toJson();
      final fromJson = ExportHistory.fromJson(json);

      expect(fromJson.id, export.id);
      expect(fromJson.churchId, export.churchId);
      expect(fromJson.exportType, export.exportType);
      expect(fromJson.exportName, export.exportName);
      expect(fromJson.filePath, export.filePath);
      expect(fromJson.graphType, export.graphType);
      expect(fromJson.recordCount, export.recordCount);
    });

    test(
      'ExportHistory copyWith should create a new instance with updated fields',
      () {
        final export = createValidExportHistory(id: 1);
        final updated = export.copyWith(
          exportName: 'Updated Export',
          recordCount: 25,
        );

        expect(updated.id, export.id);
        expect(updated.exportType, export.exportType);
        expect(updated.exportName, 'Updated Export');
        expect(updated.recordCount, 25);
      },
    );

    test('ExportHistory should implement Equatable correctly', () {
      final export1 = createValidExportHistory(id: 1);
      final export2 = createValidExportHistory(id: 1);

      expect(export1, export2);
    });

    test('ExportHistory should handle null optional fields', () {
      final export = ExportHistory(
        churchId: 1,
        exportType: 'graph',
        exportName: 'Test Export',
        exportedAt: now,
      );

      expect(export.filePath, isNull);
      expect(export.graphType, isNull);
      expect(export.recordCount, 0);
      expect(export.isValid(), true);
    });
  });
}
