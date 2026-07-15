"""Data cleaning and normalisation.

Canonicalises column names to the app-compatible schema, merges duplicate
columns, coerces numeric text (currency strings, thousands separators) to
numbers, parses the date column, and assembles the prepared DataFrame.
"""

from __future__ import annotations

import numpy as np
import pandas as pd
import re

from typing import Optional
from .config import IGNORED_COLUMNS, NUMERIC_COLUMNS


ALIASES: dict[str, list[str]] = {
    "id": ["id", "record_id"],
    "church_id": ["church_id", "churchid"],
    "created_by_admin_id": ["created_by_admin_id", "createdbyadminid", "admin_id"],
    "week_start_date": [
        "week_start_date",
        "weekstartdate",
        "week_start",
        "week_starting",
        "week_date",
        "date",
        "saturday",
        "saturday_date",
        "service_date",
    ],
    "men": ["men", "male", "males", "men_attendance"],
    "women": ["women", "female", "females", "women_attendance"],
    "youth": ["youth", "youths", "youth_attendance", "teenagers"],
    "children": [
        "children",
        "child",
        "kids",
        "children_attendance",
        "total_all_children_classes",
        "total_in_all_children_classes",
    ],
    "sunday_home_church": [
        "sunday_home_church",
        "sundayhomechurch",
        "home_church",
        "homechurch",
        "home_ch",
        "sunday_home",
        "attendance_at_the_sunday_home_church_service_required_integer",
    ],
    "total_attendance": ["total_attendance", "totalattendance", "total_attend"],
    "tithe": ["tithe", "tithes", "tithing", "tithe_kes", "tithe_ksh"],
    "offerings": ["offerings", "offering", "offertory", "offerings_kes", "offering_kes"],
    "emergency_collection": [
        "emergency_collection",
        "emergencycollection",
        "emergency",
        "emergency_collection_kes",
    ],
    "planned_collection": [
        "planned_collection",
        "plannedcollection",
        "planned",
        "planned_collection_kes",
    ],
    "mission_offering": ["mission_offering", "missionoffering", "mission"],
    "local_church_budget": [
        "local_church_budget",
        "localchurchbudget",
        "church_budget",
        "local_budget",
    ],
    "total_income": ["total_income", "totalincome", "total_income_kes"],
    "baptisms": ["baptisms", "baptism", "baptised", "baptized"],
    "holy_communion": [
        "holy_communion",
        "holycommunion",
        "communion",
        "holy_comm",
        "hc",
        "hc_attendance",
        "quarterly_holy_communion_attendance",
    ],
    "holy_communion_expected": ["holy_communion_expected", "expected_at_hc"],
    "sabbath_school_attendance": [
        "sabbath_school_attendance",
        "sabbathschoolattendance",
        "sabbath_school",
        "sabbathschool",
        "kisii_central_sda_church_sabbath_school_attendance",
    ],
    "visitors_count": ["visitors_count", "visitorscount", "visitors", "visitor_count"],
    "board_business_meeting_attendance": [
        "board_business_meeting_attendance",
        "board_meeting",
        "board_meeting_attendance",
        "board_attended",
        "and_business_meeting_attendance",
        "business_mtg",
        "business_meeting_attendance",
        "kisii_central_sda_church_board_business_meeting_attendance_2026",
    ],
    "board_business_meeting_expected": [
        "board_business_meeting_expected",
        "board_meeting_expected",
        "board_expected",
    ],
    "ambassadors_attendance": ["ambassadors_attendance", "ambassadors"],
    "adult_attendance": ["adult_attendance", "adults"],
    "created_at": ["created_at", "createdat"],
    "updated_at": ["updated_at", "updatedat"],
}


ALIAS_LOOKUP = {alias: canonical for canonical, aliases in ALIASES.items() for alias in aliases}


def normalize_name(name: object) -> str:
    """Return a stable snake_case-ish key for matching loose spreadsheet headers."""
    text = str(name).strip().replace("\n", " ").replace("\r", " ")
    text = re.sub(r"\s*\([^)]*\)", "", text)
    text = text.encode("ascii", "ignore").decode()
    text = text.lower().replace("%", "percent")
    text = re.sub(r"[^a-z0-9]+", "_", text)
    return re.sub(r"_+", "_", text).strip("_")


def canonical_column_name(name: object) -> str:
    normalized = normalize_name(name)
    return ALIAS_LOOKUP.get(normalized, normalized)


def combine_duplicate_columns(df: pd.DataFrame) -> pd.DataFrame:
    """Merge duplicate canonical columns, preferring the first non-empty value."""
    result = pd.DataFrame(index=df.index)
    for position, column in enumerate(df.columns):
        series = df.iloc[:, position]
        if column in result.columns:
            result[column] = result[column].combine_first(series)
        else:
            result[column] = series
    return result


def canonicalize_columns(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    df.columns = [canonical_column_name(column) for column in df.columns]
    return combine_duplicate_columns(df)


def clean_number(value: object) -> object:
    if value is None:
        return np.nan
    text = str(value).strip()
    if not text or text.lower() in {"nan", "none", "null", "-"}:
        return np.nan
    text = text.replace(",", "")
    text = re.sub(r"^[A-Z]{2,4}\s+", "", text)
    return text


def coerce_numeric_columns(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    for column in NUMERIC_COLUMNS.intersection(df.columns):
        df[column] = pd.to_numeric(df[column].map(clean_number), errors="coerce")
    return df


def parse_date_series(series: pd.Series, force_year: Optional[int] = None) -> pd.Series:
    """Parse ISO dates, day-first dates, and Excel serial dates."""
    if pd.api.types.is_numeric_dtype(series):
        numeric = series.dropna()
        if not numeric.empty and numeric.median() > 10000:
            parsed = pd.to_datetime(series, unit="D", origin="1899-12-30", errors="coerce")
        else:
            parsed = pd.to_datetime(series, errors="coerce")
    else:
        raw = series.astype(str).str.strip()
        dayfirst_pattern = r"^\d{1,2}[/-]\d{1,2}[/-]\d{2,4}$"
        dayfirst = raw.str.match(dayfirst_pattern, na=False).mean() > 0.5
        parsed = pd.to_datetime(raw, errors="coerce", dayfirst=dayfirst)

    parsed = parsed.dt.tz_localize(None)
    if force_year is not None:
        parsed = parsed.apply(lambda value: value.replace(year=force_year) if pd.notna(value) else value)
    return parsed


def prepare_dataframe(df: pd.DataFrame, source_file: str, source_sheet: Optional[str], force_year: Optional[int]) -> pd.DataFrame:
    df = df.dropna(axis=0, how="all").dropna(axis=1, how="all")
    if df.empty:
        return df

    df = canonicalize_columns(df)
    if IGNORED_COLUMNS.intersection(df.columns):
        df = df.drop(columns=[column for column in IGNORED_COLUMNS if column in df.columns])
    df = coerce_numeric_columns(df)

    if "week_start_date" in df.columns:
        df["week_start_date"] = parse_date_series(df["week_start_date"], force_year)
    else:
        df["week_start_date"] = pd.NaT

    if "source_file" in df.columns:
        df["source_file"] = df["source_file"].combine_first(pd.Series(source_file, index=df.index))
    else:
        df["source_file"] = source_file
    if source_sheet is not None:
        if "source_sheet" in df.columns:
            df["source_sheet"] = df["source_sheet"].combine_first(pd.Series(source_sheet, index=df.index))
        else:
            df["source_sheet"] = source_sheet

    return df.dropna(axis=0, how="all")
