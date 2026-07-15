"""Chart builders and the graph registry.

Holds the shared chart-style helpers (branding, watermark, axis styling),
every graph builder, and the GraphSpec registry that groups them for
selection from the CLI.
"""

from __future__ import annotations

# Import order mirrors the original data.py exactly: matplotlib (with the
# backend decided) before numpy/pandas, so rendering-relevant global state
# (e.g. pandas' matplotlib unit converters) is initialised identically.
import os
import re

os.environ.setdefault("MPLCONFIGDIR", "/tmp/matplotlib")

import matplotlib
from matplotlib.axes import Axes
from matplotlib.figure import Figure

if not os.environ.get("DISPLAY"):
    matplotlib.use("Agg")

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from matplotlib.backends.backend_pdf import PdfPages
from dataclasses import dataclass
from pathlib import Path
from typing import Callable, Iterable, Optional, Sequence
from .config import (
    ATTENDANCE_PARTS,
    C_GOLD,
    C_GREEN,
    C_GREY,
    C_LIGHT,
    C_NAVY,
    C_ROSE,
    C_SKY,
    C_SLATE,
    C_WHITE,
    INCOME_PARTS,
    WATERMARK_TEXT,
    XLSX_PATTERNS,
)
from .io import _find_xlsx, log


def has_data(df: pd.DataFrame, columns: Iterable[str]) -> bool:
    for column in columns:
        if column not in df.columns or df[column].dropna().empty:
            return False
    return True


def date_labels(df: pd.DataFrame) -> list[str]:
    if "week_start_date" not in df.columns:
        return [str(i + 1) for i in range(len(df))]
    dates = pd.to_datetime(df["week_start_date"], errors="coerce")
    labels = dates.dt.strftime("%Y-%m-%d")
    return [label if isinstance(label, str) else f"Row {i + 1}" for i, label in enumerate(labels)]


def configure_axes(ax: Axes, title: str, ylabel: Optional[str] = None) -> None:
    """Legacy plain style – kept so existing builders still work unchanged."""
    ax.set_title(title)
    if ylabel:
        ax.set_ylabel(ylabel)
    ax.grid(True, alpha=0.25)


def church_style(fig: Figure, ax: Axes, title: str) -> None:
    """Apply the church brand style to a figure / axes pair."""
    fig.patch.set_facecolor(C_WHITE)
    ax.set_facecolor(C_LIGHT)
    ax.set_title(title, fontsize=13, fontweight="bold", color=C_NAVY, pad=12)
    ax.tick_params(labelsize=9, colors="#3A3A3A")
    for spine in ax.spines.values():
        spine.set_edgecolor(C_GREY)
        spine.set_linewidth(0.8)
    ax.yaxis.grid(True, color=C_GREY, linewidth=0.6, linestyle="--", alpha=0.8)
    ax.set_axisbelow(True)


def add_watermark(fig: Figure) -> None:
    fig.text(0.99, 0.01, WATERMARK_TEXT,
             ha="right", va="bottom", fontsize=7.5, color="#AAAAAA", style="italic")


def bar_value_labels(ax: Axes, bars: list, color: str = C_NAVY, fmt: str = "{:.0f}") -> None:
    """Place value labels above each bar."""
    for bar in bars:
        h = bar.get_height()
        if pd.notna(h) and h > 0:
            ax.text(bar.get_x() + bar.get_width() / 2, h + ax.get_ylim()[1] * 0.01,
                    fmt.format(h), ha="center", va="bottom",
                    fontsize=8, fontweight="bold", color=color)


def make_church_fig(figsize: tuple = (12, 5)) -> tuple:
    """Return a (fig, ax) pair with the church background already applied."""
    fig, ax = plt.subplots(figsize=figsize)
    fig.patch.set_facecolor(C_WHITE)
    ax.set_facecolor(C_LIGHT)
    ax.yaxis.grid(True, color=C_GREY, linewidth=0.6, linestyle="--", alpha=0.8)
    ax.set_axisbelow(True)
    for spine in ax.spines.values():
        spine.set_edgecolor(C_GREY)
        spine.set_linewidth(0.8)
    return fig, ax


def set_categorical_x(ax: Axes, labels: Sequence[str]) -> np.ndarray:
    x = np.arange(len(labels))
    ax.set_xticks(x)
    ax.set_xticklabels(labels, rotation=25, ha="right")
    return x


def numeric_series(df: pd.DataFrame, column: str) -> pd.Series:
    return pd.to_numeric(df[column], errors="coerce")


def clean_positive_pairs(df: pd.DataFrame, x_col: str, y_col: str) -> pd.DataFrame:
    clean = df[[x_col, y_col]].apply(pd.to_numeric, errors="coerce").dropna()
    return clean[np.isfinite(clean[x_col]) & np.isfinite(clean[y_col])]


def add_mean_line(ax: Axes, series: pd.Series, label: str = "Average") -> None:
    mean = series.dropna().mean()
    if pd.notna(mean):
        ax.axhline(mean, linestyle="--", linewidth=1, color="#555555", label=label)


# ── 1. Sabbath School group bar chart ───────────────────────────────────────

def plot_sabbath_school_groups(df: pd.DataFrame) -> Optional[Figure]:
    """
    Grouped bar chart: each Sabbath School study group × up to 3 recorded
    sessions.  Reads SABBATH SCHOOL DATA*.xlsx from data/.  Falls back to
    showing a single-bar chart from the weekly total column if the XLSX is
    absent.
    """
    path = _find_xlsx(XLSX_PATTERNS["sabbath_school"])
    if path is not None:
        try:
            return _sabbath_school_from_xlsx(path)
        except Exception as exc:
            log(f"Note: could not parse Sabbath School XLSX ({exc}), falling back to summary.")

    # Fallback: use sabbath_school_attendance column
    if not has_data(df, ["sabbath_school_attendance"]):
        return None
    labels = date_labels(df)
    fig, ax = make_church_fig()
    bars = ax.bar(labels, df["sabbath_school_attendance"].fillna(0), color=C_NAVY, zorder=3)
    bar_value_labels(ax, bars)
    church_style(fig, ax, "Sabbath School Attendance by Week")
    ax.set_ylabel("Attendance", fontsize=10)
    ax.tick_params(axis="x", rotation=25)
    add_watermark(fig)
    return fig


def _sabbath_school_from_xlsx(path: Path) -> Optional[Figure]:
    from openpyxl import load_workbook
    wb = load_workbook(path, read_only=True)
    ws = wb.active
    if ws is None:
        return None
    rows = list(ws.iter_rows(values_only=True))

    # Locate header row (contains "GROUP" or datetime objects in same row)
    header_row = None
    for i, row in enumerate(rows):
        cells = [c for c in row if c is not None]
        strs  = [str(c).strip().upper() for c in cells]
        if "GROUP" in strs or any("GROUP" in s for s in strs):
            header_row = i
            break
    if header_row is None:
        return None

    import datetime
    date_labels_xlsx = []
    for val in rows[header_row]:
        if isinstance(val, datetime.datetime):
            date_labels_xlsx.append(val.strftime("%b %-d"))
        elif isinstance(val, str) and val.strip() and val.strip().upper() != "GROUP":
            date_labels_xlsx.append(val.strip())

    if not date_labels_xlsx:
        date_labels_xlsx = [f"Session {i+1}" for i in range(3)]

    groups: list[str] = []
    sessions: list[list[float]] = [[] for _ in date_labels_xlsx]

    for row in rows[header_row + 1:]:
        label = row[1] if len(row) > 1 else None
        if label is None:
            continue
        label_str = str(label).strip()
        if not label_str or label_str.upper() in ("TOTAL", "GRAND TOTAL", ""):
            continue
        if "TOTAL" in label_str.upper() or "CHILDREN" in label_str.upper():
            continue
        vals = [row[j] if j < len(row) else None for j in range(2, 2 + len(date_labels_xlsx))]
        numeric = [float(v) if isinstance(v, (int, float)) else 0.0 for v in vals]
        if all(v == 0 for v in numeric):
            continue
        groups.append(label_str.title())
        for idx, v in enumerate(numeric):
            sessions[idx].append(v)

    if not groups:
        return None

    x     = np.arange(len(groups))
    n_s   = len(date_labels_xlsx)
    width = min(0.8 / n_s, 0.25)
    colors = [C_NAVY, C_GOLD, C_SKY]

    fig, ax = make_church_fig(figsize=(14, 6))
    for si in range(n_s):
        offset = -width * (n_s - 1) / 2 + si * width
        bars = ax.bar(x + offset, sessions[si], width,
                      label=date_labels_xlsx[si] if si < len(date_labels_xlsx) else f"Session {si+1}",
                      color=colors[si % len(colors)], zorder=3)
        for bar, v in zip(bars, sessions[si]):
            if v > 0:
                ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.3,
                        str(int(v)), ha="center", va="bottom",
                        fontsize=7, fontweight="bold", color=C_NAVY)

    ax.set_xticks(x)
    ax.set_xticklabels(groups, rotation=35, ha="right", fontsize=8.5)
    church_style(fig, ax, "Sabbath School Attendance by Group")
    ax.set_ylabel("Attendance", fontsize=10)
    ax.legend(title="Session", fontsize=9, title_fontsize=9,
               framealpha=0.9, edgecolor=C_GREY)
    add_watermark(fig)
    return fig


