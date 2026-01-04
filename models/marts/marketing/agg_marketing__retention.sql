{{
    config(
        materialized='table',
        tags=['marketing', 'growth']
    )
}}

with dim_customers as (
    select * from {{ ref('dim_customers') }}
),

cohorts as (
    select
        date_trunc(first_order_date, month) as cohort_month,
        customer_unique_id,
        total_orders
    from dim_customers
    where first_order_date is not null
)

select
    cohort_month,
    count(distinct customer_unique_id) as total_customers,
    count(distinct case when total_orders >= 2 then customer_unique_id end) as repeat_customers,
    safe_divide(
        count(distinct case when total_orders >= 2 then customer_unique_id end),
        count(distinct customer_unique_id)
    ) as retention_rate
from cohorts
group by cohort_month
order by cohort_month
