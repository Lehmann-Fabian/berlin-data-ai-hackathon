-- Streaming provider lookup | 1,526 rows
-- Join to events: clickout_provider_id = id
-- Typed staging model.

with source as (

    select *
    from {{ source('jw_shared', 'PACKAGES') }}

),

final as (

    select
        id::number                                              as id,
        technical_name::varchar                                 as technical_name,
        clear_name::varchar                                     as clear_name,
        full_name::varchar                                      as full_name,
        monetization_types::varchar                              as monetization_types,
        split(monetization_types::varchar, ',')                  as monetization_types_array
    from source

)

select *
from final
