with

source1 as (
    select * from {{ ref('stg_olist__customers_dataset') }}
),

source2 as (
    select * from {{ ref('stg_olist__geolocation_dataset') }}
)

select * from source1