# ── 2. Sabbath School compound totals trend ──────────────────────────────────

def plot_sabbath_school_totals_trend(df: pd.DataFrame) -> Optional[Figure]:
    """
    Line chart of Sabbath School morning/afternoon compound totals.
    Reads the same SABBATH SCHOOL DATA*.xlsx.  If unavailable, falls back
    to the weekly sabbath_school_attendance column trend.
    """
    path = _find_xlsx(XLSX_PATTERNS["sabbath_school"])
    if path is not None:
        try:
            return _sabbath_school_totals_from_xlsx(path)
        except Exception as exc:
            log(f"Note: could not parse SS totals from XLSX ({exc}), falling back.")

    if not has_data(df, ["sabbath_school_attendance"]):
        return None
    labels = date_labels(df)
    fig, ax = make_church_fig()
    ax.plot(labels, df["sabbath_school_attendance"], "o-",
            color=C_NAVY, linewidth=2.5, markersize=8, zorder=3)
    for xi, yi in zip(labels, df["sabbath_school_attendance"].fillna(0)):
        if yi > 0:
            ax.annotate(str(int(yi)), (xi, yi),
                        textcoords="offset points", xytext=(0, 10),
                        ha="center", fontsize=9, fontweight="bold", color=C_NAVY)
    church_style(fig, ax, "Sabbath School Attendance Totals Trend")
    ax.set_ylabel("Total Attendance", fontsize=10)
    ax.tick_params(axis="x", rotation=25)
    add_watermark(fig)
    return fig


def _sabbath_school_totals_from_xlsx(path: Path) -> Optional[Figure]:
    import datetime

    from openpyxl import load_workbook
    wb = load_workbook(path, read_only=True)
    ws = wb.active
    if ws is None:
        return None
    rows = list(ws.iter_rows(values_only=True))

    # Collect all date columns and their TOTAL IN CHURCH COMPOUND rows
    header_row = None
    for i, row in enumerate(rows):
        if any(str(c).strip().upper() == "GROUP" for c in row if c is not None):
            header_row = i
            break
    if header_row is None:
        return None

    date_cols: list[str] = []
    col_indices: list[int] = []
    for ci, val in enumerate(rows[header_row]):
        if isinstance(val, datetime.datetime):
            date_cols.append(val.strftime("%b %-d"))
            col_indices.append(ci)
        elif isinstance(val, str) and re.match(r"\d{1,2}/\d{1,2}/\d{4}", val.strip()):
            date_cols.append(val.strip())
            col_indices.append(ci)

    if not date_cols:
        return None

    morning_totals: list[float] = [0.0] * len(date_cols)
    afternoon_totals: list[float] = [0.0] * len(date_cols)
    in_afternoon = False

    for row in rows[header_row + 1:]:
        label = str(row[1]).strip().upper() if len(row) > 1 and row[1] else ""
        if "AFTERNOON" in label or "PM" in label:
            in_afternoon = True
        if "TOTAL IN CHURCH" in label or ("TOTAL" in label and "COMPOUND" in label):
            for si, ci in enumerate(col_indices):
                v = row[ci] if ci < len(row) else None
                val = float(v) if isinstance(v, (int, float)) else 0.0
                if in_afternoon:
                    afternoon_totals[si] = val
                else:
                    morning_totals[si] = val

    if all(v == 0 for v in morning_totals):
        return None

    fig, ax = make_church_fig(figsize=(8, 5))
    ax.plot(date_cols, morning_totals, "o-", color=C_NAVY, linewidth=2.5, markersize=8,
            label="Morning Session", zorder=3)
    if any(v > 0 for v in afternoon_totals):
        ax.plot(date_cols, afternoon_totals, "s--", color=C_GOLD, linewidth=2.5, markersize=8,
                label="Afternoon Session", zorder=3)
    for xi, yi in zip(date_cols, morning_totals):
        ax.annotate(str(int(yi)), (xi, yi),
                    textcoords="offset points", xytext=(0, 10),
                    ha="center", fontsize=10, fontweight="bold", color=C_NAVY)
    for xi, yi in zip(date_cols, afternoon_totals):
        if yi > 0:
            ax.annotate(str(int(yi)), (xi, yi),
                        textcoords="offset points", xytext=(0, -16),
                        ha="center", fontsize=10, fontweight="bold", color=C_GOLD)

    church_style(fig, ax, "Sabbath School – Church Compound Totals")
    ax.set_ylabel("Total People", fontsize=10)
    ax.legend(fontsize=9, framealpha=0.9, edgecolor=C_GREY)
    ax.set_ylim(0, max(morning_totals) * 1.25)
    add_watermark(fig)
    return fig


# ── 3. Home Church total attendance (horizontal bar, ranked) ─────────────────

def _load_home_church_xlsx() -> Optional[pd.DataFrame]:
    """
    Parse HOME CHURCH DATA*.xlsx.
    Returns a DataFrame with columns:
        home_church, adults_m, adults_f, youth_m, youth_f,
        amb_m, amb_f, children_m, children_f, visitors_m, visitors_f, total
    """
    path = _find_xlsx(XLSX_PATTERNS["home_church"])
    if path is None:
        return None
    try:
        from openpyxl import load_workbook
        wb = load_workbook(path, read_only=True)
        ws = wb.active
        if ws is None:
            return None
        rows = list(ws.iter_rows(values_only=True))
    except Exception as exc:
        log(f"Note: could not open Home Church XLSX ({exc}).")
        return None

    records = []
    for row in rows[12:]:          # first 12 rows are headers / metadata
        name = row[1] if len(row) > 1 else None
        if name is None:
            continue
        name_str = str(name).strip()
        if not name_str or "TOTAL" in name_str.upper():
            continue
        vals = [row[j] if j < len(row) else None for j in range(2, 12)]
        def g(i): return float(vals[i]) if isinstance(vals[i], (int, float)) else 0.0
        records.append({
            "home_church":  name_str.title(),
            "adults_m":     g(0), "adults_f": g(1),
            "youth_m":      g(2), "youth_f":  g(3),
            "amb_m":        g(4), "amb_f":    g(5),
            "children_m":   g(6), "children_f": g(7),
            "visitors_m":   g(8), "visitors_f": g(9),
        })
    if not records:
        return None
    hc = pd.DataFrame(records)
    hc["total"] = hc[["adults_m", "adults_f", "youth_m", "youth_f",
                       "amb_m", "amb_f", "children_m", "children_f",
                       "visitors_m", "visitors_f"]].sum(axis=1)
    return hc


def plot_home_church_attendance(df: pd.DataFrame) -> Optional[Figure]:
    """Horizontal bar chart of Home Church total attendance, ranked."""
    hc = _load_home_church_xlsx()
    if hc is None or hc.empty:
        return None

    hc = hc.sort_values("total", ascending=True)
    colors = [C_NAVY if i % 2 == 0 else C_SKY for i in range(len(hc))]

    fig, ax = make_church_fig(figsize=(10, 7))
    bars = ax.barh(hc["home_church"], hc["total"], color=colors, height=0.65, zorder=3)
    for bar in bars:
        w = bar.get_width()
        ax.text(w + max(hc["total"]) * 0.01, bar.get_y() + bar.get_height() / 2,
                str(int(w)), va="center", ha="left",
                fontsize=9, fontweight="bold", color=C_NAVY)
    church_style(fig, ax, "Home Church Attendance — Q1 2026")
    ax.set_xlabel("Total Attendance", fontsize=10)
    ax.set_xlim(0, max(hc["total"]) * 1.12)
    ax.yaxis.grid(False)
    ax.xaxis.grid(True, color=C_GREY, linewidth=0.6, linestyle="--", alpha=0.8)
    add_watermark(fig)
    return fig


# ── 4. Home Church stacked breakdown ────────────────────────────────────────

