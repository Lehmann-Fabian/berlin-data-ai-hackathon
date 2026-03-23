WITH season_row AS (
    SELECT
        start_date,
        until_date,
        period_description,
        popular_genre,
        description_keywords
    FROM DB_TEAM_9.PUBLIC.seasonal_movie_windows_2026
    WHERE start_date = '2026-01-01'::DATE
      AND until_date = '2026-01-06'::DATE
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
        o.genre_tmdb,
        o.runtime,
        o.poster_jw,
        o.url_imdb
    FROM DB_JW_SHARED.CHALLENGE.OBJECTS o
    WHERE LOWER(o.object_type) = 'movie'
      AND o.imdb_score > 6
      AND o.show_season_id IS NULL
),

genre_matches AS (
    SELECT
        m.object_id,
        COUNT(DISTINCT LOWER(g.value::STRING)) AS matched_genre_count,
        ARRAY_AGG(DISTINCT LOWER(g.value::STRING)) AS matched_genres
    FROM movies m
    CROSS JOIN season_row s
    , LATERAL FLATTEN(input => m.genre_tmdb) g
    , LATERAL FLATTEN(input => s.popular_genre) sg
    WHERE LOWER(g.value::STRING) = LOWER(sg.value::STRING)
    GROUP BY m.object_id
),

keyword_matches AS (
    SELECT
        m.object_id,
        COUNT(DISTINCT kw.value::STRING) AS matched_keyword_count,
        ARRAY_AGG(DISTINCT kw.value::STRING) AS matched_keywords
    FROM movies m
    CROSS JOIN season_row s
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
    GROUP BY m.object_id
),

scored AS (
    SELECT
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
        /* Weighted score: genres matter most, keywords next, imdb_score as tiebreak */
        (COALESCE(gm.matched_genre_count, 0) * 5) +
        (COALESCE(km.matched_keyword_count, 0) * 3) +
        (COALESCE(m.imdb_score, 0) * 0.1) AS total_score
    FROM movies m
    LEFT JOIN genre_matches gm
        ON m.object_id = gm.object_id
    LEFT JOIN keyword_matches km
        ON m.object_id = km.object_id
)

SELECT
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
FROM scored
WHERE matched_genre_count > 0
   OR matched_keyword_count > 0
ORDER BY
    total_score DESC,
    matched_genre_count DESC,
    matched_keyword_count DESC,
    imdb_score DESC NULLS LAST,
    release_year DESC NULLS LAST
LIMIT 10;