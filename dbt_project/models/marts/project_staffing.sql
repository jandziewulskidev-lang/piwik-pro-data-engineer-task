-- Model: project_staffing
-- Aggregates project staffing: always shows all projects,
-- counts only active employees and sums their weekly hours

with all_projects as (
    select distinct
        project_code,
        project_name
    from {{ ref('int_project_assignments_joined') }}
    where project_code is not null
      and project_name is not null
),

active_assignments as (
    select
        project_code,
        employee_id,
        weekly_hours
    from {{ ref('int_project_assignments_joined') }}
    where project_code is not null
      and is_employee_active = true
),

agg as (
    select
        p.project_code,
        p.project_name,
        count(distinct a.employee_id) as team_size,
        coalesce(sum(a.weekly_hours), 0) as total_weekly_hours
    from all_projects p
    left join active_assignments a
        on p.project_code = a.project_code
    group by p.project_code, p.project_name
)

select * from agg order by project_code