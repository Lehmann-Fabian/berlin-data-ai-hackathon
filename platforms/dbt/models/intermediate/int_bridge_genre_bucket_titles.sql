-- Bridge table: genre_bucket -> titles
--
-- Output grain: genre_bucket × object_id
-- A title belongs to a genre_bucket when it matches ALL required genres for that bucket.

with requirements as (

    select
        genre_bucket,
        required_genre
    from {{ ref('int_genre_bucket_requirements') }}

),

required_counts as (

    select
        genre_bucket,
        count(*) as required_genre_count
    from requirements
    group by 1

),

matches as (

    select
        r.genre_bucket,
        g.object_id,
        count(distinct r.required_genre) as matched_genre_count
    from requirements r
    join {{ ref('int_bridge_title_genres') }} g
      on g.genre = r.required_genre
    group by 1, 2

),

final as (

    select
        m.genre_bucket,
        m.object_id
    from matches m
    join required_counts c
      on m.genre_bucket = c.genre_bucket
    where m.matched_genre_count = c.required_genre_count

)

select *
from final

