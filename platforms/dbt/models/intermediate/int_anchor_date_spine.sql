-- Anchor date spine for rolling-window popularity marts.
--
-- Produces one row per date within the clickout dataset period.

with coverage as (

    select
        min(event_date) as min_date,
        max(event_date) as max_date
    from {{ ref('fct_clickouts') }}

),

final as (

    select
        t.date_day as anchor_date
    from {{ ref('metricflow_time_spine') }} t
    cross join coverage c
    where t.date_day between c.min_date and c.max_date

)

select *
from final

