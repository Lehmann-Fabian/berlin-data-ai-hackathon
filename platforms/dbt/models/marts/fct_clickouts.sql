-- BI-facing clickout fact (thin wrapper over intermediate).
-- Human traffic only (bots filtered in intermediate).

select *
from {{ ref('int_fct_clickouts') }}

