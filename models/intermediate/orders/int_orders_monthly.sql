with source as (
    select * from {{ ref('stg_olist__orders_dataset') }}
)

select
    date_trunc(order_purchase_timestamp, day) as order_purchase_day,
    order_status,
    count(*) as order_count
from source
group by all