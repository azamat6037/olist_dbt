{{
    config(
        materialized='table'
    )
}}

with orders as (
    select * from {{ ref('stg_olist__orders_dataset') }}
),

order_items as (
    select * from {{ ref('stg_olist__order_items_dataset') }}
),

reviews as (
    -- Aggregate to one review per order to prevent duplicates
    select
        order_id,
        avg(review_score) as review_score,
        min(review_creation_date) as review_creation_date,
        min(review_answer_timestamp) as review_answer_timestamp
    from {{ ref('stg_olist__order_reviews_dataset') }}
    group by 1
),

customers as (
    select * from {{ ref('stg_olist__customers_dataset') }}
),

dim_customers as (
    select customer_key, customer_unique_id from {{ ref('dim_customers') }}
),

dim_products as (
    select product_key, product_id from {{ ref('dim_products') }}
),

dim_sellers as (
    select seller_key, seller_id from {{ ref('dim_sellers') }}
),

dim_dates as (
    select date_key, date_day from {{ ref('dim_dates') }}
),

dim_geography as (
    select geo_key, zip_code_prefix, city, state from {{ ref('dim_geography') }}
),

-- Join order items with orders and reviews
order_items_enriched as (
    select
        oi.order_id,
        oi.order_item_id,
        oi.product_id,
        oi.seller_id,
        oi.price,
        oi.freight_value,
        oi.shipping_limit_date,
        o.customer_id,
        o.order_status,
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        r.review_score,
        r.review_creation_date,
        r.review_answer_timestamp
    from order_items oi
    inner join orders o on oi.order_id = o.order_id
    left join reviews r on oi.order_id = r.order_id
),

-- Add customer unique_id for dimension lookup
with_customer_unique as (
    select
        oie.*,
        c.customer_unique_id,
        c.customer_zip_code_prefix,
        c.customer_city,
        c.customer_state
    from order_items_enriched oie
    inner join customers c on oie.customer_id = c.customer_id
),

-- Get seller geography from staging
sellers_stg as (
    select * from {{ ref('stg_olist__sellers_dataset') }}
),

with_seller_geo as (
    select
        wcu.*,
        s.seller_zip_code_prefix,
        s.seller_city,
        s.seller_state
    from with_customer_unique wcu
    inner join sellers_stg s on wcu.seller_id = s.seller_id
)

select
    -- Surrogate key for fact table
    {{ dbt_utils.generate_surrogate_key(['wsg.order_id', 'wsg.order_item_id']) }} as order_item_key,
    
    -- Natural keys
    wsg.order_id,
    wsg.order_item_id,
    
    -- Dimension keys
    dc.customer_key,
    dp.product_key,
    ds.seller_key,
    dd_order.date_key as order_date_key,
    dd_delivery.date_key as delivery_date_key,
    cg.geo_key as customer_geo_key,
    sg.geo_key as seller_geo_key,
    
    -- Degenerate dimensions
    wsg.order_status,
    
    -- Measures
    wsg.price,
    wsg.freight_value,
    wsg.price + wsg.freight_value as total_item_value,
    wsg.review_score,
    
    -- Delivery metrics
    date_diff(wsg.order_delivered_customer_date, wsg.order_purchase_timestamp, day) as delivery_lead_time_days,
    date_diff(wsg.order_delivered_carrier_date, wsg.order_purchase_timestamp, day) as days_to_carrier,
    date_diff(wsg.order_delivered_customer_date, wsg.order_delivered_carrier_date, day) as carrier_to_customer_days,
    date_diff(wsg.order_estimated_delivery_date, wsg.order_delivered_customer_date, day) as days_early,
    case 
        when wsg.order_delivered_customer_date <= wsg.order_estimated_delivery_date then true 
        else false 
    end as is_on_time,
    
    -- Review metrics
    date_diff(wsg.review_creation_date, wsg.order_delivered_customer_date, day) as review_response_days,
    
    -- Timestamps
    wsg.order_purchase_timestamp,
    wsg.order_delivered_customer_date,
    wsg.order_estimated_delivery_date,
    wsg.review_creation_date

from with_seller_geo wsg

-- Join dimension keys
left join dim_customers dc on wsg.customer_unique_id = dc.customer_unique_id
left join dim_products dp on wsg.product_id = dp.product_id
left join dim_sellers ds on wsg.seller_id = ds.seller_id
left join dim_dates dd_order on cast(wsg.order_purchase_timestamp as date) = dd_order.date_day
left join dim_dates dd_delivery on cast(wsg.order_delivered_customer_date as date) = dd_delivery.date_day
left join dim_geography cg on wsg.customer_zip_code_prefix = cg.zip_code_prefix 
    and wsg.customer_city = cg.city 
    and wsg.customer_state = cg.state
left join dim_geography sg on wsg.seller_zip_code_prefix = sg.zip_code_prefix 
    and wsg.seller_city = sg.city 
    and wsg.seller_state = sg.state
