-- Custom data test: each (listing_id, calendar_date) should join to at most
-- one amenity version. If two changelog entries share a valid_from date for
-- the same listing, the range join in fct_listing_daily_details will fan out,
-- producing duplicate rows and inflating revenue aggregates.
--
-- Returns rows (fails) if any listing/date pair appears more than once.

select
    listing_id,
    calendar_date,
    count(*) as row_count
from {{ ref("fct_listing_daily_details") }}
group by 1, 2
having count(*) > 1
