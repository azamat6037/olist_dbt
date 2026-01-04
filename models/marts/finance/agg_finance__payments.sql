{{
    config(
        materialized='table',
        tags=['finance', 'growth', 'operations']
    )
}}

with fct_payments as (
    select * from {{ ref('fct_payments') }}
),

total_gmv as (
    select sum(payment_value) as total_value
    from fct_payments
)

select
    fp.payment_type,
    count(distinct fp.order_id) as order_count,
    sum(fp.payment_value) as total_value,
    safe_divide(sum(fp.payment_value), tg.total_value) as pct_of_gmv,
    avg(fp.payment_installments) as avg_installments,
    safe_divide(sum(fp.payment_value), count(distinct fp.order_id)) as avg_order_value
from fct_payments fp
cross join total_gmv tg
group by 1, tg.total_value
order by total_value desc