def plot_home_church_stacked(df: pd.DataFrame) -> Optional[Figure]:
    """Stacked bar chart showing category breakdown per home church."""
    hc = _load_home_church_xlsx()
    if hc is None or hc.empty:
        return None

    hc = hc.sort_values("total", ascending=False)

    categories = {
        "Adults (M)":   hc["adults_m"].tolist(),
        "Adults (F)":   hc["adults_f"].tolist(),
        "Youth (M)":    hc["youth_m"].tolist(),
        "Youth (F)":    hc["youth_f"].tolist(),
        "Ambassadors":  (hc["amb_m"] + hc["amb_f"]).tolist(),
        "Children":     (hc["children_m"] + hc["children_f"]).tolist(),
        "Visitors":     (hc["visitors_m"] + hc["visitors_f"]).tolist(),
    }
    cat_colors = [C_NAVY, C_SKY, C_GREEN, "#88C070", C_GOLD, C_ROSE, C_SLATE]

    x = np.arange(len(hc))
    fig, ax = make_church_fig(figsize=(13, 6))
    bottoms = np.zeros(len(hc))
    for (label, vals), col in zip(categories.items(), cat_colors):
        ax.bar(x, vals, 0.65, bottom=bottoms, label=label, color=col, zorder=3)
        bottoms += np.array(vals)

    ax.set_xticks(x)
    ax.set_xticklabels(hc["home_church"], rotation=35, ha="right", fontsize=8)
    church_style(fig, ax, "Home Church Attendance — Category Breakdown")
    ax.set_ylabel("Attendance", fontsize=10)
    ax.legend(fontsize=8.5, ncol=4, loc="upper right", framealpha=0.9, edgecolor=C_GREY)
    add_watermark(fig)
    return fig


# ── 5. Business Meeting per home church ─────────────────────────────────────

def _load_business_meeting_xlsx() -> Optional[pd.DataFrame]:
    path = _find_xlsx(XLSX_PATTERNS["business_meeting"])
    if path is None:
        return None
    try:
        from openpyxl import load_workbook
        wb = load_workbook(path, read_only=True)
        ws = wb.active
        if ws is None:
            return None
        rows = list(ws.iter_rows(values_only=True))
    except Exception as exc:
        log(f"Note: could not open Business Meeting XLSX ({exc}).")
        return None

    records = []
    for row in rows:
        if not isinstance(row[0], int):
            continue
        name = row[1] if len(row) > 1 else None
        if name is None:
            continue
        att = float(row[4]) if len(row) > 4 and isinstance(row[4], (int, float)) else 0.0
        exp = float(row[6]) if len(row) > 6 and isinstance(row[6], (int, float)) else 0.0
        if exp > 0 or att > 0:
            records.append({"home_church": str(name).title(), "attended": att, "expected": exp})
    return pd.DataFrame(records) if records else None


def plot_business_meeting_per_home_church(df: pd.DataFrame) -> Optional[Figure]:
    """Grouped bar: Business Meeting attended vs expected per home church."""
    bm = _load_business_meeting_xlsx()
    if bm is None or bm.empty:
        # Fallback: use weekly board_business_meeting columns
        return plot_board_business_meeting_expected_vs_attended(df)

    bm = bm.sort_values("expected", ascending=False)
    x = np.arange(len(bm))
    w = 0.35

    fig, ax = make_church_fig(figsize=(13, 6))
    ax.bar(x - w / 2, bm["expected"], w, label="Expected", color=C_GREY,  zorder=3)
    ax.bar(x + w / 2, bm["attended"], w, label="Attended",  color=C_NAVY, zorder=3)

    for xi, (att, exp) in enumerate(zip(bm["attended"], bm["expected"])):
        if exp > 0:
            pct = att / exp * 100
            ax.text(xi, max(att, exp) + ax.get_ylim()[1] * 0.01,
                    f"{pct:.0f}%", ha="center", va="bottom",
                    fontsize=8, fontweight="bold",
                    color=C_GREEN if pct >= 80 else C_ROSE)
        ax.text(xi + w / 2, att / 2 if att > 0 else 0,
                str(int(att)), ha="center", va="center",
                fontsize=8, fontweight="bold", color=C_WHITE)

    ax.set_xticks(x)
    ax.set_xticklabels(bm["home_church"], rotation=35, ha="right", fontsize=8)
    church_style(fig, ax, "Business Meeting Attendance vs Expected — Q1 2026")
    ax.set_ylabel("People", fontsize=10)
    ax.legend(fontsize=9, framealpha=0.9, edgecolor=C_GREY)
    add_watermark(fig)
    return fig


# ── 6. Active Leaders — Board Meeting monthly trend ──────────────────────────

def plot_active_leaders_board(df: pd.DataFrame) -> Optional[Figure]:
    """
    Monthly board meeting attended vs expected (56).
    Uses board_business_meeting_attendance from the weekly data, grouped by
    month, OR parses the BOARD MEETING ATTENDANCE*.xlsx directly.
    """
    path = _find_xlsx(XLSX_PATTERNS["board_meeting"])
    if path is not None:
        try:
            return _board_meeting_from_xlsx(path)
        except Exception as exc:
            log(f"Note: could not parse Board Meeting XLSX ({exc}), falling back to weekly data.")

    if not has_data(df, ["board_business_meeting_attendance"]):
        return None

    temp = df[["week_start_date", "board_business_meeting_attendance",
               "board_business_meeting_expected"]].copy()
    temp["month"] = pd.to_datetime(temp["week_start_date"], errors="coerce").dt.to_period("M")
    monthly = temp.groupby("month", sort=True).agg(
        attended=("board_business_meeting_attendance", "sum"),
        expected=("board_business_meeting_expected", "sum"),
    ).reset_index()
    if monthly.empty:
        return None

    months   = [str(m) for m in monthly["month"]]
    attended = monthly["attended"].tolist()
    expected = [e if e > 0 else 56 for e in monthly["expected"]]  # default board size
    pcts     = [a / e * 100 if e > 0 else 0 for a, e in zip(attended, expected)]
    return _draw_board_chart(months, attended, expected, pcts)


def _board_meeting_from_xlsx(path: Path) -> Optional[Figure]:
    from openpyxl import load_workbook
    wb = load_workbook(path, read_only=True)
    ws = wb.active
    if ws is None:
        return None
    rows = list(ws.iter_rows(values_only=True))

    months, attended, expected = [], [], []
    MONTH_NAMES = {"january", "february", "march", "april", "may", "june",
                   "july", "august", "september", "october", "november", "december"}
    for row in rows:
        # Month name is in column index 1 (B)
        label = row[1] if len(row) > 1 else None
        if label is None:
            continue
        label_str = str(label).strip()
        if label_str.lower() not in MONTH_NAMES:
            continue
        att = float(row[2]) if len(row) > 2 and isinstance(row[2], (int, float)) else 0.0
        exp = float(row[4]) if len(row) > 4 and isinstance(row[4], (int, float)) else 56.0
        months.append(label_str.title())
        attended.append(att)
        expected.append(exp if exp > 0 else 56.0)

    if not months:
        return None

    pcts = [a / e * 100 if e > 0 else 0 for a, e in zip(attended, expected)]
    return _draw_board_chart(months, attended, expected, pcts)


def _draw_board_chart(months: list, attended: list, expected: list, pcts: list) -> Figure:
    x = np.arange(len(months))
    w = 0.32

    fig, ax = make_church_fig(figsize=(9, 5))
    ax.bar(x - w / 2, expected, w, label=f"Expected",  color=C_GREY,  zorder=3)
    ax.bar(x + w / 2, attended, w, label="Attended",   color=C_NAVY,  zorder=3)

    for xi, (att, exp, pct) in enumerate(zip(attended, expected, pcts)):
        ax.text(xi + w / 2, att + max(attended) * 0.02,
                f"{pct:.0f}%", ha="center", va="bottom",
                fontsize=10, fontweight="bold",
                color=C_GREEN if pct >= 80 else C_ROSE)
        if att > 0:
            ax.text(xi + w / 2, att / 2,
                    str(int(att)), ha="center", va="center",
                    fontsize=10, fontweight="bold", color=C_WHITE)

    # Trend line over attended
    ax.plot(x + w / 2, attended, "D--", color=C_ROSE, linewidth=1.8, markersize=0, zorder=5)

    ax.set_xticks(x)
    ax.set_xticklabels(months, fontsize=10)
    ax.set_ylim(0, max(expected) * 1.3)
    church_style(fig, ax, "Active Church Leaders — Board Meeting Attendance 2026")
    ax.set_ylabel("Number of Leaders", fontsize=10)
    ax.legend(fontsize=9.5, framealpha=0.9, edgecolor=C_GREY)
    add_watermark(fig)
    return fig


# ── 7. Church composition donut ──────────────────────────────────────────────

