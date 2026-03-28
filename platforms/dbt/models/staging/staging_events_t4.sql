-- 15 global markets | Nov–Dec 2025 | ~254M rows | 36.1 GB
-- Back-compat wrapper model name.

select *
from {{ ref('base_events_t4') }}

