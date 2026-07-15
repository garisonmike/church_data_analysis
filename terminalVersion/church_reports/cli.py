"""Command-line interface and interactive TUI.

Argument parsing for headless runs, the interactive setup wizard and graph
browser, and the report/export pipeline that writes PNGs, tables, and the
optional PDF bundle.
"""

from __future__ import annotations

# Import order mirrors the original data.py exactly: matplotlib (with the
# backend decided) before pandas, so rendering-relevant global state is
# initialised identically.
import argparse
import os
import shutil
import sys

os.environ.setdefault("MPLCONFIGDIR", "/tmp/matplotlib")

import matplotlib

if not os.environ.get("DISPLAY"):
    matplotlib.use("Agg")

import matplotlib.pyplot as plt
import pandas as pd
from matplotlib.backends.backend_pdf import PdfPages
from pathlib import Path
from typing import Optional, Sequence
from .config import APP_WEEKLY_COLUMNS, CHURCH_SHORT_NAME, OPTIONAL_METADATA_COLUMNS
from .io import (
    default_inputs,
    default_output_dir,
    load_data,
    log,
    resolve_input_paths,
)
from .plots import (
    GRAPH_GROUPS,
    GRAPH_SPECS,
    GraphSpec,
    save_figure,
)


def print_graph_list() -> None:
    log("Available graph groups:")
    for group in sorted(GRAPH_GROUPS):
        log(f"  {group}: {len(GRAPH_GROUPS[group])} graph(s)")
    log("\nAvailable graphs:")
    for graph_id, spec in GRAPH_SPECS.items():
        log(f"  {graph_id:<34} [{spec.group}] {spec.description}")


def parse_graph_selection(graph_values: Optional[Sequence[str]], group: Optional[str]) -> list[str]:
    selected: list[str] = []

    if group:
        selected.extend(GRAPH_GROUPS.get(group, []))

    if graph_values:
        for value in graph_values:
            for token in [part.strip().lower() for part in value.split(",") if part.strip()]:
                if token in GRAPH_GROUPS:
                    selected.extend(GRAPH_GROUPS[token])
                elif token in GRAPH_SPECS:
                    selected.append(token)
                else:
                    log(f"Warning: unknown graph id or group ignored: {token}")

    if not selected:
        selected = list(GRAPH_SPECS.keys())

    deduped: list[str] = []
    seen: set[str] = set()
    for graph_id in selected:
        if graph_id not in seen:
            deduped.append(graph_id)
            seen.add(graph_id)
    return deduped


# ═══════════════════════════════════════════════════════════════════════════════
# TUI HELPERS  — safe input, colour, box drawing
# ═══════════════════════════════════════════════════════════════════════════════

# ANSI colours (silently disabled on Windows or when stdout is piped)
def _ansi(code: str) -> str:
    if sys.stdout.isatty() and sys.platform != "win32":
        return f"\033[{code}m"
    return ""


RESET  = _ansi("0")


BOLD   = _ansi("1")


DIM    = _ansi("2")


RED    = _ansi("31")


GREEN  = _ansi("32")


YELLOW = _ansi("33")


BLUE   = _ansi("34")


CYAN   = _ansi("36")


WHITE  = _ansi("37")


BG_NAVY = _ansi("44")   # blue background for headers


# Box-drawing constants
H = "─"


V = "│"


TL, TR, BL, BR = "╭", "╮", "╰", "╯"


T_LEFT, T_RIGHT = "├", "┤"


TERM_WIDTH = min(shutil.get_terminal_size((80, 24)).columns, 100)


def _hr(char: str = H, width: int = TERM_WIDTH) -> str:
    return char * width


def _box_line(inner: str, width: int = TERM_WIDTH) -> str:
    """Pad inner to fill a box column."""
    pad = width - 4 - len(inner)
    return f"{V} {inner}{' ' * max(pad, 0)} {V}"


