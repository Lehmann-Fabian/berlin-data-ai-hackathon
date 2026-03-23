-- BI-facing provider dimension (thin wrapper over intermediate).

select *
from {{ ref('int_dim_providers') }}

