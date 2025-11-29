with

source as (

    select * from {{ source('olist', 'olist_orders_dataset') }}

),

renamed as (

    select *

    from source

)

select * from renamed
