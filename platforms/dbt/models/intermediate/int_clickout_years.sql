-- Distinct years present in the clickout dataset.
--
-- Used to expand a yearless (DD.MM) anchor into a real anchor_date per year.

with daily as (

    select *
    from {{ ref('int_fct_movie_clickouts_daily') }}

),

final as (

    select distinct
        extract(year from event_date) as event_year
    from daily
    where event_date is not null

)

select *
from final

