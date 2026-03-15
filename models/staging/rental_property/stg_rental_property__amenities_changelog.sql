{{
    config(
        schema = 'staging_rental_property'
    )
}}

with source as (
    select * from {{ source('rental_property_management', 'amenities_changelog') }}
),

renamed as (
    select
        listing_id,
        date(change_at) AS change_date,
        amenities
    from source
)

select * from renamed
