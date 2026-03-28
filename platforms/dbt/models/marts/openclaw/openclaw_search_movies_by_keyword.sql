with d as (

    select *
    from {{ ref('openclaw_demo_defaults') }}

)

select
    t.object_id,
    t.title as movie_title,
    t.release_year,
    t.imdb_score,
    t.runtime,
    t.poster_jw,
    t.url_imdb,
    t.url_tmdb
from {{ ref('dim_titles') }} t
cross join d
where t.object_type = 'movie'
  and (
      t.title ilike '%' || d.demo_keyword || '%'
      or t.original_title ilike '%' || d.demo_keyword || '%'
      or t.translated_title ilike '%' || d.demo_keyword || '%'
      or t.short_description ilike '%' || d.demo_keyword || '%'
      or t.object_text_short_description ilike '%' || d.demo_keyword || '%'
  )
order by t.imdb_score desc nulls last, t.release_year desc nulls last, t.object_id
limit 50

