-- Staging model for project assignment records.
-- Responsibilities:
--   - Rename emp_id → employee_id for consistency with stg_hr_employees
--   - Normalize billable flag from inconsistent strings (Y/Yes/N/No) to boolean
--   - Cast date and numeric columns to proper types
--   - Trim whitespace from string columns
-- Business logic is handled in analytics layer.
WITH source AS (
    SELECT
        *
    FROM
        {{ source('raw', 'project_assignments') }}
),
renamed AS (
    SELECT
        assignment_id,
        emp_id AS employee_id,
        -- renamed for consistency
        trim(project_code) AS project_code,
        trim(project_name) AS project_name,
        upper(left(trim(assignment_role),1)) || lower(substr(trim(assignment_role),2)) AS assignment_role,
        CAST(start_date AS DATE) AS start_date,
        CAST(weekly_hours AS INTEGER) AS weekly_hours,
        -- Normalize inconsistent billable flag values to boolean
        -- Source contains mixed formats: 'Y', 'Yes', 'N', 'No'
        CASE
            WHEN upper(trim(billable)) IN ('Y', 'YES') THEN TRUE
            WHEN upper(trim(billable)) IN ('N', 'NO') THEN FALSE
            ELSE NULL
        END AS is_billable
    FROM
        source
)
SELECT
    *
FROM
    renamed