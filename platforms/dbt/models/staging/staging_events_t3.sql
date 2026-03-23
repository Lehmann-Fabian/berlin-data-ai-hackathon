-- 8 EU markets | Nov 2025 – Jan 2026 (3 months) | ~128M rows | 17.9 GB
-- Back-compat wrapper model name.

select *
from {{ ref('base_events_t3') }}

