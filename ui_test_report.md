# UI Test Report

## Platform: Android
### Screen: reports_screen.dart
- Issue: Primary content uses a centered `Column` without scroll; cards + action buttons overflow on short-height devices and landscape.
- Severity: High
- Reproduction: Android 11 phone, landscape (or split-screen), open Reports & Backup; observe bottom actions clipped / inaccessible.
- Root Cause: `Scaffold.body` is `Center > Padding > Column` with fixed vertical spacers and no `SingleChildScrollView`.
- Suggested Fix: Wrap body in `SafeArea` + `SingleChildScrollView`, align content top-start, and keep action group in responsive `Wrap`.

### Screen: weekly_entry_screen.dart
- Issue: Keyboard can still occlude lower fields and save action despite extra bottom spacer.
- Severity: Medium
- Reproduction: Small Android device, focus last financial fields with keyboard open; scroll jitter and reduced usable space appear.
- Root Cause: Static bottom spacer (`40/80`) instead of reacting to `MediaQuery.viewInsets.bottom`; no dedicated keyboard-aware inset handling.
- Suggested Fix: Add keyboard-aware bottom padding using `viewInsets.bottom` and optional `scrollPadding` per input.

### Screen: attendance_charts_screen.dart
- Issue: AppBar action area risks horizontal compression with compact time-range chips + refresh icon.
- Severity: Medium
- Reproduction: Narrow Android width (~320dp), long localization strings in time-range labels, open Attendance Charts.
- Root Cause: `ConstrainedBox(maxWidth: 400)` in app bar actions still over-consumes width on very small screens.
- Suggested Fix: Collapse time-range selector into popup/menu at small widths; keep app bar actions minimal.

### Screen: import_screen.dart
- Issue: Validation result dialog can exceed viewport when many errors are listed.
- Severity: Medium
- Reproduction: Import file with many invalid rows; open "Import Complete" dialog.
- Root Cause: Error list rendered as `Column` entries inside dialog with only partial capping; dialog itself has no max-height strategy.
- Suggested Fix: Apply explicit dialog constraints and make full dialog content scrollable with bounded height.

### Screen: church_selection_screen.dart / profile_selection_screen.dart
- Issue: Create dialogs rely on dense vertical text fields; usability degrades on small-height devices.
- Severity: Medium
- Reproduction: Android landscape, trigger create church/profile dialogs.
- Root Cause: Dialogs use simple field stacks, no adaptive stepper/section compaction, limited spacing strategy for low-height screens.
- Suggested Fix: Reduce vertical chrome in compact mode and use constrained + scrollable dialog body.

## Platform: Linux
### Screen: dashboard_screen.dart
- Issue: Top app bar widgets (church/profile switchers + actions) can crowd and truncate with long names.
- Severity: High
- Reproduction: Resize Linux window near compact threshold (600–780px), use long church/profile names.
- Root Cause: Mixed inline action widgets in app bar with content-driven width and no overflow fallback except compact mode.
- Suggested Fix: Introduce intermediate breakpoint to move switchers into overflow menu before hard compact mode.

### Screen: custom_graph_builder_screen.dart
- Issue: Control panel uses fixed two-column metric selector row, causing cramped dropdowns on medium desktop widths.
- Severity: Medium
- Reproduction: Linux window width 700–850px; open Custom Graph Builder.
- Root Cause: Static `Row` with two `Expanded` dropdowns and fixed gap; no wrap-to-column behavior.
- Suggested Fix: Switch to `LayoutBuilder` breakpoint: stacked selectors under medium width.

### Screen: graph_center_screen.dart
- Issue: Grid cards use fixed `childAspectRatio: 1.5`, causing content crowding at non-ideal desktop sizes/high text scale.
- Severity: Medium
- Reproduction: Linux resized to narrow desktop + increased font scale.
- Root Cause: Static card aspect ratio and fixed icon/title stack density.
- Suggested Fix: Make aspect ratio adaptive and allow card min-height growth with text scale.

### Screen: dashboard_layout_editor_screen.dart
- Issue: Reorder list lacks explicit desktop drag affordance and keyboard reorder pathway.
- Severity: Low
- Reproduction: Linux desktop, keyboard-only navigation in layout editor.
- Root Cause: `ReorderableListView` default behavior without desktop-focused handles/semantics.
- Suggested Fix: Add explicit drag handles and keyboard action hints.

## Platform: Windows
### Screen: reports_screen.dart
- Issue: Window height reduction creates bottom overflow and inaccessible backup actions.
- Severity: High
- Reproduction: Windows desktop, resize height to ~550px, open Reports & Backup.
- Root Cause: Non-scrolling fixed-spacer `Column`.
- Suggested Fix: Use `CustomScrollView`/`SingleChildScrollView` with responsive section spacing.