def clear() -> None:
    os.system("cls" if sys.platform == "win32" else "clear")


def print_header(title: str, subtitle: str = "") -> None:
    w = TERM_WIDTH
    print(f"\n{BOLD}{BLUE}{TL}{_hr(H, w-2)}{TR}{RESET}")
    title_pad = (w - 2 - len(title)) // 2
    print(f"{BOLD}{BLUE}{V}{' ' * title_pad}{YELLOW}{title}{BLUE}{' ' * (w - 2 - title_pad - len(title))}{V}{RESET}")
    if subtitle:
        sub_pad = (w - 2 - len(subtitle)) // 2
        print(f"{BOLD}{BLUE}{V}{DIM}{' ' * sub_pad}{subtitle}{' ' * (w - 2 - sub_pad - len(subtitle))}{V}{RESET}")
    print(f"{BOLD}{BLUE}{BL}{_hr(H, w-2)}{BR}{RESET}\n")


def print_status(label: str, value: str, colour: str = CYAN) -> None:
    print(f"  {DIM}{label}:{RESET} {colour}{value}{RESET}")


def print_section(title: str) -> None:
    w = TERM_WIDTH
    print(f"\n{BOLD}{CYAN}{T_LEFT}{_hr(H, w-2)}{T_RIGHT}")
    pad = (w - 2 - len(title)) // 2
    print(f"{V}{' ' * pad}{WHITE}{title}{CYAN}{' ' * (w - 2 - pad - len(title))}{V}")
    print(f"{BL}{_hr(H, w-2)}{BR}{RESET}")


def print_success(msg: str) -> None:
    print(f"  {GREEN}✓  {msg}{RESET}")


def print_warn(msg: str) -> None:
    print(f"  {YELLOW}⚠  {msg}{RESET}")


def print_error(msg: str) -> None:
    print(f"  {RED}✗  {msg}{RESET}")


def prompt(label: str, default: Optional[str] = None, required: bool = False) -> Optional[str]:
    """
    Safe input() wrapper.
    - Catches KeyboardInterrupt (Ctrl-C) and EOFError cleanly.
    - Returns default on blank entry.
    - Loops if required=True and no value entered.
    """
    hint = f" [{CYAN}{default}{RESET}]" if default else ""
    arrow = f"{BOLD}{YELLOW}›{RESET} "
    while True:
        try:
            value = input(f"{arrow}{label}{hint}: ").strip()
        except (KeyboardInterrupt, EOFError):
            print()   # newline after ^C
            raise KeyboardInterrupt
        if value:
            return value
        if default is not None:
            return default
        if not required:
            return None
        print_warn("This field is required — please enter a value.")


def prompt_bool(label: str, default: bool = False) -> bool:
    hint = f"{'Y' if default else 'y'}/{' n' if default else 'N'}"
    arrow = f"{BOLD}{YELLOW}›{RESET} "
    while True:
        try:
            raw = input(f"{arrow}{label} ({hint}): ").strip().lower()
        except (KeyboardInterrupt, EOFError):
            print()
            raise KeyboardInterrupt
        if not raw:
            return default
        if raw in {"y", "yes"}:
            return True
        if raw in {"n", "no"}:
            return False
        print_warn("Please type  y  or  n.")


def prompt_int(label: str, default: Optional[int] = None,
               min_value: Optional[int] = None,
               max_value: Optional[int] = None) -> Optional[int]:
    hint = f" [{CYAN}{default}{RESET}]" if default is not None else ""
    arrow = f"{BOLD}{YELLOW}›{RESET} "
    while True:
        try:
            raw = input(f"{arrow}{label}{hint}: ").strip()
        except (KeyboardInterrupt, EOFError):
            print()
            raise KeyboardInterrupt
        if not raw:
            return default
        try:
            n = int(raw)
        except ValueError:
            print_warn("Please enter a whole number.")
            continue
        if min_value is not None and n < min_value:
            print_warn(f"Minimum is {min_value}.")
            continue
        if max_value is not None and n > max_value:
            print_warn(f"Maximum is {max_value}.")
            continue
        return n


