# Task Execution Notes

Observations, regression risks, and implementation details worth tracking across the UI stabilization task run.

---

## Task 1 — [P1] Stabilize reports_screen.dart body scrolling and overflow

**File:** `lib/ui/screens/reports_screen.dart`
**Status:** Complete

### What changed
- Replaced `Center > Padding > Column(mainAxisAlignment: center)` with `SafeArea > LayoutBuilder > SingleChildScrollView > ConstrainedBox > Column(crossAxisAlignment: stretch, mainAxisAlignment: start)`.
- Export buttons (`Export PDF`, `Export CSV`) moved into a `Wrap(spacing: 12, runSpacing: 12)`.
- Backup buttons (`Create Backup`, `Restore from Backup`) moved into a separate `Wrap(spacing: 12, runSpacing: 12)` below the `Divider`.
- Fixed spacers (`30`, `20`, `10`) replaced with breakpoint-driven `spacing` variable:
  - `< 480` → `8.0`
  - `480–839` → `12.0`
  - `≥ 840` → `16.0`

### Regression risk: Medium
- Content alignment changed from vertical center to top-start — intentional and required, but visually noticeable.
- Buttons now reflow via `Wrap` instead of stacking vertically — on very narrow widths each button will take its own row (natural behavior), but on wider widths two buttons may sit side by side, which is a layout change from the original single-column stacking.
- `ConstrainedBox(minHeight: constraints.maxHeight)` means on tall viewports the column still fills the screen height — verify this looks correct on large tablets/desktop with few cards.

### Notes
- The `_isProcessing` `CircularProgressIndicator` has no visual separator from the first card when spacing is only 8px on very small screens. Low severity.
- `LayoutBuilder` constraints reflect the body width (inside `SafeArea`), not the full screen width — this is correct behavior for inset-aware breakpoints.

---

## Task 6 — [P2] Prevent AppBar action compression in attendance_charts_screen.dart

**File:** `lib/ui/screens/attendance_charts_screen.dart`
**Status:** Complete

### What changed
- Added to `build()` header:
  - `width = MediaQuery.of(context).size.width`
  - `isNarrow = width < 480`
  - `isMedium = width >= 480 && width < 840`
  - `currentTimeRange = ref.watch(chartTimeRangeProvider)` — needed for `showMenu` `initialValue`
- Replaced single `ConstrainedBox(maxWidth: 400)` + `TimeRangeSelector` action with three-tier branch:
  - `isNarrow (<480)`: `Builder` → `IconButton(Icons.date_range)` whose `onPressed` calls `showMenu<ChartTimeRange>()` anchored to the button's `RenderBox` position. On selection, writes directly to `chartTimeRangeProvider`.
  - `isMedium (480–839)`: `ConstrainedBox(maxWidth: 220)` + `TimeRangeSelector(compact: true)`
  - `isWide (>=840)`: `ConstrainedBox(maxWidth: 400)` + `TimeRangeSelector(compact: true)` (original)
- Refresh `IconButton` is unconditional in all branches.

### Review correction
Initial implementation used `PopupMenuButton` with an `icon:` parameter instead of an `IconButton`. The spec explicitly requires an `IconButton` opening a popup menu. Corrected to use `Builder` → `IconButton` → `showMenu<ChartTimeRange>()` with the button's `RenderBox` position for proper anchoring.

### Regression risk: Low
- `>=840` path is identical to the original code — no wide-screen regression.
- `480–839` path is structurally the same as the original but with a tighter `maxWidth: 220` cap; `TimeRangeSelector` behaviour is unchanged.
- `<480` path replaces `TimeRangeSelector` with `PopupMenuButton` that writes to the same `chartTimeRangeProvider`. Functional equivalence is preserved.

### Notes
- `ref.watch(chartTimeRangeProvider)` added in `build()` so the app bar rebuilds when range changes — this makes `PopupMenuButton.initialValue` stay current. The same provider was already watched inside `TimeRangeSelector` at narrower scope; moving the watch up is safe.
- `PopupMenuButton.initialValue` marks the currently selected range with a check indicator in the popup — provides visual selection feedback equivalent to the `FilterChip.selected` state in the compact selector.
- `maxWidth: 220` at medium width was chosen to leave ~180px for the AppBar title and leading widget after accounting for the compact chip row and refresh button.

---

## Task 5 — [P2] Standardize dialog height constraints and scroll behavior

**Files:**
- `lib/ui/screens/import_screen.dart`
- `lib/ui/screens/church_selection_screen.dart`
- `lib/ui/screens/profile_selection_screen.dart`
- `lib/ui/screens/reports_screen.dart`

