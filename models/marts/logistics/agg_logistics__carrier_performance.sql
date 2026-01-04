{{
    config(
        materialized='table',
        tags=['logistics', 'operations']
    )
}}

with fct_order_items as (
    select * from {{ ref('fct_order_items') }}
    where order_status = 'delivered'
),

dim_sellers as (
    select seller_key, seller_state from {{ ref('dim_sellers') }}
),

dim_customers as (
    select customer_key, customer_state from {{ ref('dim_customers') }}
)

select
    ds.seller_state,
    dc.customer_state,
    count(distinct foi.order_id) as total_orders,
    avg(foi.days_to_carrier) as avg_carrier_pickup_days,
    avg(foi.carrier_to_customer_days) as avg_transit_days,
    avg(foi.delivery_lead_time_days) as avg_total_delivery_days,
    safe_divide(
        countif(foi.is_on_time = true),
        count(*)
    ) as on_time_rate,
    avg(safe_divide(foi.freight_value, foi.total_item_value)) as avg_freight_ratio
from fct_order_items foi
inner join dim_sellers ds on foi.seller_key = ds.seller_key
inner join dim_customers dc on foi.customer_key = dc.customer_key
where foi.delivery_lead_time_days is not null
group by 1, 2
order by total_orders desc
