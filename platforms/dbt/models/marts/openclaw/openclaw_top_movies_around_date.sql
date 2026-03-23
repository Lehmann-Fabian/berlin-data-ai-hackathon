with d as (

    select *
    from {{ ref('openclaw_demo_defaults') }}

)

select
    r.movie_title,
    r.weighted_clickouts_29d,
    r.window_rank,
    r.poster_jw,
    r.url_imdb,
    r.url_tmdb
from {{ ref('mart_movie_popularity_rolling_29d_top20') }} r
cross join d
where r.app_locale = d.default_app_locale
  and r.anchor_date = d.default_anchor_date
  and r.genre_bucket = '__all__'
order by r.window_rank

