with d as (

    select *
    from {{ ref('openclaw_demo_defaults') }}

),

window as (

    select
        d.default_app_locale as app_locale,
        dateadd('day', -14, d.default_anchor_date) as start_date,
        dateadd('day', 14, d.default_anchor_date)  as end_date
    from d

),

movies as (

    select object_id
    from {{ ref('dim_titles') }}
    where object_type = 'movie'

)

select
    t.title as movie_title,
    c.title_jw_entity_id as object_id,
    count(*) as clickouts,
    count(distinct c.user_id) as unique_users,
    count(distinct c.session_id) as unique_sessions
from {{ ref('fct_clickouts') }} c
join window w
  on c.app_locale = w.app_locale
 and c.event_date between w.start_date and w.end_date
join movies m
  on c.title_jw_entity_id = m.object_id
join {{ ref('dim_titles') }} t
  on c.title_jw_entity_id = t.object_id
group by 1, 2
order by clickouts desc, unique_users desc, unique_sessions desc, object_id
limit 50

