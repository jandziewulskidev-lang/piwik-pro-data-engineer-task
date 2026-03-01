from __future__ import annotations

import argparse
import logging
from datetime import datetime, timezone
from pathlib import Path

import duckdb
import pandas as pd


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s - %(message)s",
)
logger = logging.getLogger(__name__)


def get_connection(db_path: Path) -> duckdb.DuckDBPyConnection:
    """Create DuckDB connection and ensure raw schema exists."""
    logger.info("Connecting to DuckDB at %s", db_path)
    db_path.parent.mkdir(parents=True, exist_ok=True)
    con = duckdb.connect(str(db_path))
    con.execute("CREATE SCHEMA IF NOT EXISTS raw")
    return con


def load_csv_to_table(
    con: duckdb.DuckDBPyConnection,
    csv_path: Path,
    table_name: str,
) -> None:
    """Load a CSV file into a raw schema table.

    Uses CREATE OR REPLACE so the pipeline is idempotent -
    running it multiple times produces the same result.
    """
    logger.info("Loading %s → raw.%s", csv_path, table_name)
    df = pd.read_csv(csv_path)
    df["_loaded_at"] = datetime.now(timezone.utc)
    df["_source_file"] = csv_path.name
    con.execute(
        f"CREATE OR REPLACE TABLE raw.{table_name} AS SELECT * FROM df"
    )
    count = con.execute(f"SELECT COUNT(*) FROM raw.{table_name}").fetchone()[0]
    
    logger.info("Loaded %d rows into raw.%s", count, table_name)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Load processed CSVs into DuckDB raw schema."
    )
    parser.add_argument(
        "--db-path",
        type=Path,
        default=Path("/data/warehouse_dev.duckdb"),
        help="Path to DuckDB database file (default: /data/warehouse_dev.duckdb)",
    )
    parser.add_argument(
        "--processed-dir",
        type=Path,
        default=Path("data/processed"),
        help="Directory containing processed CSV files (default: data/processed)",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    con = get_connection(args.db_path)

    # Mapping: CSV filename → target table name in raw schema
    files = {
        "hr_employees.csv": "hr_employees",
        "project_assignments.csv": "project_assignments",
    }

    for csv_file, table_name in files.items():
        csv_path = args.processed_dir / csv_file
        if not csv_path.exists():
            raise FileNotFoundError(
                f"Processed file not found: {csv_path}. "
                "Run preprocess_sources.py first."
            )
        load_csv_to_table(con, csv_path, table_name)

    con.close()
    logger.info("All tables loaded successfully.")


if __name__ == "__main__":
    main()