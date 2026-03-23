-- Movie recommendations for a user-provided `search_date`.
--
-- This is an *example query template* intended for apps/websites (OpenClaw, CineClaw UI, etc.).
-- The date filter belongs in the consumer query (runtime), not inside the precomputed table model.
--
-- Inputs
-- - search_date: replace the literal in the params CTE (or bind it in your client).
--
-- Source table
-- - marts.mart_seasonal_window_movie_recommendations_top10

with params as (

    select '2026-01-01'::date as search_date

),

season_row as (

    select
        start_date,
        until_date,
        period_description
    from {{ ref('int_seasonal_movie_windows_2026') }}
    cross join params p
    where p.search_date >= start_date
      and p.search_date <= until_date

)

select
    r.object_id,
    r.title,
    r.original_title,
    r.translated_title,
    r.release_year,
    r.release_date,
    r.imdb_score,
    r.runtime,
    r.poster_jw,
    r.url_imdb,
    r.matched_genre_count,
    r.matched_keyword_count,
    r.matched_genres,
    r.matched_keywords,
    r.total_score,
    r.object_text_short_description,
    r.short_description
from {{ ref('mart_seasonal_window_movie_recommendations_top10') }} r
inner join season_row s
    on r.start_date = s.start_date
   and r.until_date = s.until_date
order by
    r.total_score desc,
    r.matched_genre_count desc,
    r.matched_keyword_count desc,
    r.imdb_score desc nulls last,
    r.release_year desc nulls last,
    r.object_id
limit 10

