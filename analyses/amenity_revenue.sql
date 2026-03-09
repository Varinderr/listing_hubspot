with
    monthly_revenue as (
        select
            date_trunc('month', calendar_date) as revenue_month,
            case
                when
                    array_to_string(amenities_at_timestamp, ',')
                    ilike '%Air conditioning%'
                then 'Has AC'
                else 'No AC'
            end as ac_status,
            sum(daily_revenue) as total_revenue
        from {{ ref("fct_listing_daily_details") }}
        group by all
    )

select
    revenue_month,
    ac_status,
    total_revenue / sum(total_revenue) over (partition by revenue_month) * 100 as revenue_percentage
from monthly_revenue
order by 1, 2