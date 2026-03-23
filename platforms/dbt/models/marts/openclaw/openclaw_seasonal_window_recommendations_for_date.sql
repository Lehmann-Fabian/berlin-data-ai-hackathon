with first_window as (

    select min(start_date) as start_date
    from {{ ref('int_seasonal_movie_windows_2026') }}

)

select
    r.start_date,
    r.until_date,
    r.period_description,
    r.title,
    r.release_year,
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
join first_window w
  on r.start_date = w.start_date
order by r.window_rank

