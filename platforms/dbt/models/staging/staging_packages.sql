-- Streaming provider lookup | 1,526 rows
-- Back-compat wrapper model name.

select *
from {{ ref('base_packages') }}

