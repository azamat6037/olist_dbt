with

source as (

    select * from {{ source('olist', 'olist_order_reviews_dataset') }}

),

renamed as (

    select *

    from source

)

select * from renamed
