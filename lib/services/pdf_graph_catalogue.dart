// lib/services/pdf_graph_catalogue.dart

/// Unique identifier for every graph that can appear in a PDF export.
enum PdfGraphId {
  // Attendance category
  attendanceTrend,
  demographicBreakdown,
  attendanceGrowthRate,
  homeChurchTrend,
  adultVsYoungDistribution,

  // Financial category
  incomeTrend,
  incomeComposition,
  titheVsOfferingsTrend,
  incomePerAttendeeTrend,
  regularVsSpecialIncome,

  // Ratios & Correlations category
  perCapitaGivingTrend,
  menWomenRatioTrend,
  adultYoungRatioTrend,
}

/// Category used to group graph options in the selection UI.
enum PdfGraphCategory {
  attendance,
  financial,
  ratios,
}

/// Human-readable label for each category (used as section headers in the UI).
const Map<PdfGraphCategory, String> kPdfGraphCategoryLabels = {
  PdfGraphCategory.attendance: 'Attendance',
  PdfGraphCategory.financial: 'Financial',
  PdfGraphCategory.ratios: 'Ratios & Correlations',
};

/// Display information for one graph option in the selection UI.
class PdfGraphOption {
  final PdfGraphId id;
  final String label;
  final String description;
  final PdfGraphCategory category;

  const PdfGraphOption({
    required this.id,
    required this.label,
    required this.description,
    required this.category,
  });
}

/// The complete catalogue of available graphs.
/// Order within each category determines the order in the exported PDF.
const List<PdfGraphOption> kPdfGraphCatalogue = [
  // ── Attendance ────────────────────────────────────────────────────────────
  PdfGraphOption(
    id: PdfGraphId.attendanceTrend,
    label: 'Total Attendance Trend',
    description: 'Weekly total attendance as a line chart over time.',
    category: PdfGraphCategory.attendance,
  ),
  PdfGraphOption(
    id: PdfGraphId.demographicBreakdown,
    label: 'Demographic Breakdown',
    description: 'Men, Women, Youth, Children attendance per week as grouped bars.',
    category: PdfGraphCategory.attendance,
  ),
  PdfGraphOption(
    id: PdfGraphId.attendanceGrowthRate,
    label: 'Attendance Growth Rate',
    description: 'Week-over-week attendance change as a percentage bar chart.',
    category: PdfGraphCategory.attendance,
  ),
  PdfGraphOption(
    id: PdfGraphId.homeChurchTrend,
    label: 'Home Church Trend',
    description: 'Sunday home church attendance over time.',
    category: PdfGraphCategory.attendance,
  ),
  PdfGraphOption(
    id: PdfGraphId.adultVsYoungDistribution,
    label: 'Adult vs Young Distribution',
    description: 'Pie chart: Adults (Men+Women) vs Young (Youth+Children).',
    category: PdfGraphCategory.attendance,
  ),

  // ── Financial ─────────────────────────────────────────────────────────────
  PdfGraphOption(
    id: PdfGraphId.incomeTrend,
    label: 'Total Income Trend',
    description: 'Weekly total income as a line chart over time.',
    category: PdfGraphCategory.financial,
  ),
  PdfGraphOption(
    id: PdfGraphId.incomeComposition,
    label: 'Income Composition',
    description: 'Tithe, Offerings, Emergency, Planned stacked by week.',
    category: PdfGraphCategory.financial,
  ),
  PdfGraphOption(
    id: PdfGraphId.titheVsOfferingsTrend,
    label: 'Tithe vs Offerings Trend',
    description: 'Side-by-side line chart of tithe and offerings over time.',
    category: PdfGraphCategory.financial,
  ),
  PdfGraphOption(
    id: PdfGraphId.incomePerAttendeeTrend,
    label: 'Income Per Attendee',
    description: 'Weekly income divided by attendance over time.',
    category: PdfGraphCategory.financial,
  ),
  PdfGraphOption(
    id: PdfGraphId.regularVsSpecialIncome,
    label: 'Regular vs Special Income',
    description: 'Pie chart: Regular (Tithe+Offerings) vs Special Collections.',
    category: PdfGraphCategory.financial,
  ),

  // ── Ratios & Correlations ─────────────────────────────────────────────────
  PdfGraphOption(
    id: PdfGraphId.perCapitaGivingTrend,
    label: 'Per-Capita Giving Trend',
    description: 'Tithe per attendee per week as a bar chart.',
    category: PdfGraphCategory.ratios,
  ),
  PdfGraphOption(
    id: PdfGraphId.menWomenRatioTrend,
    label: 'Men:Women Ratio Trend',
    description: 'Weekly Men-to-Women attendance ratio over time.',
    category: PdfGraphCategory.ratios,
  ),
  PdfGraphOption(
    id: PdfGraphId.adultYoungRatioTrend,
    label: 'Adult:Young Ratio Trend',
    description: 'Weekly Adult-to-Young attendance ratio over time.',
    category: PdfGraphCategory.ratios,
  ),
];