def prompt_path(label: str, default: Optional[str] = None,
                must_exist: bool = False) -> str:
    """Prompt for a file/folder path with tab-expansion and existence check."""
    while True:
        raw = prompt(label, default, required=(default is None))
        if raw is None:
            continue
        expanded = os.path.expanduser(raw)
        if must_exist and not os.path.exists(expanded):
            print_error(f"Path not found: {expanded}")
            continue
        return expanded


# ═══════════════════════════════════════════════════════════════════════════════
# SETUP WIZARD  — collects data paths and output folder before showing the menu
# ═══════════════════════════════════════════════════════════════════════════════

def setup_wizard(default_out: str = "church_analysis",
                 default_dpi: int = 150) -> dict:
    """
    Guides the user through supplying data inputs and output settings.
    Returns a dict with keys: inputs, output_dir, pdf, export_clean,
                               no_tables, dpi, force_year.
    Raises KeyboardInterrupt if the user presses Ctrl-C.
    """
    clear()
    print_header(
        f"{CHURCH_SHORT_NAME}  ·  Church Analytics",
        "Data Setup  —  press Ctrl-C at any time to exit"
    )

    # ── DATA INPUTS ──────────────────────────────────────────────────────────
    print_section("Step 1 of 3  ·  Data Inputs")
    print(f"""
  {DIM}Provide the CSV or XLSX files that contain your church records.
  You can enter:
    • A single file path   e.g.  data/netFinalData.csv
    • A folder path        e.g.  data/               (all CSV/XLSX inside)
    • Multiple paths       separated by commas{RESET}
""")

    auto = default_inputs()
    if auto:
        print_status("Auto-detected", ", ".join(auto), CYAN)

    inputs: list[str] = []
    while not inputs:
        raw = prompt(
            "Enter path(s) to data file(s) or folder",
            ", ".join(auto) if auto else None,
            required=not bool(auto),
        )
        candidates = [p.strip() for p in (raw or "").split(",") if p.strip()]
        if not candidates and auto:
            candidates = auto
        # validate
        bad = [p for p in candidates if not os.path.exists(os.path.expanduser(p))]
        if bad:
            for b in bad:
                print_error(f"Not found: {b}")
            if not prompt_bool("Continue anyway (with the valid paths)?", False):
                continue
            candidates = [p for p in candidates if p not in bad]
        if candidates:
            inputs = candidates
        else:
            if auto:
                inputs = auto
            else:
                print_warn("Please supply at least one valid path.")

    for p in inputs:
        print_success(os.path.expanduser(p))

    # ── OUTPUT FOLDER ─────────────────────────────────────────────────────────
    print_section("Step 2 of 3  ·  Output Folder")
    print(f"  {DIM}PNGs, tables, and optional PDF will be saved here.{RESET}\n")
    output_dir = prompt_path("Output directory", default_out)
    print_success(output_dir)

    # ── OPTIONS ───────────────────────────────────────────────────────────────
    print_section("Step 3 of 3  ·  Options")
    pdf          = prompt_bool("Also bundle all graphs into one PDF?", False)
    export_clean = prompt_bool("Export a cleaned/normalised CSV?",     False)
    no_tables    = prompt_bool("Skip summary statistics tables?",       False)
    dpi          = prompt_int("PNG resolution (DPI)", default_dpi, min_value=72, max_value=600) or default_dpi
    force_year   = prompt_int("Force all dates to year (blank = auto)", None, min_value=1900)

    return dict(inputs=inputs, output_dir=output_dir, pdf=pdf,
                export_clean=export_clean, no_tables=no_tables,
                dpi=dpi, force_year=force_year)


