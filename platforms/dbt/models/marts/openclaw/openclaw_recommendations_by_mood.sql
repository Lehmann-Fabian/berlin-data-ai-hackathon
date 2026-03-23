with d as (

    select *
    from {{ ref('openclaw_demo_defaults') }}

),

mood_bucket as (

    select
        d.demo_mood as mood,
        case lower(d.demo_mood)
            when 'romantic' then 'RomCom'
            when 'funny' then 'Comedy'
            when 'scary' then 'HorrorThriller'
            when 'action' then 'ActionAdventure'
            when 'family' then 'FamilyAnimation'
            when 'cozy' then 'ComedyFamily'
            when 'thrilling' then 'CrimeThriller'
            when 'mystery' then 'MysteryThriller'
            else '__all__'
        end as genre_bucket
    from d

)

select
    m.movie_title as title,
    m.release_year as year,
    b.mood,
    m.weighted_clickouts_29d_sum as score,
    m.poster_jw,
    m.url_imdb,
    m.url_tmdb
from {{ ref('mart_movie_popularity_seasonal_ddmm_top20') }} m
cross join d
cross join mood_bucket b
where m.app_locale = d.default_app_locale
  and m.anchor_ddmm = d.default_anchor_ddmm
  and m.genre_bucket = b.genre_bucket
qualify row_number() over (order by m.window_rank asc, m.object_id) <= 20

