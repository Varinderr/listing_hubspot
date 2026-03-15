{{ config(schema="staging_rental_property") }}

with
    source as (select * from {{ source("rental_property_management", "calendar") }}),

    renamed as (
        select
            listing_id,
            date(date) as calendar_date,
            reservation_id,
            case when available = 't' then true else false end as is_available,
            {{ clean_price("price") }} as calendar_price,
            minimum_nights,
            maximum_nights
        from source
    ),

    -- Source has duplicate (listing_id, date) rows for listing 1303261 on 2022-07-07.
    -- All 3 rows are identical so we deduplicate here before anything downstream sees
    -- them.
    deduped as (
        select *
        from renamed
        qualify
            row_number() over (
                partition by listing_id, calendar_date order by calendar_date
            )
            = 1
    )

select *
from deduped
