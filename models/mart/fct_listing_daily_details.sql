{{
    config(
        materialized = 'table',
        schema = 'edw_rental_property'
    )
}}

with
    calendar as (
        select * from {{ ref("int_calendar_enriched") }}
    ),

    dim as (
        select * from {{ ref("dim_listings") }}
    ),

    amenities as (
        select * from {{ ref("int_amenities_history") }}
    ),

    joined as (
        select
            {{ dbt_utils.generate_surrogate_key(['c.listing_id', 'c.calendar_date']) }} as fact_id,
            c.calendar_date,
            c.listing_id,
            d.listing_version_id,
            d.listing_name,
            d.neighborhood,
            d.property_type,
            d.room_type,
            d.accommodates,
            d.bedrooms,
            d.beds,
            d.listing_price          as listed_price,    -- snapshot price at that version
            d.review_scores_rating,
            c.calendar_price         as price_on_day,
            c.minimum_nights,
            c.maximum_nights,
            c.is_available,
            c.is_reserved,
            c.reservation_id,
            c.daily_revenue,
            (c.is_available = false and c.is_reserved = false) as is_blocked_by_host,
            a.amenity_version_id,
            a.amenities_snapshot     as amenities_at_timestamp
        from calendar c
        left join dim d
            on  c.listing_id    = d.listing_id
        left join amenities a
            on  c.listing_id    = a.listing_id
            and c.calendar_date >= a.valid_from
            and c.calendar_date <  a.valid_to
    )

select * from joined