# ═══════════════════════════════════════════════════════════════════════════════
# GRAPH BROWSER MENU
# ═══════════════════════════════════════════════════════════════════════════════

# Ordering for display
_GROUP_ORDER = ["presentation", "attendance", "financial", "events",
                "meetings", "correlation", "advanced"]


# Short category headers shown in the menu
_GROUP_LABELS: dict[str, str] = {
    "presentation": "📊  Presentation Graphs",
    "attendance":   "👥  Attendance",
    "financial":    "💰  Financial",
    "events":       "✝️   Events",
    "meetings":     "📋  Meetings",
    "correlation":  "🔗  Correlations",
    "advanced":     "🔬  Advanced / Forecasts",
}


def _grouped_specs() -> list[tuple[str, list[GraphSpec]]]:
    """Return specs sorted by group order then by name."""
    buckets: dict[str, list[GraphSpec]] = {}
    for spec in GRAPH_SPECS.values():
        buckets.setdefault(spec.group, []).append(spec)

    result = []
    # known groups first, then any extras alphabetically
    seen: set[str] = set()
    for g in _GROUP_ORDER:
        if g in buckets:
            result.append((g, sorted(buckets[g], key=lambda s: s.title)))
            seen.add(g)
    for g in sorted(buckets):
        if g not in seen:
            result.append((g, sorted(buckets[g], key=lambda s: s.title)))
    return result


def _render_menu(grouped: list[tuple[str, list[GraphSpec]]],
                 bucket: set[str],
                 page_group: Optional[str] = None) -> dict[int, str]:
    """
    Print the full browsable menu and return a mapping  number → graph_id.
    If page_group is set, only that category is expanded.
    """
    clear()
    print_header(
        "Church Analytics  ·  Graph Browser",
        f"Bucket: {len(bucket)} graph(s) selected"
    )

    index: dict[int, str] = {}   # number shown on screen → graph_id
    n = 1

    for group, specs in grouped:
        label = _GROUP_LABELS.get(group, group.title())
        is_expanded = (page_group is None or page_group == group)

        # Group header
        marker = f"{GREEN}▾{RESET}" if is_expanded else f"{DIM}▸{RESET}"
        count_selected = sum(1 for s in specs if s.graph_id in bucket)
        sel_tag = f"{GREEN}({count_selected} selected){RESET}" if count_selected else ""
        print(f"\n  {marker} {BOLD}{WHITE}{label}{RESET}  {sel_tag}")

        if not is_expanded:
            # show only a summary line
            gids = [s.graph_id for s in specs]
            print(f"     {DIM}  {len(gids)} graphs  ·  type the group name to expand{RESET}")
            continue

        for spec in specs:
            in_bucket = spec.graph_id in bucket
            tick = f"{GREEN}✓{RESET}" if in_bucket else f"{DIM}○{RESET}"
            num  = f"{YELLOW}{n:>2}{RESET}"
            name = f"{WHITE}{spec.title}{RESET}" if in_bucket else spec.title
            print(f"     {tick}  {num}.  {name}")
            if spec.description:
                print(f"          {DIM}{spec.description[:TERM_WIDTH - 12]}{RESET}")
            index[n] = spec.graph_id
            n += 1

    return index


def _print_bucket(bucket: set[str]) -> None:
    if not bucket:
        print(f"\n  {DIM}Your bucket is empty.{RESET}")
        return
    print(f"\n  {BOLD}Selected graphs  ({len(bucket)}):{RESET}")
    for gid in sorted(bucket):
        spec = GRAPH_SPECS[gid]
        print(f"    {GREEN}✓{RESET}  {spec.title}  {DIM}[{gid}]{RESET}")


