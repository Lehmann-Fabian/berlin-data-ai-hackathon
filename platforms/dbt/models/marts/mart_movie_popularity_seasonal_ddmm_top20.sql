-- Seasonal (multi-year) rolling-window movie popularity.
--
-- Anchor: day+month only (anchor_ddmm, e.g. '25.12'), aggregated across all dataset years.
-- Window per year: anchor_date ± 14 days (29-day window)
-- Weighting: triangular (anchor day counts most; linear decay to window edges)
-- Partition/rank: anchor_ddmm × app_locale × genre_bucket
-- Output: Top 20 movies per partition by weighted_clickouts_29d_sum
--
-- genre_bucket values:
-- - '__all__' for overall popularity (no genre constraint)
-- - single genres (e.g. 'Comedy')
-- - curated multi-genre buckets (e.g. 'RomCom' = Romance + Comedy)

with anchor_dates as (

    select *
    from {{ ref('int_anchor_dates_by_year') }}

),

daily as (

    select *
    from {{ ref('int_fct_movie_clickouts_daily') }}

),

per_year_overall as (

    select
        a.event_year,
        a.anchor_ddmm,
        a.anchor_day,
        a.anchor_month,
        a.anchor_day_date,
        a.anchor_date,
        dateadd('day', -14, a.anchor_date) as window_start_date,
        dateadd('day', 14, a.anchor_date)  as window_end_date,

        d.app_locale,
        d.object_id,

        sum(d.clickouts_daily) as clickouts_29d,

        sum(
            d.clickouts_daily
            * ((15.0 - abs(datediff('day', d.event_date, a.anchor_date))) / 15.0)
        ) as weighted_clickouts_29d
    from anchor_dates a
    join daily d
      on d.event_date between dateadd('day', -14, a.anchor_date) and dateadd('day', 14, a.anchor_date)
    group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10

),

bucket_membership as (

    select *
    from {{ ref('int_bridge_genre_bucket_titles') }}

),

per_year_bucketed as (

    select
        o.event_year,
        o.anchor_ddmm,
        o.anchor_day,
        o.anchor_month,
        o.anchor_day_date,
        o.anchor_date,
        o.window_start_date,
        o.window_end_date,

        o.app_locale,
        b.genre_bucket,
        o.object_id,

        o.clickouts_29d,
        o.weighted_clickouts_29d
    from per_year_overall o
    join bucket_membership b
      on o.object_id = b.object_id

),

per_year_union as (

    select
        event_year,
        anchor_ddmm,
        anchor_day,
        anchor_month,
        anchor_day_date,
        anchor_date,
        window_start_date,
        window_end_date,
        app_locale,
        '__all__' as genre_bucket,
        object_id,
        clickouts_29d,
        weighted_clickouts_29d
    from per_year_overall

    union all

    select
        event_year,
        anchor_ddmm,
        anchor_day,
        anchor_month,
        anchor_day_date,
        anchor_date,
        window_start_date,
        window_end_date,
        app_locale,
        genre_bucket,
        object_id,
        clickouts_29d,
        weighted_clickouts_29d
    from per_year_bucketed

),

across_years as (

    select
        anchor_ddmm,
        anchor_day,
        anchor_month,
        anchor_day_date,
        app_locale,
        genre_bucket,
        object_id,

        sum(clickouts_29d) as clickouts_29d_sum,
        sum(weighted_clickouts_29d) as weighted_clickouts_29d_sum,
        count(distinct event_year) as years_covered
    from per_year_union
    group by 1, 2, 3, 4, 5, 6, 7

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
        runtime as runtime_minutes,
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
        a.anchor_ddmm,
        a.anchor_day,
        a.anchor_month,
        a.anchor_day_date,

        a.app_locale,
        a.genre_bucket,
        a.object_id,

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
        m.runtime_minutes,
        m.imdb_score,

        a.clickouts_29d_sum,
        a.weighted_clickouts_29d_sum,
        a.years_covered,

        row_number() over (
            partition by a.anchor_ddmm, a.app_locale, a.genre_bucket
            order by a.weighted_clickouts_29d_sum desc, a.clickouts_29d_sum desc, a.object_id
        ) as window_rank,

        a.anchor_ddmm || '|' || coalesce(a.app_locale, '') || '|' || a.genre_bucket || '|' || a.object_id as seasonal_popularity_id
    from across_years a
    join movies m
      on a.object_id = m.object_id
    left join movie_genres g
      on a.object_id = g.object_id

)

select *
from ranked
where window_rank <= 20
