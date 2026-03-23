with d as (

    select *
    from {{ ref('openclaw_demo_defaults') }}

)

select
    m.movie_title as title,
    m.release_year as year,
    m.genres as genre,
    m.weighted_clickouts_29d_sum as score,
    'Family-friendly seasonal popularity' as reason,
    m.poster_jw,
    m.url_imdb,
    m.url_tmdb
from {{ ref('mart_movie_popularity_seasonal_ddmm_top20') }} m
cross join d
where m.app_locale = d.default_app_locale
  and m.anchor_ddmm = d.default_anchor_ddmm
  and m.genre_bucket in ('FamilyAnimation', 'ComedyFamily', 'Family')
qualify row_number() over (
    order by m.weighted_clickouts_29d_sum desc, m.window_rank asc, m.object_id
) <= 20

