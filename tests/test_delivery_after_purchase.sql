-- Test: Delivery date should always be on or after purchase date
-- A product cannot be delivered before it was ordered

select
    order_item_key,
    order_purchase_timestamp,
    order_delivered_customer_date,
    delivery_lead_time_days
from {{ ref('fct_order_items') }}
where order_delivered_customer_date < order_purchase_timestamp
