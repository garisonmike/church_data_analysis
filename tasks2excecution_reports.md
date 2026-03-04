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
