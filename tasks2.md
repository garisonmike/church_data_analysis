# UI Stabilization Master Task List

## Agent Notes – Known Gaps / Guardrails
- These notes are intentionally informational only (do not rewrite existing tasks/issues unless explicitly requested).
- Known untracked UI gap from test report: `not_found_screen.dart` can overflow on tiny/short windows (low severity).
- Known untracked UX gap from test report: import preview `DataTable` with high column counts degrades on web (low severity).
- Accessibility follow-up not explicitly scoped in tasks: validate contrast for warning/success tinted containers in all themes.
- Dependency guardrail: execute Task 1 before Task 3 (same screen/layout foundation), and complete dialog/form structural tasks before Task 12 keyboard-flow normalization.
- Evidence guardrail for completion: attach breakpoint matrix checks + overflow-free debug console proof + platform screenshots/video for each completed task.

- [ ] Phase 1 – Critical Stability
- [ ] Phase 2 – Cross-Platform Layout Consistency
- [ ] Phase 3 – Desktop Optimization
- [ ] Phase 4 – Accessibility & Focus Improvements
- [ ] Phase 5 – Performance & Rendering Safety

## GitHub Issue Titles
- [ ] [P1] Stabilize reports_screen.dart body scrolling and overflow across Android/Windows/Web
- [ ] [P1] Add medium-breakpoint app bar overflow strategy in dashboard_screen.dart
- [ ] [P1] Implement >=840 responsive two-column reports layout for Web
- [ ] [P2] Make weekly_entry_screen.dart keyboard-inset aware and remove static bottom spacer
- [ ] [P2] Standardize dialog height constraints and scroll behavior across import/church/profile/reports dialogs
- [ ] [P2] Prevent AppBar action compression in attendance_charts_screen.dart using width breakpoints
- [ ] [P2] Replace fixed 300px chart heights with responsive containers and wrapped legends
- [ ] [P3] Add responsive selector stacking in custom_graph_builder_screen.dart for medium widths
- [ ] [P3] Make graph_center_screen.dart grid aspect ratios adaptive by breakpoint
- [ ] [P3] Rework import_screen.dart mapping rows for high-DPI and narrow desktop widths
- [ ] [P3] Improve desktop reorder affordance and focus traversal in dashboard_layout_editor_screen.dart
- [ ] [P4] Normalize keyboard focus traversal and submit actions in forms and dialogs
- [ ] [P4] Add semantics parity for icon-only actions and chart controls
- [ ] [P4] Enforce minimum tap targets and text-scale resilience in dense action UIs
- [ ] [P5] Constrain InteractiveViewer behavior for predictable web/desktop chart rendering
- [ ] [P5] Harden LazyLoadChart visibility checks for nested scroll safety
- [ ] [P5] Reduce rebuild pressure in large forms using const extraction and local state isolation

## Phase 1 – Critical Stability

- [x] Task 1
---
## [P1] Stabilize reports_screen.dart body scrolling and overflow across Android/Windows/Web

### Summary
`reports_screen.dart` overflows vertically because the primary content is a centered fixed-flow `Column` with large static spacing and no scroll container.

### Background
`Scaffold.body` is currently `Center > Padding > Column` with fixed vertical spacers and stacked actions, so short-height viewports and resized desktop windows clip bottom controls.

### Scope of Work
- File: `lib/ui/screens/reports_screen.dart`
- Replace body tree with:
  - `SafeArea`
    - `LayoutBuilder(builder: (context, constraints) => SingleChildScrollView(...))`
    - Inside scroll view: `ConstrainedBox(constraints: BoxConstraints(minHeight: constraints.maxHeight))`
    - Content root: `Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisAlignment: MainAxisAlignment.start)`
- Replace vertically stacked export/backup buttons with `Wrap(spacing: 12, runSpacing: 12)` for width resilience.
- Replace fixed large spacers (`30`, `20`) with breakpoint-based spacing:
  - `<480`: 8
  - `480–839`: 12
  - `>=840`: 16

### Platforms Affected
- Android
- Windows
- Web

### Acceptance Criteria
- No vertical overflow occurs at widths/heights in these ranges: `0–479`, `480–599`, `600–839`, `840–1199`, `1200+`.
- No `RenderFlex overflowed` warnings are emitted on this screen in debug console.
- Bottom action controls are reachable via scroll at all viewport heights.
- At `>=840`, spacing is visually consistent and no clipping occurs around action groups.

