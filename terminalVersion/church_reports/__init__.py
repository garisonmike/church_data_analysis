"""Church Reports — terminal analytics package.

The terminal companion to the Flutter app's analytics screens, restructured
from the former single-file data.py into focused modules:

    config.py    branding, data locations, column schemas — everything that
                 was previously hardcoded
    io.py        input discovery, header detection, CSV/XLSX reading
    cleaning.py  column canonicalisation, type coercion, date parsing
    metrics.py   derived metric calculations shared with the app
    plots.py     chart styling helpers, the graph builders, and the registry
    cli.py       argument parsing, the interactive TUI, and report output

Entry points:
    python -m church_reports.cli        (from the terminalVersion/ folder)
    python data.py                      (thin compatibility shim)
"""

__version__ = "2.0.0"
