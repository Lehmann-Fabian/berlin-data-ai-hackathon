SELECT
    start_date,
    until_date,
    period_description,
    season_rank,
    object_id,
    title,
    original_title,
    translated_title,
    release_year,
    release_date,
    imdb_score,
    runtime,
    poster_jw,
    url_imdb,
    matched_genre_count,
    matched_keyword_count,
    matched_genres,
    matched_keywords,
    total_score,
    object_text_short_description,
    short_description
FROM DB_TEAM_9.PUBLIC.seasonal_top50_movies
WHERE CAST(? AS DATE) BETWEEN start_date AND until_date
ORDER BY
    CASE WHEN NULLIF(TRIM(poster_jw), '') IS NOT NULL THEN 0 ELSE 1 END,
    season_rank ASC
LIMIT 10;