### Regression Risk
Medium — primary layout flow and action arrangement are being changed.

### Testing Instructions
1. Open Reports & Backup screen on Android emulator and Chrome.
2. Test widths: 360, 480, 600, 840, 1200 and short heights (landscape/split view).
3. On Windows/Linux desktop, resize window down to ~550px height and verify all controls remain accessible.
4. Confirm no overflow/debug warnings.

### Definition of Done
- Code implemented
- Tested on all listed platforms
- No overflow/debug warnings
- Responsive across defined breakpoints
- tasks2.md checkbox marked complete
---

- [x] Task 2
---
## [P1] Add medium-breakpoint app bar overflow strategy in dashboard_screen.dart

### Summary
`dashboard_screen.dart` app bar crowds and truncates when church/profile switchers and actions are all rendered inline at medium widths.

### Background
Action widgets are content-width-driven and only collapse at compact mode; no intermediate breakpoint exists for `600–839` where truncation risk is highest.

### Scope of Work
- File: `lib/ui/screens/dashboard_screen.dart`
- Keep existing compact menu path, but add intermediate breakpoint logic in `build`:
  - `isNarrow = width < 600`
  - `isMedium = width >= 600 && width < 840`
  - `isWide = width >= 840`
- For `isMedium`, move `ChurchSelectorWidget` and `ProfileSwitcherWidget` out of app bar action row into overflow menu entries only.
- Keep only `settings`, `more`, `refresh` as direct actions in `isMedium`.
- Add `Flexible` around title text only if still needed; do not add new components.

### Platforms Affected
- Linux
- Windows
- Web
- Android (tablet/landscape)

### Acceptance Criteria
- AppBar actions never truncate without overflow menu fallback at `600–839`.
- At `0–599`, compact behavior remains intact.
- At `840–1199` and `1200+`, wide behavior shows inline controls without clipping.
- No horizontal overflow or clipped text in app bar title/actions.

### Regression Risk
Low — behavior is limited to action placement logic at medium widths.

### Testing Instructions
1. Open Dashboard with long church/profile names.
2. Resize to widths 599, 600, 700, 839, 840, 1200.
3. Verify action relocation and menu entries across breakpoints.
4. Confirm all menu actions still navigate correctly.

### Definition of Done
- Code implemented
- Tested on all listed platforms
- No overflow/debug warnings
- Responsive across defined breakpoints
- tasks2.md checkbox marked complete
---

- [x] Task 3
---
## [P1] Implement >=840 responsive two-column reports layout for Web

### Summary
Web reports page remains mobile-stacked, causing poor horizontal usage and increased vertical overflow risk.

### Background
No web/desktop-specific branch exists for card/action arrangement in reports content.

### Scope of Work
- File: `lib/ui/screens/reports_screen.dart`
- In the same scrollable body refactor, wrap report cards in `LayoutBuilder` and branch:
  - `<840`: existing single-column flow
  - `>=840`: `Wrap` two-column card placement (`SizedBox(width: (maxWidth - 12) / 2)`)
- Keep action controls in `Wrap` so buttons naturally reflow.
- Preserve existing card content and theming.

### Platforms Affected
- Web
- Linux
- Windows

### Acceptance Criteria
- At `840–1199` and `1200+`, report cards render as stable two-column layout without clipping.
- At `0–839`, single-column layout remains intact with no overflow.
- No horizontal scrollbar appears solely due to reports card layout.
- No `RenderFlex`/pixel overflow warnings in debug console.

### Regression Risk
Medium — multi-column layout branch added for web/desktop widths.

### Testing Instructions
1. Open Reports screen in Chrome.
2. Test widths: 480, 600, 839, 840, 1024, 1280.
3. Verify card wrap behavior and action reflow.
4. Repeat on Linux/Windows desktop builds.

### Definition of Done
- Code implemented
- Tested on all listed platforms
- No overflow/debug warnings
- Responsive across defined breakpoints
- tasks2.md checkbox marked complete
---

## Phase 2 – Cross-Platform Layout Consistency

- [x] Task 4
---
## [P2] Make weekly_entry_screen.dart keyboard-inset aware and remove static bottom spacer

### Summary
Final inputs and save action can be obscured by keyboard despite static bottom spacing.

### Background
Screen uses fixed terminal spacer (`40/80`) rather than `viewInsets`-driven padding and per-field scroll padding.

