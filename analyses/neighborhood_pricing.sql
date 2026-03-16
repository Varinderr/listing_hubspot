with
    price_start as (
        select listing_id, neighborhood, price_on_day as price_jul_2021
        from {{ ref("fct_listing_daily_details") }}
        where calendar_date = '2021-07-12'
    ),

    price_end as (
        select listing_id, price_on_day as price_jul_2022
        from {{ ref("fct_listing_daily_details") }}
        where calendar_date = '2022-07-11'
    ),

    listing_delta as (
        select
            s.listing_id,
            s.neighborhood,
            s.price_jul_2021,
            e.price_jul_2022,
            e.price_jul_2022 - s.price_jul_2021 as price_change
        from price_start s
        inner join price_end e on s.listing_id = e.listing_id
    -- inner join: only include listings that have a price on BOTH dates
    )

select
    neighborhood,
    count(listing_id) as listing_count,
    round(avg(price_change), 2) as avg_price_increase
from listing_delta
group by 1
order by avg_price_increase desc
