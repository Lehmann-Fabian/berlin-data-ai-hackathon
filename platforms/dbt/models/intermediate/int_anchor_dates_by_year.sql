-- Expand yearless anchors (DD.MM) into concrete anchor dates for each dataset year.
--
-- Output grain: event_year × anchor_ddmm

with anchors as (

    select *
    from {{ ref('int_anchor_ddmm_spine') }}

),

years as (

    select *
    from {{ ref('int_clickout_years') }}

),

final as (

    select
        y.event_year,
        a.anchor_ddmm,
        a.anchor_day,
        a.anchor_month,
        a.anchor_day_date,
        date_from_parts(y.event_year, a.anchor_month, a.anchor_day) as anchor_date
    from anchors a
    cross join years y

)

select *
from final

