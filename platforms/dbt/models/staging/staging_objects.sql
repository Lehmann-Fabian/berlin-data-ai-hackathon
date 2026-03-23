-- JustWatch content metadata | ~2.3M rows
-- Back-compat wrapper model name.

select *
from {{ ref('base_objects') }}

