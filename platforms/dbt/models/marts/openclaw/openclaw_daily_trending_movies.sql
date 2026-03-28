with d as (

    select *
    from {{ ref('openclaw_demo_defaults') }}

)

select
    t.movie_title,
    t.clickouts,
    t.daily_rank,
    t.poster_jw,
    t.url_imdb,
    t.url_tmdb
from {{ ref('mart_movie_popularity_daily_top50') }} t
cross join d
where t.app_locale = d.default_app_locale
  and t.event_date = d.default_event_date
order by t.daily_rank

