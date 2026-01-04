{{
    config(
        materialized='table',
        tags=['customer_service', 'experience']
    )
}}

with fct_order_items as (
    select * from {{ ref('fct_order_items') }}
),

dim_sellers as (
    select * from {{ ref('dim_sellers') }}
)

select
    ds.seller_key,
    ds.seller_id,
    ds.seller_state,
    ds.seller_city,
    count(distinct foi.order_id) as total_orders,
    avg(foi.review_score) as avg_review_score,
    countif(foi.review_score <= 2) as low_score_count,
    safe_divide(
        countif(foi.review_score <= 2),
        countif(foi.review_score is not null)
    ) as low_score_rate,
    count(distinct case when foi.order_status = 'canceled' then foi.order_id end) as cancelled_orders,
    safe_divide(
        count(distinct case when foi.order_status = 'canceled' then foi.order_id end),
        count(distinct foi.order_id)
    ) as cancellation_rate,
    countif(foi.is_on_time = false) as late_delivery_count,
    safe_divide(
        countif(foi.is_on_time = false),
        countif(foi.is_on_time is not null)
    ) as late_delivery_rate
from fct_order_items foi
inner join dim_sellers ds on foi.seller_key = ds.seller_key
group by 1, 2, 3, 4
order by low_score_rate desc