**Status:** Complete

### What changed
All 6 targeted dialogs received two changes:
1. `insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)` added to each `AlertDialog`.
2. `content:` wrapped with `LayoutBuilder` → `ConstrainedBox(maxHeight: constraints.maxHeight * 0.8, maxWidth: 560)` → `SingleChildScrollView`.

Additionally, the **Import Complete** results dialog replaced the unbounded spread `...errors.map((e) => Text(...))` inside `Column` with `ListView.builder(shrinkWrap: true, physics: NeverScrollableScrollPhysics())`. This prevents the unbounded list from fighting the outer `SingleChildScrollView`.

For the two **reports_screen.dart** dialogs (`Customize PDF Report`, `Customize CSV Export`), the existing `StatefulBuilder` → `Column` content was moved to be the child of the new `SingleChildScrollView`, preserving all toggle/switch state logic.

### Regression risk: Medium
- All dialog action callbacks (`Navigator.pop`, form submission) are unchanged — no navigation regression.
- `StatefulBuilder` in reports dialogs still rebuilds its `Column` on switch toggles; the added wrappers are stateless and do not interfere.
- `_hasCsvContent(options)` in the CSV dialog `ElevatedButton.onPressed` was already evaluated at `AlertDialog` build time (outside `StatefulBuilder`), not reactively — this pre-existing behavior is unchanged.
- `ConstrainedBox` maxWidth of 560 may make dialogs narrower than the screen on very wide viewports. This is intentional for readability but worth confirming visually.

### Notes
- `LayoutBuilder` inside `AlertDialog.content` receives the dialog's internal available size constraints, not raw screen size. The 80% cap is applied relative to the dialog's allocated area, which itself is already inset by Material's default `insetPadding` (now overridden to `horizontal: 16, vertical: 12`). Effective maximum dialog height ≈ `screen height - 24px`; content height ≈ `(screen height - 24) * 0.8`.
- The `ListView.builder` in the import results dialog requires `shrinkWrap: true` because it lives inside `SingleChildScrollView` (unbounded height context). `NeverScrollableScrollPhysics` delegates scrolling to the outer `SingleChildScrollView`.
- `maxWidth: 560` is applied as a maximum, not a fixed width. On narrow screens (<560px), the dialog will use the full available width minus `insetPadding`.

---

## Task 4 — [P2] Make weekly_entry_screen.dart keyboard-inset aware and remove static bottom spacer

**File:** `lib/ui/screens/weekly_entry_screen.dart`
**Status:** Complete

### What changed
- Added `import 'dart:math' show max;`.
- In `build()`, added three variables after existing breakpoint variables:
  - `keyboardInset = MediaQuery.viewInsetsOf(context).bottom`
  - `bottomPadding = max(16.0, keyboardInset + 16.0)`
  - `verticalPadding = 16.0 + bottomPadding`
- `SingleChildScrollView` padding changed from `EdgeInsets.symmetric(horizontal, vertical: 16)` to `EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, bottomPadding)`.
- `ConstrainedBox` minHeight changed from `constraints.maxHeight - 32` to `constraints.maxHeight - verticalPadding` (stays correct when bottom padding grows with keyboard).
- Removed `SizedBox(height: isDesktop ? 80.0 : 40.0)` (the fixed terminal spacer) from the bottom of the form column.
- Added `scrollPadding: EdgeInsets.only(bottom: 24 + MediaQuery.viewInsetsOf(context).bottom)` to both `_buildIntegerField` and `_buildDecimalField` helpers.

### Regression risk: Low
- When keyboard is closed, `keyboardInset = 0`, so `bottomPadding = max(16, 16) = 16` and `verticalPadding = 32` — identical to the old hardcoded `- 32` and `vertical: 16.0`.
- When keyboard is open, the scroll view gains extra bottom padding equal to keyboard height, preventing any field from being obscured.
- Removing the `80/40` spacer is safe because its role is fully replaced by the dynamic `bottomPadding`.

### Notes
- `isDesktop` variable is still referenced (`horizontalPadding = isDesktop ? 32.0 : 16.0`) — no dead variable warning.
- `scrollPadding` applies to all 9 `TextFormField` instances (5 integer + 4 decimal fields) through the two shared helpers. Any future fields added via these helpers will inherit the behavior automatically.
- `resizeToAvoidBottomInset` defaults to `true` on `Scaffold`, so on Android the scaffold body already shrinks when keyboard appears. The `viewInsets`-driven bottom padding provides an additional safety margin and ensures the save button remains accessible even on devices or platforms where resize behavior differs.