def plot_church_composition_donut(df: pd.DataFrame) -> Optional[Figure]:
    """Donut chart of average weekly attendance by category."""
    parts = [c for c in ["men", "women", "youth", "children"] if has_data(df, [c])]
    if not parts:
        return None

    avgs   = [df[c].mean() for c in parts]
    labels = [c.title() for c in parts]
    colors = [C_NAVY, C_ROSE, C_GREEN, C_GOLD][:len(parts)]
    total  = sum(avgs)

    fig, ax = plt.subplots(figsize=(7, 6))
    fig.patch.set_facecolor(C_WHITE)
    pie_result = ax.pie(
        avgs, labels=labels, autopct="%1.1f%%",
        colors=colors, startangle=90,
        wedgeprops=dict(width=0.45, edgecolor=C_WHITE, linewidth=2),
        pctdistance=0.75,
        textprops=dict(fontsize=11),
    )
    # ax.pie() returns (wedges, label_texts, autotext_texts) when autopct is set
    autotexts: list = pie_result[2] if len(pie_result) > 2 else []
    for t in autotexts:
        t.set_color(C_WHITE)
        t.set_fontweight("bold")
        t.set_fontsize(10)

    ax.text(0, 0, f"{int(total):,}\nAvg/Week",
            ha="center", va="center",
            fontsize=12, fontweight="bold", color=C_NAVY)
    ax.set_title("Average Weekly Church Composition — Q1 2026",
                 fontsize=13, fontweight="bold", color=C_NAVY, pad=16)
    add_watermark(fig)
    return fig


# ── 8. Weekly demographic trend (styled) ────────────────────────────────────

def plot_demographic_trends_styled(df: pd.DataFrame) -> Optional[Figure]:
    """Multi-line weekly attendance trend with church palette + fill."""
    columns = [c for c in ["men", "women", "youth", "children"] if has_data(df, [c])]
    if len(columns) < 2:
        return None

    labels  = date_labels(df)
    markers = ["o", "s", "^", "D"]
    colors  = [C_NAVY, C_ROSE, C_GREEN, C_GOLD]

    fig, ax = make_church_fig(figsize=(12, 5.5))
    for col, marker, color in zip(columns, markers, colors):
        ax.plot(labels, df[col], f"{marker}-",
                color=color, linewidth=2.5, markersize=7,
                label=col.title(), zorder=3)
        ax.fill_between(labels, df[col], alpha=0.06, color=color)

    church_style(fig, ax, "Weekly Sabbath Attendance by Category — Q1 2026")
    ax.set_ylabel("Attendance Count", fontsize=10)
    ax.set_xlabel("Sabbath Date", fontsize=10)
    ax.legend(fontsize=9.5, framealpha=0.9, edgecolor=C_GREY, loc="upper left")
    ax.tick_params(axis="x", rotation=25)
    add_watermark(fig)
    return fig


# ── 9. Financial trend (styled) ──────────────────────────────────────────────

def plot_financial_trend_styled(df: pd.DataFrame) -> Optional[Figure]:
    """Tithe & Offerings trend with fill under curves."""
    if not has_data(df, ["tithe", "offerings"]):
        return None

    labels = date_labels(df)
    fig, ax = make_church_fig(figsize=(12, 5))
    ax.fill_between(labels, df["tithe"].fillna(0),    alpha=0.18, color=C_NAVY)
    ax.fill_between(labels, df["offerings"].fillna(0), alpha=0.18, color=C_GOLD)
    ax.plot(labels, df["tithe"],    "o-",  color=C_NAVY, linewidth=2.5, markersize=7,
            label="Tithe", zorder=3)
    ax.plot(labels, df["offerings"], "s--", color=C_GOLD, linewidth=2.5, markersize=7,
            label="Offerings", zorder=3)
    church_style(fig, ax, "Weekly Tithe & Offerings — Q1 2026")
    ax.set_ylabel("KES", fontsize=10)
    ax.legend(fontsize=9.5, framealpha=0.9, edgecolor=C_GREY)
    ax.tick_params(axis="x", rotation=25)
    add_watermark(fig)
    return fig


# ── 10. Holy Communion per home church ───────────────────────────────────────

def _load_holy_communion_xlsx() -> Optional[pd.DataFrame]:
    path = _find_xlsx(XLSX_PATTERNS["holy_communion"])
    if path is None:
        return None
    try:
        from openpyxl import load_workbook
        wb = load_workbook(path, read_only=True)
        ws = wb.active
        if ws is None:
            return None
        rows = list(ws.iter_rows(values_only=True))
    except Exception as exc:
        log(f"Note: could not open Holy Communion XLSX ({exc}).")
        return None

    records = []
    for row in rows:
        if not isinstance(row[0], int):
            continue
        name = row[1] if len(row) > 1 else None
        if name is None:
            continue
        att = float(row[2]) if len(row) > 2 and isinstance(row[2], (int, float)) else 0.0
        exp = float(row[3]) if len(row) > 3 and isinstance(row[3], (int, float)) else 0.0
        records.append({"home_church": str(name).title(), "attended": att, "expected": exp})
    return pd.DataFrame(records) if records else None


def plot_holy_communion_per_home_church(df: pd.DataFrame) -> Optional[Figure]:
    """Grouped bar: Holy Communion attended vs expected per home church."""
    hc = _load_holy_communion_xlsx()
    if hc is None or hc.empty:
        return plot_holy_communion_expected_vs_attended(df)

    hc = hc.sort_values("expected", ascending=False)
    x = np.arange(len(hc))
    w = 0.35

    fig, ax = make_church_fig(figsize=(14, 6))
    ax.bar(x - w / 2, hc["expected"], w, label="Expected", color=C_GREY, zorder=3)
    ax.bar(x + w / 2, hc["attended"], w, label="Attended",  color=C_GOLD, zorder=3)

    for xi, (att, exp) in enumerate(zip(hc["attended"], hc["expected"])):
        if exp > 0:
            pct = att / exp * 100
            ax.text(xi, max(att, exp) + ax.get_ylim()[1] * 0.01,
                    f"{pct:.0f}%", ha="center", va="bottom",
                    fontsize=7, fontweight="bold",
                    color=C_GREEN if pct >= 50 else C_ROSE)

    ax.set_xticks(x)
    ax.set_xticklabels(hc["home_church"], rotation=38, ha="right", fontsize=8)
    church_style(fig, ax, "Holy Communion Q1 2026 — Attendance vs Expected")
    ax.set_ylabel("People", fontsize=10)
    ax.legend(fontsize=9, framealpha=0.9, edgecolor=C_GREY)
    add_watermark(fig)
    return fig


# ---------------------------------------------------------------------------
# Graph builders
# ---------------------------------------------------------------------------


def plot_total_attendance_trend(df: pd.DataFrame) -> Optional[Figure]:
    if not has_data(df, ["total_attendance"]):
        return None
    labels = date_labels(df)
    fig, ax = plt.subplots(figsize=(11, 5))
    ax.plot(labels, df["total_attendance"], marker="o", linewidth=2.2, color="#2563eb")
    add_mean_line(ax, df["total_attendance"])
    configure_axes(ax, "Total Attendance Trend", "Attendance")
    ax.tick_params(axis="x", rotation=25)
    ax.legend()
    return fig


def plot_demographic_trends(df: pd.DataFrame) -> Optional[Figure]:
    columns = [c for c in ATTENDANCE_PARTS if has_data(df, [c])]
    if len(columns) < 2:
        return None
    labels = date_labels(df)
    fig, ax = plt.subplots(figsize=(11, 5))
    for column in columns:
        ax.plot(labels, df[column], marker="o", linewidth=1.8, label=column.replace("_", " ").title())
    configure_axes(ax, "Attendance Trends by Group", "Attendance")
    ax.tick_params(axis="x", rotation=25)
    ax.legend()
    return fig


def plot_attendance_by_group(df: pd.DataFrame) -> Optional[Figure]:
    columns = [c for c in ATTENDANCE_PARTS if has_data(df, [c])]
    if len(columns) < 2:
        return None
    labels = date_labels(df)
    x = np.arange(len(labels))
    width = min(0.8 / len(columns), 0.18)
    fig, ax = plt.subplots(figsize=(12, 5.5))
    offset_start = -width * (len(columns) - 1) / 2
    for index, column in enumerate(columns):
        ax.bar(x + offset_start + index * width, df[column].fillna(0), width, label=column.replace("_", " ").title())
    ax.set_xticks(x)
    ax.set_xticklabels(labels, rotation=25, ha="right")
    configure_axes(ax, "Attendance by Group per Week", "Attendance")
    ax.legend(ncol=min(len(columns), 3))
    return fig


