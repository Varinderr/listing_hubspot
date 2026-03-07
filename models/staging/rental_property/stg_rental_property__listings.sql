{{
    config(
        schema = 'staging_rental_property'
    )
}}

with source as (
    select * from {{ source("rental_property_management", "listings") }}
),

renamed as (
    select
        id as listing_id,
        host_id,
        name as listing_name,
        host_name,
        date(host_since) AS host_since_date,
        host_location,
        host_verifications,
        neighborhood,
        property_type,
        room_type,
        accommodates,
        bathrooms_text,
        bedrooms,
        beds,
        amenities,
        cast(replace(price, '$', '') as numeric) as listing_price,
        number_of_reviews,
        DATE(first_review) AS first_review_date,
        DATE(last_review) AS last_review_date,
        review_scores_rating
    from source
)

select *
from renamed
