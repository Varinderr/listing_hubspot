-- Custom data test: each listing_id in dim_listings must have exactly one
-- current version (is_current = true). More than one means the snapshot
-- produced duplicate open-ended rows — this would cause fan-out when
-- joining dim_listings to the fact table on is_current = true.

select
    listing_id,
    count(*) as current_version_count
from {{ ref('dim_listings') }}
where is_current = true
group by 1
having count(*) > 1
