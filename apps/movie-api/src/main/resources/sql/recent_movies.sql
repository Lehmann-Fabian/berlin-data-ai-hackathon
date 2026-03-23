SELECT
    anchor_date,
    rank,
    object_id,
    title,
    original_title,
    release_year,
    release_date,
    imdb_score,
    runtime,
    genre_tmdb,
    poster_jw,
    url_imdb,
    watch_count
FROM DB_TEAM_9.PUBLIC.monthly_top20_recent_movies
WHERE anchor_date = DATE_TRUNC('MONTH', CAST(? AS DATE))
ORDER BY
    CASE WHEN NULLIF(TRIM(poster_jw), '') IS NOT NULL THEN 0 ELSE 1 END,
    rank ASC
LIMIT 10;
