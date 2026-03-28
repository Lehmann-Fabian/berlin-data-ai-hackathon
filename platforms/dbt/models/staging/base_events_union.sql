-- Unioned Snowplow events source for scalable multi-table builds.
--
-- Default union members are chosen to expand coverage without jumping straight to the
-- largest datasets. Override with:
--   dbt build --select base_events_union --vars '{"events_union_members":["base_events_t4"]}'

{% set members = var('events_union_members', ['base_events_t1', 'base_events_t1_5']) %}

{% set label_map = {
    'base_events_t1': 'T1',
    'base_events_t1_5': 'T1_5',
    'base_events_t2': 'T2',
    'base_events_t3': 'T3',
    'base_events_t4': 'T4'
} %}

{% for model_name in members %}
select
    '{{ label_map.get(model_name, model_name) }}' as event_source,
    e.*
from {{ ref(model_name) }} e
{% if not loop.last %}
union all
{% endif %}
{% endfor %}