### Scope of Work
- File: `lib/ui/screens/weekly_entry_screen.dart`
- In `SingleChildScrollView`, set bottom padding to `max(16, MediaQuery.viewInsetsOf(context).bottom + 16)`.
- Keep `ConstrainedBox(minHeight: constraints.maxHeight - verticalPadding)`.
- Set `scrollPadding: EdgeInsets.only(bottom: 24 + MediaQuery.viewInsetsOf(context).bottom)` on each `TextFormField`.
- Remove fixed terminal spacer `SizedBox(height: isDesktop ? 80 : 40)`.

### Platforms Affected
- Android
- Linux
- Windows
- Web

### Acceptance Criteria
- Keyboard does not obscure final input or save action at `0–479` and `480–599` widths.
- Form remains fully reachable via scroll at all breakpoint ranges.
- No bottom overflow warnings in portrait/landscape/split-screen.
- Save/update action remains visible or scroll-reachable when keyboard is open.

### Regression Risk
Low — targeted to keyboard/scroll padding only.

### Testing Instructions
1. Open Weekly Entry screen.
2. Focus last financial input fields at widths 360, 480, 600.
3. Verify keyboard open state does not hide active field/save action.
4. Repeat with desktop virtual keyboard scenarios where applicable.

### Definition of Done
- Code implemented
- Tested on all listed platforms
- No overflow/debug warnings
- Responsive across defined breakpoints
- tasks2.md checkbox marked complete
---

- [x] Task 5
---
## [P2] Standardize dialog height constraints and scroll behavior across import/church/profile/reports dialogs

### Summary
Multiple dialogs can exceed viewport height and produce clipped content on short screens.

### Background
Dialog implementations are inconsistent; some use unbounded vertical content with limited or no max-height constraints.

### Scope of Work
- Files:
  - `lib/ui/screens/import_screen.dart`
  - `lib/ui/screens/church_selection_screen.dart`
  - `lib/ui/screens/profile_selection_screen.dart`
  - `lib/ui/screens/reports_screen.dart`
- Standardize dialog content wrapper to:
  - `LayoutBuilder` -> `ConstrainedBox(maxHeight: constraints.maxHeight * 0.8, maxWidth: 560)`
  - Inner `SingleChildScrollView`
- For list dialogs, replace unbounded `Column` error lists with `ListView.builder(shrinkWrap: true, physics: NeverScrollableScrollPhysics())` inside bounded scroll region.
- Apply `insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)` for small screens.

### Platforms Affected
- Android
- Linux
- Windows
- Web

### Acceptance Criteria
- Dialog never exceeds 80% of viewport height across `0–479`, `480–599`, `600–839`, `840–1199`, `1200+`.
- All dialog content remains reachable through internal scrolling when content is long.
- No clipped action buttons in landscape or short-height windows.
- No overflow warnings triggered while opening/closing dialogs.

### Regression Risk
Medium — touches multiple dialogs and interaction paths.

### Testing Instructions
1. Open each targeted dialog (create profile/church, report options, import results with long errors).
2. Validate in narrow widths and short heights (including landscape).
3. Confirm all actions remain accessible and dialog dismiss/submit works.
4. Check debug console for overflow warnings.

### Definition of Done
- Code implemented
- Tested on all listed platforms
- No overflow/debug warnings
- Responsive across defined breakpoints
- tasks2.md checkbox marked complete
---

- [x] Task 6
---
## [P2] Prevent AppBar action compression in attendance_charts_screen.dart using width breakpoints

### Summary
AppBar action area compresses on narrow widths due to compact selector + refresh controls.

### Background
Current `ConstrainedBox(maxWidth: 400)` still over-allocates on very small screens and can crowd action layout.

### Scope of Work
- File: `lib/ui/screens/attendance_charts_screen.dart`
- In `AppBar.actions`, switch by width:
  - `<480`: replace `TimeRangeSelector(compact: true)` with a single `IconButton` opening popup menu for range options.
  - `480–839`: keep compact selector but cap width to `220`.
  - `>=840`: keep current `ConstrainedBox(maxWidth: 400)`.
- Keep refresh icon always visible.

### Platforms Affected
- Android
- Linux
- Windows
- Web

### Acceptance Criteria
- No app bar overflow at widths in `0–479`, `480–599`, `600–839`.
- Time range selection remains available in all breakpoints.
- Refresh remains visible and clickable at all widths.
- No debug overflow warnings from app bar action row.

