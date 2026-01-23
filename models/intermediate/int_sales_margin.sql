{{ config(enabled=true)}}

with orders as (

    select * 
    from {{ ref('int_orders_operational')}}


)

select 
orders_id,
revenue,
ship_cost,
revenue - ship_cost as margin
from orders