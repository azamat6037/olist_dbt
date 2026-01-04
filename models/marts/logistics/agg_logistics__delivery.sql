{{
    config(
        materialized='table',
        tags=['logistics', 'operations']
    )
}}

with fct_order_items as (
    select * from {{ ref('fct_order_items') }}
    where order_status = 'delivered'
)

select
    date_trunc(order_purchase_timestamp, month) as order_month,
    count(distinct order_id) as total_orders_delivered,
    avg(delivery_lead_time_days) as avg_delivery_lead_time_days,
    avg(days_to_carrier) as avg_days_to_carrier,
    avg(carrier_to_customer_days) as avg_carrier_to_customer_days,
    avg(days_early) as avg_days_early_or_late,
    safe_divide(
        countif(is_on_time = true),
        count(*)
    ) as on_time_delivery_rate,
    avg(safe_divide(freight_value, total_item_value)) as avg_freight_ratio
from fct_order_items
where delivery_lead_time_days is not null
group by 1
order by 1
