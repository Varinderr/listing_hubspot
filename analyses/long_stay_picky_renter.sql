with
    qualified_days as (
        select
            listing_id,
            calendar_date,
            maximum_nights,
            -- GAPS & ISLANDS TRICK:
            -- Subtract row_number from date within each listing's partition.
            -- Consecutive dates (Jul 1,2,3) minus (1,2,3) = same anchor (Jun 30).
            -- A gap (Jul 1,2, then Jul 5) shifts the anchor — Jul 5 minus 4 = Jul 1.
            -- Same anchor = same consecutive run. Different anchor = new run.
            dateadd(
                'day',
                -row_number() over (partition by listing_id order by calendar_date),
                calendar_date
            ) as island_anchor

        from {{ ref("fct_listing_daily_details") }}
        where
            is_available = true
            and {{ has_amenity("Lockbox") }}
            and {{ has_amenity("First aid kit") }}
    ),

    windows as (
        -- Group by island_anchor to collapse each consecutive run into one row.
        -- COUNT(*) = how many consecutive available days in this run.
        -- MIN(maximum_nights) = tightest cap if it varies mid-window (conservative choice).
        select
            listing_id,
            island_anchor,
            min(calendar_date) as window_start,
            max(calendar_date) as window_end,
            count(*)           as consecutive_days,
            min(maximum_nights) as max_nights_cap
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
            -- KEY LOGIC: even if window is 200 days, owner may cap at 159 nights.
            -- LEAST picks whichever is the binding constraint.
            least(consecutive_days, max_nights_cap) as longest_possible_stay
        from windows
    )

select
    listing_id,
    max(longest_possible_stay) as longest_possible_stay_days
from capped
group by 1
order by longest_possible_stay_days desc
