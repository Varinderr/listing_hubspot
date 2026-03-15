{{ config(schema="staging_rental_property") }}

with
    source as (
        select *
        from {{ source("rental_property_management", "listings") }}
        where id is not null
    ),

    renamed as (
        select
            id as listing_id,
            host_id,
            host_name,
            date(host_since) as host_since_date,
            host_location,
            host_verifications,
            name as listing_name,
            neighborhood,
            property_type,
            room_type,
            accommodates,
            bathrooms_text,
            cast(bedrooms as integer) as bedrooms,
            beds,
            amenities,
            {{ clean_price("price") }} as listing_price,
            number_of_reviews,
            date(first_review) as first_review_date,
            date(last_review) as last_review_date,
            cast(review_scores_rating as numeric) as review_scores_rating
        from source
    )

select *
from renamed
