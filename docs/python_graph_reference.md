# Python Graph Reference - `terminalVersion/data.py`

`terminalVersion/data.py` is the terminal companion for the app analytics
workflow. It imports CSV/XLSX weekly church records, normalizes app-style
columns, derives core metrics, and exports selected graphs as PNG files with an
optional multi-page PDF.

## Common Commands

```bash
cd terminalVersion
python data.py --list-graphs
python data.py --input data/netFinalData.csv --graphs all --pdf --export-clean
python data.py --input data --group attendance
python data.py --input weekly.xlsx --graphs total_attendance_trend,income_distribution
```

## Inputs

Supported file types:

- `.csv`
- `.xlsx`
- `.xls`
- `.xslx` as a forgiving alias for mistyped Excel filenames

CSV files are read with the first row as headers. Excel files are scanned per
sheet for a likely header row, which lets the CLI handle title rows in exported
forms.

## Canonical Columns

The app import template accepts these 12 columns only:

`week_start_date`, `men`, `women`, `youth`, `children`, `sunday_home_church`,
`tithe`, `offerings`, `emergency_collection`, `planned_collection`,
`baptisms`, `holy_communion`.

The CLI accepts app-style snake_case headers and common variants such as
`weekStartDate`, `home_church`, `offering`, `holy_comm`, and `sabbath_school`.
After import, columns are normalized to:

| Area | Columns |
|---|---|
| Metadata | `id`, `church_id`, `created_by_admin_id`, `created_at`, `updated_at` |
| Date | `week_start_date` |
| Attendance | `men`, `women`, `youth`, `children`, `sunday_home_church`, `sabbath_school_attendance`, `visitors_count`, `ambassadors_attendance`, `adult_attendance` |
| Finance | `tithe`, `offerings`, `emergency_collection`, `planned_collection`, `mission_offering`, `local_church_budget` |
| Events | `baptisms`, `holy_communion`, `holy_communion_expected` |
| Meetings | `board_business_meeting_attendance`, `board_business_meeting_expected` |
| Totals | `total_attendance`, `total_income` |
| Optional metadata | `granularity`, `source`, `source_file`, `source_sheet`, `source_table` |

## Derived Metrics

The CLI derives:

- `sabbath_attendance = men + women + youth + children`
- `total_attendance = men + women + youth + children + sunday_home_church`
- `adult_attendance = men + women`
- `young_attendance = youth + children`
- `core_income = tithe + offerings + emergency_collection + planned_collection`
- `regular_income = tithe + offerings`
- `special_collections = emergency_collection + planned_collection`
- `total_income = core income + mission_offering + local_church_budget`
- per-attendee giving metrics
- demographic percentages
- week-over-week attendance, income, and tithe growth
- men:women, adult:young, and tithe:offerings ratios

If legacy input has `total_attendance` equal to only
`men + women + youth + children`, the CLI preserves that value as
`source_total_attendance` and uses the app-style total including home church for
graphs.

## Graph Groups

| Group | Purpose |
|---|---|
| `attendance` | Attendance trends, group bars, distribution, growth, optional Sabbath School and visitors |
| `financial` | Giving trends, composition, distribution, income growth, per-capita metrics, ratios |
| `events` | Baptisms and Holy Communion charts |
| `meetings` | Board/business meeting attendance charts |
| `correlation` | Attendance/income scatter, dual-axis comparisons, correlation heatmap |
| `advanced` | Histograms, moving average, simple forecast, summary dashboard |
| `all` | Every registered graph |

From terminalVersion/, run `python data.py --list-graphs` for the exact graph IDs.

## Outputs

By default, graphs are written under the output directory in group folders:

```text
church_analysis/
  attendance/
  financial/
  events/
  correlation/
  advanced/
  tables/
```

Optional outputs:

- `--pdf` writes `graphs.pdf`.
- `--export-clean` writes `normalized_data.csv`.
- Summary tables are written by default:
  - `tables/summary_statistics.csv`
  - `tables/correlation_matrix.csv`

Use `--no-tables` to skip table generation.
