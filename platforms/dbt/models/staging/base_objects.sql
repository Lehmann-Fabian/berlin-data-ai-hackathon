-- JustWatch content metadata | ~2.3M rows
-- Join to events: title_jw_entity_id = object_id
-- Typed staging model.

with source as (

    select *
    from {{ source('jw_shared', 'OBJECTS') }}

),

final as (

    select
        object_id::varchar                                      as object_id,
        lower(object_type::varchar)                             as object_type,
        regexp_substr(object_id::varchar, '^[a-z]+')            as object_id_prefix,

        title_id::varchar                                       as title_id,
        parent_id::varchar                                      as parent_id,
        show_season_id::varchar                                 as show_season_id,

        title::varchar                                          as title,
        original_title::varchar                                 as original_title,
        translated_title::varchar                               as translated_title,
        short_description::varchar                              as short_description,
        object_text_short_description::varchar                   as object_text_short_description,
        object_text_translated_title::varchar                    as object_text_translated_title,

        release_year::number                                    as release_year,
        release_date::date                                      as release_date,
        runtime::number                                         as runtime,
        original_language::varchar                               as original_language,

        genre_tmdb                                              as genre_tmdb,
        production_countries                                    as production_countries,
        production_budget::number                               as production_budget,

        seasons::number                                         as seasons,
        season_number::number                                   as season_number,
        episodes::number                                        as episodes,
        episode_number::number                                  as episode_number,
        episodes_per_season::number                             as episodes_per_season,

        imdb_score::number                                      as imdb_score,
        scoring                                                 as scoring,
        scoring:score_imdb_votes::number                        as score_imdb_votes,

        id_imdb::varchar                                        as id_imdb,
        id_tmdb::varchar                                        as id_tmdb,
        url_imdb::varchar                                       as url_imdb,
        url_tmdb::varchar                                       as url_tmdb,

        talent_cast                                             as talent_cast,
        talent_director                                         as talent_director,
        talent_writer                                           as talent_writer,

        studios                                                 as studios,
        studios:name::text                                      as studio_name,

        poster_jw::varchar                                      as poster_jw,
        trailers                                                as trailers
    from source

)

select *
from final
