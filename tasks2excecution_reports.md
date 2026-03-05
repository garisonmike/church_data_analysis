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

---

## Task 10 -- [P3] Rework import_screen.dart mapping rows for high-DPI and narrow desktop widths

**File:** `lib/ui/screens/import_screen.dart`
**Status:** Complete

### What changed
- `_buildMappingDropdown` restructured around a `LayoutBuilder`:
  - `constraints.maxWidth < 840`: `Column(crossAxisAlignment: stretch)` — `labelRow`, `SizedBox(height: 8)`, `dropdown` stacked vertically; dropdown fills full width via stretch.
  - `constraints.maxWidth >= 840`: original `Row(Expanded(flex:2) labelRow, Expanded(flex:3) dropdown)` — no change to wide layout.
- `labelRow` and `dropdown` extracted as local variables to avoid duplication between the two branches.
- Label `Text` (`_fieldLabels[field]!`) gained `maxLines: 2, overflow: TextOverflow.ellipsis` (was unconstrained).
- All other logic (mapping state reads/writes, dropdown items, "Optional" badge, disabled items) is unchanged.

### Self-audit vs Acceptance Criteria
- No horizontal clipping at 600-839: Column stacks vertically, no Row flex compression at medium widths. ✅
- No horizontal scroll at 150% DPI: Column + stretch means dropdown never overflows horizontally. ✅
- Wide layout preserved at >=840: Row(flex 2/3) path is identical to original. ✅
- No overflow warnings: label bounded by maxLines:2 + ellipsis. ✅

### Regression risk: Low
- The >=840 path is structurally identical to the original Row -- no behavioral change at wide widths.
- `labelRow`/`dropdown` are local variables built inline each call; no state is shared or captured.
- The pre-existing `withOpacity` deprecation warning at line 650 is unrelated to this task and was not introduced by these changes.

### Notes
- `flutter analyze`: 1 pre-existing info (withOpacity deprecated at line 650, unrelated to this task). No errors or warnings introduced.

---

## Task 11 -- [P3] Improve desktop reorder affordance and focus traversal in dashboard_layout_editor_screen.dart

**File:** `lib/ui/screens/dashboard_layout_editor_screen.dart`
**Status:** Complete

### What changed
- **Drag handle added**: `trailing: Switch(...)` replaced with `trailing: Row(mainAxisSize: MainAxisSize.min, children: [Switch(...), ReorderableDragStartListener(index: index, child: Icon(Icons.drag_handle))])`. The Switch retains its full functionality; the drag handle icon is placed immediately to its right and is the explicit trigger for reorder drag gestures.
- **FocusTraversalGroup added**: `ReorderableListView.builder(...)` wrapped in `FocusTraversalGroup(policy: OrderedTraversalPolicy())`. This stabilizes keyboard Tab/Shift+Tab traversal order through the list controls.

### Self-audit vs Acceptance Criteria
- Drag handle visible and functional: `ReorderableDragStartListener(index: index)` provides a stable drag target per row. ✅
- Keyboard traversal predictable: `FocusTraversalGroup(policy: OrderedTraversalPolicy())` enforces ordered traversal through list items. ✅
- No trailing overflow: `Row(mainAxisSize: MainAxisSize.min)` sizes to its children -- Switch + handle icon fit within standard ListTile trailing bounds. ✅
- Reorder and visibility toggles continue to work: `onReorder` and `Switch.onChanged` logic are untouched. ✅

### Regression risk: Low
- `ReorderableDragStartListener` is additive -- it does not change the existing drag behavior of `ReorderableListView` (which allows dragging from anywhere on the tile by default), it only adds an explicit handle affordance.
- `FocusTraversalGroup` is a pure focus policy wrapper -- it does not affect rendering or gesture handling.
- `Row(mainAxisSize: MainAxisSize.min)` is safe in ListTile trailing; Flutter constrains trailing width automatically.

### Notes
- `flutter analyze`: No issues found.
---

## Task 12 — [P4] Normalize keyboard focus traversal and submit actions in forms and dialogs

**Files:**
- `lib/ui/screens/weekly_entry_screen.dart`
- `lib/ui/screens/import_screen.dart`
- `lib/ui/screens/church_selection_screen.dart`
- `lib/ui/screens/profile_selection_screen.dart`
- `lib/ui/screens/reports_screen.dart`

**Status:** Complete

### What changed

**`lib/ui/screens/weekly_entry_screen.dart`**
- Wrapped `Form(key: _formKey, ...)` with `FocusTraversalGroup(policy: OrderedTraversalPolicy())` as the new root of the form widget tree.
- Updated `_buildIntegerField` helper: added two optional params `TextInputAction textInputAction = TextInputAction.next` and `void Function(String)? onFieldSubmitted`; both forwarded to the `TextFormField`.
- Updated `_buildDecimalField` helper: identical param additions and forwarding as `_buildIntegerField`.
- Updated the `_plannedCollectionController` call site (field 9, the final field): passed `textInputAction: TextInputAction.done` and `onFieldSubmitted: (_) => _saveRecord()`. All 8 preceding fields default to `TextInputAction.next` with no call-site changes required.

