-- OpenClaw demo defaults.
--
-- This model exists to make all demo queries parameter-free and lightning fast at runtime.
-- It computes a single “default context” row derived from existing marts/facts.
--
-- Output grain: exactly 1 row.

with default_locale as (

    select
        c.app_locale as default_app_locale
    from {{ ref('fct_clickouts') }} c
    where c.app_locale is not null
    group by 1
    order by count(*) desc
    limit 1

),

default_anchor_ddmm as (

    select
        m.anchor_ddmm as default_anchor_ddmm
    from {{ ref('mart_movie_popularity_seasonal_ddmm_top20') }} m
    join default_locale l
      on m.app_locale = l.default_app_locale
    where m.genre_bucket = '__all__'
    group by 1
    order by sum(m.weighted_clickouts_29d_sum) desc, m.anchor_ddmm
    limit 1

),

default_anchor_date as (

    select
        r.anchor_date as default_anchor_date
    from {{ ref('mart_movie_popularity_rolling_29d_top20') }} r
    join default_locale l
      on r.app_locale = l.default_app_locale
    where r.genre_bucket = '__all__'
    group by 1
    order by sum(r.weighted_clickouts_29d) desc, r.anchor_date
    limit 1

),

default_event_date as (

    select
        max(c.event_date) as default_event_date
    from {{ ref('fct_clickouts') }} c
    join default_locale l
      on c.app_locale = l.default_app_locale

),

demo_genre_bucket as (

    select
        m.genre_bucket as demo_genre_bucket
    from {{ ref('mart_movie_popularity_seasonal_ddmm_top20') }} m
    join default_locale l
      on m.app_locale = l.default_app_locale
    join default_anchor_ddmm a
      on m.anchor_ddmm = a.default_anchor_ddmm
    where m.genre_bucket <> '__all__'
    group by 1
    order by sum(m.weighted_clickouts_29d_sum) desc, m.genre_bucket
    limit 1

),

demo_source_movie as (

    select
        m.object_id as demo_source_object_id
    from {{ ref('mart_movie_popularity_seasonal_ddmm_top20') }} m
    join default_locale l
      on m.app_locale = l.default_app_locale
    join default_anchor_ddmm a
      on m.anchor_ddmm = a.default_anchor_ddmm
    where m.genre_bucket = '__all__'
    qualify row_number() over (order by m.window_rank asc, m.object_id) = 1

),

demo_user as (

    select
        c.user_id as demo_user_id
    from {{ ref('fct_clickouts') }} c
    join default_locale l
      on c.app_locale = l.default_app_locale
    cross join default_event_date d
    where c.user_id is not null
      and c.event_date between dateadd('day', -60, d.default_event_date) and d.default_event_date
    group by 1
    order by count(*) desc, c.user_id
    limit 1

),

final as (

    select
        l.default_app_locale,
        a.default_anchor_ddmm,
        ad.default_anchor_date,
        e.default_event_date,

        'christmas'::text as demo_keyword,
        'romantic'::text  as demo_mood,

        g.demo_genre_bucket,
        s.demo_source_object_id,
        u.demo_user_id
    from default_locale l
    cross join default_anchor_ddmm a
    cross join default_anchor_date ad
    cross join default_event_date e
    cross join demo_genre_bucket g
    cross join demo_source_movie s
    cross join demo_user u

)

select *
from final