def _print_controls() -> None:
    w = TERM_WIDTH
    print(f"\n{DIM}{_hr(H, w)}{RESET}")
    print(f"  {CYAN}NUMBER{RESET}          toggle a graph into/out of the bucket")
    print(f"  {CYAN}a  / all{RESET}        add ALL graphs to bucket")
    print(f"  {CYAN}c  / clear{RESET}      clear the bucket")
    print(f"  {CYAN}GROUP NAME{RESET}      expand that category  (e.g.  attendance)")
    print(f"  {CYAN}b  / bucket{RESET}     show current bucket")
    print(f"  {CYAN}g  / go{RESET}         generate the bucket and save PNGs")
    print(f"  {CYAN}q  / quit{RESET}       exit without generating")
    print(f"{DIM}{_hr(H, w)}{RESET}\n")


def graph_browser(df: pd.DataFrame, settings: dict) -> Optional[list[str]]:
    """
    Full-screen TUI graph browser.
    Returns the list of graph_ids to generate, or None to quit.
    """
    grouped    = _grouped_specs()
    all_ids    = list(GRAPH_SPECS.keys())
    bucket:   set[str] = set()
    page_group: Optional[str] = None

    while True:
        index = _render_menu(grouped, bucket, page_group)
        _print_controls()

        try:
            raw = input(f"{BOLD}{YELLOW}›{RESET} ").strip().lower()
        except (KeyboardInterrupt, EOFError):
            print()
            if prompt_bool("\nQuit without generating?", True):
                return None
            continue

        if not raw:
            continue

        # ── quit ─────────────────────────────────────────────────────────────
        if raw in {"q", "quit", "exit"}:
            return None

        # ── generate ─────────────────────────────────────────────────────────
        if raw in {"g", "go", "generate", "print", "save"}:
            if not bucket:
                print_warn("Bucket is empty — add graphs first (type 'a' for all).")
                input(f"  {DIM}Press Enter to continue...{RESET}")
                continue
            return sorted(bucket, key=lambda gid: list(GRAPH_SPECS.keys()).index(gid))

        # ── show bucket ───────────────────────────────────────────────────────
        if raw in {"b", "bucket", "list"}:
            clear()
            print_header("Your Bucket")
            _print_bucket(bucket)
            print()
            input(f"  {DIM}Press Enter to go back...{RESET}")
            continue

        # ── add all ──────────────────────────────────────────────────────────
        if raw in {"a", "all"}:
            bucket = set(all_ids)
            page_group = None
            continue

        # ── clear ─────────────────────────────────────────────────────────────
        if raw in {"c", "clear", "none"}:
            bucket.clear()
            page_group = None
            continue

        # ── expand a category by name ─────────────────────────────────────────
        matched_group = next(
            (g for g, _ in grouped
             if g.lower().startswith(raw) or raw in g.lower()
             or raw in _GROUP_LABELS.get(g, "").lower()),
            None
        )
        if matched_group:
            page_group = None if page_group == matched_group else matched_group
            continue

        # ── add/remove entire category ────────────────────────────────────────
        # e.g. "+attendance" or "-financial"
        if raw.startswith("+") or raw.startswith("-"):
            action = raw[0]
            keyword = raw[1:].strip()
            tgt_group = next(
                (g for g, _ in grouped if g.lower().startswith(keyword)),
                None
            )
            if tgt_group:
                ids = {s.graph_id for _, specs in grouped for s in specs
                       if _ == tgt_group or (tgt_group and tgt_group == _)}
                # rebuild properly
                ids = {s.graph_id for g, specs in grouped if g == tgt_group for s in specs}
                if action == "+":
                    bucket |= ids
                    print_success(f"Added {len(ids)} graphs from '{tgt_group}'.")
                else:
                    bucket -= ids
                    print_success(f"Removed {len(ids)} graphs from '{tgt_group}'.")
                input(f"  {DIM}Press Enter to continue...{RESET}")
                continue

        # ── toggle by number ──────────────────────────────────────────────────
        # supports single numbers, ranges (1-5), and comma lists (1,3,5)
        def _toggle_ids(nums: list[int]) -> tuple[int, int]:
            added = removed = 0
            for num in nums:
                gid = index.get(num)
                if gid is None:
                    print_warn(f"  No graph #{num}.")
                elif gid in bucket:
                    bucket.discard(gid)
                    removed += 1
                else:
                    bucket.add(gid)
                    added += 1
            return added, removed

        nums: list[int] = []
        for part in raw.split(","):
            part = part.strip()
            if "-" in part and not part.startswith("-"):
                # range like 3-7
                try:
                    lo, hi = part.split("-", 1)
                    nums += list(range(int(lo.strip()), int(hi.strip()) + 1))
                except ValueError:
                    pass
            else:
                try:
                    nums.append(int(part))
                except ValueError:
                    pass

        if nums:
            added, removed = _toggle_ids(nums)
            if added:
                print_success(f"Added {added} graph(s) to bucket.")
            if removed:
                print_warn(f"Removed {removed} graph(s) from bucket.")
            if added or removed:
                input(f"  {DIM}Press Enter to continue...{RESET}")
            continue

        # ── unrecognised ──────────────────────────────────────────────────────
        print_warn(f"Unknown command: '{raw}'  —  see controls above.")
        input(f"  {DIM}Press Enter to continue...{RESET}")


