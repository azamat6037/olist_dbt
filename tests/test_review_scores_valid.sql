-- Test: Review scores in fact table should be between 1 and 5
-- Invalid scores indicate data quality issues

select
    order_item_key,
    review_score
from {{ ref('fct_order_items') }}
where review_score is not null
  and (review_score < 1 or review_score > 5)
