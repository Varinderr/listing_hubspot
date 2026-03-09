{{
    config(
        schema = 'int_rental_property'
    )
}}

with
    exploded as (
        select listing_id, change_date as valid_from, value as amenity
        from
            {{ ref("stg_rental_property__amenities_changelog") }},
            lateral flatten(input => parse_json(amenities))
    ),

    windows as (
        select
            listing_id,
            amenity,
            valid_from,
            lead(valid_from) over (
                partition by listing_id order by valid_from
            ) as valid_to
        from exploded
    )

select *
from windows