# ═══════════════════════════════════════════════════════════════════════════════
# GENERATE + RESULTS SCREEN
# ═══════════════════════════════════════════════════════════════════════════════

def run_and_report(df: pd.DataFrame, graph_ids: list[str], settings: dict) -> int:
    """Generate the selected graphs and show a results summary screen."""
    out_dir  = Path(settings["output_dir"])
    out_dir.mkdir(parents=True, exist_ok=True)
    dpi      = settings.get("dpi", 150)
    make_pdf = settings.get("pdf", False)

    if not settings.get("no_tables", False):
        save_stats_tables(df, out_dir)

    if settings.get("export_clean", False):
        export_cols = [c for c in APP_WEEKLY_COLUMNS if c in df.columns]
        export_cols += [c for c in OPTIONAL_METADATA_COLUMNS
                        if c in df.columns and c not in export_cols]
        df[export_cols].to_csv(out_dir / "normalized_data.csv", index=False)

    clear()
    print_header(
        "Generating Graphs…",
        f"Saving to: {out_dir}  ·  DPI: {dpi}"
    )

    pdf_obj: Optional[PdfPages] = PdfPages(str(out_dir / "graphs.pdf")) if make_pdf else None
    generated, skipped = 0, 0
    results: list[tuple[str, str, str]] = []   # (name, status, path/reason)

    total = len(graph_ids)
    for i, gid in enumerate(graph_ids, 1):
        spec = GRAPH_SPECS[gid]
        # progress bar
        filled = int((i - 1) / total * 40)
        bar = f"{GREEN}{'█' * filled}{DIM}{'░' * (40 - filled)}{RESET}"
        print(f"\r  [{bar}]  {i}/{total}  {spec.title[:35]:<35}", end="", flush=True)

        try:
            fig = spec.builder(df)
        except Exception as exc:
            skipped += 1
            results.append((spec.title, "error", str(exc)))
            plt.close("all")
            continue

        if fig is None:
            skipped += 1
            results.append((spec.title, "skipped", "Required data not available"))
            continue

        path = save_figure(fig, spec, out_dir, pdf_obj, dpi)
        plt.close(fig)
        generated += 1
        results.append((spec.title, "ok", str(path)))

    if pdf_obj:
        pdf_obj.close()

    print(f"\r  {' ' * (TERM_WIDTH - 2)}\r", end="")   # clear progress line

    # ── results summary ───────────────────────────────────────────────────────
    print_section("Results")
    ok_results   = [(n, p) for n, s, p in results if s == "ok"]
    skip_results = [(n, r) for n, s, r in results if s == "skipped"]
    err_results  = [(n, r) for n, s, r in results if s == "error"]

    if ok_results:
        print(f"\n  {BOLD}{GREEN}Generated  ({len(ok_results)}){RESET}")
        for name, path in ok_results:
            short = path.replace(str(out_dir), "").lstrip("/\\")
            print(f"    {GREEN}✓{RESET}  {name:<45}  {DIM}{short}{RESET}")

    if skip_results:
        print(f"\n  {BOLD}{YELLOW}Skipped  ({len(skip_results)}){RESET}")
        for name, reason in skip_results:
            print(f"    {YELLOW}○{RESET}  {name:<45}  {DIM}{reason}{RESET}")

    if err_results:
        print(f"\n  {BOLD}{RED}Errors  ({len(err_results)}){RESET}")
        for name, reason in err_results:
            print(f"    {RED}✗{RESET}  {name:<45}  {DIM}{reason}{RESET}")

    print_section("Summary")
    print_status("Data rows loaded",  str(len(df)))
    print_status("Graphs generated",  str(generated), GREEN)
    if skipped:
        print_status("Graphs skipped", str(skipped), YELLOW)
    print_status("Output folder",     str(out_dir.resolve()), CYAN)
    if make_pdf:
        print_status("PDF bundle",     str((out_dir / "graphs.pdf").resolve()), CYAN)
    print()
    return 0 if generated > 0 else 1


