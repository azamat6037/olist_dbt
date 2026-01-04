-- Test: Prices in fact table should be positive
-- Zero or negative prices indicate data quality issues

select
    order_item_key,
    price,
    freight_value
from {{ ref('fct_order_items') }}
where price <= 0 or freight_value < 0
