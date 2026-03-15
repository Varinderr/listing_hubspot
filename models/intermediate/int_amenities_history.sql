{{
    config(
        schema = 'int_rental_property',
        materialized = 'ephemeral'    
    )
}}

with
    raw_changes as (
        select 
            listing_id,
            parse_json(amenities) as amenities_snapshot,
            change_date as valid_from
        from {{ ref("stg_rental_property__amenities_changelog") }}
    ),

    versioned as (
        select
            listing_id,
            amenities_snapshot,
            valid_from,
            lead(valid_from) over (
                partition by listing_id 
                order by valid_from
            ) as valid_to_raw
        from raw_changes
    )

select
    {{ dbt_utils.generate_surrogate_key(['listing_id', 'valid_from']) }} as amenity_version_id,
    listing_id,
    amenities_snapshot,
    valid_from,
    coalesce(valid_to_raw, '9999-12-31'::date) as valid_to
from versioned
