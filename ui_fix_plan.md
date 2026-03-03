# UI Fix Plan

## Phase 1 – Critical Stability (Must Fix Before Release)

### 1) Reports screen overflow across Android/Windows/Web
- Screen: reports_screen.dart
- Problem: `Scaffold.body` uses `Center > Padding > Column` with fixed vertical gaps; bottom actions become unreachable on short-height viewports and resized desktop windows.
- Exact Technical Fix (specific widget changes):
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
- Risk of Regression: Medium (changes primary layout flow and interaction density).
- Estimated Complexity: Medium

### 2) Dashboard app bar action crowding (Linux high severity)
- Screen: dashboard_screen.dart
- Problem: App bar embeds church switcher + profile switcher + reports/settings actions inline; truncation/crowding occurs around medium widths with long names.
- Exact Technical Fix (specific widget changes):
  - Keep existing compact menu path, but add intermediate breakpoint logic in `build`:
    - `isNarrow = width < 600`
    - `isMedium = width >= 600 && width < 840`
    - `isWide = width >= 840`
  - For `isMedium`, move `ChurchSelectorWidget` and `ProfileSwitcherWidget` out of app bar action row into overflow menu entries only.
  - Keep only `settings`, `more`, `refresh` as direct actions in `isMedium`.
  - Add `Flexible` around title text only if still needed; do not add new components.
- Risk of Regression: Low (menu relocation only; no navigation contract changes).
- Estimated Complexity: Low

### 3) Reports web layout inefficiency + overflow risk (Web high severity)
- Screen: reports_screen.dart
- Problem: Single-column mobile-style stack wastes horizontal space and increases vertical overflow risk.
- Exact Technical Fix (specific widget changes):
  - In the same scrollable body refactor, wrap report cards in `LayoutBuilder` and branch:
    - `<840`: existing single-column flow
    - `>=840`: `Wrap` two-column card placement (`SizedBox(width: (maxWidth - 12) / 2)`)
  - Keep action controls in `Wrap` so buttons naturally reflow.
  - Preserve existing card content and theming.
- Risk of Regression: Medium (desktop/web arrangement changes).
- Estimated Complexity: Medium

## Phase 2 – Cross-Platform Layout Consistency

### 1) Keyboard occlusion on entry form
- Screen: weekly_entry_screen.dart
- Problem: Static bottom spacer (`40/80`) does not track keyboard insets; lower fields/save can be obscured.
- Exact Technical Fix (specific widget changes):
  - In `SingleChildScrollView`, set bottom padding to `max(16, MediaQuery.viewInsetsOf(context).bottom + 16)`.
  - Keep `ConstrainedBox(minHeight: constraints.maxHeight - verticalPadding)`.
  - Set `scrollPadding: EdgeInsets.only(bottom: 24 + MediaQuery.viewInsetsOf(context).bottom)` on each `TextFormField`.
  - Remove fixed terminal spacer `SizedBox(height: isDesktop ? 80 : 40)`.
- Risk of Regression: Low
- Estimated Complexity: Medium

### 2) Dialog overflow and inconsistent constraints
- Screen: import_screen.dart, church_selection_screen.dart, profile_selection_screen.dart, reports_screen.dart (options dialogs)
- Problem: Several dialogs can exceed viewport height with dense forms/lists.
- Exact Technical Fix (specific widget changes):
  - Standardize dialog content wrapper to:
    - `LayoutBuilder` -> `ConstrainedBox(maxHeight: constraints.maxHeight * 0.8, maxWidth: 560)`
    - Inner `SingleChildScrollView`
  - For list dialogs, replace unbounded `Column` error lists with `ListView.builder(shrinkWrap: true, physics: NeverScrollableScrollPhysics())` inside bounded scroll region.
  - Apply `insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)` for small screens.
- Risk of Regression: Medium (touches multiple dialogs).
- Estimated Complexity: Medium

### 3) AppBar compression in attendance charts
- Screen: attendance_charts_screen.dart
- Problem: Time-range chips + refresh in app bar can compress on narrow widths.
- Exact Technical Fix (specific widget changes):
  - In `AppBar.actions`, switch by width:
    - `<480`: replace `TimeRangeSelector(compact: true)` with a single `IconButton` opening popup menu for range options.
    - `480–839`: keep compact selector but cap width to `220`.
    - `>=840`: keep current `ConstrainedBox(maxWidth: 400)`.
  - Keep refresh icon always visible.
