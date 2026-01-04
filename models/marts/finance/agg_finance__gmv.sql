{{
    config(
        materialized='table',
        tags=['finance', 'growth', 'operations']
    )
}}

with fct_payments as (
    select * from {{ ref('fct_payments') }}
),

fct_order_items as (
    select 
        order_id,
        sum(freight_value) as total_freight
    from {{ ref('fct_order_items') }}
    group by 1
)

select
    date_trunc(fp.order_purchase_timestamp, month) as order_month,
    count(distinct fp.order_id) as order_count,
    sum(fp.payment_value) as gmv,
    safe_divide(sum(fp.payment_value), count(distinct fp.order_id)) as avg_order_value,
    sum(foi.total_freight) as total_freight,
    sum(fp.payment_value) - coalesce(sum(foi.total_freight), 0) as net_product_revenue
from fct_payments fp
left join fct_order_items foi on fp.order_id = foi.order_id
group by 1
order by 1
