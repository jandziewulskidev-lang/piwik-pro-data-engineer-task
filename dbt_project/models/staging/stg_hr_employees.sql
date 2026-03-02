WITH source AS (
    SELECT
        *
    FROM
        {{ source('raw', 'hr_employees') }}
),
renamed AS (
    SELECT
        employee_id,
        {{ dbt_utils.generate_surrogate_key(['upper(trim(employee_id))']) }} AS employee_sk,
        first_name,
        last_name,
        first_name || ' ' || last_name AS full_name,
              lower(
            replace(trim(first_name), ' ', '') || '.' || replace(trim(last_name), ' ', '')
        ) || '@company.com' as email,
        lower(email_address) AS raw_email,
        department,
        job_title,
      
    
        upper(trim(reports_to)) AS manager_id,
        case WHEN manager_id is not NULL
        then   {{ dbt_utils.generate_surrogate_key(['upper(trim(manager_id))']) }}
        else null
        end as manager_sk,
        CAST(date_of_hire AS DATE) AS date_of_hire,
        CAST(termination_date AS DATE) AS termination_date,
        upper(trim(status)) AS status,
        -- AUDIT z dbt
        cast('{{ run_started_at }}' as date) AS _dbt_updated_at
    FROM
        source
),
final AS (
    SELECT
        *,
        CASE
            WHEN status = 'ACTIVE'
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