- Risk of Regression: Low
- Estimated Complexity: Medium

### 4) Fixed chart heights causing clipping under text scaling/resizing
- Screen: financial_charts_screen.dart, correlation_charts_screen.dart, advanced_charts_screen.dart
- Problem: Repeated `SizedBox(height: 300)` and row legends cause label collisions.
- Exact Technical Fix (specific widget changes):
  - Replace direct `SizedBox(height: 300)` chart containers with `ResponsiveChartContainer(minHeight: 220, maxHeight: 420, aspectRatio: 16/10, enableInteractive: false)`.
  - Change rigid legend `Row` to `Wrap(spacing: 12, runSpacing: 8, alignment: WrapAlignment.center)`.
  - Breakpoint rules:
    - `<480`: `minHeight 200`
    - `480–839`: `minHeight 220`
    - `>=840`: `minHeight 260`
- Risk of Regression: Medium (chart sizing behavior changes).
- Estimated Complexity: Medium

## Phase 3 – Desktop Optimization

### 1) Custom graph builder control row crowding
- Screen: custom_graph_builder_screen.dart
- Problem: Two fixed `Expanded` dropdowns in one row become cramped on medium desktop widths.
- Exact Technical Fix (specific widget changes):
  - Wrap selector row in `LayoutBuilder`:
    - `<840`: `Column` with first selector, `SizedBox(height: 12)`, second selector.
    - `>=840`: existing `Row` with two `Expanded` children.
  - Keep chart type selector unchanged.
- Risk of Regression: Low
- Estimated Complexity: Low

### 2) Graph center card crowding under text scale
- Screen: graph_center_screen.dart
- Problem: Fixed `childAspectRatio: 1.5` causes card content compression.
- Exact Technical Fix (specific widget changes):
  - In grid delegate, compute by width:
    - `<600`: `crossAxisCount: 1`, `childAspectRatio: 1.25`
    - `600–839`: `crossAxisCount: 2`, `childAspectRatio: 1.2`
    - `>=840`: `crossAxisCount: 2`, `childAspectRatio: 1.35`
  - Add `maxLines` + `overflow: TextOverflow.ellipsis` on title/description already present; retain and ensure both stay enabled.
- Risk of Regression: Low
- Estimated Complexity: Low

### 3) Import mapping row stability at high DPI
- Screen: import_screen.dart (`_buildMappingDropdown`)
- Problem: `Row` with label/badge/dropdown compresses at 150–200% scaling.
- Exact Technical Fix (specific widget changes):
  - Add `LayoutBuilder` inside `_buildMappingDropdown`:
    - `<840`: `Column(crossAxisAlignment: stretch)` with label row above dropdown.
    - `>=840`: current `Row(flex 2/3)` layout.
  - Label text: `maxLines: 2`, `overflow: TextOverflow.ellipsis`.
- Risk of Regression: Low
- Estimated Complexity: Medium

### 4) Reorder affordance and keyboard pathway in layout editor
- Screen: dashboard_layout_editor_screen.dart
- Problem: Default reorder UX is weak for keyboard/mouse desktop workflows.
- Exact Technical Fix (specific widget changes):
  - In `ListTile.trailing`, wrap `Switch` and `ReorderableDragStartListener(index: index, child: Icon(Icons.drag_handle))` in `Row(mainAxisSize: MainAxisSize.min)`.
  - Wrap list in `FocusTraversalGroup` to stabilize keyboard traversal order.
- Risk of Regression: Low
- Estimated Complexity: Low

## Phase 4 – Accessibility & Focus Improvements

### 1) Focus traversal normalization in forms and dialogs
- Screen: weekly_entry_screen.dart, import_screen.dart, church/profile creation dialogs, reports option dialogs
- Problem: Keyboard-first traversal is inconsistent across dense forms.
- Exact Technical Fix (specific widget changes):
  - Wrap each form/dialog content root with `FocusTraversalGroup(policy: OrderedTraversalPolicy())`.
  - Set `textInputAction` chain (`next` except final field `done`) on all text fields.
  - On final field submit, trigger primary action (validate/create/import).
- Risk of Regression: Low
- Estimated Complexity: Medium

