-- Genre bucket requirements mapping.
--
-- Output grain: genre_bucket × required_genre
-- Includes:
-- - curated multi-genre buckets (explicit list)
-- - single-genre buckets (one required genre)
--
-- `__all__` is handled as a special bucket in downstream marts and is not included here.

with curated as (

    select *
    from (
        values
            ('RomCom', 'Romance'),
            ('RomCom', 'Comedy'),
            ('ActionAdventure', 'Action'),
            ('ActionAdventure', 'Adventure'),
            ('SciFiFantasy', 'Science Fiction'),
            ('SciFiFantasy', 'Fantasy'),
            ('HorrorThriller', 'Horror'),
            ('HorrorThriller', 'Thriller'),
            ('CrimeThriller', 'Crime'),
            ('CrimeThriller', 'Thriller'),
            ('MysteryThriller', 'Mystery'),
            ('MysteryThriller', 'Thriller'),
            ('FamilyAnimation', 'Family'),
            ('FamilyAnimation', 'Animation'),
            ('DramaRomance', 'Drama'),
            ('DramaRomance', 'Romance'),
            ('ComedyFamily', 'Comedy'),
            ('ComedyFamily', 'Family'),
            ('ActionThriller', 'Action'),
            ('ActionThriller', 'Thriller')
    ) as t(genre_bucket, required_genre)

),

single_genres as (

    select
        g.genre as genre_bucket,
        g.genre as required_genre
    from (
        select distinct genre
        from {{ ref('int_bridge_title_genres') }}
        where genre is not null
    ) g

),

final as (

    select genre_bucket, required_genre from curated
    union all
    select genre_bucket, required_genre from single_genres

)

select *
from final

