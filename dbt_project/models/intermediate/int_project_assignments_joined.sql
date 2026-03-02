with assignments as (
    -- Get cleaned project assignment records
    select
        *
    from
        {{ ref('stg_project_assignments') }}
),
employees as (
    -- Get cleaned employee records
    select
        *
    from
        {{ ref('stg_hr_employees') }}
),
joined as (
    -- Join assignments with employees, no GROUP BY here
    select
        -- Primary keys from both tables
        a.assignment_id,
        a.employee_id,
        a.project_code,
        -- Project details from assignments
        a.project_name,
        a.assignment_role,
        a.weekly_hours,
        a.start_date as assignment_start_date,
        a.is_billable,
        -- Employee details from HR
        e.full_name as employee_name,
        e.email,
        e.department,
        e.job_title,
        e.is_active as is_employee_active,
        cast('{{ run_started_at }}' as date) AS _int_dbt_updated_at,
    from
        assignments a -- Using LEFT JOIN ensures no project assignment is lost, even if the employee record is missing.
        left join employees e on a.employee_sk = e.employee_sk
)
select
    *
from
    joined