### 2) Semantics for icon-only and chart actions
- Screen: attendance_charts_screen.dart + chart screens + dashboard action icons
- Problem: Icon-only controls and chart export actions have limited semantic clarity.
- Exact Technical Fix (specific widget changes):
  - Wrap icon-only actionable widgets with `Semantics(button: true, label: '...')`.
  - Ensure every `IconButton` has explicit `tooltip` and semantic label parity.
  - For chart cards, add short textual summary below chart title (already partially present in some screens; normalize where absent).
- Risk of Regression: Low
- Estimated Complexity: Low

### 3) Tap-target and text-scale hardening
- Screen: dashboard_screen.dart, graph_center_screen.dart, time_range_selector.dart
- Problem: Dense action rows can fall below comfortable tap area under scaling.
- Exact Technical Fix (specific widget changes):
  - Apply `VisualDensity.standard` and `minimumSize: Size(48, 48)` to icon-based controls in dense rows.
  - In `TimeRangeSelector` compact chips, enforce min chip height via `materialTapTargetSize: MaterialTapTargetSize.padded`.
- Risk of Regression: Low
- Estimated Complexity: Low

## Phase 5 – Performance & Rendering Safety

### 1) Constrain chart interactivity on web/desktop
- Screen: responsive_chart_container.dart and chart screen call sites
- Problem: `InteractiveViewer(constrained: false)` can produce oversized paint areas and unpredictable pan bounds.
- Exact Technical Fix (specific widget changes):
  - Change to `InteractiveViewer(constrained: true, boundaryMargin: EdgeInsets.zero, clipBehavior: Clip.hardEdge)`.
  - Keep `enableInteractive: false` by default for static dashboards; enable only where zoom is required.
- Risk of Regression: Medium (interaction behavior changes).
- Estimated Complexity: Medium

### 2) Lazy-load visibility robustness
- Screen: lazy_load_chart.dart
- Problem: Render-object visibility checks tied to nested scroll notifications are brittle.
- Exact Technical Fix (specific widget changes):
  - Preserve existing logic, but short-circuit repeated calculations using `if (_hasBeenVisible) return` earlier in notification handler.
  - Add `Scrollable.of(context)` null-safe path before viewport math and skip expensive checks if size is zero.
  - Keep API unchanged.
- Risk of Regression: Low
- Estimated Complexity: Low

### 3) Rebuild pressure reduction in large forms
- Screen: import_screen.dart, weekly_entry_screen.dart, app_settings_screen.dart
- Problem: Large composite sections rebuild on every state mutation.
- Exact Technical Fix (specific widget changes):
  - Extract static subsections to `const` widgets where possible (labels/help blocks/cards).
  - Isolate mutable sections with local `StatefulBuilder` only where interaction is local (dialogs already use this pattern in some paths).
  - No state-management rewrite.
- Risk of Regression: Low
- Estimated Complexity: Medium

## Unified Breakpoint Strategy Proposal

Use these global width breakpoints consistently across all UI screens:

- 0–479 (Compact Phone)
  - Single-column only.
  - AppBar actions: max 1 primary icon + overflow menu.
  - Dialog max width: 92% viewport, max height: 80% viewport.
  - Prefer `SingleChildScrollView` around dense form content.

- 480–599 (Phone Landscape / Small Tablet)
  - Single-column with tighter spacing.
  - AppBar can show refresh + one compact control.
  - Chart legends must use `Wrap`, never fixed `Row`.

- 600–839 (Medium / Small Desktop Window)
  - Transitional layout.
  - Move non-critical app bar widgets into overflow.
  - Use `LayoutBuilder` to switch form rows (`Row`) to stacked `Column` where controls are text-heavy.

- 840–1199 (Desktop Standard)
  - Two-column cards/forms allowed.
  - Inline app bar switchers allowed if text truncation is protected.
  - Dialog max width: 560.

- 1200+ (Large Desktop)
  - Wider spacing allowed; keep same widget structure.
  - Increase chart min heights modestly; do not add new layout paradigms.

Global usage rules:
- Overflow prevention defaults: `SafeArea` + `SingleChildScrollView` for any screen with >1 action section.
- Width adaptation defaults: `LayoutBuilder` for all mixed-content rows (labels + controls).
- Horizontal button/action groups: `Wrap` first, `Row` only when guaranteed width.
- Flexible text containers: use `Flexible/Expanded` around user-generated labels (church/profile names).
