-- Lightdash-ready daily movie popularity distribution.
--
-- Grain: event_date (UTC day) × app_locale × movie
-- Signal: human clickouts (fct_clickouts)
-- Output: Top 50 movies per (day, market) by clickouts, with rank for charting.

with clickouts as (

    select *
    from {{ ref('fct_clickouts') }}

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

daily as (

    select
        c.event_date,
        c.app_locale,
        c.title_jw_entity_id                        as object_id,

        count(*)                                    as clickouts,
        count(distinct c.user_id)                   as unique_users,
        count(distinct c.session_id)                as unique_sessions
    from clickouts c
    join movies m
      on c.title_jw_entity_id = m.object_id
    group by 1, 2, 3

),

ranked as (

    select
        d.event_date,
        d.app_locale,
        d.object_id,

        m.movie_title,
        m.original_title,
        m.translated_title,
        m.short_description,
        m.object_text_short_description,
        m.poster_jw,
        m.url_imdb,
        m.url_tmdb,
        m.release_year,
        m.imdb_score,
        g.genres,

        d.clickouts,
        d.unique_users,
        d.unique_sessions,

        row_number() over (
            partition by d.event_date, d.app_locale
            order by d.clickouts desc, d.unique_users desc, d.unique_sessions desc, d.object_id
        )                                           as daily_rank,

        to_varchar(d.event_date) || '|' || coalesce(d.app_locale, '') || '|' || d.object_id as daily_popularity_id
    from daily d
    join movies m
      on d.object_id = m.object_id
    left join movie_genres g
      on d.object_id = g.object_id

)

select *
from ranked
where daily_rank <= 50
