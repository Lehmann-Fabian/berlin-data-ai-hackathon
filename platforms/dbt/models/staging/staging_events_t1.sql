-- Back-compat wrapper: keep old model name, delegate to typed base model.

select *
from {{ ref('base_events_t1') }}
