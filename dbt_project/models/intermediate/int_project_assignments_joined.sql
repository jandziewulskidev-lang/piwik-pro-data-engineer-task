with assignments as (
    select * from {{ ref('stg_project_assignments') }}
),

employees as (
    select * from {{ ref('stg_hr_employees') }}
),

joined as (
    select
        -- Klucze SK z Twojego stagingu (zmienisz nazwy, jeśli wygenerowałeś je inaczej)
        a.assignment_id,
        a.employee_sk,
        
        -- Wymiary pracownika (dociągnięte z tabeli HR)
        e.full_name as employee_name,
        e.email as employee_email,
        e.department,
        e.job_title,
        e.status as employee_status,
        
        -- Wymiary i fakty z przypisań
        a.project_code,
        a.project_name,
        a.assignment_role,
        a.start_date as assignment_start_date,
        a.weekly_hours,
        a.is_billable,

        -- Tutaj sprawdzamy regułę biznesową: "Czy przypisanie na pewno jest aktywne?"
        -- Taki zapis jest wydajny i uodporniony na błędy, tak jak rozmawialiśmy
        case 
            when e.status = 'ACTIVE' 
                 and (e.termination_date is null or a.start_date <= e.termination_date)
            then true 
            else false 
        end as is_valid_assignment

    from assignments a
    -- JOIN używa Twoich nowych Surrogate Keys!
    left join employees e
        on a.employee_sk = e.employee_sk
)

select * from joined
