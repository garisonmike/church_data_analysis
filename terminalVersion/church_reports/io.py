"""Input discovery and file reading.

Resolves input paths (files or folders), detects the most likely header row
in XLSX sheets that carry title rows, loads CSV/XLSX sources into raw
DataFrames, and locates the raw XLSX exports behind the presentation graphs.
"""

from __future__ import annotations

import pandas as pd
import re

from pathlib import Path
from typing import Optional, Sequence
from .config import SCRIPT_DIR, SUPPORTED_SUFFIXES, data_home
from .metrics import derive_metrics
from .cleaning import combine_duplicate_columns, prepare_dataframe


HEADER_KEYWORDS = {
    "date",
    "week",
    "saturday",
    "men",
    "women",
    "youth",
    "children",
    "attendance",
    "home",
    "church",
    "tithe",
    "offering",
    "offerings",
    "emergency",
    "planned",
    "communion",
    "baptism",
    "board",
    "business",
    "meeting",
    "ambassador",
    "ambassadors",
}


def log(message: str) -> None:
    print(message)


def detect_header_row(raw: pd.DataFrame, scan_rows: int = 30) -> Optional[int]:
    """Find a likely header row in a raw Excel sheet that may contain title rows."""
    best_idx: Optional[int] = None
    best_score = 0
    for idx in range(min(len(raw), scan_rows)):
        tokens: set[str] = set()
        for value in raw.iloc[idx].tolist():
            if value is None:
                continue
            text = str(value).strip()
            if not text or text.lower() == "nan":
                continue
            tokens.update(re.split(r"[^a-zA-Z0-9]+", text.lower()))
        score = sum(1 for token in HEADER_KEYWORDS if token in tokens)
        if score >= 2 and score > best_score:
            best_idx = idx
            best_score = score
    return best_idx


def read_csv_file(path: Path, force_year: Optional[int]) -> list[pd.DataFrame]:
    df = pd.read_csv(path)
    return [prepare_dataframe(df, path.name, None, force_year)]


def read_excel_file(path: Path, force_year: Optional[int]) -> list[pd.DataFrame]:
    frames: list[pd.DataFrame] = []
    xls = pd.ExcelFile(path)
    for sheet in xls.sheet_names:
        raw = pd.read_excel(xls, sheet_name=sheet, header=None)
        raw = raw.dropna(axis=0, how="all").dropna(axis=1, how="all")
        if raw.empty:
            continue

        header_idx = detect_header_row(raw)
        if header_idx is None:
            df = pd.read_excel(xls, sheet_name=sheet)
        else:
            df = raw.iloc[header_idx + 1 :].copy()
            df.columns = raw.iloc[header_idx].tolist()

        prepared = prepare_dataframe(df, path.name, str(sheet), force_year)
        if not prepared.empty:
            frames.append(prepared)
    return frames


def resolve_input_paths(inputs: Sequence[str]) -> list[Path]:
    paths: list[Path] = []
    for value in inputs:
        path = Path(value).expanduser()
        if not path.is_absolute() and not path.exists():
            path = SCRIPT_DIR / path
        if path.is_dir():
            for suffix in SUPPORTED_SUFFIXES:
                paths.extend(sorted(path.glob(f"*{suffix}")))
        elif path.exists():
            paths.append(path)
        else:
            log(f"Warning: input path does not exist: {path}")

    unique_paths: list[Path] = []
    seen: set[Path] = set()
    for path in paths:
        resolved = path.resolve()
        if resolved not in seen and path.suffix.lower() in SUPPORTED_SUFFIXES:
            unique_paths.append(path)
            seen.add(resolved)
    return unique_paths


def load_data(paths: Sequence[Path], force_year: Optional[int]) -> pd.DataFrame:
    frames: list[pd.DataFrame] = []
    for path in paths:
        suffix = path.suffix.lower()
        try:
            if suffix == ".csv":
                frames.extend(read_csv_file(path, force_year))
            elif suffix in {".xlsx", ".xls", ".xslx"}:
                frames.extend(read_excel_file(path, force_year))
        except Exception as exc:
            log(f"Warning: could not read {path}: {exc}")

    if not frames:
        return pd.DataFrame()

    combined = pd.concat(frames, ignore_index=True, sort=False)
    combined = combine_duplicate_columns(combined)
    combined = derive_metrics(combined)

    metric_columns = [
        "men",
        "women",
        "youth",
        "children",
        "sunday_home_church",
        "tithe",
        "offerings",
        "total_attendance",
        "total_income",
        "baptisms",
        "holy_communion",
        "sabbath_school_attendance",
    ]
    has_metric = combined[[c for c in metric_columns if c in combined.columns]].notna().any(axis=1)
    return combined[has_metric].reset_index(drop=True)


# ---------------------------------------------------------------------------
# ── NEW PRESENTATION GRAPHS ─────────────────────────────────────────────────
# These builders read the raw XLSX source files from a `data/` sub-folder
# next to this script when the aggregated CSV lacks that granularity
# (Sabbath School groups, Home Church breakdown, Board/Business meeting per
#  home-church). For the weekly-series graphs they use the normalised df.
# ---------------------------------------------------------------------------

def _data_dir() -> Path:
    """Return the data directory: $CHURCH_DATA_DIR if set, else the data/
    folder next to this script, else cwd/data."""
    home = data_home()
    candidates = ([home] if home else []) + [SCRIPT_DIR / "data", Path.cwd() / "data"]
    for candidate in candidates:
        if candidate.is_dir():
            return candidate
    return SCRIPT_DIR  # last resort: same folder


def _find_xlsx(pattern: str) -> Optional[Path]:
    """Case-insensitive glob for an XLSX file matching *pattern* in data/."""
    d = _data_dir()
    pattern_lower = pattern.lower()
    for p in d.glob("*.xlsx"):
        if pattern_lower in p.name.lower():
            return p
    return None


def default_inputs() -> list[str]:
    names = ["netFinalData.csv", "finalData.csv", "church_data.csv"]
    home = data_home()
    bases = ([home] if home else []) + [SCRIPT_DIR / "data"]
    for base in bases:
        for name in names:
            path = base / name
            if path.exists():
                return [str(path)]
    return []


def default_output_dir() -> str:
    """Default output directory: inside $CHURCH_DATA_DIR when configured, so
    generated reports (which contain real data) also stay out of the repo."""
    home = data_home()
    if home:
        return str(home / "church_analysis")
    return "church_analysis"
