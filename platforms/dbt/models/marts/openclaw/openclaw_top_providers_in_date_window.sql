with d as (

    select *
    from {{ ref('openclaw_demo_defaults') }}

),

window as (

    select
        d.default_app_locale as app_locale,
        dateadd('day', -14, d.default_anchor_date) as start_date,
        dateadd('day', 14, d.default_anchor_date)  as end_date
    from d

)

select
    p.clear_name as provider_name,
    c.clickout_monetization_type as monetization_type,
    count(*) as clickouts
from {{ ref('fct_clickouts') }} c
join window w
  on c.app_locale = w.app_locale
 and c.event_date between w.start_date and w.end_date
join {{ ref('dim_providers') }} p
  on c.clickout_provider_id = p.id
group by 1, 2
order by clickouts desc, provider_name, monetization_type
limit 50

