from __future__ import annotations

import argparse
import logging
import re
from pathlib import Path

import pandas as pd


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s - %(message)s",
)
logger = logging.getLogger(__name__)


def to_snake_case(columns: list[str]) -> list[str]:
    """Normalize column names to snake_case."""
    result = []
    for col in columns:
        col = str(col).strip().lower()  # str() handles non-string column names
        col = re.sub(r"[^a-z0-9]+", "_", col)
        col = col.strip("_")
        result.append(col)
    return result


def read_excel(path: Path, skip_rows: int = 0) -> pd.DataFrame:
    """Read Excel file, skip metadata rows and normalize column names to snake_case.

    Some HR exports contain metadata rows at the top (report title, export date)
    before actual data headers. Use skip_rows to skip them.
    Intentionally minimal - business logic cleaning happens in dbt staging layer.
    """
    logger.info("Reading %s (skipping %d metadata rows)", path, skip_rows)
    df = pd.read_excel(path, skiprows=skip_rows)
    df.columns = to_snake_case(df.columns.tolist())
    logger.info("Loaded %d rows, columns: %s", len(df), df.columns.tolist())
    return df


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Read raw Excel exports and save as CSV for dbt ingestion."
    )
    parser.add_argument("--raw-dir", type=Path, default=Path("data/raw"))
    parser.add_argument("--output-dir", type=Path, default=Path("data/processed"))
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    args.output_dir.mkdir(parents=True, exist_ok=True)

    # Mapping: source filename → (target filename, metadata rows to skip)
    # HR exports contain metadata rows before actual headers - skip_rows handles this
    files = {
        "hr_employees_export.xlsx": ("hr_employees.csv", 3),
        "project_assignments_report.xlsx": ("project_assignments.csv", 3),
    }

    for source, (target, skip_rows) in files.items():
        df = read_excel(args.raw_dir / source, skip_rows=skip_rows)
        out_path = args.output_dir / target
        df.to_csv(out_path, index=False)
        logger.info("Saved → %s (%d rows)", out_path, len(df))


if __name__ == "__main__":
    main()
