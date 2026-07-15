"""Derived metric calculations.

Computes the same core metrics the Flutter app derives from weekly records
(totals, ratios, per-capita figures), so terminal reports and in-app
analytics agree.
"""

from __future__ import annotations

import numpy as np
import pandas as pd

from typing import Sequence
from .config import (
    APP_WEEKLY_COLUMNS,
    ATTENDANCE_PARTS,
    CORE_INCOME_PARTS,
    INCOME_PARTS,
    NUMERIC_COLUMNS,
    SABBATH_ATTENDANCE_PARTS,
)


def safe_divide(numerator: pd.Series, denominator: pd.Series) -> pd.Series:
    denominator = denominator.replace(0, np.nan)
    return numerator / denominator


def ensure_numeric_column(df: pd.DataFrame, column: str) -> pd.Series:
    if column not in df.columns:
        df[column] = np.nan
    return pd.to_numeric(df[column], errors="coerce")


def sum_existing(df: pd.DataFrame, columns: Sequence[str]) -> pd.Series:
    available = [column for column in columns if column in df.columns]
    if not available:
        return pd.Series(np.nan, index=df.index, dtype="float64")
    return df[available].apply(pd.to_numeric, errors="coerce").sum(axis=1, min_count=1)


def looks_like_sabbath_total(existing: pd.Series, sabbath_total: pd.Series, app_total: pd.Series) -> bool:
    """Detect legacy totals that excluded Sunday Home Church attendance."""
    comparable = pd.DataFrame(
        {"existing": existing, "sabbath": sabbath_total, "app": app_total}
    ).dropna()
    if comparable.empty:
        return False
    sabbath_matches = np.isclose(comparable["existing"], comparable["sabbath"], rtol=0.01, atol=1).mean()
    app_matches = np.isclose(comparable["existing"], comparable["app"], rtol=0.01, atol=1).mean()
    return sabbath_matches > 0.6 and sabbath_matches > app_matches


def derive_metrics(df: pd.DataFrame) -> pd.DataFrame:
    """Add app-style totals plus analysis-only helper columns."""
    df = df.copy()

    for column in APP_WEEKLY_COLUMNS:
        if column not in df.columns:
            df[column] = np.nan

    for column in NUMERIC_COLUMNS.intersection(df.columns):
        df[column] = pd.to_numeric(df[column], errors="coerce")

    df["sabbath_attendance"] = sum_existing(df, SABBATH_ATTENDANCE_PARTS)
    computed_total_attendance = sum_existing(df, ATTENDANCE_PARTS)

    if "total_attendance" in df.columns and df["total_attendance"].notna().any():
        df["source_total_attendance"] = df["total_attendance"]
        if looks_like_sabbath_total(df["total_attendance"], df["sabbath_attendance"], computed_total_attendance):
            df["total_attendance"] = computed_total_attendance.combine_first(df["total_attendance"])
        else:
            df["total_attendance"] = df["total_attendance"].combine_first(computed_total_attendance)
    else:
        df["total_attendance"] = computed_total_attendance

    df["total_with_home_church"] = computed_total_attendance
    if "adult_attendance" in df.columns:
        existing_adult = pd.to_numeric(df["adult_attendance"], errors="coerce")
    else:
        existing_adult = pd.Series(np.nan, index=df.index, dtype="float64")
    derived_adult = ensure_numeric_column(df, "men").fillna(0) + ensure_numeric_column(df, "women").fillna(0)
    df["adult_attendance"] = existing_adult.combine_first(derived_adult)
    df["young_attendance"] = ensure_numeric_column(df, "youth").fillna(0) + ensure_numeric_column(df, "children").fillna(0)

    df["core_income"] = sum_existing(df, CORE_INCOME_PARTS)
    df["regular_income"] = ensure_numeric_column(df, "tithe").fillna(0) + ensure_numeric_column(df, "offerings").fillna(0)
    df["special_collections"] = (
        ensure_numeric_column(df, "emergency_collection").fillna(0)
        + ensure_numeric_column(df, "planned_collection").fillna(0)
    )

    computed_total_income = sum_existing(df, INCOME_PARTS)
    if "total_income" in df.columns and df["total_income"].notna().any():
        df["source_total_income"] = df["total_income"]
        # The app derives totalIncome from its component fields, including the
        # newer optional giving streams when present.
        df["total_income"] = computed_total_income.combine_first(df["total_income"])
    else:
        df["total_income"] = computed_total_income

    df["income_per_attendee"] = safe_divide(df["total_income"], df["total_attendance"])
    df["tithe_per_attendee"] = safe_divide(df["tithe"], df["total_attendance"])
    df["offerings_per_attendee"] = safe_divide(df["offerings"], df["total_attendance"])
    df["regular_income_per_adult"] = safe_divide(df["regular_income"], df["adult_attendance"])

    pct_denominator = df["sabbath_attendance"].replace(0, np.nan)
    for source, target in [
        ("men", "men_pct"),
        ("women", "women_pct"),
        ("youth", "youth_pct"),
        ("children", "children_pct"),
    ]:
        df[target] = safe_divide(df[source], pct_denominator) * 100

    if "sunday_home_church" in df.columns:
        df["home_church_pct"] = safe_divide(df["sunday_home_church"], df["total_attendance"]) * 100

    df = df.sort_values("week_start_date", na_position="last").reset_index(drop=True)
    df["attendance_growth"] = df["total_attendance"].pct_change(fill_method=None) * 100
    df["income_growth"] = df["total_income"].pct_change(fill_method=None) * 100
    df["tithe_growth"] = df["tithe"].pct_change(fill_method=None) * 100
    df["men_women_ratio"] = safe_divide(df["men"], df["women"])
    df["adult_young_ratio"] = safe_divide(df["adult_attendance"], df["young_attendance"])
    df["tithe_offerings_ratio"] = safe_divide(df["tithe"], df["offerings"])

    return df
