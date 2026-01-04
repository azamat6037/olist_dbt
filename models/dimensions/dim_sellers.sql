{{
    config(
        materialized='table'
    )
}}

with sellers as (
    select * from {{ ref('stg_olist__sellers_dataset') }}
),

order_items as (
    select * from {{ ref('stg_olist__order_items_dataset') }}
),

seller_stats as (
    select
        seller_id,
        count(distinct order_id) as total_orders,
        count(*) as total_items_sold,
        sum(price) as total_revenue,
        sum(freight_value) as total_freight
    from order_items
    group by 1
)

select
    {{ dbt_utils.generate_surrogate_key(['s.seller_id']) }} as seller_key,
    s.seller_id,
    s.seller_zip_code_prefix,
    s.seller_city,
    s.seller_state,
    coalesce(ss.total_orders, 0) as total_orders,
    coalesce(ss.total_items_sold, 0) as total_items_sold,
    coalesce(ss.total_revenue, 0) as total_revenue,
    coalesce(ss.total_freight, 0) as total_freight
from sellers s
left join seller_stats ss on s.seller_id = ss.seller_id
