-- Model: project_staffing
-- Agreguje staffing projektów zgodnie z wymaganiami biznesowymi

with cleaned as (
    select
        project_code,
        project_name,
        assignment_role,
        employee_name,
        employee_status,
        assignment_start_date,
        weekly_hours,
        is_valid_assignment
    from {{ ref('int_project_assignments_joined') }}
    where project_code is not null and project_name is not null
),

project_leads as (
    -- Lider projektu: pierwszy aktywny pracownik z rolą 'Lead' (jeśli nie ma aktywnego, to dowolny Lead)
    select
        project_code,
        project_name,
        min_by(employee_name, case when employee_status = 'ACTIVE' and is_valid_assignment then 1 else 2 end) as project_lead
    from cleaned
    where assignment_role = 'Lead'
    group by project_code, project_name
),

active_assignments as (
    select
        project_code,
        project_name,
        employee_name,
        weekly_hours
    from cleaned
    where employee_status = 'ACTIVE' and is_valid_assignment
),

agg as (
    select
        p.project_code,
        p.project_name,
        p.project_lead,
        count(a.employee_name) as team_size,
        coalesce(sum(a.weekly_hours), 0) as total_weekly_hours
    from project_leads p
    left join active_assignments a
        on p.project_code = a.project_code and p.project_name = a.project_name
    group by p.project_code, p.project_name, p.project_lead
)

select * from agg