def save_stats_tables(df: pd.DataFrame, out_dir: Path) -> None:
    tables_dir = out_dir / "tables"
    tables_dir.mkdir(parents=True, exist_ok=True)

    numeric_cols = [
        column
        for column in df.columns
        if pd.api.types.is_numeric_dtype(df[column]) and df[column].notna().any()
    ]
    if numeric_cols:
        df[numeric_cols].describe().to_csv(tables_dir / "summary_statistics.csv")

    corr_cols = [
        "men", "women", "youth", "children", "sunday_home_church",
        "total_attendance", "tithe", "offerings", "total_income",
        "baptisms", "holy_communion", "sabbath_school_attendance",
    ]
    corr_available = [c for c in corr_cols if c in df.columns and df[c].notna().sum() >= 2]
    if len(corr_available) >= 2:
        df[corr_available].corr(numeric_only=True).to_csv(tables_dir / "correlation_matrix.csv")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Generate church analytics graphs from CSV or XLSX data.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument("--input", nargs="*", default=None,
                        help="CSV/XLSX files or directories.")
    parser.add_argument("--output-dir", "--output", default=default_output_dir(),
                        help="Directory for output files.")
    parser.add_argument("--graphs", nargs="*", default=None,
                        help="Graph IDs to generate (skips the menu).")
    parser.add_argument("--group", choices=sorted(GRAPH_GROUPS), default=None,
                        help="Generate one graph group (skips the menu).")
    parser.add_argument("--list-graphs", action="store_true",
                        help="List all graph IDs and exit.")
    parser.add_argument("--pdf", action="store_true",
                        help="Bundle all graphs into a PDF.")
    parser.add_argument("--dpi", type=int, default=150,
                        help="PNG export resolution.")
    parser.add_argument("--force-year", type=int, default=None,
                        help="Force all parsed dates to this year.")
    parser.add_argument("--export-clean", action="store_true",
                        help="Write a normalised weekly-record CSV.")
    parser.add_argument("--no-tables", action="store_true",
                        help="Skip summary statistics tables.")
    return parser


