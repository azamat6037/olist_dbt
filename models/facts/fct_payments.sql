{{
    config(
        materialized='table'
    )
}}

with payments as (
    select * from {{ ref('stg_olist__order_payments_dataset') }}
),

orders as (
    select 
        order_id,
        order_purchase_timestamp
    from {{ ref('stg_olist__orders_dataset') }}
),

dim_dates as (
    select date_key, date_day from {{ ref('dim_dates') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['p.order_id', 'p.payment_sequential']) }} as payment_key,
    p.order_id,
    p.payment_sequential,
    p.payment_type,
    p.payment_installments,
    p.payment_value,
    o.order_purchase_timestamp,
    dd.date_key as order_date_key
from payments p
inner join orders o on p.order_id = o.order_id
left join dim_dates dd on cast(o.order_purchase_timestamp as date) = dd.date_day
