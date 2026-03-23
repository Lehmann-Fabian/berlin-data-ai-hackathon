-- Daily movie clickout counts (human traffic only).
--
-- Grain: event_date × app_locale × object_id
-- Source: fct_clickouts (already filtered to human clickouts).

with clickouts as (

    select *
    from {{ ref('fct_clickouts') }}

),

movies as (

    select object_id
    from {{ ref('dim_titles') }}
    where object_type = 'movie'

),

final as (

    select
        c.event_date,
        c.app_locale,
        c.title_jw_entity_id as object_id,
        count(*) as clickouts_daily
    from clickouts c
    join movies m
      on c.title_jw_entity_id = m.object_id
    group by 1, 2, 3

)

select *
from final

