-- Test: All CLV values should be non-negative
-- A customer cannot have negative lifetime value

select
    customer_key,
    customer_lifetime_value
from {{ ref('agg_marketing__clv') }}
where customer_lifetime_value < 0
