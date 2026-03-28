-- Intermediate fact table at event grain for recommendation signals.
--
-- "Watched" proxy: clickout events only (se_category='clickout').
-- Bot handling: staging retains bots; intermediate filters them out.
--
-- Defaults to a unioned staging model for expanded coverage (T1 + T1_5 by default). Override with:
--   dbt build --select int_fct_clickouts --vars '{"events_model": "base_events_t4"}'

{% set events_model = var('events_model', 'base_events_union') %}

{% set label_map = {
    'base_events_t1': 'T1',
    'base_events_t1_5': 'T1_5',
    'base_events_t2': 'T2',
    'base_events_t3': 'T3',
    'base_events_t4': 'T4'
} %}

with events as (

    {% if events_model == 'base_events_union' %}
        select *
        from {{ ref(events_model) }}
    {% else %}
        select
            '{{ label_map.get(events_model, events_model) }}' as event_source,
            e.*
        from {{ ref(events_model) }} e
    {% endif %}

),

clickouts as (

    select
        event_source,
        event_source || '_' || rid::varchar            as clickout_event_id,

        rid,
        collector_tstamp,
        derived_tstamp,
        to_date(collector_tstamp)                    as event_date,

        -- event metadata
        event,
        se_category,
        se_action,
        se_label,
        se_property,
        se_value,

        user_id,
        login_id,
        session_id,
        session_idx,

        app_id,
        platform,

        app_locale,
        geo_country,

        -- title join key
        title_jw_entity_id,
        title_object_type,
        title_id,
        season_number,
        episode_number,

        -- clickout details
        clickout_provider_id,
        clickout_monetization_type,
        clickout_presentation_type,
        clickout_type,
        clickout_placement,
        clickout_country,
        clickout_currency,
        clickout_filter_option,
        clickout_row_number,
        clickout_no_offer,

        -- page context (useful for UX funnels)
        page_type,
        page_view_uuid,
        page_entry_mode
    from events
    where se_category = 'clickout'
      and not is_bot
      and title_jw_entity_id is not null
      and clickout_provider_id is not null

)

select *
from clickouts
