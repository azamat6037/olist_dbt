{{
    config(
        materialized='table',
        tags=['marketing', 'growth']
    )
}}

with dim_customers as (
    select * from {{ ref('dim_customers') }}
),

dim_geography as (
    select * from {{ ref('dim_geography') }}
)

select
    c.customer_state,
    c.customer_city,
    g.latitude as avg_latitude,
    g.longitude as avg_longitude,
    count(distinct c.customer_unique_id) as customer_count,
    sum(c.total_orders) as total_orders,
    sum(c.total_spent) as total_revenue,
    avg(c.total_spent) as avg_clv
from dim_customers c
left join dim_geography g 
    on c.customer_zip_code_prefix = g.zip_code_prefix
    and c.customer_city = g.city
    and c.customer_state = g.state
group by 1, 2, 3, 4
order by total_revenue desc
