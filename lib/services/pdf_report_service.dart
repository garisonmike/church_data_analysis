import 'package:church_analytics/models/models.dart' as models;
import 'package:church_analytics/services/file_service.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'pdf_graph_catalogue.dart'; // 2.5-A
import 'pdf_chart_builder.dart'; // 2.5-A

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
      if (kDebugMode) {
        debugPrint('Warning: DateFormat failed, using fallback: $e');
      }
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

  // 2.5-B — dispatch method ─────────────────────────────────────────────────

  /// Dispatches a [PdfGraphId] to the correct [PdfChartBuilder] method.
  /// Always returns a valid [pw.Widget] — never null, never throws.
  /// If the records list is too short for a given chart, the chart builder
  /// returns its own empty-state placeholder widget.
  static pw.Widget buildGraph({
    required PdfGraphId id,
    required List<models.WeeklyRecord> records,
    List<models.HolyCommunionEvent> communionEvents = const [],
    String currencySymbol = r'$',
  }) {
    switch (id) {
      case PdfGraphId.attendanceTrend:
        return PdfChartBuilder.attendanceTrend(records);
      case PdfGraphId.demographicBreakdown:
        return PdfChartBuilder.demographicBreakdown(records);
      case PdfGraphId.attendanceGrowthRate:
        return PdfChartBuilder.attendanceGrowthRate(records);
      case PdfGraphId.homeChurchTrend:
        return PdfChartBuilder.homeChurchTrend(records);
      case PdfGraphId.adultVsYoungDistribution:
        return PdfChartBuilder.adultVsYoungDistribution(records);
      case PdfGraphId.incomeTrend:
        return PdfChartBuilder.incomeTrend(
            records, currencySymbol: currencySymbol);
      case PdfGraphId.incomeComposition:
        return PdfChartBuilder.incomeComposition(
            records, currencySymbol: currencySymbol);
      case PdfGraphId.titheVsOfferingsTrend:
        return PdfChartBuilder.titheVsOfferingsTrend(
            records, currencySymbol: currencySymbol);
      case PdfGraphId.incomePerAttendeeTrend:
        return PdfChartBuilder.incomePerAttendeeTrend(
            records, currencySymbol: currencySymbol);
      case PdfGraphId.regularVsSpecialIncome:
        return PdfChartBuilder.regularVsSpecialIncome(records);
      case PdfGraphId.perCapitaGivingTrend:
        return PdfChartBuilder.perCapitaGivingTrend(
            records, currencySymbol: currencySymbol);
      case PdfGraphId.menWomenRatioTrend:
        return PdfChartBuilder.menWomenRatioTrend(records);
      case PdfGraphId.adultYoungRatioTrend:
        return PdfChartBuilder.adultYoungRatioTrend(records);
      // Baptisms
      case PdfGraphId.baptismsTrend:
        return PdfChartBuilder.baptismsTrend(records);
      case PdfGraphId.baptismsMonthly:
        return PdfChartBuilder.baptismsMonthly(records);
      case PdfGraphId.baptismsCumulative:
        return PdfChartBuilder.baptismsCumulative(records);
      // Holy Communion
      case PdfGraphId.communionAttendanceRateTrend:
        return PdfChartBuilder.communionAttendanceRateTrend(communionEvents);
      case PdfGraphId.communionActualVsExpected:
        return PdfChartBuilder.communionActualVsExpected(communionEvents);
      case PdfGraphId.communionByHomeChurch:
        return PdfChartBuilder.communionByHomeChurch(communionEvents);
      case PdfGraphId.communionQuarterlyComparison:
        return PdfChartBuilder.communionQuarterlyComparison(communionEvents);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────

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
  // 2.5-C: replaced Map<String, Uint8List> chartImages with List<PdfGraphId> selectedGraphs
  static Future<pw.Document> buildMultiChartReport({
    required String churchName,
    required List<models.WeeklyRecord> records,
    List<PdfGraphId> selectedGraphs = const [], // 2.5-C
    List<models.HolyCommunionEvent> communionEvents = const [], // FEAT-010
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
          // 2.5-D: replaced old chartImages block with selectedGraphs block
          if (includeGraphs && selectedGraphs.isNotEmpty) ...[
            pw.Text(
              'Visual Analytics',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 16),
            ...selectedGraphs.map((id) => buildGraph(
                  id: id,
                  records: records,
                  communionEvents: communionEvents, // FEAT-010
                  currencySymbol: currencySymbol ?? r'$',
                )),
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
          // 2.5-E: analytics summary wired in before existing summary section
          if (includeTrends) ...[
            _buildAnalyticsSummary(
              records,
              numberFormat: numberFormat,
              currencySymbol: currencySymbol,
            ),
            _buildSummarySection(
              records,
              locale: locale,
              numberFormat: numberFormat,
            ),
          ],
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

  // 2.5-E — Analytics highlights table ─────────────────────────────────────

  static pw.Widget _buildAnalyticsSummary(
    List<models.WeeklyRecord> records, {
    required NumberFormat numberFormat,
    String? currencySymbol,
  }) {
    if (records.length < 2) return pw.Container();

    final symbol = currencySymbol ?? r'$';
    final sorted = List<models.WeeklyRecord>.from(records)
      ..sort((a, b) => a.weekStartDate.compareTo(b.weekStartDate));

    final firstAtt = sorted.first.totalAttendance.toDouble();
    final lastAtt = sorted.last.totalAttendance.toDouble();
    final growthPct =
        firstAtt == 0 ? 0.0 : ((lastAtt - firstAtt) / firstAtt) * 100;

    final peakAtt = sorted.reduce(
        (a, b) => a.totalAttendance > b.totalAttendance ? a : b);
    final peakInc =
        sorted.reduce((a, b) => a.totalIncome > b.totalIncome ? a : b);

    final totalInc = records.fold<double>(0, (s, r) => s + r.totalIncome);
    final totalAtt = records.fold<int>(0, (s, r) => s + r.totalAttendance);
    final perCapita = totalAtt == 0 ? 0.0 : totalInc / totalAtt;

    final totalBaptisms = records.fold<int>(0, (s, r) => s + (r.baptisms ?? 0));
    final totalCommunion =
        records.fold<int>(0, (s, r) => s + (r.holyCommunion ?? 0));
    final totalVisitors =
        records.fold<int>(0, (s, r) => s + (r.visitorsCount ?? 0));

    final df = DateFormat('MMM d, yyyy');

    final rows = [
      ['Attendance growth (period)', '${growthPct.toStringAsFixed(1)}%'],
      ['Peak attendance week', df.format(peakAtt.weekStartDate)],
      ['Peak attendance', numberFormat.format(peakAtt.totalAttendance)],
      ['Peak income week', df.format(peakInc.weekStartDate)],
      [
        'Peak income',
        '$symbol ${peakInc.totalIncome.toStringAsFixed(2)}'
      ],
      ['Avg per-capita giving', '$symbol ${perCapita.toStringAsFixed(2)}'],
      if (totalBaptisms > 0) ['Total baptisms', totalBaptisms.toString()],
      if (totalCommunion > 0)
        ['Holy communion events', totalCommunion.toString()],
      if (totalVisitors > 0)
        ['Total visitors recorded', numberFormat.format(totalVisitors)],
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Analytics Highlights',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blue50),
          cellAlignment: pw.Alignment.centerLeft,
          cellStyle: const pw.TextStyle(fontSize: 10),
          headers: ['Metric', 'Value'],
          data: rows,
        ),
        pw.SizedBox(height: 20),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────

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

  // 2.5-F — Expanded records table (two tables: attendance + financial) ─────

  static pw.Widget _buildRecordsTable(
    List<models.WeeklyRecord> records, {
    required NumberFormat numberFormat,
    String? locale,
    String? currencySymbol,
    String Function(double)? formatCurrencyPrecise,
  }) {
    if (records.isEmpty) return pw.Container();

    final dateFormat = locale == null
        ? DateFormat('MMM d, yyyy')
        : DateFormat('MMM d, yyyy', locale);
    final symbol = currencySymbol ?? r'$';

    String fc(double value) => formatCurrencyPrecise != null
        ? formatCurrencyPrecise(value)
        : '$symbol ${value.toStringAsFixed(2)}';

    // ── Table 1: Attendance detail ─────────────────────────────────────────
    final attendanceTable = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Weekly Attendance Detail',
          style: pw.TextStyle(
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800),
        ),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
              fontSize: 8),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blue50),
          cellStyle: const pw.TextStyle(fontSize: 8),
          cellAlignment: pw.Alignment.centerLeft,
          headers: [
            'Week',
            'Total',
            'Men',
            'Women',
            'Youth',
            'Children',
            'Home Ch.',
            'Sabbath',
            'Visitors',
          ],
          data: records.map((r) => [
                dateFormat.format(r.weekStartDate),
                numberFormat.format(r.totalAttendance),
                r.men.toString(),
                r.women.toString(),
                r.youth.toString(),
                r.children.toString(),
                r.sundayHomeChurch.toString(),
                r.sabbathSchoolAttendance?.toString() ?? '-',
                r.visitorsCount?.toString() ?? '-',
              ]).toList(),
        ),
      ],
    );

    // ── Table 2: Financial detail ──────────────────────────────────────────
    final financialTable = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 16),
        pw.Text(
          'Weekly Financial Detail ($symbol)',
          style: pw.TextStyle(
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800),
        ),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
              fontSize: 8),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blue50),
          cellStyle: const pw.TextStyle(fontSize: 8),
          cellAlignment: pw.Alignment.centerLeft,
          headers: [
            'Week',
            'Tithe',
            'Offerings',
            'Emergency',
            'Planned',
            'Mission',
            'Local Budget',
            'Total',
          ],
          data: records.map((r) => [
                dateFormat.format(r.weekStartDate),
                fc(r.tithe),
                fc(r.offerings),
                fc(r.emergencyCollection),
                fc(r.plannedCollection),
                fc(r.missionOffering ?? 0.0),
                fc(r.localChurchBudget ?? 0.0),
                fc(r.totalIncome),
              ]).toList(),
        ),
      ],
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Weekly Records',
          style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800),
        ),
        pw.SizedBox(height: 8),
        attendanceTable,
        financialTable,
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────

  /// Saves PDF document to device storage
  static Future<String?> savePdf({
    required pw.Document pdf,
    required String fileName,
    String? customPath,
    FileService? fileService,
  }) async {
    try {
      final service = fileService ?? FileService();

      // Ensure filename has .pdf extension
      final fullFileName =
          fileName.endsWith('.pdf') ? fileName : '$fileName.pdf';
      final fullPath = customPath == null
          ? null
          : customPath.endsWith('.pdf')
              ? customPath
              : '$customPath.pdf';

      if (kDebugMode) {
        debugPrint('PDF save requested. Custom path: $customPath');
      }

      // Generate PDF bytes
      final bytes = await pdf.save();

      // Save via FileService
      final result = await service.exportFileBytes(
        filename: fullFileName,
        bytes: bytes,
        forcedPath: fullPath,
      );

      if (kDebugMode) {
        debugPrint('PDF saved to: ${result.filePath}');
      }

      return result.filePath;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving PDF: $e');
      }
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
      if (kDebugMode) {
        debugPrint('Error sharing PDF: $e');
      }
      return false;
    }
  }

  /// Prints PDF document using the system print dialog
  static Future<bool> printPdf({required pw.Document pdf}) async {
    try {
      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error printing PDF: $e');
      }
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
      if (kDebugMode) {
        debugPrint('Warning: DateFormat failed, using fallback: $e');
      }
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
