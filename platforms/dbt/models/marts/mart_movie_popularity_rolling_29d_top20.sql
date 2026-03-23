-- Rolling-window movie popularity for “around a date” recommendations.
--
-- Window: anchor_date ± 14 days (29-day window)
-- Partition/rank: anchor_date × app_locale × genre_bucket
-- Output: Top 20 movies per partition by clickouts_29d
--
-- genre_bucket values:
-- - '__all__' for overall popularity
-- - single genres (e.g. 'Comedy')
-- - curated multi-genre buckets (e.g. 'RomCom' = Romance + Comedy)

with spine as (

    select *
    from {{ ref('int_anchor_date_spine') }}

),

daily as (

    select *
    from {{ ref('int_fct_movie_clickouts_daily') }}

),

overall_window as (

    select
        s.anchor_date,
        dateadd('day', -14, s.anchor_date) as window_start_date,
        dateadd('day', 14, s.anchor_date)  as window_end_date,
        d.app_locale,
        d.object_id,
        sum(d.clickouts_daily) as clickouts_29d,

        -- Triangular weighting: center day counts most, linear decay to the edge of the window.
        -- weight(days_diff) = (15 - days_diff) / 15  for days_diff in [0..14]
        sum(
            d.clickouts_daily
            * ((15.0 - abs(datediff('day', d.event_date, s.anchor_date))) / 15.0)
        ) as weighted_clickouts_29d
    from spine s
    join daily d
      on d.event_date between dateadd('day', -14, s.anchor_date) and dateadd('day', 14, s.anchor_date)
    group by 1, 2, 3, 4, 5

),

bucket_membership as (

    select *
    from {{ ref('int_bridge_genre_bucket_titles') }}

),

bucketed_window as (

    select
        o.anchor_date,
        o.window_start_date,
        o.window_end_date,
        o.app_locale,
        b.genre_bucket,
        o.object_id,
        o.clickouts_29d,
        o.weighted_clickouts_29d
    from overall_window o
    join bucket_membership b
      on o.object_id = b.object_id

),

unioned as (

    select
        anchor_date,
        window_start_date,
        window_end_date,
        app_locale,
        '__all__' as genre_bucket,
        object_id,
        clickouts_29d,
        weighted_clickouts_29d
    from overall_window

    union all

    select
        anchor_date,
        window_start_date,
        window_end_date,
        app_locale,
        genre_bucket,
        object_id,
        clickouts_29d,
        weighted_clickouts_29d
    from bucketed_window

),

movies as (

    select
        object_id,
        title as movie_title,
        original_title,
        translated_title,
        short_description,
        object_text_short_description,
        poster_jw,
        url_imdb,
        url_tmdb,
        release_date,
        release_year,
        imdb_score
    from {{ ref('dim_titles') }}
    where object_type = 'movie'

),

movie_genres as (

    select
        object_id,
        listagg(distinct genre, ', ') within group (order by genre) as genres
    from {{ ref('int_bridge_title_genres') }}
    group by 1

),

ranked as (

    select
        u.anchor_date,
        u.window_start_date,
        u.window_end_date,
        u.app_locale,
        u.genre_bucket,
        u.object_id,

        m.movie_title,
        m.original_title,
        m.translated_title,
        m.short_description,
        m.object_text_short_description,
        g.genres,
        m.poster_jw,
        m.url_imdb,
        m.url_tmdb,
        m.release_year,
        m.imdb_score,

        u.clickouts_29d,
        u.weighted_clickouts_29d,

        row_number() over (
            partition by u.anchor_date, u.app_locale, u.genre_bucket
            order by u.weighted_clickouts_29d desc, u.clickouts_29d desc, u.object_id
        ) as window_rank,

        to_varchar(u.anchor_date) || '|' || coalesce(u.app_locale, '') || '|' || u.genre_bucket || '|' || u.object_id as rolling_popularity_id
    from unioned u
    join movies m
      on u.object_id = m.object_id
     and (
         m.release_date is null
         or dateadd('month', 6, m.release_date) <= u.anchor_date
     )
    left join movie_genres g
      on u.object_id = g.object_id

)

select *
from ranked
where window_rank <= 20
