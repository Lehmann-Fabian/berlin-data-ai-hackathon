-- Bridge table: title -> genre (one row per title/genre).
-- Enables genre filtering without exploding the clickout fact table.

with titles as (

    select
        object_id,
        genre_tmdb
    from {{ ref('int_dim_titles') }}
    where genre_tmdb is not null

),

final as (

    select
        t.object_id                                  as object_id,
        g.value::text                                as genre
    from titles t,
         lateral flatten(input => t.genre_tmdb) g
    where g.value is not null

)

select *
from final

