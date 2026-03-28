-- Snowplow event stream | same schema as T1–T4
-- Typed/extracted staging model.

with source as (

    select *
    from {{ source('jw_shared', 'T1_5') }}

),

final as (

    select
        -- core identifiers + timestamps
        rid::number                                             as rid,
        event_id::varchar                                       as event_id,
        collector_tstamp::timestamp_ntz                         as collector_tstamp,
        derived_tstamp::timestamp_ntz                           as derived_tstamp,

        -- event / user / session
        event::varchar                                          as event,
        user_id::varchar                                        as user_id,
        login_id::varchar                                       as login_id,
        session_id::varchar                                     as session_id,
        session_idx::number                                     as session_idx,

        -- app
        app_id::varchar                                         as app_id,
        platform::varchar                                       as platform,

        -- structured event fields (NULL for page_view)
        se_category::varchar                                    as se_category,
        se_action::varchar                                      as se_action,
        se_label::varchar                                       as se_label,
        se_property::varchar                                    as se_property,
        se_value::number                                        as se_value,

        -- geo + ua
        geo_country::varchar                                    as geo_country,
        geo_region_name::varchar                                as geo_region_name,
        geo_city::varchar                                       as geo_city,
        useragent::varchar                                      as useragent,

        -- raw contexts
        cc_title                                                as cc_title,
        cc_page_type                                            as cc_page_type,
        cc_clickout                                             as cc_clickout,
        cc_yauaa                                                as cc_yauaa,
        cc_search                                               as cc_search,

        -- title context fields (when present)
        cc_title:jwEntityId::text                               as title_jw_entity_id,
        cc_title:jwRawEntityId::text                            as title_jw_raw_entity_id,
        cc_title:objectType::text                               as title_object_type,
        cc_title:titleId::number                                as title_id,
        cc_title:seasonNumber::int                              as season_number,
        cc_title:episodeNumber::int                             as episode_number,
        cc_title:index::int                                     as title_index,

        -- page type context fields (present on all events)
        cc_page_type:pageType::text                             as page_type,
        cc_page_type:appLocale::text                            as app_locale,
        cc_page_type:appLanguage::text                          as app_language,
        cc_page_type:pageViewUuid::text                         as page_view_uuid,
        cc_page_type:pageEntryMode::text                        as page_entry_mode,

        -- clickout context fields (present on se_category='clickout' events)
        cc_clickout:providerId::number                          as clickout_provider_id,
        cc_clickout:provider::text                              as clickout_provider,
        cc_clickout:monetizationType::text                      as clickout_monetization_type,
        cc_clickout:presentationType::text                      as clickout_presentation_type,
        cc_clickout:clickoutType::text                          as clickout_type,
        cc_clickout:placement::text                             as clickout_placement,
        cc_clickout:currency::text                              as clickout_currency,
        cc_clickout:country::text                               as clickout_country,
        cc_clickout:filterOption::text                          as clickout_filter_option,
        cc_clickout:rowNumber::int                              as clickout_row_number,
        cc_clickout:noOffer::boolean                            as clickout_no_offer,

        -- parsed user agent (YAUAA)
        cc_yauaa:deviceClass::text                              as device_class,
        cc_yauaa:agentName::text                                as agent_name,
        iff(cc_yauaa:deviceClass::text in ('Robot', 'Spy', 'Hacker'), true, false) as is_bot,

        -- search context (when present)
        cc_search:sessionUuid::text                             as search_session_uuid,
        cc_search:prevSessionUuid::text                         as search_prev_session_uuid,
        cc_search:searchEntry::text                             as search_entry,
        cc_search:searchEntries                                 as search_entries
    from source

)

select *
from final

