{{
    config(
        schema = 'int_rental_property'
    )
}}

with
    source as (
        select * from {{ ref("stg_rental_property__calendar") }}
    ),

    enriched as (
        select
            listing_id,
            calendar_date,
            reservation_id,
            is_available,
            calendar_price,
            minimum_nights,
            maximum_nights,

            -- A date is reserved when a reservation_id is present
            (reservation_id is not null) as is_reserved,

            -- Revenue only accrues on reserved days
            case
                when reservation_id is not null
                then calendar_price
                else 0
            end as daily_revenue
        from source
    )

select * from enriched

