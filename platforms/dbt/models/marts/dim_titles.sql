-- BI-facing title dimension (thin wrapper over intermediate).

select *
from {{ ref('int_dim_titles') }}

