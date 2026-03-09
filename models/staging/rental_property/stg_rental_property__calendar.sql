{{ config(schema="staging_rental_property") }}

with
    source as (select * from {{ source("rental_property_management", "calendar") }}),

    renamed as (
        select
            listing_id,
            date(date) as calendar_date,
            reservation_id,
            case when available = 't' then true else false end AS is_available,
            {{clean_price('price')}} as calendar_price,
            minimum_nights,
            maximum_nights
        from source
    )

select *
from renamed
