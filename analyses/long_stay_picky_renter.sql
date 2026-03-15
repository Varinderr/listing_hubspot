with
    qualified_days as (
        select
            listing_id,
            calendar_date,
            maximum_nights,
            dateadd(
                'day',
                -row_number() over (partition by listing_id order by calendar_date),
                calendar_date
            ) as island_anchor
        from {{ ref("fct_listing_daily_details") }}
        where
            is_available = true
            and {{ has_amenity('Lockbox') }}
            and {{ has_amenity('First aid kit') }}
    ),

    windows as (
        select
            listing_id,
            island_anchor,
            min(calendar_date)      as window_start,
            max(calendar_date)      as window_end,
            count(*)                as consecutive_days,
            min(maximum_nights)     as max_nights_cap
        from qualified_days
        group by 1, 2
    ),

    capped as (
        select
            listing_id,
            window_start,
            window_end,
            consecutive_days,
            max_nights_cap,
            least(consecutive_days, max_nights_cap) as longest_possible_stay
        from windows
    )

select
    listing_id,
    max(longest_possible_stay) as longest_possible_stay_days
from capped
group by 1
order by longest_possible_stay_days desc
