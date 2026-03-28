with d as (

    select *
    from {{ ref('openclaw_demo_defaults') }}

)

select
    m.movie_title,
    m.weighted_clickouts_29d_sum,
    m.window_rank,
    m.years_covered,
    m.poster_jw,
    m.url_imdb,
    m.url_tmdb
from {{ ref('mart_movie_popularity_seasonal_ddmm_top20') }} m
cross join d
where m.app_locale = d.default_app_locale
  and m.anchor_ddmm = d.default_anchor_ddmm
  and m.genre_bucket = '__all__'
order by m.window_rank

