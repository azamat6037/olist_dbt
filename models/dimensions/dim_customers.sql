{{
    config(
        materialized='table'
    )
}}

with customers as (
    select * from {{ ref('stg_olist__customers_dataset') }}
),

orders as (
    select * from {{ ref('stg_olist__orders_dataset') }}
),

order_items as (
    select * from {{ ref('stg_olist__order_items_dataset') }}
),

-- Get aggregate order stats per customer_unique_id
customer_order_stats as (
    select
        c.customer_unique_id,
        min(o.order_purchase_timestamp) as first_order_date,
        max(o.order_purchase_timestamp) as last_order_date,
        count(distinct o.order_id) as total_orders,
        sum(oi.price + oi.freight_value) as total_spent
    from customers c
    left join orders o on c.customer_id = o.customer_id
    left join order_items oi on o.order_id = oi.order_id
    group by 1
),

-- Get the most recent customer record for geography (one row per customer_unique_id)
customer_latest_geo as (
    select
        c.customer_unique_id,
        c.customer_state,
        c.customer_city,
        c.customer_zip_code_prefix,
        row_number() over (
            partition by c.customer_unique_id 
            order by o.order_purchase_timestamp desc nulls last
        ) as rn
    from customers c
    left join orders o on c.customer_id = o.customer_id
),

customer_geo_deduped as (
    select * from customer_latest_geo where rn = 1
)

select
    {{ dbt_utils.generate_surrogate_key(['cos.customer_unique_id']) }} as customer_key,
    cos.customer_unique_id,
    cg.customer_state,
    cg.customer_city,
    cg.customer_zip_code_prefix,
    cos.first_order_date,
    cos.last_order_date,
    cos.total_orders,
    coalesce(cos.total_spent, 0) as total_spent,
    date_diff(cos.last_order_date, cos.first_order_date, day) as customer_tenure_days
from customer_order_stats cos
left join customer_geo_deduped cg on cos.customer_unique_id = cg.customer_unique_id

