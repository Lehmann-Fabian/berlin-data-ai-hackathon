with d as (

    select *
    from {{ ref('openclaw_demo_defaults') }}

),

src_genres as (

    select distinct lower(g.genre) as genre
    from {{ ref('int_bridge_title_genres') }} g
    cross join d
    where g.object_id = d.demo_source_object_id

),

candidate_pool as (

    -- Keep the candidate set bounded for demo purposes: top 200 overall seasonal movies.
    select
        m.object_id,
        m.movie_title,
        m.release_year,
        m.genres,
        m.poster_jw,
        m.url_imdb,
        m.url_tmdb,
        m.window_rank
    from {{ ref('mart_movie_popularity_seasonal_ddmm_top20') }} m
    cross join d
    where m.app_locale = d.default_app_locale
      and m.anchor_ddmm = d.default_anchor_ddmm
      and m.genre_bucket = '__all__'
    qualify row_number() over (order by m.window_rank asc, m.object_id) <= 200

),

overlap as (

    select
        c.object_id,
        count(distinct sg.genre) as overlap_count
    from candidate_pool c
    join {{ ref('int_bridge_title_genres') }} cg
      on c.object_id = cg.object_id
    join src_genres sg
      on lower(cg.genre) = sg.genre
    group by 1

),

scored as (

    select
        c.object_id,
        c.movie_title as recommended_title,
        c.release_year as year,
        c.genres as genre,
        (o.overlap_count / nullif((select count(*) from src_genres), 0))::float as similarity_score,
        c.poster_jw,
        c.url_imdb,
        c.url_tmdb
    from overlap o
    join candidate_pool c
      on o.object_id = c.object_id
    cross join d
    where c.object_id <> d.demo_source_object_id

)

select *
from scored
order by similarity_score desc nulls last, year desc nulls last, object_id
limit 20