def plot_attendance_distribution(df: pd.DataFrame) -> Optional[Figure]:
    columns = [c for c in ATTENDANCE_PARTS if has_data(df, [c])]
    if not columns:
        return None
    totals = [numeric_series(df, c).sum() for c in columns]
    if sum(totals) <= 0:
        return None
    fig, ax = plt.subplots(figsize=(7, 7))
    ax.pie(totals, labels=[c.replace("_", " ").title() for c in columns], autopct="%1.1f%%", startangle=90)
    ax.set_title("Attendance Distribution")
    return fig


def plot_attendance_growth(df: pd.DataFrame) -> Optional[Figure]:
    if not has_data(df, ["attendance_growth"]):
        return None
    labels = date_labels(df)
    values = df["attendance_growth"].fillna(0)
    colors = ["#16a34a" if value >= 0 else "#dc2626" for value in values]
    fig, ax = plt.subplots(figsize=(11, 5))
    ax.bar(labels, values, color=colors)
    ax.axhline(0, color="#111111", linewidth=0.8)
    configure_axes(ax, "Week-over-Week Attendance Growth", "Growth %")
    ax.tick_params(axis="x", rotation=25)
    return fig


def plot_adult_vs_young(df: pd.DataFrame) -> Optional[Figure]:
    if not has_data(df, ["adult_attendance", "young_attendance"]):
        return None
    labels = date_labels(df)
    x = np.arange(len(labels))
    width = 0.35
    fig, ax = plt.subplots(figsize=(11, 5))
    ax.bar(x - width / 2, df["adult_attendance"], width, label="Adults")
    ax.bar(x + width / 2, df["young_attendance"], width, label="Young")
    ax.set_xticks(x)
    ax.set_xticklabels(labels, rotation=25, ha="right")
    configure_axes(ax, "Adult vs Young Attendance", "Attendance")
    ax.legend()
    return fig


def plot_demographic_percentage_trends(df: pd.DataFrame) -> Optional[Figure]:
    columns = ["men_pct", "women_pct", "youth_pct", "children_pct"]
    if not has_data(df, columns):
        return None
    labels = date_labels(df)
    fig, ax = plt.subplots(figsize=(11, 5))
    for column in columns:
        ax.plot(labels, df[column], marker="o", linewidth=1.8, label=column.replace("_pct", "").title())
    configure_axes(ax, "Demographic Percentage Trends", "Share of Sabbath Attendance (%)")
    ax.tick_params(axis="x", rotation=25)
    ax.legend()
    return fig


def plot_average_demographic_percentage(df: pd.DataFrame) -> Optional[Figure]:
    columns = ["men_pct", "women_pct", "youth_pct", "children_pct"]
    if not has_data(df, columns):
        return None
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.bar(["Men", "Women", "Youth", "Children"], [df[c].mean() for c in columns], color="#2563eb")
    configure_axes(ax, "Average Demographic Percentage", "Percentage (%)")
    return fig


def plot_sabbath_school_trend(df: pd.DataFrame) -> Optional[Figure]:
    if not has_data(df, ["sabbath_school_attendance"]):
        return None
    labels = date_labels(df)
    fig, ax = plt.subplots(figsize=(11, 5))
    ax.plot(labels, df["sabbath_school_attendance"], marker="o", linewidth=2, color="#7c3aed")
    add_mean_line(ax, df["sabbath_school_attendance"])
    configure_axes(ax, "Sabbath School Attendance Trend", "Attendance")
    ax.tick_params(axis="x", rotation=25)
    ax.legend()
    return fig


def plot_visitors_trend(df: pd.DataFrame) -> Optional[Figure]:
    if not has_data(df, ["visitors_count"]):
        return None
    labels = date_labels(df)
    fig, ax = plt.subplots(figsize=(11, 5))
    ax.bar(labels, df["visitors_count"].fillna(0), color="#0f766e")
    configure_axes(ax, "Visitors per Week", "Visitors")
    ax.tick_params(axis="x", rotation=25)
    return fig


def plot_tithe_offerings_trend(df: pd.DataFrame) -> Optional[Figure]:
    if not has_data(df, ["tithe", "offerings"]):
        return None
    labels = date_labels(df)
    fig, ax = plt.subplots(figsize=(11, 5))
    ax.plot(labels, df["tithe"], marker="o", linewidth=2, label="Tithe")
    ax.plot(labels, df["offerings"], marker="s", linewidth=2, label="Offerings")
    configure_axes(ax, "Tithe vs Offerings Trend", "Amount")
    ax.tick_params(axis="x", rotation=25)
    ax.legend()
    return fig


def plot_income_composition(df: pd.DataFrame) -> Optional[Figure]:
    columns = [c for c in INCOME_PARTS if has_data(df, [c])]
    if len(columns) < 2:
        return None
    labels = date_labels(df)
    fig, ax = plt.subplots(figsize=(11, 5))
    ax.stackplot(labels, [df[c].fillna(0) for c in columns], labels=[c.replace("_", " ").title() for c in columns], alpha=0.85)
    configure_axes(ax, "Income Composition over Time", "Amount")
    ax.tick_params(axis="x", rotation=25)
    ax.legend(loc="upper left")
    return fig


def plot_income_distribution(df: pd.DataFrame) -> Optional[Figure]:
    columns = [c for c in INCOME_PARTS if has_data(df, [c])]
    if not columns:
        return None
    totals = [numeric_series(df, c).sum() for c in columns]
    if sum(totals) <= 0:
        return None
    fig, ax = plt.subplots(figsize=(7, 7))
    ax.pie(totals, labels=[c.replace("_", " ").title() for c in columns], autopct="%1.1f%%", startangle=90)
    ax.set_title("Income Distribution")
    return fig


def plot_income_vs_attendance_dual(df: pd.DataFrame) -> Optional[Figure]:
    if not has_data(df, ["total_attendance", "total_income"]):
        return None
    labels = date_labels(df)
    fig, ax1 = plt.subplots(figsize=(11, 5))
    ax2 = ax1.twinx()
    ax1.plot(labels, df["total_attendance"], marker="o", color="#2563eb", label="Attendance")
    ax2.plot(labels, df["total_income"], marker="s", color="#16a34a", label="Income")
    ax1.set_title("Total Attendance vs Total Income")
    ax1.set_ylabel("Attendance")
    ax2.set_ylabel("Income")
    ax1.tick_params(axis="x", rotation=25)
    lines, labels_combined = [], []
    for axis in (ax1, ax2):
        handles, axis_labels = axis.get_legend_handles_labels()
        lines.extend(handles)
        labels_combined.extend(axis_labels)
    ax1.legend(lines, labels_combined, loc="upper left")
    ax1.grid(True, alpha=0.25)
    return fig


def pairwise_bar(df: pd.DataFrame, left: str, right: str, title: str, ylabel: str = "Amount") -> Optional[Figure]:
    if not has_data(df, [left, right]):
        return None
    labels = date_labels(df)
    x = np.arange(len(labels))
    width = 0.35
    fig, ax = plt.subplots(figsize=(11, 5))
    ax.bar(x - width / 2, df[left].fillna(0), width, label=left.replace("_", " ").title())
    ax.bar(x + width / 2, df[right].fillna(0), width, label=right.replace("_", " ").title())
    ax.set_xticks(x)
    ax.set_xticklabels(labels, rotation=25, ha="right")
    configure_axes(ax, title, ylabel)
    ax.legend()
    return fig


def plot_regular_vs_total_income(df: pd.DataFrame) -> Optional[Figure]:
    return pairwise_bar(df, "regular_income", "total_income", "Regular vs Total Income per Week")


def plot_income_growth(df: pd.DataFrame) -> Optional[Figure]:
    if not has_data(df, ["income_growth"]):
        return None
    labels = date_labels(df)
    values = df["income_growth"].fillna(0)
    colors = ["#16a34a" if value >= 0 else "#dc2626" for value in values]
    fig, ax = plt.subplots(figsize=(11, 5))
    ax.bar(labels, values, color=colors)
    ax.axhline(0, color="#111111", linewidth=0.8)
    configure_axes(ax, "Week-over-Week Income Growth", "Growth %")
    ax.tick_params(axis="x", rotation=25)
    return fig


def plot_per_capita_metrics(df: pd.DataFrame) -> Optional[Figure]:
    columns = ["income_per_attendee", "tithe_per_attendee", "offerings_per_attendee"]
    if not has_data(df, columns):
        return None
    labels = date_labels(df)
    fig, ax = plt.subplots(figsize=(11, 5))
    for column in columns:
        ax.plot(labels, df[column], marker="o", linewidth=1.8, label=column.replace("_", " ").title())
    configure_axes(ax, "Per Capita Giving Metrics", "Amount")
    ax.tick_params(axis="x", rotation=25)
    ax.legend()
    return fig


