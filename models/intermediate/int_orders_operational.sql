{{ config(enabled=true) }}

with sales as (
    select
        date_date,
        orders_id,
        products_id,
        revenue,
        quantity
    from {{ ref('stg_raw__sales') }}
),

ship as (
    select
        orders_id,
        shipping_fee,
        log_cost,
        ship_cost
    from {{ ref('stg_raw_ship') }}
),

product as (
    select
        products_id,
        purchase_price
    from {{ ref('stg_raw__product') }}
),

joined as (
    select
        s.date_date,
        s.orders_id,
        s.products_id,
        s.revenue,
        s.quantity,

        -- kargo/lojistik
        sh.shipping_fee,
        sh.log_cost,
        sh.ship_cost,

        -- ürün maliyeti (birim alış fiyatı * adet)
        (p.purchase_price * s.quantity) as purchase_cost,

        -- marj (burada senin önceki mantığınla aynı: revenue - ship_cost)
        (s.revenue - sh.ship_cost) as margin,

        -- operasyonel marj (revenue - purchase_cost - shipping_fee - log_cost - ship_cost)
        (s.revenue
 - (coalesce(p.purchase_price, 0) * s.quantity)
 - coalesce(sh.shipping_fee, 0)
 - coalesce(sh.log_cost, 0)
 - coalesce(sh.ship_cost, 0)
) as operational_margin

    from sales s
    left join ship sh
        on s.orders_id = sh.orders_id
    left join product p
        on s.products_id = p.products_id
)

select *
from joined
