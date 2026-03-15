with
    daily as (
        select
            date_trunc('month', calendar_date)              as revenue_month,
            case
                when {{ has_amenity('Air conditioning') }}  then 'Has AC'
                else 'No AC'
            end                                             as ac_status,
            daily_revenue
        from {{ ref("fct_listing_daily_details") }}
        where is_reserved = true
    ),

    monthly as (
        select
            revenue_month,
            ac_status,
            sum(daily_revenue) as total_revenue
        from daily
        group by 1, 2
    )

select
    revenue_month,
    ac_status,
    total_revenue,
    round(
        total_revenue / nullif(sum(total_revenue) over (partition by revenue_month), 0) * 100,
        1
    ) as revenue_pct
from monthly
order by revenue_month, ac_status
