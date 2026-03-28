-- Popular movies mart for the available dataset period (not a full calendar year).
--
-- Grain: (app_locale, provider, movie)
-- Sliceable by genre via join to: int_bridge_title_genres on object_id.

with clickouts as (

    select *
    from {{ ref('fct_clickouts') }}

),

movies as (

    select
        object_id,
        title,
        release_year,
        imdb_score
    from {{ ref('dim_titles') }}
    where object_type = 'movie'

),

providers as (

    select
        id,
        technical_name,
        clear_name
    from {{ ref('dim_providers') }}

),

coverage as (

    select
        min(collector_tstamp) as dataset_min_tstamp,
        max(collector_tstamp) as dataset_max_tstamp
    from clickouts

),

agg as (

    select
        c.app_locale,
        c.clickout_provider_id,
        c.title_jw_entity_id                           as object_id,

        count(*)                                       as clickouts,
        count(distinct c.user_id)                      as unique_users,
        count(distinct c.session_id)                   as unique_sessions,

        min(c.collector_tstamp)                        as first_clickout_tstamp,
        max(c.collector_tstamp)                        as last_clickout_tstamp
    from clickouts c
    join movies m
      on c.title_jw_entity_id = m.object_id
    group by 1, 2, 3

),

final as (

    select
        a.app_locale,
        a.clickout_provider_id,
        p.technical_name                               as provider_technical_name,
        p.clear_name                                   as provider_name,

        a.object_id,
        m.title                                        as movie_title,
        m.release_year,
        m.imdb_score,

        a.clickouts,
        a.unique_users,
        a.unique_sessions,

        a.first_clickout_tstamp,
        a.last_clickout_tstamp,

        cov.dataset_min_tstamp,
        cov.dataset_max_tstamp,
        datediff('day', cov.dataset_min_tstamp, cov.dataset_max_tstamp) + 1 as dataset_days
    from agg a
    join movies m
      on a.object_id = m.object_id
    left join providers p
      on a.clickout_provider_id = p.id
    cross join coverage cov

)

select *
from final

