CREATE OR REPLACE TABLE DB_TEAM_9.PUBLIC.seasonal_top50_movies AS

WITH season_rows AS (
    SELECT
        start_date,
        until_date,
        period_description,
        popular_genre,
        description_keywords
    FROM DB_TEAM_9.PUBLIC.SEASONAL_MOVIE_WINDOWS_2026
),

movies AS (
    SELECT
        o.object_id,
        o.title,
        o.original_title,
        o.translated_title,
        o.short_description,
        o.object_text_short_description,
        o.release_year,
        o.release_date,
        o.imdb_score,
        o.runtime,
        o.poster_jw,
        o.url_imdb,
        o.genre_tmdb
    FROM DB_JW_SHARED.CHALLENGE.OBJECTS o
    WHERE LOWER(o.object_type) = 'movie'
),

genre_matches AS (
    SELECT
        s.start_date,
        s.until_date,
        m.object_id,
        COUNT(DISTINCT LOWER(g.value::STRING)) AS matched_genre_count,
        ARRAY_AGG(DISTINCT LOWER(g.value::STRING)) AS matched_genres
    FROM movies m
    CROSS JOIN season_rows s
    , LATERAL FLATTEN(input => m.genre_tmdb) g
    , LATERAL FLATTEN(input => s.popular_genre) sg
    WHERE LOWER(g.value::STRING) = LOWER(sg.value::STRING)
    GROUP BY s.start_date, s.until_date, m.object_id
),

keyword_matches AS (
    SELECT
        s.start_date,
        s.until_date,
        m.object_id,
        COUNT(DISTINCT kw.value::STRING) AS matched_keyword_count,
        ARRAY_AGG(DISTINCT kw.value::STRING) AS matched_keywords
    FROM movies m
    CROSS JOIN season_rows s
    , LATERAL FLATTEN(input => s.description_keywords) kw
    WHERE CONTAINS(
              LOWER(
                  COALESCE(m.title, '') || ' ' ||
                  COALESCE(m.original_title, '') || ' ' ||
                  COALESCE(m.translated_title, '') || ' ' ||
                  COALESCE(m.object_text_short_description, '') || ' ' ||
                  COALESCE(m.short_description, '')
              ),
              LOWER(kw.value::STRING)
          )
    GROUP BY s.start_date, s.until_date, m.object_id
),

scored AS (
    SELECT
        s.start_date,
        s.until_date,
        s.period_description,
        m.object_id,
        m.title,
        m.original_title,
        m.translated_title,
        m.release_year,
        m.release_date,
        m.imdb_score,
        m.runtime,
        m.poster_jw,
        m.url_imdb,
        m.short_description,
        m.object_text_short_description,
        COALESCE(gm.matched_genre_count, 0) AS matched_genre_count,
        COALESCE(km.matched_keyword_count, 0) AS matched_keyword_count,
        COALESCE(gm.matched_genres, ARRAY_CONSTRUCT()) AS matched_genres,
        COALESCE(km.matched_keywords, ARRAY_CONSTRUCT()) AS matched_keywords,
        (COALESCE(gm.matched_genre_count, 0) * 5) +
        (COALESCE(km.matched_keyword_count, 0) * 3) +
        (COALESCE(m.imdb_score, 0) * 0.1) AS total_score
    FROM season_rows s
    CROSS JOIN movies m
    LEFT JOIN genre_matches gm
        ON gm.start_date = s.start_date
       AND gm.until_date = s.until_date
       AND gm.object_id = m.object_id
    LEFT JOIN keyword_matches km
        ON km.start_date = s.start_date
       AND km.until_date = s.until_date
       AND km.object_id = m.object_id
    WHERE COALESCE(gm.matched_genre_count, 0) > 0
       OR COALESCE(km.matched_keyword_count, 0) > 0
),

ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY start_date, until_date
            ORDER BY
                total_score DESC,
                matched_genre_count DESC,
                matched_keyword_count DESC,
                imdb_score DESC NULLS LAST,
                release_year DESC NULLS LAST
        ) AS season_rank
    FROM scored
)

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
FROM ranked
WHERE season_rank <= 50
ORDER BY start_date, season_rank;