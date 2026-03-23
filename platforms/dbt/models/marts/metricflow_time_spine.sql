-- Time spine model required by dbt's semantic layer (MetricFlow).
--
-- Produces a contiguous daily date spine based on the min/max event timestamps
-- in a chosen staging events model.
--
-- Override the source for min/max bounds if needed:
--   dbt build --select metricflow_time_spine --vars '{"time_spine_events_model":"base_events_t4"}'

{{ config(materialized='table') }}

{% set events_model = var('time_spine_events_model', 'base_events_union') %}

with bounds as (

    select
        min(to_date(collector_tstamp)) as start_date,
        max(to_date(collector_tstamp)) as end_date
    from {{ ref(events_model) }}

),

spine as (

    select
        dateadd(day, seq4(), b.start_date)::date as date_day,
        b.end_date                               as end_date
    from bounds b,
         table(generator(rowcount => 4000))

)

select date_day
from spine
where date_day is not null
  and date_day <= end_date
