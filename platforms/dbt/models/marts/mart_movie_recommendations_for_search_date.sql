-- Convenience view: "movie recommendations for a given date".
--
-- This keeps the output columns aligned with the ad-hoc query pattern:
-- - pick a search_date
-- - find the matching seasonal window
-- - return Top 10 scored movies
--
-- Provide the date at build-time via dbt vars:
--   dbt build --select marts.mart_movie_recommendations_for_search_date --vars '{"search_date":"2026-01-01"}'

with params as (

    select to_date('{{ var("search_date", "2026-01-01") }}') as search_date

),

season_row as (

    select
        w.start_date,
        w.until_date,
        w.period_description
    from {{ ref('int_seasonal_movie_windows_2026') }} w
    cross join params p
    where p.search_date >= w.start_date
      and p.search_date <= w.until_date

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