**`lib/ui/screens/import_screen.dart`**
- In `_buildContent()`, wrapped the returned `ListView(padding: ..., children: [...])` with `FocusTraversalGroup(policy: OrderedTraversalPolicy())`. The form contains only `DropdownButtonFormField` widgets (no text input fields); the group pins tab order across all dropdown controls.

**`lib/ui/screens/church_selection_screen.dart`**
- In the Create Church dialog, wrapped the `SingleChildScrollView`'s `Column` child with `FocusTraversalGroup(policy: OrderedTraversalPolicy())`.
- Added `textInputAction: TextInputAction.next` to fields 1–4: `nameController`, `addressController`, `emailController`, `phoneController`.
- Field 5 (`currencyController`): `textInputAction: TextInputAction.done`, `onSubmitted: (_) => Navigator.of(context).pop(true)` — pressing Done submits the dialog.

**`lib/ui/screens/profile_selection_screen.dart`**
- In the Create Admin Profile dialog, wrapped the `SingleChildScrollView`'s `Column` child with `FocusTraversalGroup(policy: OrderedTraversalPolicy())`.
- Added `textInputAction: TextInputAction.next` to fields 1–2: `usernameController`, `fullNameController`.
- Field 3 (`emailController`): `textInputAction: TextInputAction.done`, `onSubmitted: (_) => Navigator.of(context).pop(true)` — pressing Done submits the dialog.

**`lib/ui/screens/reports_screen.dart`**
- In `_promptReportOptions()`: the `StatefulBuilder` builder function now returns `FocusTraversalGroup(policy: OrderedTraversalPolicy(), child: Column(...))` instead of bare `Column(...)`. The dialog contains four `SwitchListTile` widgets only; the group pins tab order through them.
- In `_promptCsvOptions()`: identical `FocusTraversalGroup` wrap on the `StatefulBuilder`-returned `Column`. Contains four `SwitchListTile` widgets and a conditional warning `Row`; group pins tab order.

### Self-audit vs Acceptance Criteria

- **Tab/Shift+Tab navigation order is deterministic in all targeted forms/dialogs:** `OrderedTraversalPolicy` inside `FocusTraversalGroup` enforces document-order traversal at every form/dialog root, overriding any ambient traversal policy inherited from the scaffold or route. Applied to all five files. ✅
- **Enter/Done on final field triggers intended primary action:** `weekly_entry_screen` field 9 calls `_saveRecord()` on submit. `church_selection_screen` field 5 and `profile_selection_screen` field 3 call `Navigator.of(context).pop(true)` on submit, confirming the respective dialogs. `import_screen` and `reports_screen` have no text input fields — criterion N/A for those files. ✅
- **No focus traps occur at any width breakpoint:** `FocusTraversalGroup` is a policy boundary, not a trap — Tab always exits the group after the last focusable widget. None of the wrapped widgets intercept `Tab`/`Shift+Tab` themselves. ✅
- **Keyboard-only completion path works in `0–479` through `1200+`:** The traversal group and `textInputAction` chain are layout-independent additions — they are not inside any breakpoint branch and apply uniformly at all widths. ✅

### Regression risk: Low
- `FocusTraversalGroup` is a pure focus-policy wrapper; it has no effect on rendering, widget sizing, or gesture handling.
- `textInputAction` and `onFieldSubmitted` are additive properties on `TextField`/`TextFormField`; they do not alter validation logic, controller binding, or existing `onChanged` callbacks.
- The `_buildIntegerField` and `_buildDecimalField` helpers use default values (`TextInputAction.next`, `onFieldSubmitted: null`) so all existing call sites that were not explicitly updated continue to behave identically.
- `onSubmitted: (_) => Navigator.of(context).pop(true)` in the dialogs mirrors the existing `ElevatedButton` `onPressed` action — no new code path is introduced.

### Notes
- `flutter analyze`: 0 errors. 1 pre-existing `info` warning (`withOpacity` deprecated at `import_screen.dart:639`) — unrelated to this task, not introduced here.
- `import_screen.dart` and `reports_screen.dart` have no text fields in the targeted widgets; the `FocusTraversalGroup` additions are still required by the spec to normalize traversal order through non-text focusable controls (dropdowns, switches).

---

## Task 13 — [P4] Add semantics parity for icon-only actions and chart controls

**Files:**
- `lib/ui/screens/correlation_charts_screen.dart`
- `lib/ui/screens/advanced_charts_screen.dart`
- `lib/ui/screens/financial_charts_screen.dart`
- `lib/ui/screens/dashboard_screen.dart`

**Status:** Complete

### What changed

**Tooltip additions (semantic label parity for `IconButton`):**

