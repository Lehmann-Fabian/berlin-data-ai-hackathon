WITH filtered AS (
    SELECT
        p.anchor_date,
        p.window_start_date,
        p.window_end_date,
        p.app_locale,
        p.genre_bucket,
        p.object_id,
        p.movie_title,
        p.original_title,
        p.translated_title,
        p.short_description,
        p.object_text_short_description,
        p.genres,
        p.poster_jw,
        p.url_imdb,
        p.url_tmdb,
        p.release_year,
        p.imdb_score,
        o.runtime,
        p.clickouts_29d,
        p.weighted_clickouts_29d,
        p.window_rank,
        p.rolling_popularity_id
    FROM DB_TEAM_9.MARTS.MART_MOVIE_POPULARITY_ROLLING_29D_TOP20 p
    LEFT JOIN DB_JW_SHARED.CHALLENGE.OBJECTS o
        ON p.object_id = o.object_id
    WHERE app_locale = 'DE'
      AND COALESCE(
            TO_VARCHAR(TRY_TO_DATE(p.anchor_date::STRING), 'DD.MM'),
            p.anchor_date::STRING
          ) = ?
),

deduplicated AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY object_id
            ORDER BY
                CASE WHEN NULLIF(TRIM(poster_jw), '') IS NOT NULL THEN 0 ELSE 1 END,
                CASE WHEN genre_bucket = '__all__' THEN 0 ELSE 1 END,
                window_rank ASC,
                weighted_clickouts_29d DESC,
                clickouts_29d DESC
        ) AS object_rank
    FROM filtered
)

SELECT
    anchor_date,
    window_start_date,
    window_end_date,
    app_locale,
    genre_bucket,
    object_id,
    movie_title,
    original_title,
    translated_title,
    short_description,
    object_text_short_description,
    genres,
    poster_jw,
    url_imdb,
    url_tmdb,
    release_year,
    imdb_score,
    runtime,
    clickouts_29d,
    weighted_clickouts_29d,
    window_rank,
    rolling_popularity_id
FROM deduplicated
WHERE object_rank = 1
ORDER BY
    CASE WHEN NULLIF(TRIM(poster_jw), '') IS NOT NULL THEN 0 ELSE 1 END,
    window_rank ASC,
    weighted_clickouts_29d DESC,
    clickouts_29d DESC
LIMIT 20;
