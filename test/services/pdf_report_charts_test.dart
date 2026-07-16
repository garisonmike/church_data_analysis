import 'package:church_analytics/models/holy_communion_event.dart';
import 'package:church_analytics/models/weekly_record.dart';
import 'package:church_analytics/services/pdf_graph_catalogue.dart';
import 'package:church_analytics/services/pdf_report_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;

/// U10 — live PDF generation pass.
///
/// Generates the actual report from realistic data and confirms every chart
/// renders populated data rather than the "Not enough data" placeholder that
/// [PdfChartBuilder] falls back to when its data series is empty.
///
/// A populated line/bar/pie chart emits far more content-stream drawing than
/// the placeholder (a title plus one line of text), so rendering each graph
/// once with rich data and once with empty data and comparing the emitted
/// byte size is a reliable per-chart discriminator — more reliable than
/// grepping the PDF for the placeholder sentence, which the pdf package splits
/// across kerned TJ fragments so it never appears contiguously.
void main() {
  // 16 weeks of realistic records: attendance, finances, and baptisms.
  List<WeeklyRecord> richRecords() {
    final start = DateTime(2026, 1, 4); // a Sunday
    return List.generate(16, (i) {
      final now = DateTime(2026, 1, 1);
      return WeeklyRecord(
        churchId: 1,
        weekStartDate: start.add(Duration(days: 7 * i)),
        men: 40 + i,
        women: 55 + i,
        youth: 30 + (i % 5),
        children: 25 + (i % 4),
        sundayHomeChurch: 15 + (i % 3),
        baptisms: i % 3, // some weeks 0, some 1-2 — still a populated trend
        tithe: 90000 + i * 1500.0,
        offerings: 30000 + i * 800.0,
        emergencyCollection: i.isEven ? 0 : 5000.0,
        plannedCollection: i.isEven ? 4000.0 : 0,
        createdAt: now,
        updatedAt: now,
      );
    });
  }

  // Four quarterly Holy Communion events, each with per-home-church rows.
  List<HolyCommunionEvent> richCommunion() {
    final now = DateTime(2026, 1, 1);
    return List.generate(4, (q) {
      final rows = List.generate(
        3,
        (h) => HolyCommunionAttendanceRow(
          eventId: q + 1,
          homeChurchId: h + 1,
          homeChurchName: 'Home Church ${h + 1}',
          actualAttendance: 40 + q * 5 + h,
          expectedAtHc: 60 + h,
        ),
      );
      return HolyCommunionEvent(
        churchId: 1,
        eventDate: DateTime(2026, 3 * (q + 1), 15),
        year: 2026,
        quarter: q + 1,
        totalExpectedAtKcc: 200,
        attendance: rows,
        createdAt: now,
        updatedAt: now,
      );
    });
  }

  /// Renders one catalogue graph into an uncompressed single-page PDF and
  /// returns the emitted byte size.
  Future<int> graphByteSize({
    required PdfGraphId id,
    required List<WeeklyRecord> records,
    required List<HolyCommunionEvent> communion,
  }) async {
    // compress: false so the emitted byte size reflects the actual drawing
    // operations, not compression luck.
    final doc = pw.Document(compress: false);
    doc.addPage(
      pw.Page(
        build: (context) => PdfReportService.buildGraph(
          id: id,
          records: records,
          communionEvents: communion,
        ),
      ),
    );
    return (await doc.save()).length;
  }

  test('every catalogue graph renders populated for a data-rich church',
      () async {
    final records = richRecords();
    final communion = richCommunion();

    for (final option in kPdfGraphCatalogue) {
      final populated = await graphByteSize(
        id: option.id,
        records: records,
        communion: communion,
      );
      final placeholder = await graphByteSize(
        id: option.id,
        records: const [],
        communion: const [],
      );

      // A real chart draws materially more than the placeholder (a title plus
      // one line of "Not enough data" text). If they were equal, the "chart"
      // was actually the empty-state fallback despite rich data.
      expect(
        populated,
        greaterThan(placeholder),
        reason: '${option.id.name} rendered no more than its empty-state '
            'placeholder despite rich data (populated=$populated, '
            'placeholder=$placeholder bytes)',
      );
    }

    // Sanity: the catalogue really did cover all 20 charts.
    expect(kPdfGraphCatalogue.length, 20);
  });

  test('buildMultiChartReport produces a substantial PDF end-to-end', () async {
    final pdf = await PdfReportService.buildMultiChartReport(
      churchName: 'Test Church',
      records: richRecords(),
      selectedGraphs: PdfGraphId.values,
      communionEvents: richCommunion(),
    );
    final bytes = await pdf.save();
    // A real multi-page report with 20 charts is far larger than an empty doc.
    expect(bytes.length, greaterThan(20000));
  });
}
