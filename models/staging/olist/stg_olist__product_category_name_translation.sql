with

source as (

    select * from {{ source('olist', 'product_category_name_translation') }}

),

renamed as (

    select *

    from source

)

select * from renamed
