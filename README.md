# dbt Project: Project Staffing Analytics

This dbt project provides analytics and data quality checks for project staffing, using HR and project assignment data. Below are step-by-step instructions and documentation for using and understanding the project.

## 1. Project Overview
- Cleans and transforms raw HR and project assignment data.
- Aggregates project staffing: team size, total weekly hours, and active team members per project.
- Ensures data quality with custom tests.

## 2. Setup & Running
1. **Install dependencies**
   - Make sure you have dbt installed and configured for your environment (DuckDB, Postgres, etc.).
2. **Prepare your data**
   - Place raw Excel exports in `data/raw/`.
   - Run the preprocessing script to convert Excel files to CSV:
     ```bash
     python scripts/preprocess_sources.py
     ```
3. **Run dbt models**
   - Build all models:
     ```bash
     dbt run
     ```
   - Run all tests:
     ```bash
     dbt test
     ```

## 3. Data Flow
- **Staging models**: Clean and standardize raw data (`stg_hr_employees`, `stg_project_assignments`).
- **Intermediate models**: Join HR and assignment data, add business logic flags (`int_project_assignments_joined`).
- **Marts models**: Aggregate staffing metrics per project (`project_staffing`).

## 4. Key Models
- `project_staffing`: Shows all projects, counts only active employees, sums their weekly hours, and lists active team members. Projects with no active employees are still included.
- `int_project_assignments_joined`: Joins assignments with HR data, flags valid assignments and active employees.

## 5. Data Quality & Tests
- Custom dbt tests check:
  - No assignments for inactive employees.
  - Employees with no termination date must be marked as active.
  - Unique combinations of project code and name.
  - Team size is always zero or positive.

## 6. Documentation
- All models and columns are documented in their respective `schema.yml` files.
- Column descriptions and business logic are provided for clarity and maintainability.

## 7. Resources
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