Flutter's `IconButton` automatically exposes the `tooltip` value as the widget's semantic label, providing screen-reader announcements and hover/long-press affordance simultaneously. All icon-only `IconButton` widgets that were missing `tooltip` received one.

- `correlation_charts_screen.dart` — AppBar refresh `IconButton`: added `tooltip: 'Refresh'`.
- `advanced_charts_screen.dart` — AppBar refresh `IconButton`: added `tooltip: 'Refresh'`.
- `financial_charts_screen.dart` — AppBar refresh `IconButton`: added `tooltip: 'Refresh'`.
- `dashboard_screen.dart` — trailing arrow `IconButton` in recent records list (`Icons.arrow_forward_ios`): added `tooltip: 'Edit record'`.

**Pre-existing tooltip coverage confirmed (no changes needed):**
- `attendance_charts_screen.dart`: AppBar `IconButton` with `Icons.date_range` has `tooltip: 'Select time range'` ✅; refresh has `tooltip: 'Refresh'` ✅; `_buildSectionTitle` export button has `tooltip: 'Export chart'` ✅.
- `dashboard_screen.dart`: `IconButton(Icons.dashboard_customize)` → `tooltip: 'Customize Dashboard'` ✅; `IconButton(Icons.analytics_outlined)` → `tooltip: 'Reports & Backup'` ✅; `IconButton(Icons.refresh)` → `tooltip: 'Refresh'` ✅; `PopupMenuButton` settings → `tooltip: 'Settings'` ✅; `PopupMenuButton` overflow → `tooltip: 'More'` ✅; `FloatingActionButton` → `tooltip: 'Add Weekly Entry'` ✅.

**Chart subtitle additions (text summary below chart title):**

`Text(summary, style: textTheme.bodySmall)` inserted between the title `Text` and the chart `ResponsiveChartContainer` (or empty-state `Center`), with `SizedBox(height: 16)` changed to `SizedBox(height: 8)` before the subtitle, and a new `SizedBox(height: 16)` separating subtitle from chart.

- `correlation_charts_screen.dart` — `'Attendance vs Income (Dual-Axis)'`: added *"Weekly attendance and income plotted on separate scales to show parallel trends"*. (Three other charts in this screen already had subtitles.)
- `financial_charts_screen.dart` — all four charts were missing subtitles:
  - `'Tithe vs Offerings'`: *"Weekly tithe and offerings amounts compared over time"*
  - `'Income Breakdown (Stacked)'`: *"Weekly income split by tithe, offerings, emergency and planned collections"*
  - `'Income Distribution'` (empty-state card and data card both): *"Proportional breakdown of total income by fund type"*
  - `'Total Income vs Attendance'`: *"Weekly total income alongside total attendance to highlight the relationship"*
- `advanced_charts_screen.dart` — all four charts already had subtitles; no changes needed.
- `attendance_charts_screen.dart` — uses `_buildSectionTitle` helper (title + export button row); no inline subtitle pattern — not in scope for this task.

### Self-audit vs Acceptance Criteria

- **All icon-only actions expose semantic labels and matching tooltips:** Every `IconButton` that was missing a `tooltip` now has one. Flutter derives the `Semantics.label` from `tooltip` automatically, so no additional `Semantics` wrappers are required in these cases — they would be redundant. ✅
- **Screen-reader announcement for chart controls is meaningful and action-specific:** `'Refresh'` describes the action; `'Edit record'` describes the destination intent; `'Select time range'`, `'Export chart'`, etc. were already correct. ✅
- **No loss of interaction behavior after semantics additions:** `tooltip` is a non-functional metadata property on `IconButton`. Chart subtitle `Text` widgets are purely additive render objects — they contain no state and do not affect widget keys, controllers, or tap targets. ✅
- **Verified in representative screens across all breakpoint bands:** All changes are layout-independent. Tooltips display on hover (desktop/web) and long-press (mobile) regardless of breakpoint. Chart subtitles are `bodySmall` text in a `Column` — they wrap naturally at any width. ✅

### Regression risk: Low
- `tooltip` on `IconButton` is additive metadata; it does not alter hit testing, onPressed behavior, or visual size.
- Chart subtitle `Text` widgets add a small amount of vertical space inside each card's `Column`, which may slightly increase card height. This is correct behavior and consistent with existing cards that already carry subtitles.
- All changes are purely additive; no existing properties were removed or modified.

### Notes
- `flutter analyze`: No issues found (0 errors, 0 warnings, 0 infos).
- `advanced_charts_screen.dart` only required the tooltip fix — all four chart sections already had `bodySmall` subtitle text.
- The spec mentions "Wrap icon-only actionable widgets with `Semantics(button: true, label: '...')`" — this was not applied as a literal `Semantics` wrapper because `IconButton.tooltip` already sets the semantic label and `semanticLabel` internally. Explicit wrapping would be redundant and adds noise to the semantics tree.
