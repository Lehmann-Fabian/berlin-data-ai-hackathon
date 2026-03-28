-- Seasonal-window movie recommendations (Top 10 per window).
--
-- Intended use: power an app/website that picks a "season row" for a given date and then
-- shows recommended movies based on matching genres + description keywords.
--
-- Source windows: {{ ref('int_seasonal_movie_windows_2026') }}
-- Source movies:  {{ ref('base_objects') }} (typed staging for JW OBJECTS)

with windows as (

    select
        start_date,
        until_date,
        period_description,
        popular_genre,
        description_keywords
    from {{ ref('int_seasonal_movie_windows_2026') }}

),

movies as (

    select
        object_id,
        title,
        original_title,
        translated_title,
        short_description,
        object_text_short_description,
        release_year,
        release_date,
        imdb_score,
        genre_tmdb,
        runtime,
        poster_jw,
        url_imdb
    from {{ ref('base_objects') }}
    where object_type = 'movie'
      and imdb_score > 6
      and show_season_id is null

),

window_genres as (

    select
        w.start_date,
        w.until_date,
        w.period_description,
        lower(sg.value::string) as genre
    from windows w,
         lateral flatten(input => w.popular_genre) sg
    where sg.value is not null

),

movie_genres as (

    select
        m.object_id,
        lower(g.value::string) as genre
    from movies m,
         lateral flatten(input => m.genre_tmdb) g
    where g.value is not null

),

genre_matches as (

    select
        wg.start_date,
        wg.until_date,
        wg.period_description,
        mg.object_id,
        count(distinct mg.genre)             as matched_genre_count,
        array_agg(distinct mg.genre)         as matched_genres
    from window_genres wg
    inner join movie_genres mg
        on wg.genre = mg.genre
    group by 1, 2, 3, 4

),

window_keywords as (

    select
        w.start_date,
        w.until_date,
        w.period_description,
        lower(kw.value::string) as keyword
    from windows w,
         lateral flatten(input => w.description_keywords) kw
    where kw.value is not null

),

movie_text as (

    select
        m.object_id,
        lower(
            coalesce(m.title, '') || ' ' ||
            coalesce(m.original_title, '') || ' ' ||
            coalesce(m.translated_title, '') || ' ' ||
            coalesce(m.object_text_short_description, '') || ' ' ||
            coalesce(m.short_description, '')
        ) as search_text
    from movies m

),

keyword_matches as (

    select
        wk.start_date,
        wk.until_date,
        wk.period_description,
        mt.object_id,
        count(distinct wk.keyword)           as matched_keyword_count,
        array_agg(distinct wk.keyword)       as matched_keywords
    from window_keywords wk
    inner join movie_text mt
        on position(wk.keyword in mt.search_text) > 0
    group by 1, 2, 3, 4

),

scored as (

    select
        w.start_date,
        w.until_date,
        w.period_description,

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

        coalesce(gm.matched_genre_count, 0)                                 as matched_genre_count,
        coalesce(km.matched_keyword_count, 0)                               as matched_keyword_count,
        coalesce(gm.matched_genres, array_construct())                      as matched_genres,
        coalesce(km.matched_keywords, array_construct())                    as matched_keywords,

        /* Weighted score: genres matter most, keywords next, imdb_score as tiebreak */
        (coalesce(gm.matched_genre_count, 0) * 5) +
        (coalesce(km.matched_keyword_count, 0) * 3) +
        (coalesce(m.imdb_score, 0) * 0.1)                                   as total_score
    from windows w
    cross join movies m
    left join genre_matches gm
        on w.start_date = gm.start_date
       and w.until_date = gm.until_date
       and m.object_id = gm.object_id
    left join keyword_matches km
        on w.start_date = km.start_date
       and w.until_date = km.until_date
       and m.object_id = km.object_id

),

ranked as (

    select
        *,
        row_number() over (
            partition by start_date, until_date
            order by
                total_score desc,
                matched_genre_count desc,
                matched_keyword_count desc,
                imdb_score desc nulls last,
                release_year desc nulls last,
                object_id
        ) as window_rank
    from scored
    where matched_genre_count > 0
       or matched_keyword_count > 0

)

select
    start_date,
    until_date,
    period_description,

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
    short_description,

    window_rank
from ranked
where window_rank <= 10

