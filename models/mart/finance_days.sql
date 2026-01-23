select
    date_date,
    count(distinct orders_id) as nb_transactions,

    sum(revenue) as revenue,
    sum(purchase_cost) as purchase_cost,
    sum(log_cost) as log_cost,
    sum(ship_cost) as ship_cost,

    -- toplam marj
    sum(revenue)
      - sum(purchase_cost)
      - sum(log_cost)
      - sum(ship_cost) as margin,

    -- ortalama sepet
    sum(revenue) / count(distinct orders_id) as average_basket,

     round(
      (
        sum(revenue)
        - sum(purchase_cost)
        - sum(log_cost)
        - sum(ship_cost)
      ) / nullif(sum(revenue), 0),
      2
    ) as margin_rate


from {{ ref('int_orders_operational') }}
group by date_date
order by date_date desc