---

## Task 3 — [P1] Implement >=840 responsive two-column reports layout for Web

**File:** `lib/ui/screens/reports_screen.dart`
**Status:** Complete

### What changed
- Introduced a `width >= 840` branch inside the existing `LayoutBuilder` (from Task 1) to switch card layout.
- `>=840`: all three report cards (`_buildExportLocationCard`, `_buildReportBuilderCard`, `_buildCsvOptionsCard`) are wrapped in `Wrap(spacing: 12, runSpacing: 12)`, each inside `SizedBox(width: (width - 44) / 2)`.
  - `44 = 32 (scroll view horizontal padding) + 12 (wrap gap)` — cards fill the content area exactly with no overflow.
- `<840`: original single-column stacking preserved verbatim from Task 1.
- Action button `Wrap` groups (export, backup) are unaffected and remain below the card section at all breakpoints.

### Regression risk: Medium
- `<840` branch is structurally identical to Task 1 — no regression risk at narrow/medium widths.
- `>=840` branch is additive only; existing card builder methods are called unchanged.
- With 3 cards in a two-column `Wrap`, the third card always occupies the first slot of the second row alone — expected `Wrap` behavior, but worth confirming visually against design intent.

### Notes
- Card width formula: `(constraints.maxWidth - 44) / 2`. At exactly `width = 840` each card is `398px`; at `1280` each is `618px`.
- If a fourth card is added in future, it will pair naturally with the third card in the second row — no code change needed.
- The `>=840` threshold is consistent with the Unified Breakpoint Strategy and matches the `spacing` variable breakpoint already present.

---

## Task 2 — [P1] Add medium-breakpoint app bar overflow strategy in dashboard_screen.dart

**File:** `lib/ui/screens/dashboard_screen.dart`
**Status:** Complete

### What changed
- Replaced single `isCompactLayout = width < 600` flag with three named breakpoint variables:
  - `isNarrow = width < 600`
  - `isMedium = width >= 600 && width < 840`
  - `isWide = width >= 840`
- `isWide` block: all inline controls visible (`dashboard_customize`, `ChurchSelectorWidget`, `ProfileSwitcherWidget`, `analytics_outlined`).
- `isMedium` block: no inline content controls; only `_buildSettingsMenu()` + `_buildOverflowMenu()` + refresh remain.
- `isNarrow` block: identical to previous `isCompactLayout = true` path — `_buildOverflowMenu()` shown, no inline controls.
- `_buildOverflowMenu()` already contained `customize`, `reports`, `church`, and `profile` entries, so no new overflow items were needed for medium coverage.

### Regression risk: Low
- `isNarrow` path is structurally identical to the old `isCompactLayout = true` path — no behavior change at narrow widths.
- `isWide` path is structurally identical to the old `isCompactLayout = false` path — no behavior change at wide widths.
- The only new behavior is at `600–839`, which previously had no dedicated handling.

### Notes
- The three breakpoint variables (`isNarrow`, `isMedium`, `isWide`) are declared in `build()` but `isNarrow` is used only in the `if (isNarrow || isMedium)` expression. If future tasks add medium-specific body layout branching to this screen, the variables are already in place.
- `_buildSettingsMenu()` (settings icon) always appears at all breakpoints, which is correct — settings should never be hidden.
- At exactly `width == 600` and `width == 840`, boundary conditions resolve as: 600 → `isMedium`, 840 → `isWide`. Consistent with the Unified Breakpoint Strategy.

---

## Task 7 — [P2] Replace fixed 300px chart heights with responsive containers and wrapped legends

**Files:**
- `lib/ui/screens/financial_charts_screen.dart`
- `lib/ui/screens/correlation_charts_screen.dart`
- `lib/ui/screens/advanced_charts_screen.dart`

**Status:** Complete

### What changed

**SizedBox(height: 300) replacements (11 total):**
- `financial_charts_screen.dart`: 4 occurrences — Tithe vs Offerings (LineChart), Income Breakdown (BarChart), Income Distribution (PieChart), Total Income vs Attendance (LineChart).
- `correlation_charts_screen.dart`: 3 occurrences — Attendance vs Income Dual-Axis (LineChart), Attendance vs Income Scatter Plot (ScatterChart), Groups vs Funds Correlation (LineChart).
- `advanced_charts_screen.dart`: 4 occurrences — Attendance Forecast Projection (LineChart), Attendance with Moving Average Overlay (LineChart), Attendance vs Funds Heatmap (custom Column grid), Attendance with Outlier Detection (LineChart).

