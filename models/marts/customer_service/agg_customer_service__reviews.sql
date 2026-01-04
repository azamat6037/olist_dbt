{{
    config(
        materialized='table',
        tags=['customer_service', 'experience']
    )
}}

with fct_order_items as (
    select * from {{ ref('fct_order_items') }}
    where review_score is not null
),

total_reviews as (
    select count(*) as total_count
    from fct_order_items
)

select
    foi.review_score,
    count(*) as review_count,
    safe_divide(count(*), tr.total_count) as pct_of_total,
    avg(foi.review_response_days) as avg_response_latency_days,
    avg(foi.total_item_value) as avg_order_value
from fct_order_items foi
cross join total_reviews tr
group by 1, tr.total_count
order by 1
