{{
    config(
        materialized='table'
    )
}}

with products as (
    select * from {{ ref('stg_olist__products_dataset') }}
),

translations as (
    select
        string_field_0 as category_name_pt,
        string_field_1 as category_name_en
    from {{ ref('stg_olist__product_category_name_translation') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['p.product_id']) }} as product_key,
    p.product_id,
    p.product_category_name as category_name_pt,
    coalesce(t.category_name_en, p.product_category_name) as category_name_en,
    p.product_name_length,
    p.product_description_length,
    case
        when p.product_description_length < 100 then 'Short'
        when p.product_description_length < 500 then 'Medium'
        when p.product_description_length < 1000 then 'Long'
        else 'Very Long'
    end as description_length_bucket,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
from products p
left join translations t on p.product_category_name = t.category_name_pt
