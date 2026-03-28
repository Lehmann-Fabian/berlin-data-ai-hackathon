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
  and (
      r.movie_title ilike '%' || d.demo_keyword || '%'
      or r.short_description ilike '%' || d.demo_keyword || '%'
      or r.object_text_short_description ilike '%' || d.demo_keyword || '%'
      or r.genres ilike '%' || d.demo_keyword || '%'
  )
qualify row_number() over (order by r.weighted_clickouts_29d desc, r.window_rank asc, r.object_id) <= 20

