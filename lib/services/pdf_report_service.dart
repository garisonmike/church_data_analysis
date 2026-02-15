import 'package:church_analytics/models/models.dart' as models;
import 'package:church_analytics/platform/file_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfReportService {
  /// Creates a PDF document with standardized layout template
  ///
  /// Returns a PDF document ready for content insertion
  static Future<pw.Document> createPdfTemplate({
    required String title,
    required String churchName,
  }) async {
    final pdf = pw.Document();

    return pdf;
  }

  /// Builds a header section for the PDF with title and metadata
  static pw.Widget buildHeader({
    required String title,
    required String churchName,
    required DateTime generatedDate,
    String? locale,
  }) {
    // Safe date formatting with fallback to prevent LocaleDataException
    String formattedDate;
    try {
      final dateFormat = locale == null
          ? DateFormat('MMMM d, yyyy')
          : DateFormat('MMMM d, yyyy', locale);
      formattedDate = dateFormat.format(generatedDate);
    } catch (e) {
      debugPrint('Warning: DateFormat failed, using fallback: $e');
      // Fallback to simple ISO format if locale initialization failed
      formattedDate =
          '${generatedDate.year}-${generatedDate.month.toString().padLeft(2, '0')}-${generatedDate.day.toString().padLeft(2, '0')}';
    }

    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 20),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.blue700, width: 2),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                churchName,
                style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700),
              ),
              pw.Text(
                'Generated: $formattedDate',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a footer section with page numbers
  static pw.Widget buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 20),
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey400, width: 1),
        ),
      ),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
      ),
    );
  }

  /// Inserts a captured chart image into the PDF
  static pw.Widget buildChartSection({
    required String chartTitle,
    required Uint8List chartImageBytes,
    String? description,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          chartTitle,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 8),
        if (description != null) ...[
          pw.Text(
            description,
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 8),
        ],
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          padding: const pw.EdgeInsets.all(8),
          child: pw.Image(
            pw.MemoryImage(chartImageBytes),
            fit: pw.BoxFit.contain,
          ),
        ),
        pw.SizedBox(height: 20),
      ],
    );
  }

  /// Builds a KPI statistics section with key metrics
  static pw.Widget buildKpiSection({
    required String title,
    required List<KpiMetric> metrics,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Wrap(
          spacing: 16,
          runSpacing: 16,
          children: metrics.map((metric) {
            return pw.Container(
              width: 140,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: metric.color ?? PdfColors.blue50,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                border: pw.Border.all(
                  color: metric.borderColor ?? PdfColors.blue200,
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    metric.label,
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    metric.value,
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  if (metric.subtitle != null) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(
                      metric.subtitle!,
                      style: pw.TextStyle(
                        fontSize: 8,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
        pw.SizedBox(height: 20),
      ],
    );
  }

  /// Creates a comprehensive multi-chart report
  static Future<pw.Document> buildMultiChartReport({
    required String churchName,
    required List<models.WeeklyRecord> records,
    required Map<String, Uint8List> chartImages,
    DateTime? reportDate,
    bool includeGraphs = true,
    bool includeKpi = true,
    bool includeTable = true,
    bool includeTrends = true,
    String? locale,
    String? currencySymbol,
    String Function(double)? formatCurrency,
    String Function(double)? formatCurrencyPrecise,
  }) async {
    final pdf = pw.Document();
    final date = reportDate ?? DateTime.now();
    final numberFormat = locale == null
        ? NumberFormat.decimalPattern()
        : NumberFormat.decimalPattern(locale);

    // Calculate KPI metrics
    final kpis = _calculateKpis(
      records,
      numberFormat: numberFormat,
      currencySymbol: currencySymbol,
      formatCurrency: formatCurrency,
      formatCurrencyPrecise: formatCurrencyPrecise,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => buildHeader(
          title: 'Church Analytics Report',
          churchName: churchName,
          generatedDate: date,
          locale: locale,
        ),
        footer: (context) => buildFooter(context),
        build: (context) => [
          if (includeKpi) ...[
            buildKpiSection(title: 'Key Performance Indicators', metrics: kpis),
            pw.SizedBox(height: 20),
          ],
          if (includeGraphs && chartImages.isNotEmpty) ...[
            pw.Text(
              'Visual Analytics',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 16),
            ...chartImages.entries.map((entry) {
              return buildChartSection(
                chartTitle: entry.key,
                chartImageBytes: entry.value,
              );
            }),
            pw.SizedBox(height: 20),
          ],
          if (includeTable) ...[
            _buildRecordsTable(
              records,
              numberFormat: numberFormat,
              locale: locale,
              currencySymbol: currencySymbol,
              formatCurrencyPrecise: formatCurrencyPrecise,
            ),
            pw.SizedBox(height: 20),
          ],
          if (includeTrends)
            _buildSummarySection(
              records,
              locale: locale,
              numberFormat: numberFormat,
            ),
        ],
      ),
    );

    return pdf;
  }

  /// Calculates KPI metrics from weekly records
  static List<KpiMetric> _calculateKpis(
    List<models.WeeklyRecord> records, {
    required NumberFormat numberFormat,
    String? currencySymbol,
    String Function(double)? formatCurrency,
    String Function(double)? formatCurrencyPrecise,
  }) {
    if (records.isEmpty) {
      return [KpiMetric(label: 'No Data', value: '-', subtitle: 'Add records')];
    }

    final totalAttendance = records.fold<int>(
      0,
      (sum, r) => sum + r.totalAttendance,
    );
    final avgAttendance = totalAttendance / records.length;

    final totalIncome = records.fold<double>(
      0,
      (sum, r) => sum + r.totalIncome,
    );

    final totalTithe = records.fold<double>(0, (sum, r) => sum + r.tithe);

    final totalOfferings = records.fold<double>(
      0,
      (sum, r) => sum + r.offerings,
    );

    String formatCurrencyValue(double value, {bool precise = false}) {
      if (precise && formatCurrencyPrecise != null) {
        return formatCurrencyPrecise(value);
      }
      if (!precise && formatCurrency != null) {
        return formatCurrency(value);
      }
      final symbol = currencySymbol ?? r'\$';
      return '$symbol ${value.toStringAsFixed(0)}';
    }

    String formatPercent(double numerator, double denominator) {
      if (denominator == 0) {
        return '0%';
      }
      final percent = (numerator / denominator) * 100;
      return '${percent.toStringAsFixed(0)}%';
    }

    return [
      KpiMetric(
        label: 'Avg Attendance',
        value: numberFormat.format(avgAttendance.round()),
        subtitle: 'per week',
        color: PdfColors.blue50,
        borderColor: PdfColors.blue200,
      ),
      KpiMetric(
        label: 'Total Income',
        value: formatCurrencyValue(totalIncome, precise: true),
        subtitle: '${records.length} weeks',
        color: PdfColors.green50,
        borderColor: PdfColors.green200,
      ),
      KpiMetric(
        label: 'Total Tithe',
        value: formatCurrencyValue(totalTithe, precise: true),
        subtitle: '${formatPercent(totalTithe, totalIncome)} of income',
        color: PdfColors.purple50,
        borderColor: PdfColors.purple200,
      ),
      KpiMetric(
        label: 'Total Offerings',
        value: formatCurrencyValue(totalOfferings, precise: true),
        subtitle: '${formatPercent(totalOfferings, totalIncome)} of income',
        color: PdfColors.orange50,
        borderColor: PdfColors.orange200,
      ),
    ];
  }

  /// Builds a summary section with insights
  static pw.Widget _buildSummarySection(
    List<models.WeeklyRecord> records, {
    required String? locale,
    required NumberFormat numberFormat,
  }) {
    if (records.isEmpty) {
      return pw.Container();
    }

    final sortedByDate = List<models.WeeklyRecord>.from(records)
      ..sort((a, b) => a.weekStartDate.compareTo(b.weekStartDate));

    final firstDate = sortedByDate.first.weekStartDate;
    final lastDate = sortedByDate.last.weekStartDate;
    final dateFormat = locale == null
        ? DateFormat('MMM d, yyyy')
        : DateFormat('MMM d, yyyy', locale);

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Report Summary',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Period: ${dateFormat.format(firstDate)} - ${dateFormat.format(lastDate)}',
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Total Weeks: ${numberFormat.format(records.length)}',
            style: const pw.TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildRecordsTable(
    List<models.WeeklyRecord> records, {
    required NumberFormat numberFormat,
    String? locale,
    String? currencySymbol,
    String Function(double)? formatCurrencyPrecise,
  }) {
    if (records.isEmpty) {
      return pw.Container();
    }

    final dateFormat = locale == null
        ? DateFormat('MMM d, yyyy')
        : DateFormat('MMM d, yyyy', locale);
    final symbol = currencySymbol ?? r'\$';

    String formatCurrencyValue(double value) {
      if (formatCurrencyPrecise != null) {
        return formatCurrencyPrecise(value);
      }
      return '$symbol ${value.toStringAsFixed(2)}';
    }

    final rows = records.map((record) {
      return [
        dateFormat.format(record.weekStartDate),
        numberFormat.format(record.totalAttendance),
        formatCurrencyValue(record.totalIncome),
      ];
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Weekly Records',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blue50),
          cellAlignment: pw.Alignment.centerLeft,
          cellStyle: const pw.TextStyle(fontSize: 10),
          headers: ['Week Start', 'Attendance', 'Total Income ($symbol)'],
          data: rows,
        ),
      ],
    );
  }

  /// Saves PDF document to device storage
  static Future<String?> savePdf({
    required pw.Document pdf,
    required String fileName,
    String? customPath,
  }) async {
    try {
      final fileStorage = getFileStorage();

      // Ensure filename has .pdf extension
      final fullFileName = fileName.endsWith('.pdf')
          ? fileName
          : '$fileName.pdf';
      final fullPath = customPath == null
          ? null
          : customPath.endsWith('.pdf')
          ? customPath
          : '$customPath.pdf';

      // Generate PDF bytes
      final bytes = await pdf.save();

      // Save to file
      final path = await fileStorage.saveFileBytes(
        fileName: fullFileName,
        bytes: bytes,
        fullPath: fullPath,
      );

      return path;
    } catch (e) {
      debugPrint('Error saving PDF: $e');
      return null;
    }
  }

  /// Shares PDF document using the system share dialog
  static Future<bool> sharePdf({
    required pw.Document pdf,
    required String fileName,
  }) async {
    try {
      final bytes = await pdf.save();

      // Use the printing package's share functionality
      await Printing.sharePdf(
        bytes: bytes,
        filename: fileName.endsWith('.pdf') ? fileName : '$fileName.pdf',
      );

      return true;
    } catch (e) {
      debugPrint('Error sharing PDF: $e');
      return false;
    }
  }

  /// Prints PDF document using the system print dialog
  static Future<bool> printPdf({required pw.Document pdf}) async {
    try {
      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
      return true;
    } catch (e) {
      debugPrint('Error printing PDF: $e');
      return false;
    }
  }

  /// Generates a standardized filename for PDF reports
  static String generatePdfFileName({
    required String churchName,
    required String reportType,
  }) {
    final cleanChurchName = churchName
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();

    final cleanReportType = reportType
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();

    // Generate timestamp with safe date formatting
    String timestamp;
    try {
      timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    } catch (e) {
      debugPrint('Warning: DateFormat failed, using fallback: $e');
      // Fallback to manual formatting if locale fails
      final now = DateTime.now();
      timestamp =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
          '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    }

    return '${cleanChurchName}_${cleanReportType}_$timestamp';
  }
}

/// Data class for KPI metrics in PDF reports
class KpiMetric {
  final String label;
  final String value;
  final String? subtitle;
  final PdfColor? color;
  final PdfColor? borderColor;

  KpiMetric({
    required this.label,
    required this.value,
    this.subtitle,
    this.color,
    this.borderColor,
  });
}
