"""Configuration: branding, data locations, and column schemas.

Single home for every value that was previously hardcoded across the old
data.py monolith — church name, watermark, chart palette, data-directory
resolution, and the column-name schemas shared with the Flutter app's
import template.

Environment overrides (all optional):
    CHURCH_DATA_DIR     directory holding the data files (keeps real
                        congregation data outside the repo checkout)
    CHURCH_NAME         full church name used in the chart watermark
    CHURCH_SHORT_NAME   short name used in TUI headers
    CHURCH_WATERMARK    full watermark text; when unset, the watermark is
                        "<CHURCH_NAME>  ·  Q<n> <year>" for the current
                        quarter, so it never goes stale
"""

from __future__ import annotations

import os
from datetime import date
from pathlib import Path
from typing import Optional

# ---------------------------------------------------------------------------
# Locations
# ---------------------------------------------------------------------------

# terminalVersion/ — the folder holding the package and the data.py shim.
SCRIPT_DIR = Path(__file__).resolve().parent.parent

SUPPORTED_SUFFIXES = {".csv", ".xlsx", ".xls", ".xslx"}

# Real congregation data must live outside the repo checkout. Point the
# CHURCH_DATA_DIR environment variable at the directory holding your data
# files; the legacy data/ folder next to the shim remains a fallback.
DATA_DIR_ENV = "CHURCH_DATA_DIR"


def data_home() -> Optional[Path]:
    """Return $CHURCH_DATA_DIR as a Path if it is set and exists, else None."""
    raw = os.environ.get(DATA_DIR_ENV, "").strip()
    if raw:
        path = Path(raw).expanduser()
        if path.is_dir():
            return path
    return None


# ---------------------------------------------------------------------------
# Branding
# ---------------------------------------------------------------------------

CHURCH_NAME = os.environ.get("CHURCH_NAME", "").strip() or "Kisii Central SDA Church"
CHURCH_SHORT_NAME = os.environ.get("CHURCH_SHORT_NAME", "").strip() or "Kisii Central SDA"


def _current_quarter_label(today: Optional[date] = None) -> str:
    """Return e.g. 'Q3 2026' for the current (or given) date."""
    today = today or date.today()
    return f"Q{(today.month - 1) // 3 + 1} {today.year}"


WATERMARK_TEXT = (
    os.environ.get("CHURCH_WATERMARK", "").strip()
    or f"{CHURCH_NAME}  ·  {_current_quarter_label()}"
)

# Church brand palette
C_NAVY   = "#1B3A6B"
C_GOLD   = "#C8972B"
C_SKY    = "#4A90D9"
C_GREEN  = "#2E8B57"
C_ROSE   = "#C0395A"
C_AMBER  = "#E07B30"
C_SLATE  = "#5C6E8A"
C_LIGHT  = "#EEF3FA"
C_WHITE  = "#FFFFFF"
C_GREY   = "#D0D7E2"

CHURCH_PALETTE = [C_NAVY, C_GOLD, C_SKY, C_GREEN, C_ROSE, C_AMBER, C_SLATE,
                  "#7B5EA7", "#2CA4A4", "#A44A3F", "#7A9E3B", "#4A7A7A"]

# ---------------------------------------------------------------------------
# Source-file name patterns
# ---------------------------------------------------------------------------

# Case-insensitive substrings used to locate the raw XLSX exports that back
# the presentation graphs. Adjust these if your report files are named
# differently.
XLSX_PATTERNS = {
    "sabbath_school": "sabbath school",
    "home_church": "home church",
    "business_meeting": "business attendance",
    "board_meeting": "board meeting",
    "holy_communion": "holy communion",
}

# ---------------------------------------------------------------------------
# Column schemas (shared with the Flutter app)
# ---------------------------------------------------------------------------

IMPORT_TEMPLATE_COLUMNS = [
    "week_start_date",
    "men",
    "women",
    "youth",
    "children",
    "sunday_home_church",
    "tithe",
    "offerings",
    "emergency_collection",
    "planned_collection",
    "baptisms",
    "holy_communion",
]

APP_WEEKLY_COLUMNS = [
    "id",
    "church_id",
    "created_by_admin_id",
    "week_start_date",
    "men",
    "women",
    "youth",
    "children",
    "sunday_home_church",
    "total_attendance",
    "tithe",
    "offerings",
    "emergency_collection",
    "planned_collection",
    "mission_offering",
    "local_church_budget",
    "total_income",
    "baptisms",
    "holy_communion",
    "holy_communion_expected",
    "sabbath_school_attendance",
    "visitors_count",
    "board_business_meeting_attendance",
    "board_business_meeting_expected",
    "ambassadors_attendance",
    "adult_attendance",
    "created_at",
    "updated_at",
]

OPTIONAL_METADATA_COLUMNS = [
    "granularity",
    "source",
    "source_file",
    "source_sheet",
    "source_table",
]

IGNORED_COLUMNS = {
    "col",
    "col_2",
    "col_3",
    "col_4",
    "col_5",
    "25",
    "112",
    "126",
    "148",
}
