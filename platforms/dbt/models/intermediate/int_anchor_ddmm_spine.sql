-- Yearless anchor spine for seasonal popularity marts.
--
-- Output grain: one row per day-of-year (365 rows).
-- Leap day (29.02) is excluded by choosing a non-leap reference year.
--
-- Fields:
-- - anchor_ddmm: 'DD.MM' (e.g. '25.12')
-- - anchor_day / anchor_month: integers for filtering without string parsing
-- - anchor_day_date: date in a fixed non-leap year (2001) for charting/sorting

with spine as (

    select
        dateadd('day', seq4(), to_date('2001-01-01')) as anchor_day_date
    from table(generator(rowcount => 365))

),

final as (

    select
        to_varchar(anchor_day_date, 'DD.MM') as anchor_ddmm,
        extract(day from anchor_day_date)    as anchor_day,
        extract(month from anchor_day_date)  as anchor_month,
        anchor_day_date
    from spine

)

select *
from final

