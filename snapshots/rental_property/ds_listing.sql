{% snapshot ds_listing %}

{{
    config(
        target_schema = 'snapshots',
        unique_key = 'listing_id',
        strategy = 'check',
        check_cols = [
            'listing_name',
            'neighborhood',
            'property_type',
            'room_type',
            'accommodates',
            'bathrooms_text',
            'bedrooms',
            'beds',
            'listing_price',
            'host_location',
            'host_verifications'
        ]
    )
}}

--  We snapshot the staging model (not the raw source) so that all column
--  renames, type casts, and the clean_price() macro are already applied.
--  dbt will add: dbt_scd_id, dbt_updated_at, dbt_valid_from, dbt_valid_to.
--  dbt_valid_to IS NULL  → this is the current / live version of the row.
--  dbt_valid_to NOT NULL → this version has been superseded.

select
    listing_id,
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
    review_scores_rating
from {{ ref('stg_rental_property__listings') }}

{% endsnapshot %}
