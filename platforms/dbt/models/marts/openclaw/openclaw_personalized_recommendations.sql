with d as (

    select *
    from {{ ref('openclaw_demo_defaults') }}

),

user_params as (

    select
        d.demo_user_id as user_id,
        d.default_app_locale as app_locale,
        dateadd('day', -60, d.default_event_date) as start_date,
        d.default_event_date as end_date,
        d.default_anchor_ddmm as anchor_ddmm
    from d

),

user_genres as (

    select
        lower(g.genre) as genre,
        count(*) as user_clickouts_in_genre
    from {{ ref('fct_clickouts') }} c
    join {{ ref('int_bridge_title_genres') }} g
      on c.title_jw_entity_id = g.object_id
    join user_params p
      on c.user_id = p.user_id
     and c.app_locale = p.app_locale
     and c.event_date between p.start_date and p.end_date
    group by 1
    qualify row_number() over (order by user_clickouts_in_genre desc, genre) <= 3

),

recs as (

    select
        m.object_id,
        m.movie_title as title,
        m.release_year as year,
        m.genres as genre,
        m.weighted_clickouts_29d_sum as score,
        'Popular around ' || (select anchor_ddmm from user_params) || ' and matches your genre: ' || ug.genre as reason,
        m.poster_jw,
        m.url_imdb,
        m.url_tmdb
    from {{ ref('mart_movie_popularity_seasonal_ddmm_top20') }} m
    cross join d
    join user_params p
      on m.app_locale = p.app_locale
     and m.anchor_ddmm = p.anchor_ddmm
    join user_genres ug
      on lower(m.genre_bucket) = ug.genre

)

select *
from recs
order by score desc, year desc nulls last, object_id
limit 20

