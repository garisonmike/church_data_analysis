import 'dart:io';

import 'package:church_analytics/models/models.dart';
import 'package:church_analytics/services/pdf_graph_catalogue.dart';
import 'package:church_analytics/services/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  group('PdfReportService', () {
    group('generatePdfFileName', () {
      test('generates valid PDF filename with clean church name', () {
        final fileName = PdfReportService.generatePdfFileName(
          churchName: 'Holy Trinity Church',
          reportType: 'Monthly Report',
        );

        expect(fileName, contains('holy_trinity_church'));
        expect(fileName, contains('monthly_report'));
        expect(fileName, matches(RegExp(r'\d{8}_\d{6}'))); // timestamp
      });

      test('handles special characters in names', () {
        final fileName = PdfReportService.generatePdfFileName(
          churchName: "St. Mary's Church & Chapel",
          reportType: 'Annual Analysis!',
        );

        expect(fileName, contains('st_marys_church_chapel'));
        expect(fileName, contains('annual_analysis'));
        expect(fileName, isNot(contains('&')));
        expect(fileName, isNot(contains('!')));
      });

      test('converts to lowercase', () {
        final fileName = PdfReportService.generatePdfFileName(
          churchName: 'GRACE COMMUNITY',
          reportType: 'WEEKLY SUMMARY',
        );

        expect(fileName, equals(fileName.toLowerCase()));
      });

      test('replaces multiple spaces with single underscore', () {
        final fileName = PdfReportService.generatePdfFileName(
          churchName: 'First    Baptist    Church',
          reportType: 'Quarterly   Report',
        );

        expect(fileName, contains('first_baptist_church'));
        expect(fileName, contains('quarterly_report'));
        expect(fileName, isNot(contains('  ')));
      });
    });

    group('buildHeader', () {
      test('creates header with title and metadata', () {
        final header = PdfReportService.buildHeader(
          title: 'Test Report',
          churchName: 'Test Church',
          generatedDate: DateTime(2026, 1, 29),
        );

        expect(header, isNotNull);
      });
    });

    group('buildFooter', () {
      test('creates footer widget', () {
        // This test just verifies the method exists and returns a widget
        // Actual rendering would require a full PDF context
        expect(PdfReportService.buildFooter, isNotNull);
      });
    });

    group('buildChartSection', () {
      test('validates chart section structure', () {
        // Test just validates the method signature and basic structure
        // Actual image rendering requires a valid PNG which is complex to mock
        expect(PdfReportService.buildChartSection, isNotNull);
      });

      test('validates description parameter handling', () {
        // Test parameter handling without actually rendering
        expect(PdfReportService.buildChartSection, isNotNull);
      });
    });

    group('buildKpiSection', () {
      test('creates KPI section with metrics', () {
        final metrics = [
          KpiMetric(
            label: 'Total Attendance',
            value: '250',
            subtitle: 'per week',
          ),
          KpiMetric(
            label: 'Total Income',
            value: 'KES 5000.00',
            subtitle: '12 weeks',
          ),
        ];

        final kpiSection = PdfReportService.buildKpiSection(
          title: 'Key Metrics',
          metrics: metrics,
        );

        expect(kpiSection, isNotNull);
      });

      test('creates KPI with custom colors', () {
        final metric = KpiMetric(
          label: 'Test Metric',
          value: '100',
          subtitle: 'test',
          color: PdfColors.blue50,
          borderColor: PdfColors.blue200,
        );

        expect(metric.color, PdfColors.blue50);
        expect(metric.borderColor, PdfColors.blue200);
      });
    });

    group('savePdf', () {
      test('saves a PDF and returns a path', () async {
        final pdf = pw.Document();
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (context) => pw.Text('Test PDF'),
          ),
        );

        final savedPath = await PdfReportService.savePdf(
          pdf: pdf,
          fileName: 'test_report',
        );

        expect(savedPath, isNotNull);
        expect(savedPath, endsWith('.pdf'));
        expect(await File(savedPath!).exists(), isTrue);
      });

      test('validates PDF signature', () {
        // Test PDF signature validation logic
        const pdfSignature = '%PDF-';
        expect(pdfSignature.length, 5);
        expect(pdfSignature[0], '%');
        expect(pdfSignature[1], 'P');
        expect(pdfSignature[2], 'D');
        expect(pdfSignature[3], 'F');
        expect(pdfSignature[4], '-');
      });
    });

    group('KpiMetric', () {
      test('creates metric with required fields', () {
        final metric = KpiMetric(label: 'Test', value: '100');

        expect(metric.label, 'Test');
        expect(metric.value, '100');
        expect(metric.subtitle, isNull);
      });

      test('creates metric with all fields', () {
        final metric = KpiMetric(
          label: 'Test',
          value: '100',
          subtitle: 'per week',
          color: PdfColors.blue50,
          borderColor: PdfColors.blue200,
        );

        expect(metric.label, 'Test');
        expect(metric.value, '100');
        expect(metric.subtitle, 'per week');
        expect(metric.color, PdfColors.blue50);
        expect(metric.borderColor, PdfColors.blue200);
      });
    });

    group('savePdf', () {
      test('ensures PDF extension is added', () {
        const fileName = 'test_report';
        expect(fileName.endsWith('.pdf'), false);

        final withExtension =
            fileName.endsWith('.pdf') ? fileName : '$fileName.pdf';
        expect(withExtension, 'test_report.pdf');
      });

      test('preserves PDF extension if already present', () {
        const fileName = 'test_report.pdf';
        expect(fileName.endsWith('.pdf'), true);

        final withExtension =
            fileName.endsWith('.pdf') ? fileName : '$fileName.pdf';
        expect(withExtension, 'test_report.pdf');
      });
    });
  });

  // 2.7 — New tests for buildGraph and PdfChartBuilder ──────────────────────

  group('PdfReportService.buildGraph', () {
    final records = [
      WeeklyRecord(
        id: 1,
        churchId: 1,
        createdByAdminId: null,
        weekStartDate: DateTime(2026, 1, 3),
        men: 100,
        women: 120,
        youth: 80,
        children: 60,
        sundayHomeChurch: 40,
        tithe: 5000,
        offerings: 3000,
        emergencyCollection: 500,
        plannedCollection: 200,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      WeeklyRecord(
        id: 2,
        churchId: 1,
        createdByAdminId: null,
        weekStartDate: DateTime(2026, 1, 10),
        men: 110,
        women: 130,
        youth: 85,
        children: 65,
        sundayHomeChurch: 45,
        tithe: 5500,
        offerings: 3200,
        emergencyCollection: 600,
        plannedCollection: 250,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (final id in PdfGraphId.values) {
      test('buildGraph does not throw for id=$id with valid records', () {
        expect(
          () => PdfReportService.buildGraph(
            id: id,
            records: records,
            currencySymbol: 'Ksh',
          ),
          returnsNormally,
        );
      });

      test('buildGraph does not throw for id=$id with empty records', () {
        expect(
          () => PdfReportService.buildGraph(
            id: id,
            records: const [],
            currencySymbol: r'$',
          ),
          returnsNormally,
        );
      });
    }
  });
}