def plot_tithe_per_attendee(df: pd.DataFrame) -> Optional[Figure]:
    if not has_data(df, ["tithe_per_attendee"]):
        return None
    labels = date_labels(df)
    fig, ax = plt.subplots(figsize=(11, 5))
    ax.bar(labels, df["tithe_per_attendee"].fillna(0), color="#16a34a")
    configure_axes(ax, "Tithe per Attendee", "Amount")
    ax.tick_params(axis="x", rotation=25)
    return fig


def plot_regular_income_per_adult(df: pd.DataFrame) -> Optional[Figure]:
    if not has_data(df, ["regular_income_per_adult"]):
        return None
    labels = date_labels(df)
    fig, ax = plt.subplots(figsize=(11, 5))
    ax.bar(labels, df["regular_income_per_adult"].fillna(0), color="#2563eb")
    configure_axes(ax, "Regular Income per Adult", "Amount")
    ax.tick_params(axis="x", rotation=25)
    return fig


def plot_ratio_trends(df: pd.DataFrame) -> Optional[Figure]:
    columns = ["men_women_ratio", "adult_young_ratio", "tithe_offerings_ratio"]
    if not has_data(df, columns):
        return None
    labels = date_labels(df)
    fig, ax = plt.subplots(figsize=(11, 5))
    for column in columns:
        ax.plot(labels, df[column], marker="o", linewidth=1.8, label=column.replace("_", " ").title())
    configure_axes(ax, "Ratio Trends", "Ratio")
    ax.tick_params(axis="x", rotation=25)
    ax.legend()
    return fig


def plot_baptisms_trend(df: pd.DataFrame) -> Optional[Figure]:
    if not has_data(df, ["baptisms"]):
        return None
    labels = date_labels(df)
    fig, ax = plt.subplots(figsize=(11, 5))
    ax.bar(labels, df["baptisms"].fillna(0), color="#0284c7")
    configure_axes(ax, "Baptisms per Week", "Baptisms")
    ax.tick_params(axis="x", rotation=25)
    return fig


def plot_holy_communion_trend(df: pd.DataFrame) -> Optional[Figure]:
    if not has_data(df, ["holy_communion"]):
        return None
    labels = date_labels(df)
    fig, ax = plt.subplots(figsize=(11, 5))
    ax.plot(labels, df["holy_communion"], marker="o", linewidth=2, color="#9333ea")
    configure_axes(ax, "Holy Communion Attendance", "Attendance")
    ax.tick_params(axis="x", rotation=25)
    return fig


def plot_baptisms_vs_holy_communion(df: pd.DataFrame) -> Optional[Figure]:
    return pairwise_bar(df, "baptisms", "holy_communion", "Baptisms vs Holy Communion", "Count")


def plot_holy_communion_expected_vs_attended(df: pd.DataFrame) -> Optional[Figure]:
    return pairwise_bar(
        df,
        "holy_communion",
        "holy_communion_expected",
        "Holy Communion: Attended vs Expected",
        "Count",
    )


def plot_ambassadors_trend(df: pd.DataFrame) -> Optional[Figure]:
    if not has_data(df, ["ambassadors_attendance"]):
        return None
    labels = date_labels(df)
    fig, ax = plt.subplots(figsize=(11, 5))
    ax.plot(labels, df["ambassadors_attendance"], marker="o", linewidth=2, color="#f59e0b")
    add_mean_line(ax, df["ambassadors_attendance"])
    configure_axes(ax, "Ambassadors Attendance Trend", "Attendance")
    ax.tick_params(axis="x", rotation=25)
    ax.legend()
    return fig


def plot_board_business_meeting_trend(df: pd.DataFrame) -> Optional[Figure]:
    if not has_data(df, ["board_business_meeting_attendance"]):
        return None
    labels = date_labels(df)
    fig, ax = plt.subplots(figsize=(11, 5))
    ax.plot(labels, df["board_business_meeting_attendance"], marker="o", linewidth=2, color="#0ea5e9")
    add_mean_line(ax, df["board_business_meeting_attendance"])
    configure_axes(ax, "Board/Business Meeting Attendance", "Attendance")
    ax.tick_params(axis="x", rotation=25)
    ax.legend()
    return fig


def plot_board_business_meeting_expected_vs_attended(df: pd.DataFrame) -> Optional[Figure]:
    return pairwise_bar(
        df,
        "board_business_meeting_attendance",
        "board_business_meeting_expected",
        "Board/Business Meeting: Attended vs Expected",
        "Attendance",
    )


def plot_attendance_income_scatter(df: pd.DataFrame) -> Optional[Figure]:
    clean = clean_positive_pairs(df, "total_attendance", "total_income")
    if len(clean) < 2:
        return None
    fig, ax = plt.subplots(figsize=(8, 6))
    ax.scatter(clean["total_attendance"], clean["total_income"], color="#2563eb", s=70, alpha=0.75)
    if clean["total_attendance"].nunique() > 1:
        fit = np.polyfit(clean["total_attendance"], clean["total_income"], 1)
        line = np.poly1d(fit)
        xs = np.linspace(clean["total_attendance"].min(), clean["total_attendance"].max(), 100)
        ax.plot(xs, line(xs), "--", color="#dc2626", linewidth=1.5)
    configure_axes(ax, "Attendance vs Income Correlation", "Total Income")
    ax.set_xlabel("Total Attendance")
    return fig


def dual_axis(df: pd.DataFrame, primary: str, secondary: str, title: str) -> Optional[Figure]:
    if not has_data(df, [primary, secondary]):
        return None
    labels = date_labels(df)
    fig, ax1 = plt.subplots(figsize=(11, 5))
    ax2 = ax1.twinx()
    ax1.plot(labels, df[primary], marker="o", color="#2563eb", label=primary.replace("_", " ").title())
    ax2.plot(labels, df[secondary], marker="s", color="#f97316", label=secondary.replace("_", " ").title())
    ax1.set_title(title)
    ax1.set_ylabel(primary.replace("_", " ").title())
    ax2.set_ylabel(secondary.replace("_", " ").title())
    ax1.tick_params(axis="x", rotation=25)
    ax1.grid(True, alpha=0.25)
    lines, labels_combined = [], []
    for axis in (ax1, ax2):
        handles, axis_labels = axis.get_legend_handles_labels()
        lines.extend(handles)
        labels_combined.extend(axis_labels)
    ax1.legend(lines, labels_combined, loc="upper left")
    return fig


def plot_correlation_heatmap(df: pd.DataFrame) -> Optional[Figure]:
    columns = [
        "men",
        "women",
        "youth",
        "children",
        "sunday_home_church",
        "total_attendance",
        "tithe",
        "offerings",
        "total_income",
        "baptisms",
        "holy_communion",
        "sabbath_school_attendance",
    ]
    available = [column for column in columns if has_data(df, [column])]
    if len(available) < 3:
        return None
    corr = df[available].corr(numeric_only=True)
    fig, ax = plt.subplots(figsize=(10, 8))
    image = ax.imshow(corr, cmap="coolwarm", vmin=-1, vmax=1)
    ax.set_xticks(np.arange(len(available)))
    ax.set_yticks(np.arange(len(available)))
    ax.set_xticklabels([c.replace("_", " ").title() for c in available], rotation=45, ha="right")
    ax.set_yticklabels([c.replace("_", " ").title() for c in available])
    for row in range(len(available)):
        for col in range(len(available)):
            ax.text(col, row, f"{corr.iloc[row, col]:.2f}", ha="center", va="center", fontsize=8)
    ax.set_title("Metric Correlation Heatmap")
    fig.colorbar(image, ax=ax, shrink=0.8)
    return fig


def plot_distribution_histograms(df: pd.DataFrame) -> Optional[Figure]:
    columns = [
        "men",
        "women",
        "youth",
        "children",
        "sunday_home_church",
        "total_attendance",
        "tithe",
        "offerings",
        "total_income",
    ]
    available = [column for column in columns if has_data(df, [column])]
    if not available:
        return None
    rows = int(np.ceil(len(available) / 3))
    fig, axes = plt.subplots(rows, 3, figsize=(13, max(4, rows * 3.4)))
    axes_flat = np.atleast_1d(axes).ravel()
    for axis, column in zip(axes_flat, available):
        values = numeric_series(df, column).dropna()
        axis.hist(values, bins=min(8, max(3, len(values))), color="#2563eb", alpha=0.78)
        axis.axvline(values.mean(), color="#dc2626", linestyle="--", linewidth=1, label="Mean")
        axis.set_title(column.replace("_", " ").title())
        axis.grid(True, alpha=0.2)
    for axis in axes_flat[len(available) :]:
        axis.axis("off")
    fig.suptitle("Distribution Histograms", y=1.02)
    return fig


