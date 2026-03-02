-- Test: assert_active_status_if_no_termination_date
-- This test checks that every employee record with a NULL termination_date has status 'active'.
-- If an employee has no termination date, they should always be marked as active in the HR data.

{{ config(
    severity = 'error',
    tags = ['hr_data', 'data_quality']
) }}

SELECT
employee_id,
status,
termination_date
from {{ ref('stg_hr_employees') }} 
where termination_date is  null
and lower(status) != 'active'