{{
    config(
        materialized='table',
        tags=['product', 'experience']
    )
}}

with fct_order_items as (
    select * from {{ ref('fct_order_items') }}
),

dim_products as (
    select * from {{ ref('dim_products') }}
)

select
    dp.description_length_bucket,
    count(distinct dp.product_id) as product_count,
    count(*) as total_items_sold,
    sum(foi.price) as total_revenue,
    avg(foi.price) as avg_item_price,
    avg(foi.review_score) as avg_review_score,
    safe_divide(count(*), count(distinct dp.product_id)) as items_sold_per_product
from fct_order_items foi
inner join dim_products dp on foi.product_key = dp.product_key
group by 1
order by 
    case dp.description_length_bucket
        when 'Short' then 1
        when 'Medium' then 2
        when 'Long' then 3
        when 'Very Long' then 4
        else 5
    end