def plot_attendance_moving_average(df: pd.DataFrame) -> Optional[Figure]:
    if not has_data(df, ["total_attendance"]) or len(df) < 2:
        return None
    labels = date_labels(df)
    window = min(4, max(2, len(df) // 3 or 2))
    moving = df["total_attendance"].rolling(window=window, min_periods=1).mean()
    fig, ax = plt.subplots(figsize=(11, 5))
    ax.plot(labels, df["total_attendance"], marker="o", label="Actual")
    ax.plot(labels, moving, marker="s", linewidth=2.2, label=f"{window}-Week Moving Average")
    configure_axes(ax, "Attendance Moving Average", "Attendance")
    ax.tick_params(axis="x", rotation=25)
    ax.legend()
    return fig


def plot_attendance_forecast(df: pd.DataFrame) -> Optional[Figure]:
    clean = df[df["week_start_date"].notna() & df["total_attendance"].notna()].copy()
    if len(clean) < 2:
        return None
    clean = clean.sort_values("week_start_date")
    y = clean["total_attendance"].to_numpy(dtype=float)
    x = np.arange(len(clean), dtype=float)
    slope, intercept = np.polyfit(x, y, 1)
    future_steps = np.arange(len(clean), len(clean) + 4, dtype=float)
    future_dates = [clean["week_start_date"].iloc[-1] + pd.Timedelta(days=7 * (i + 1)) for i in range(4)]
    forecast = np.maximum(slope * future_steps + intercept, 0)

    fig, ax = plt.subplots(figsize=(11, 5))
    ax.plot(clean["week_start_date"], y, marker="o", linewidth=2, label="Historical")
    ax.plot(future_dates, forecast, marker="s", linestyle="--", linewidth=2, label="Forecast")
    configure_axes(ax, "Four-Week Attendance Forecast", "Attendance")
    fig.autofmt_xdate()
    ax.legend()
    return fig


def plot_summary_dashboard(df: pd.DataFrame) -> Optional[Figure]:
    if not has_data(df, ["total_attendance", "total_income"]):
        return None
    labels = date_labels(df)
    fig, axes = plt.subplots(2, 2, figsize=(13, 8))

    axes[0, 0].plot(labels, df["total_attendance"], marker="o", color="#2563eb")
    configure_axes(axes[0, 0], "Attendance", "Count")
    axes[0, 0].tick_params(axis="x", rotation=25)

    axes[0, 1].plot(labels, df["total_income"], marker="s", color="#16a34a")
    configure_axes(axes[0, 1], "Income", "Amount")
    axes[0, 1].tick_params(axis="x", rotation=25)

    attendance_cols = [c for c in ATTENDANCE_PARTS if has_data(df, [c])]
    attendance_totals = [df[c].sum() for c in attendance_cols]
    if sum(attendance_totals) > 0:
        axes[1, 0].pie(attendance_totals, labels=[c.replace("_", " ").title() for c in attendance_cols], autopct="%1.1f%%")
    axes[1, 0].set_title("Attendance Mix")

    income_cols = [c for c in INCOME_PARTS if has_data(df, [c])]
    income_totals = [df[c].sum() for c in income_cols]
    if sum(income_totals) > 0:
        axes[1, 1].pie(income_totals, labels=[c.replace("_", " ").title() for c in income_cols], autopct="%1.1f%%")
    axes[1, 1].set_title("Income Mix")

    fig.suptitle("Church Analytics Summary", fontsize=15)
    return fig


GraphBuilder = Callable[[pd.DataFrame], Optional[Figure]]


@dataclass(frozen=True)
class GraphSpec:
    graph_id: str
    title: str
    group: str
    filename: str
    builder: GraphBuilder
    description: str


GRAPH_SPECS: dict[str, GraphSpec] = {
    "total_attendance_trend": GraphSpec(
        "total_attendance_trend",
        "Total Attendance Trend",
        "attendance",
        "total_attendance_trend.png",
        plot_total_attendance_trend,
        "Line chart of app-style total attendance over time.",
    ),
    "demographic_trends": GraphSpec(
        "demographic_trends",
        "Attendance Trends by Group",
        "attendance",
        "demographic_trends.png",
        plot_demographic_trends,
        "Multi-line weekly trend for attendance groups.",
    ),
    "attendance_by_group": GraphSpec(
        "attendance_by_group",
        "Attendance by Group per Week",
        "attendance",
        "attendance_by_group.png",
        plot_attendance_by_group,
        "Grouped bar chart for Men/Women/Youth/Children/Home Church.",
    ),
    "attendance_distribution": GraphSpec(
        "attendance_distribution",
        "Attendance Distribution",
        "attendance",
        "attendance_distribution.png",
        plot_attendance_distribution,
        "Pie chart of aggregate attendance mix.",
    ),
    "attendance_growth": GraphSpec(
        "attendance_growth",
        "Attendance Growth",
        "attendance",
        "attendance_growth.png",
        plot_attendance_growth,
        "Week-over-week attendance growth percentage.",
    ),
    "adult_vs_young": GraphSpec(
        "adult_vs_young",
        "Adult vs Young Attendance",
        "attendance",
        "adult_vs_young.png",
        plot_adult_vs_young,
        "Grouped bar chart of adults against youth and children.",
    ),
    "demographic_percentage_trends": GraphSpec(
        "demographic_percentage_trends",
        "Demographic Percentage Trends",
        "attendance",
        "demographic_percentage_trends.png",
        plot_demographic_percentage_trends,
        "Weekly percentage share of Sabbath attendance groups.",
    ),
    "average_demographic_percentage": GraphSpec(
        "average_demographic_percentage",
        "Average Demographic Percentage",
        "attendance",
        "average_demographic_percentage.png",
        plot_average_demographic_percentage,
        "Average percentage share for Men/Women/Youth/Children.",
    ),
    "sabbath_school_trend": GraphSpec(
        "sabbath_school_trend",
        "Sabbath School Attendance Trend",
        "attendance",
        "sabbath_school_trend.png",
        plot_sabbath_school_trend,
        "Trend for optional Sabbath School attendance.",
    ),
    "visitors_trend": GraphSpec(
        "visitors_trend",
        "Visitors Trend",
        "attendance",
        "visitors_trend.png",
        plot_visitors_trend,
        "Weekly visitor counts when available.",
    ),
    "ambassadors_trend": GraphSpec(
        "ambassadors_trend",
        "Ambassadors Attendance Trend",
        "attendance",
        "ambassadors_trend.png",
        plot_ambassadors_trend,
        "Weekly ambassadors attendance when available.",
    ),
    "tithe_offerings_trend": GraphSpec(
        "tithe_offerings_trend",
        "Tithe vs Offerings Trend",
        "financial",
        "tithe_offerings_trend.png",
        plot_tithe_offerings_trend,
        "Line chart comparing tithe and offerings over time.",
    ),
    "income_composition": GraphSpec(
        "income_composition",
        "Income Composition",
        "financial",
        "income_composition.png",
        plot_income_composition,
        "Stacked area chart of giving streams.",
    ),
    "income_distribution": GraphSpec(
        "income_distribution",
        "Income Distribution",
        "financial",
        "income_distribution.png",
        plot_income_distribution,
        "Pie chart of aggregate income mix.",
    ),
    "income_vs_attendance": GraphSpec(
        "income_vs_attendance",
        "Income vs Attendance",
        "financial",
        "income_vs_attendance.png",
        plot_income_vs_attendance_dual,
        "Dual-axis trend for attendance and income.",
    ),
    "tithe_vs_offerings_week": GraphSpec(
        "tithe_vs_offerings_week",
        "Tithe vs Offerings per Week",
        "financial",
        "tithe_vs_offerings_week.png",
        lambda df: pairwise_bar(df, "tithe", "offerings", "Tithe vs Offerings per Week"),
        "Grouped bar comparison of tithe and offerings.",
    ),
    "regular_vs_total_income": GraphSpec(
        "regular_vs_total_income",
        "Regular vs Total Income",
        "financial",
        "regular_vs_total_income.png",
        plot_regular_vs_total_income,
        "Grouped bar comparison of regular income and total income.",
    ),
    "income_growth": GraphSpec(
        "income_growth",
        "Income Growth",
        "financial",
        "income_growth.png",
        plot_income_growth,
        "Week-over-week total income growth percentage.",
    ),
    "per_capita_metrics": GraphSpec(
        "per_capita_metrics",
        "Per Capita Metrics",
        "financial",
        "per_capita_metrics.png",
        plot_per_capita_metrics,
        "Income, tithe, and offerings per attendee.",
    ),
    "tithe_per_attendee": GraphSpec(
        "tithe_per_attendee",
        "Tithe per Attendee",
        "financial",
        "tithe_per_attendee.png",
        plot_tithe_per_attendee,
        "Bar chart of tithe divided by total attendance.",
    ),
    "regular_income_per_adult": GraphSpec(
        "regular_income_per_adult",
        "Regular Income per Adult",
        "financial",
        "regular_income_per_adult.png",
        plot_regular_income_per_adult,
        "Bar chart of tithe plus offerings per adult attendee.",
    ),
    "ratio_trends": GraphSpec(
        "ratio_trends",
        "Ratio Trends",
        "financial",
        "ratio_trends.png",
        plot_ratio_trends,
        "Men:Women, Adult:Young, and Tithe:Offerings ratios.",
    ),
    "baptisms_trend": GraphSpec(
        "baptisms_trend",
        "Baptisms Trend",
        "events",
        "baptisms_trend.png",
        plot_baptisms_trend,
        "Weekly baptism counts when available.",
    ),
    "holy_communion_trend": GraphSpec(
        "holy_communion_trend",
        "Holy Communion Trend",
        "events",
        "holy_communion_trend.png",
        plot_holy_communion_trend,
        "Holy Communion attendance when available.",
    ),
    "baptisms_vs_holy_communion": GraphSpec(
        "baptisms_vs_holy_communion",
        "Baptisms vs Holy Communion",
        "events",
        "baptisms_vs_holy_communion.png",
        plot_baptisms_vs_holy_communion,
        "Grouped weekly event-count comparison.",
    ),
    "holy_communion_expected_vs_attended": GraphSpec(
        "holy_communion_expected_vs_attended",
        "Holy Communion: Attended vs Expected",
        "events",
        "holy_communion_expected_vs_attended.png",
        plot_holy_communion_expected_vs_attended,
        "Grouped comparison of holy communion expected vs attended.",
    ),
    "board_business_meeting_trend": GraphSpec(
        "board_business_meeting_trend",
        "Board/Business Meeting Attendance",
        "meetings",
        "board_business_meeting_trend.png",
        plot_board_business_meeting_trend,
        "Weekly board/business meeting attendance when available.",
    ),
    "board_business_meeting_expected_vs_attended": GraphSpec(
        "board_business_meeting_expected_vs_attended",
        "Board/Business Meeting: Attended vs Expected",
        "meetings",
        "board_business_meeting_expected_vs_attended.png",
        plot_board_business_meeting_expected_vs_attended,
        "Grouped bar comparison of expected vs attended board/business meetings.",
    ),
    "attendance_income_scatter": GraphSpec(
        "attendance_income_scatter",
        "Attendance vs Income Scatter",
        "correlation",
        "attendance_income_scatter.png",
        plot_attendance_income_scatter,
        "Scatter plot with trendline.",
    ),
    "men_vs_tithe": GraphSpec(
        "men_vs_tithe",
        "Men vs Tithe",
        "correlation",
        "men_vs_tithe.png",
        lambda df: dual_axis(df, "men", "tithe", "Men vs Tithe over Time"),
        "Dual-axis chart comparing men attendance and tithe.",
    ),
    "women_vs_offerings": GraphSpec(
        "women_vs_offerings",
        "Women vs Offerings",
        "correlation",
        "women_vs_offerings.png",
        lambda df: dual_axis(df, "women", "offerings", "Women vs Offerings over Time"),
        "Dual-axis chart comparing women attendance and offerings.",
    ),
    "correlation_heatmap": GraphSpec(
        "correlation_heatmap",
        "Correlation Heatmap",
        "correlation",
        "correlation_heatmap.png",
        plot_correlation_heatmap,
        "Correlation matrix heatmap for available numeric metrics.",
    ),
    "distribution_histograms": GraphSpec(
        "distribution_histograms",
        "Distribution Histograms",
        "advanced",
        "distribution_histograms.png",
        plot_distribution_histograms,
        "Histogram grid for attendance and finance metrics.",
    ),
    "attendance_moving_average": GraphSpec(
        "attendance_moving_average",
        "Attendance Moving Average",
        "advanced",
        "attendance_moving_average.png",
        plot_attendance_moving_average,
        "Actual attendance with a rolling average.",
    ),
    "attendance_forecast": GraphSpec(
        "attendance_forecast",
        "Attendance Forecast",
        "advanced",
        "attendance_forecast.png",
        plot_attendance_forecast,
        "Simple four-week linear attendance forecast.",
    ),
    "summary_dashboard": GraphSpec(
        "summary_dashboard",
        "Summary Dashboard",
        "advanced",
        "summary_dashboard.png",
        plot_summary_dashboard,
        "Compact 2x2 dashboard of attendance, income, and mix charts.",
    ),
    # ── Presentation-grade graphs (church palette) ────────────────────────
    "sabbath_school_groups": GraphSpec(
        "sabbath_school_groups",
        "Sabbath School Attendance by Group",
        "presentation",
        "sabbath_school_groups.png",
        plot_sabbath_school_groups,
        "Grouped bar for each SS group × session; reads SABBATH SCHOOL DATA*.xlsx.",
    ),
    "sabbath_school_totals_trend": GraphSpec(
        "sabbath_school_totals_trend",
        "Sabbath School Compound Totals Trend",
        "presentation",
        "sabbath_school_totals_trend.png",
        plot_sabbath_school_totals_trend,
        "Morning/afternoon compound totals trend from SABBATH SCHOOL DATA*.xlsx.",
    ),
    "home_church_attendance": GraphSpec(
        "home_church_attendance",
        "Home Church Total Attendance",
        "presentation",
        "home_church_attendance.png",
        plot_home_church_attendance,
        "Horizontal ranked bar for each home church total; reads HOME CHURCH DATA*.xlsx.",
    ),
    "home_church_stacked": GraphSpec(
        "home_church_stacked",
        "Home Church Category Breakdown",
        "presentation",
        "home_church_stacked.png",
        plot_home_church_stacked,
        "Stacked bar per home church (Adults/Youth/Ambassadors/Children/Visitors).",
    ),
    "business_meeting_per_home_church": GraphSpec(
        "business_meeting_per_home_church",
        "Business Meeting Attendance vs Expected",
        "presentation",
        "business_meeting_per_home_church.png",
        plot_business_meeting_per_home_church,
        "Grouped bar: business meeting attended vs expected per home church.",
    ),
    "active_leaders_board": GraphSpec(
        "active_leaders_board",
        "Active Leaders — Board Meeting",
        "presentation",
        "active_leaders_board.png",
        plot_active_leaders_board,
        "Monthly board meeting attended vs expected; reads BOARD MEETING*.xlsx.",
    ),
    "church_composition_donut": GraphSpec(
        "church_composition_donut",
        "Church Composition Donut",
        "presentation",
        "church_composition_donut.png",
        plot_church_composition_donut,
        "Donut chart of average weekly Men/Women/Youth/Children split.",
    ),
    "demographic_trends_styled": GraphSpec(
        "demographic_trends_styled",
        "Weekly Demographic Trends (Styled)",
        "presentation",
        "demographic_trends_styled.png",
        plot_demographic_trends_styled,
        "Multi-line weekly attendance trend with church palette and fill.",
    ),
    "financial_trend_styled": GraphSpec(
        "financial_trend_styled",
        "Weekly Financial Trend (Styled)",
        "presentation",
        "financial_trend_styled.png",
        plot_financial_trend_styled,
        "Tithe & offerings trend with fill under curves, church palette.",
    ),
    "holy_communion_per_home_church": GraphSpec(
        "holy_communion_per_home_church",
        "Holy Communion Attendance vs Expected",
        "presentation",
        "holy_communion_per_home_church.png",
        plot_holy_communion_per_home_church,
        "Grouped bar: holy communion attended vs expected per home church.",
    ),
}


GRAPH_GROUPS: dict[str, list[str]] = {
    group: [graph_id for graph_id, spec in GRAPH_SPECS.items() if spec.group == group]
    for group in sorted({spec.group for spec in GRAPH_SPECS.values()})
}


GRAPH_GROUPS["all"] = list(GRAPH_SPECS.keys())


def save_figure(fig: Figure, spec: GraphSpec, out_dir: Path,
                pdf: Optional[PdfPages], dpi: int) -> Path:
    group_dir = out_dir / spec.group
    group_dir.mkdir(parents=True, exist_ok=True)
    fig.tight_layout()
    path = group_dir / spec.filename
    fig.savefig(str(path), dpi=dpi, bbox_inches="tight")
    if pdf is not None:
        pdf.savefig(fig)
    return path
