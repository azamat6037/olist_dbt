-- Test: GMV from payments fact should match sum of actual payment values
-- This validates that the finance mart correctly aggregates payment data

with payment_total as (
    select sum(payment_value) as total_payments
    from {{ ref('fct_payments') }}
),

gmv_total as (
    select sum(gmv) as total_gmv
    from {{ ref('agg_finance__gmv') }}
)

select 
    pt.total_payments,
    gt.total_gmv,
    abs(pt.total_payments - gt.total_gmv) as difference
from payment_total pt
cross join gmv_total gt
where abs(pt.total_payments - gt.total_gmv) > 0.01 -- Allow for tiny floating point differences
