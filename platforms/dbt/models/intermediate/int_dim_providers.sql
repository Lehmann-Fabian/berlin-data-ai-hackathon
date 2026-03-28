-- Curated provider dimension.
-- Source: PACKAGES table.

with packages as (

    select *
    from {{ ref('base_packages') }}

),

final as (

    select
        id,
        technical_name,
        clear_name,
        full_name,
        monetization_types,
        monetization_types_array
    from packages

)

select *
from final