### Regression Risk
Low — change is isolated to app bar action rendering.

### Testing Instructions
1. Open Attendance Charts.
2. Verify app bar actions at widths 360, 480, 700, 840, 1200.
3. Confirm time range can be changed and refresh works at each width.
4. Validate no clipping with long locale labels.

### Definition of Done
- Code implemented
- Tested on all listed platforms
- No overflow/debug warnings
- Responsive across defined breakpoints
- tasks2.md checkbox marked complete
---

- [x] Task 7
---
## [P2] Replace fixed 300px chart heights with responsive containers and wrapped legends

### Summary
Fixed chart heights and rigid legend rows cause clipping/collisions under narrow widths and high text scale.

### Background
Charts in multiple screens use `SizedBox(height: 300)` and `Row` legends, which do not adapt to viewport or DPI changes.

### Scope of Work
- Files:
  - `lib/ui/screens/financial_charts_screen.dart`
  - `lib/ui/screens/correlation_charts_screen.dart`
  - `lib/ui/screens/advanced_charts_screen.dart`
- Replace direct `SizedBox(height: 300)` chart containers with `ResponsiveChartContainer(minHeight: 220, maxHeight: 420, aspectRatio: 16/10, enableInteractive: false)`.
- Change rigid legend `Row` to `Wrap(spacing: 12, runSpacing: 8, alignment: WrapAlignment.center)`.
- Breakpoint rules:
  - `<480`: `minHeight 200`
  - `480–839`: `minHeight 220`
  - `>=840`: `minHeight 260`

### Platforms Affected
- Android
- Linux
- Windows
- Web

### Acceptance Criteria
- No legend overlap/collision at any width breakpoint.
- Charts remain readable without clipping at text scale 1.0 and 1.3.
- No horizontal scroll required for legends at 150% DPI scaling.
- No overflow warnings in chart sections.

### Regression Risk
Medium — chart container behavior and layout are changing.

### Testing Instructions
1. Open all three chart screens.
2. Resize through widths 360, 480, 700, 840, 1200.
3. Increase OS/browser scaling to 150% and verify legend wrapping.
4. Confirm no chart clipping/overflow warnings.

### Definition of Done
- Code implemented
- Tested on all listed platforms
- No overflow/debug warnings
- Responsive across defined breakpoints
- tasks2.md checkbox marked complete
---

## Phase 3 – Desktop Optimization

- [x] Task 8
---
## [P3] Add responsive selector stacking in custom_graph_builder_screen.dart for medium widths

### Summary
Two side-by-side metric selectors become cramped in medium desktop windows.

### Background
A fixed `Row` with two `Expanded` dropdowns and static spacing is used with no medium-width fallback.

### Scope of Work
- File: `lib/ui/screens/custom_graph_builder_screen.dart`
- Wrap selector row in `LayoutBuilder`:
  - `<840`: `Column` with first selector, `SizedBox(height: 12)`, second selector.
  - `>=840`: existing `Row` with two `Expanded` children.
- Keep chart type selector unchanged.

### Platforms Affected
- Linux
- Windows
- Web

### Acceptance Criteria
- No dropdown clipping/compression at `600–839`.
- Existing wide layout remains intact at `>=840`.
- No horizontal overflow warnings in control panel.
- Selector usability preserved with keyboard and pointer.

### Regression Risk
Low — local layout branch only.

### Testing Instructions
1. Open Custom Graph Builder.
2. Test widths 700, 839, 840, 1024.
3. Confirm stack behavior below 840 and row behavior at/above 840.
4. Verify metric selection still updates chart.

### Definition of Done
- Code implemented
- Tested on all listed platforms
- No overflow/debug warnings
- Responsive across defined breakpoints
- tasks2.md checkbox marked complete
---

- [x] Task 9
---
## [P3] Make graph_center_screen.dart grid aspect ratios adaptive by breakpoint

### Summary
Fixed card aspect ratio in chart grid causes content crowding at certain widths/text scales.

### Background
Current `childAspectRatio: 1.5` is static and not resilient to narrow desktop windows or larger text.

### Scope of Work
- File: `lib/ui/screens/graph_center_screen.dart`
- In grid delegate, compute by width:
  - `<600`: `crossAxisCount: 1`, `childAspectRatio: 1.25`
  - `600–839`: `crossAxisCount: 2`, `childAspectRatio: 1.2`
  - `>=840`: `crossAxisCount: 2`, `childAspectRatio: 1.35`
