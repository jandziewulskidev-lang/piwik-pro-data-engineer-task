.PHONY: all preprocess load dbt-run dbt-test pipeline help

# Default target - runs full pipeline
all: pipeline

# Display available commands
help:
	@echo "Available commands:"
	@echo "  make preprocess - Process raw Excel files into CSVs"
	@echo "  make load       - Load processed CSVs into DuckDB raw schema"


# Step 1: Process raw Excel files → data/processed/*.csv
preprocess:
	python scripts/preprocess_sources.py \
		--raw-dir data/raw \
		--output-dir data/processed

# Step 2: Load processed CSVs → DuckDB raw schema
load:
	python scripts/load_to_duckdb.py \
		--db-path /data/warehouse_dev.duckdb \
		--processed-dir data/processed

# Step 3: Run dbt models (staging → analytics)
dbt-run:
	dbt run --profiles-dir .

# Step 4: Run dbt tests
dbt-test:
	dbt test --profiles-dir .

# Full pipeline: all steps in order
pipeline: preprocess load dbt-run dbt-test