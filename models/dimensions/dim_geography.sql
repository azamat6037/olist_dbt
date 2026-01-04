{{
    config(
        materialized='table'
    )
}}

with geolocation as (
    select * from {{ ref('stg_olist__geolocation_dataset') }}
),

-- Deduplicate by taking average lat/lng per zip code prefix
geo_deduped as (
    select
        geolocation_zip_code_prefix,
        geolocation_city,
        geolocation_state,
        avg(geolocation_lat) as latitude,
        avg(geolocation_lng) as longitude
    from geolocation
    group by 1, 2, 3
)

select
    {{ dbt_utils.generate_surrogate_key(['geolocation_zip_code_prefix', 'geolocation_city', 'geolocation_state']) }} as geo_key,
    geolocation_zip_code_prefix as zip_code_prefix,
    geolocation_city as city,
    geolocation_state as state,
    latitude,
    longitude
from geo_deduped
