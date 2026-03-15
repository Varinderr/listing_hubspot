-- Custom data test: daily_revenue must be 0 on any day that is not reserved.
--
-- If this test returns rows, it means the mart is incorrectly attributing
-- revenue to dates with no reservation — a critical data correctness issue
-- that would cause overstated revenue in every downstream report.
--
-- dbt runs this as a "test" model: it passes when zero rows are returned.

select
    listing_id,
    calendar_date,
    is_reserved,
    daily_revenue
from {{ ref("fct_listing_daily_details") }}
where
    is_reserved = false
    and daily_revenue != 0
