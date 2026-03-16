{{ config(materialized="table", schema="edw_rental_property") }}

with
    snapshot as (select * from {{ ref("ds_listing") }}),

    cleaned as (
        select
            {{ dbt_utils.generate_surrogate_key(["listing_id", "dbt_valid_from"]) }}
            as listing_version_id,
            listing_id,
            dbt_valid_from::date as valid_from,
            dbt_valid_to::date as valid_to,
            (dbt_valid_to is null) as is_current,
            listing_name,
            neighborhood,
            property_type,
            room_type,
            accommodates,
            bathrooms_text,
            bedrooms,
            beds,
            listing_price,
            host_id,
            host_name,
            host_since_date,
            host_location,
            host_verifications,
            number_of_reviews,
            first_review_date,
            last_review_date,
            review_scores_rating,
            dbt_updated_at as snapshot_updated_at
        from snapshot
    )

select *
from cleaned
