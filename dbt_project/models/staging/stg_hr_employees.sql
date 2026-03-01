WITH source AS (
    SELECT
        *
    FROM
        {{ source('raw', 'hr_employees') }}
),
renamed AS (
    SELECT
        employee_id,
        first_name,
        last_name,
        first_name || ' ' || last_name AS full_name,
        lower(email_address) AS email,
        department,
        job_title,
        reports_to AS manager_id,
        CAST(date_of_hire AS DATE) AS date_of_hire,
        CAST(termination_date AS DATE) AS termination_date,
        upper(trim(status)) AS status,
        -- AUDIT z dbt
        '{{ run_started_at }}' AS _dbt_updated_at
    FROM
        source
),
final AS (
    SELECT
        *,
        CASE
            WHEN status = 'Active'
            AND (
                termination_date IS NULL
                OR termination_date > CURRENT_DATE
            ) THEN TRUE
            ELSE FALSE
        END AS is_active
    FROM
        renamed
)
SELECT
    *
FROM
    final