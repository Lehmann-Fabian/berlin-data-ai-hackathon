with d as (

    select *
    from {{ ref('openclaw_demo_defaults') }}

)

select
    t.object_id,
    t.title as movie_title,
    t.original_title,
    t.translated_title,
    t.release_year,
    t.imdb_score,
    t.short_description,
    t.object_text_short_description,
    t.poster_jw,
    t.url_imdb,
    t.url_tmdb
from {{ ref('dim_titles') }} t
cross join d
where t.object_type = 'movie'
  and t.object_id = d.demo_source_object_id
limit 1

