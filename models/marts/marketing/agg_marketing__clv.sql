{{
    config(
        materialized='table',
        tags=['marketing', 'growth']
    )
}}

with dim_customers as (
    select * from {{ ref('dim_customers') }}
)

select
    customer_key,
    customer_unique_id,
    customer_state,
    customer_city,
    first_order_date,
    last_order_date,
    total_orders,
    total_spent as customer_lifetime_value,
    case 
        when total_orders > 0 then total_spent / total_orders 
        else 0 
    end as avg_order_value,
    customer_tenure_days,
    case
        when total_orders >= 5 then 'VIP'
        when total_orders >= 2 then 'Repeat'
        else 'One-time'
    end as customer_segment
from dim_customers
