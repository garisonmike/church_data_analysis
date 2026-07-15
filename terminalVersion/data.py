#!/usr/bin/env python3
"""Church Data Analysis CLI — compatibility shim.

The implementation lives in the church_reports package (config, io,
cleaning, metrics, plots, cli). This shim keeps the historical entry point
working:

    python data.py --graphs all --pdf
    python data.py --list-graphs

Equivalent package invocation:

    python -m church_reports --graphs all --pdf

Data location: set CHURCH_DATA_DIR to the directory holding your CSV/XLSX
files (keeps real congregation data outside the repo checkout). See
church_reports/config.py for all environment overrides.
"""

from church_reports.cli import main

if __name__ == "__main__":
    raise SystemExit(main())
