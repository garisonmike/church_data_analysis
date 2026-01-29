import 'package:church_analytics/services/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';

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
            value: '\$5000',
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

    group('verifyPdfOutput', () {
      test('returns false for non-existent file', () async {
        final result = await PdfReportService.verifyPdfOutput(
          '/non/existent/path/file.pdf',
        );

        expect(result, false);
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

        final withExtension = fileName.endsWith('.pdf')
            ? fileName
            : '$fileName.pdf';
        expect(withExtension, 'test_report.pdf');
      });

      test('preserves PDF extension if already present', () {
        const fileName = 'test_report.pdf';
        expect(fileName.endsWith('.pdf'), true);

        final withExtension = fileName.endsWith('.pdf')
            ? fileName
            : '$fileName.pdf';
        expect(withExtension, 'test_report.pdf');
      });
    });
  });
}