All replaced with `ResponsiveChartContainer(minHeight: <breakpoint-driven>, maxHeight: 420, aspectRatio: 16/10, enableInteractive: false, child: <chart>)`. The `minHeight` is computed inline via `MediaQuery.sizeOf(context).width`:
- `< 480` -> `200.0`
- `480-839` -> `220.0`
- `>= 840` -> `260.0`

**Legend Row -> Wrap replacements (7 total):**
- `financial_charts_screen.dart`: 2 Rows -> Wrap. (Income Breakdown and Income Distribution legends were already Wrap -- left unchanged.)
- `correlation_charts_screen.dart`: 2 Rows -> Wrap.
- `advanced_charts_screen.dart`: 3 Rows -> Wrap.

All Wrap parameters: `spacing: 12, runSpacing: 8, alignment: WrapAlignment.center`. `SizedBox(width: 24)` spacers removed (handled by `Wrap.spacing`).

**Not changed:**
- `_buildHeatmapLegend()` Row in `advanced_charts_screen.dart` -- custom color-gradient key legend, not a `_buildLegendItem`-based legend. Not in scope.

### Regression risk: Medium
- `ResponsiveChartContainer` clamps height and applies a 0.85 scale factor below 600px width.
- Heatmap grid (`_buildHeatmapGrid`) uses `Expanded` children -- previously constrained by `SizedBox(height: 300)`, now by `ResponsiveChartContainer`'s internal sizing. Functionally equivalent.

### Notes
- `flutter analyze` on all 3 files: No issues found.
- `ResponsiveChartContainer` already available via `widgets.dart` -- no import changes required.
- `aspectRatio: 16/10` (1.6) chosen per spec.

---

## Task 8 -- [P3] Add responsive selector stacking in custom_graph_builder_screen.dart for medium widths

**File:** `lib/ui/screens/custom_graph_builder_screen.dart`
**Status:** Complete

### What changed
- Wrapped the metric selectors `Row` (lines ~200-217) in a `LayoutBuilder`.
- `constraints.maxWidth < 840`: renders a `Column(crossAxisAlignment: stretch)` with `_buildMetricSelector('X-Axis Metric', ...)`, `SizedBox(height: 12)`, `_buildMetricSelector('Y-Axis Metric', ...)`.
- `constraints.maxWidth >= 840`: renders the original `Row` with two `Expanded` children and `SizedBox(width: 16)` spacer.
- Chart type selector and TimeRangeSelector above/below are unchanged.

### Regression risk: Low
- `>=840` path is structurally identical to the original -- no behavior or visual change at wide widths.
- `<840` path stacks selectors vertically with `crossAxisAlignment: stretch` so both dropdowns fill available width, consistent with full-width Column layout.

### Notes
- `flutter analyze`: No issues found.
- `LayoutBuilder` constraints reflect the Container's inner width (inside `padding: all(16)`), so at exactly 840px screen width the effective constraint is 808px -- correctly triggers the Column path. The switch to Row occurs when the container content area reaches 840px (screen ~872px), which is acceptable and consistent with the Unified Breakpoint Strategy.

---

## Task 9 -- [P3] Make graph_center_screen.dart grid aspect ratios adaptive by breakpoint

**File:** `lib/ui/screens/graph_center_screen.dart`
**Status:** Complete

### What changed
- **`crossAxisCount` boundary corrected**: was `constraints.maxWidth > 600` (strictly greater), changed to `>= 600` so exactly 600px correctly yields 2 columns as specified.
- **Breakpoint-driven `childAspectRatio`** (was static `1.5`):
  - `< 600` -> `1.25`
  - `600-839` -> `1.2`
  - `>= 840` -> `1.35`
- **Title `Text`**: added `maxLines: 2, overflow: TextOverflow.ellipsis` (was missing). Description already had these -- left unchanged.
- `width` local variable extracted from `constraints.maxWidth` to avoid repeating the expression.

### Regression risk: Low
- `crossAxisCount` boundary fix is a 1px correction (`>600` to `>=600`); no visible change except at exactly 600px.
- `childAspectRatio` values are all lower than the original 1.5, meaning cards are taller -- more vertical space for content, less likely to clip.
- `maxLines: 2` on title is a safeguard; existing titles are all short single-line strings so no visual change under normal conditions.

### Notes
- `flutter analyze`: No issues found.
- The chart description field already had `maxLines: 2, overflow: TextOverflow.ellipsis` from before this task -- confirmed and left intact.