- Add `maxLines` + `overflow: TextOverflow.ellipsis` on title/description already present; retain and ensure both stay enabled.

### Platforms Affected
- Linux
- Windows
- Web
- Android (tablet/landscape)

### Acceptance Criteria
- Card content does not clip at all width breakpoints.
- No `RenderFlex` overflow in grid cards with increased text scale.
- Grid remains 1-column below 600 and 2-column at/above 600.
- Visual density remains stable at 150% DPI.

### Regression Risk
Low — sizing math and text truncation only.

### Testing Instructions
1. Open Chart Center.
2. Test widths 480, 599, 600, 839, 840, 1200.
3. Increase text scale and verify card content readability.
4. Confirm card taps still navigate correctly.

### Definition of Done
- Code implemented
- Tested on all listed platforms
- No overflow/debug warnings
- Responsive across defined breakpoints
- tasks2.md checkbox marked complete
---

- [x] Task 10
---
## [P3] Rework import_screen.dart mapping rows for high-DPI and narrow desktop widths

### Summary
Mapping rows become unstable and cramped at high DPI and medium-narrow desktop widths.

### Background
`_buildMappingDropdown` uses a tight `Row` with fixed flex assumptions for label/badge/dropdown.

### Scope of Work
- File: `lib/ui/screens/import_screen.dart`
- Add `LayoutBuilder` inside `_buildMappingDropdown`:
  - `<840`: `Column(crossAxisAlignment: stretch)` with label row above dropdown.
  - `>=840`: current `Row(flex 2/3)` layout.
- Label text: `maxLines: 2`, `overflow: TextOverflow.ellipsis`.

### Platforms Affected
- Linux
- Windows
- Web

### Acceptance Criteria
- No horizontal clipping in mapping rows at widths `600–839`.
- No horizontal scroll required for mapping controls at 150% DPI scaling.
- Existing wide row layout preserved at `>=840`.
- No overflow warnings in mapping section.

### Regression Risk
Low — localized responsive row/column switch.

### Testing Instructions
1. Open Import screen and proceed to mapping step.
2. Test widths 700, 839, 840, 1024 with long column headers.
3. Test desktop scaling at 150–200%.
4. Validate dropdown usability and mapping persistence.

### Definition of Done
- Code implemented
- Tested on all listed platforms
- No overflow/debug warnings
- Responsive across defined breakpoints
- tasks2.md checkbox marked complete
---

- [x] Task 11
---
## [P3] Improve desktop reorder affordance and focus traversal in dashboard_layout_editor_screen.dart

### Summary
Layout editor reorder interactions are less discoverable and keyboard traversal is weak.

### Background
Default `ReorderableListView` behavior is used without explicit drag handle or focused traversal grouping.

### Scope of Work
- File: `lib/ui/screens/dashboard_layout_editor_screen.dart`
- In `ListTile.trailing`, wrap `Switch` and `ReorderableDragStartListener(index: index, child: Icon(Icons.drag_handle))` in `Row(mainAxisSize: MainAxisSize.min)`.
- Wrap list in `FocusTraversalGroup` to stabilize keyboard traversal order.

### Platforms Affected
- Linux
- Windows
- Web

### Acceptance Criteria
- Drag handle is visible and functional for each list row.
- Keyboard traversal order is predictable through list controls.
- No layout overflow in trailing controls at all breakpoints.
- Reorder and visibility toggles continue to work.

### Regression Risk
Low — additive affordance and focus grouping.

### Testing Instructions
1. Open Dashboard Layout Editor.
2. Reorder with mouse/trackpad using drag handle.
3. Navigate via keyboard (Tab/Shift+Tab) through switches and rows.
4. Verify no clipping at widths 600, 840, 1200.

### Definition of Done
- Code implemented
- Tested on all listed platforms
- No overflow/debug warnings
- Responsive across defined breakpoints
- tasks2.md checkbox marked complete
---

## Phase 4 – Accessibility & Focus Improvements

- [x] Task 12
---
## [P4] Normalize keyboard focus traversal and submit actions in forms and dialogs

### Summary
Keyboard-first workflows are inconsistent in complex forms and dialogs.

### Background
Form/dialog roots lack standardized traversal policy and text input action chaining.

### Scope of Work
- Files:
  - `lib/ui/screens/weekly_entry_screen.dart`
  - `lib/ui/screens/import_screen.dart`
  - Church/profile creation dialogs in `church_selection_screen.dart` and `profile_selection_screen.dart`
  - Reports option dialogs in `reports_screen.dart`
