-- 8 EU markets | Dec 2025 | ~40M rows | 5.7 GB
-- Back-compat wrapper model name.

select *
from {{ ref('base_events_t2') }}