def main(argv: Optional[Sequence[str]] = None) -> int:
    # The old data.py applied this in its __main__ block; keep it in main()
    # so every entry path (python -m church_reports, the data.py shim)
    # renders with the same style.
    plt.style.use("seaborn-v0_8-whitegrid")

    parser = build_parser()
    argv_list = list(sys.argv[1:] if argv is None else argv)

    # ── handle --list-graphs before full parse so it never needs data ─────────
    if "--list-graphs" in argv_list:
        print_graph_list()
        return 0

    args = parser.parse_args(argv_list)

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # NON-INTERACTIVE (CLI flags supplied)
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    headless = bool(args.input or args.graphs or args.group)
    if headless:
        input_values = args.input if args.input else default_inputs()
        if not input_values:
            parser.error("No input files provided and no default data files found.")

        paths = resolve_input_paths(input_values)
        if not paths:
            parser.error("No readable CSV/XLSX files found in the provided inputs.")

        log(f"Loading {len(paths)} input file(s)…")
        df = load_data(paths, args.force_year)
        if df.empty:
            parser.error("No usable records loaded — check your input files.")

        out_dir = Path(args.output_dir)
        out_dir.mkdir(parents=True, exist_ok=True)

        if args.export_clean:
            export_cols = [c for c in APP_WEEKLY_COLUMNS if c in df.columns]
            export_cols += [c for c in OPTIONAL_METADATA_COLUMNS
                            if c in df.columns and c not in export_cols]
            df[export_cols].to_csv(out_dir / "normalized_data.csv", index=False)
            log(f"Generated {out_dir / 'normalized_data.csv'}")

        if not args.no_tables:
            save_stats_tables(df, out_dir)
            log(f"Generated summary tables in {out_dir / 'tables'}")

        graph_ids = parse_graph_selection(args.graphs, args.group)
        settings = dict(output_dir=str(out_dir), pdf=args.pdf,
                        dpi=args.dpi, export_clean=False, no_tables=True)
        return run_and_report(df, graph_ids, settings)

    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # INTERACTIVE TUI  (no CLI flags, or running in a terminal)
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    try:
        settings = setup_wizard(
            default_out=args.output_dir,
            default_dpi=args.dpi,
        )
    except KeyboardInterrupt:
        print(f"\n\n  {YELLOW}Cancelled — goodbye.{RESET}\n")
        return 0

    # Load data after wizard so errors are reported clearly
    try:
        paths = resolve_input_paths(settings["inputs"])
        if not paths:
            print_error("No readable CSV/XLSX files found — check your paths.")
            return 1

        clear()
        print_header("Loading Data…")
        df = load_data(paths, settings.get("force_year"))
        if df.empty:
            print_error("No usable records found in the data files.")
            return 1
        print_success(f"Loaded {len(df)} weekly record(s) from {len(paths)} file(s).")
        input(f"\n  {DIM}Press Enter to open the Graph Browser…{RESET}")

    except KeyboardInterrupt:
        print(f"\n\n  {YELLOW}Cancelled — goodbye.{RESET}\n")
        return 0
    except Exception as exc:
        print_error(f"Failed to load data: {exc}")
        return 1

    # Graph browser loop — stay in menu until the user generates or quits
    while True:
        try:
            graph_ids = graph_browser(df, settings)
        except KeyboardInterrupt:
            graph_ids = None

        if graph_ids is None:
            # User pressed q / Ctrl-C inside the browser
            try:
                if prompt_bool("\n  Really quit without generating?", True):
                    print(f"\n  {YELLOW}Goodbye.{RESET}\n")
                    return 0
                # else: go back to browser
            except KeyboardInterrupt:
                print(f"\n\n  {YELLOW}Goodbye.{RESET}\n")
                return 0
            continue

        # Generate the bucket
        try:
            rc = run_and_report(df, graph_ids, settings)
        except KeyboardInterrupt:
            print(f"\n\n  {YELLOW}Interrupted — some graphs may not have saved.{RESET}\n")
            return 1

        # After generating, offer to go back to the browser or quit
        print()
        try:
            again = prompt_bool("Go back to the browser to generate more?", False)
        except KeyboardInterrupt:
            again = False

        if not again:
            print(f"\n  {GREEN}All done!{RESET}  Files saved to: {CYAN}{settings['output_dir']}{RESET}\n")
            return rc


if __name__ == "__main__":
    sys.exit(main())
