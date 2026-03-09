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

    listings as (
        select 
            listing_id,
            listing_name,
            neighborhood,
            property_type,
            room_type
        from {{ ref("stg_rental_property__listings") }}
    ),

    amenities as (
        select * from {{ ref("int_amenities_history") }}
    ),

    joined as (
        select
            -- Composite Primary Key for the Fact Table
            {{ dbt_utils.generate_surrogate_key(['c.listing_id', 'c.calendar_date']) }} as fact_id,
            c.calendar_date,
            c.listing_id,
            l.listing_name,
            l.neighborhood,
            
            -- Measures
            c.calendar_price as price_on_day,
            c.is_reserved,
            c.daily_revenue,
            
            -- Amenities State (The range join)
            a.amenities_snapshot as amenities_at_timestamp,
            
            -- Operational flags
            case when c.is_available = false and c.is_reserved = false then true else false end as is_blocked_by_host
        from calendar c
        left join listings l 
            on c.listing_id = l.listing_id
        left join amenities a
            on c.listing_id = a.listing_id
            and c.calendar_date >= a.valid_from
            and c.calendar_date < a.valid_to
    )

select * from joined