- Wrap each form/dialog content root with `FocusTraversalGroup(policy: OrderedTraversalPolicy())`.
- Set `textInputAction` chain (`next` except final field `done`) on all text fields.
- On final field submit, trigger primary action (validate/create/import).

### Platforms Affected
- Android
- Linux
- Windows
- Web

### Acceptance Criteria
- Tab/Shift+Tab navigation order is deterministic in all targeted forms/dialogs.
- Enter/Done on final field triggers intended primary action.
- No focus traps occur at any width breakpoint.
- Keyboard-only completion path works in `0–479` through `1200+`.

### Regression Risk
Low — interaction behavior is standardized without structural redesign.

### Testing Instructions
1. Open each targeted form/dialog.
2. Complete workflows using keyboard only.
3. Verify final field submit behavior.
4. Repeat across narrow and wide breakpoints.

### Definition of Done
- Code implemented
- Tested on all listed platforms
- No overflow/debug warnings
- Responsive across defined breakpoints
- tasks2.md checkbox marked complete
---

- [ ] Task 13
---
## [P4] Add semantics parity for icon-only actions and chart controls

### Summary
Icon-only actions and chart controls are under-described for assistive technologies.

### Background
Some controls rely on visual affordance only and do not provide robust semantic labeling parity.

### Scope of Work
- Files:
  - `lib/ui/screens/attendance_charts_screen.dart`
  - Other chart screens with icon-only controls
  - `lib/ui/screens/dashboard_screen.dart`
- Wrap icon-only actionable widgets with `Semantics(button: true, label: '...')`.
- Ensure every `IconButton` has explicit `tooltip` and semantic label parity.
- For chart cards, add short textual summary below chart title (already partially present in some screens; normalize where absent).

### Platforms Affected
- Android
- Linux
- Windows
- Web

### Acceptance Criteria
- All icon-only actions expose semantic labels and matching tooltips.
- Screen-reader announcement for chart controls is meaningful and action-specific.
- No loss of interaction behavior after semantics wrapping.
- Verified in representative screens across all breakpoint bands.

### Regression Risk
Low — metadata/semantics additions only.

### Testing Instructions
1. Inspect semantics tree in Flutter tooling for icon-only controls.
2. Verify tooltips appear on hover (desktop/web) and long-press (mobile).
3. Confirm action behavior unchanged after semantics wrappers.
4. Validate on charts and dashboard action rows.

### Definition of Done
- Code implemented
- Tested on all listed platforms
- No overflow/debug warnings
- Responsive across defined breakpoints
- tasks2.md checkbox marked complete
---

- [ ] Task 14
---
## [P4] Enforce minimum tap targets and text-scale resilience in dense action UIs

### Summary
Dense action rows/chips can drop below comfortable hit target size and degrade under text scaling.

### Background
Current dense controls do not consistently enforce padded material tap targets and minimum dimensions.

### Scope of Work
- Files:
  - `lib/ui/screens/dashboard_screen.dart`
  - `lib/ui/screens/graph_center_screen.dart`
  - `lib/ui/widgets/time_range_selector.dart`
- Apply `VisualDensity.standard` and `minimumSize: Size(48, 48)` to icon-based controls in dense rows.
- In `TimeRangeSelector` compact chips, enforce min chip height via `materialTapTargetSize: MaterialTapTargetSize.padded`.

### Platforms Affected
- Android
- Linux
- Windows
- Web

### Acceptance Criteria
- Interactive controls maintain >=48x48 logical tap area where specified.
- No clipping or overlap at text scale 1.3 and 1.5.
- Dense action rows remain functional across all breakpoint ranges.
- No new overflow warnings introduced by increased tap target sizing.

### Regression Risk
Low — sizing/padding hardening on existing controls.

### Testing Instructions
1. Verify touch target dimensions visually and through widget inspector.
2. Increase text scale and retest dashboard/graph center/time-range chips.
3. Check mobile and desktop interaction behavior.
4. Confirm no overflow warnings in debug output.

### Definition of Done
- Code implemented
- Tested on all listed platforms
- No overflow/debug warnings
- Responsive across defined breakpoints
- tasks2.md checkbox marked complete
---

## Phase 5 – Performance & Rendering Safety

