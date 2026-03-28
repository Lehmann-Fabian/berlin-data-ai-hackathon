-- Curated title dimension for recommendation and analysis.
-- Source: JustWatch OBJECTS table, filtered to movies/shows.

with objects as (

    select *
    from {{ ref('base_objects') }}

),

final as (

    select
        object_id,
        object_type,
        object_id_prefix,

        title,
        original_title,
        translated_title,
        short_description,
        object_text_short_description,
        object_text_translated_title,
        url_imdb,
        url_tmdb,
        release_year,
        release_date,
        runtime,
        original_language,

        imdb_score,
        score_imdb_votes,

        genre_tmdb,
        production_countries,

        poster_jw,
        trailers
    from objects
    where object_type in ('movie', 'show')

)

select *
from final