### Screen: financial_charts_screen.dart / correlation_charts_screen.dart / advanced_charts_screen.dart
- Issue: Multiple charts use fixed `SizedBox(height: 300)` and side legends that compress content under narrow windows.
- Severity: Medium
- Reproduction: Resize Windows window narrow; chart labels/legends clip or collide.
- Root Cause: Hard-coded chart heights and row-based legends with limited adaptive behavior.
- Suggested Fix: Use adaptive chart heights + legend wrapping/stacking by width breakpoint.

### Screen: import_screen.dart
- Issue: Mapping rows (`Expanded` + label + optional badge + dropdown) become cramped and visually unstable with high DPI/text scaling.
- Severity: Medium
- Reproduction: Windows 150–200% scaling, open import mapping step.
- Root Cause: Tight `Row` composition with fixed flex assumptions and long labels.
- Suggested Fix: Switch mapping rows to vertical layout below a width threshold and cap label line count.

### Screen: not_found_screen.dart
- Issue: Non-scrolling centered column can overflow in tiny resized windows.
- Severity: Low
- Reproduction: Resize Windows app to very short height and navigate to unknown route.
- Root Cause: Fixed center `Column` with no scroll fallback.
- Suggested Fix: Wrap content in `SingleChildScrollView` + `SafeArea`.

## Platform: Web
### Screen: reports_screen.dart
- Issue: Web still presents mobile-like stacked action column; poor horizontal space utilization and potential vertical overflow.
- Severity: High
- Reproduction: Chrome with short viewport height, open Reports & Backup.
- Root Cause: No web/desktop-specific layout branch for action groups.
- Suggested Fix: Use responsive two-column card/action layout on wide web viewports.

### Screen: attendance_charts_screen.dart
- Issue: Desktop web hover/keyboard semantics are minimal for export and filter controls.
- Severity: Medium
- Reproduction: Navigate via keyboard only; inspect focus order and discoverability for chart export controls.
- Root Cause: No explicit focus traversal groups or enhanced desktop/web interaction hints.
- Suggested Fix: Add focus order tuning and tooltip/semantic labels for chart actions.

### Screen: responsive_chart_container.dart usage across chart screens
- Issue: `InteractiveViewer(constrained: false)` can create unexpected pan/zoom behavior and oversized paint areas on web.
- Severity: Medium
- Reproduction: Chrome, zoom/pan charts repeatedly on narrow viewport.
- Root Cause: Unconstrained interactive child inside fixed-height container.
- Suggested Fix: Keep interaction opt-in per chart type and constrain pan bounds for web.

### Screen: import_screen.dart
- Issue: DataTable preview uses horizontal scroll only; high column counts still degrade usability on web.
- Severity: Low
- Reproduction: Import wide CSV (many columns), inspect mapping preview.
- Root Cause: Single-axis scroll strategy and no column-priority truncation.
- Suggested Fix: Add compact preview mode with prioritized columns and expandable details.

## Cross-Platform Issues
- `reports_screen.dart`: Critical non-scroll body layout; highest overflow risk across Android/Desktop/Web.
- Dialog consistency: Multiple `AlertDialog` forms (church/profile/report options) use dense vertical content and are not uniformly constrained for very short viewports.
- Safe area inconsistency: Several screens rely on default Scaffold insets only; explicit `SafeArea` is used in some bottom sheets but not consistently across top-level forms.
- Hardcoded dimensions: Widespread fixed chart heights (`300`) and static spacers (`24/32/80`) reduce resilience to resize/orientation changes.
- Breakpoint strategy fragmentation: Different screens use different implicit thresholds (e.g., 600 only), causing alignment and behavior shifts between similar layouts.
- Focus traversal gaps: No explicit traversal groups for complex forms/dialogs; keyboard-first desktop flows are inconsistent.
- Nested scroll complexity: Import/preview/error surfaces contain nested scrollables that can produce awkward wheel/trackpad behavior.

## Accessibility Issues
- Tap target consistency: Some action chips/buttons in dense rows risk borderline target size on mobile.
- Contrast risks: Use of light warning/success containers with tinted text may fail contrast in certain themes.
- Keyboard accessibility: Dialog forms rely on pointer flow; no strong submit-next field progression or focus order control.
- Screen reader semantics: Chart visuals and icon-only actions need clearer semantic labels and summaries.
- Text scaling robustness: Fixed chart cards and rigid row compositions degrade with large font scales.

## Performance & Rendering Risks
- Chart-heavy screens stack multiple expensive FL Chart widgets; only partial lazy loading is applied.
- `LazyLoadChart` uses render-object visibility checks tied to scroll notifications, which can be brittle in nested scroll contexts.
- `InteractiveViewer` around chart content increases repaint/interactivity complexity and can impact smoothness on low-end GPUs.
- Frequent rebuild pressure in settings/forms/dialogs due to large composite widget trees without sectional memoization.

## Overall Stability Risk Score (1-10)
8