- [ ] Task 15
---
## [P5] Constrain InteractiveViewer behavior for predictable web/desktop chart rendering

### Summary
Unconstrained chart interactivity can create oversized paint areas and unpredictable pan behavior.

### Background
`InteractiveViewer(constrained: false)` is currently used in responsive chart container flow.

### Scope of Work
- Files:
  - `lib/ui/widgets/responsive_chart_container.dart`
  - Relevant chart screen call sites
- Change to `InteractiveViewer(constrained: true, boundaryMargin: EdgeInsets.zero, clipBehavior: Clip.hardEdge)`.
- Keep `enableInteractive: false` by default for static dashboards; enable only where zoom is required.

### Platforms Affected
- Web
- Linux
- Windows
- Android

### Acceptance Criteria
- No oversized paint/pan behavior on web narrow viewports.
- Chart panning/zoom is bounded and predictable where enabled.
- Default static chart screens run with interactivity disabled unless explicitly required.
- No regressions in chart visibility across breakpoint bands.

### Regression Risk
Medium — interaction model changes can affect user chart manipulation behavior.

### Testing Instructions
1. Open chart screens on web and desktop.
2. Attempt pan/zoom on interactive and non-interactive chart contexts.
3. Resize through breakpoint widths and verify rendering stability.
4. Confirm no clipping/paint anomalies.

### Definition of Done
- Code implemented
- Tested on all listed platforms
- No overflow/debug warnings
- Responsive across defined breakpoints
- tasks2.md checkbox marked complete
---

- [ ] Task 16
---
## [P5] Harden LazyLoadChart visibility checks for nested scroll safety

### Summary
Lazy-load visibility logic can be brittle under nested scroll and repeated notifications.

### Background
Visibility checks rely on render-object math with scroll notifications; repeated checks are not minimized early enough.

### Scope of Work
- File: `lib/ui/widgets/lazy_load_chart.dart`
- Preserve existing logic, but short-circuit repeated calculations using `if (_hasBeenVisible) return` earlier in notification handler.
- Add `Scrollable.of(context)` null-safe path before viewport math and skip expensive checks if size is zero.
- Keep API unchanged.

### Platforms Affected
- Android
- Linux
- Windows
- Web

### Acceptance Criteria
- Charts still lazy-load correctly when entering viewport.
- No repeated expensive checks after visibility is resolved.
- No runtime exceptions from null/zero-size scroll/viewport states.
- Behavior remains stable across all breakpoint ranges in long scroll pages.

### Regression Risk
Low — internal guard/robustness update without API change.

### Testing Instructions
1. Open long chart pages and scroll gradually.
2. Validate charts load once upon visibility.
3. Test nested/complex scroll contexts where applicable.
4. Monitor logs for exceptions and verify no regressions.

### Definition of Done
- Code implemented
- Tested on all listed platforms
- No overflow/debug warnings
- Responsive across defined breakpoints
- tasks2.md checkbox marked complete
---

- [ ] Task 17
---
## [P5] Reduce rebuild pressure in large forms using const extraction and local state isolation

### Summary
Large form screens rebuild broad widget trees on small state changes.

### Background
Static sections are not consistently extracted as `const` and mutable portions are not always isolated.

### Scope of Work
- Files:
  - `lib/ui/screens/import_screen.dart`
  - `lib/ui/screens/weekly_entry_screen.dart`
  - `lib/ui/screens/app_settings_screen.dart`
- Extract static subsections to `const` widgets where possible (labels/help blocks/cards).
- Isolate mutable sections with local `StatefulBuilder` only where interaction is local (dialogs already use this pattern in some paths).
- No state-management rewrite.

### Platforms Affected
- Android
- Linux
- Windows
- Web

### Acceptance Criteria
- Static sections are converted to `const` where valid and safe.
- Localized state updates do not trigger unnecessary full-section rebuilds.
- Functional behavior and visual output remain unchanged across breakpoints.
- No new layout warnings or runtime issues introduced.

### Regression Risk
Medium — broad refactor touches multiple high-traffic forms.

### Testing Instructions
1. Exercise import, weekly entry, and app settings workflows.
2. Use Flutter rebuild profiling tools to compare before/after hotspots.
3. Verify all interactions and validations behave identically.
4. Confirm no overflow/debug warnings.

### Definition of Done
- Code implemented
- Tested on all listed platforms
- No overflow/debug warnings
- Responsive across defined breakpoints
- tasks2.md checkbox marked complete
---
