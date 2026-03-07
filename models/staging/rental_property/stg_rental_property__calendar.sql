{{
    config(
        schema = 'staging_rental_property'
    )
}}

with source as (
    select * from {{ source("rental_property_management", "calendar") }}
),

renamed as (
    select
        listing_id,
        reservation_id,
        date,
        available as is_available,
        price,
        minimum_nights,
        maximum_nights
    from source
)

select *
from renamed
