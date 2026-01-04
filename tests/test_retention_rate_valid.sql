-- Test: Retention rate should be between 0 and 1 (0% to 100%)

select
    cohort_month,
    retention_rate
from {{ ref('agg_marketing__retention') }}
where retention_rate < 0 or retention_rate > 1
