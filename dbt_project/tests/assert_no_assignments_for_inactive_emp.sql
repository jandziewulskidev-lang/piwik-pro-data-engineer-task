-- Test: assert_no_assignments_for_inactive_emp
-- This test checks that no project assignments exist for employees who are not active.
-- If is_employee_active is False, the assignment should be considered invalid and flagged for review.

{{ config(
    severity = 'warn',
    tags = ['hr_data', 'data_quality', 'project_assignments']
) }}

select
    assignment_id,
    employee_id,
    project_code,
from {{ ref('int_project_assignments_joined') }}

where is_employee_active = False

