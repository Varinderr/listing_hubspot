{{
    config(
        schema = 'int_rental_property'
    )
}}

with
    updated_data as (
        select *,
            case when reservation_id = 'NULL' then false else true end is_reserved,
            case
            when reservation_id is not null
            then calendar_price
            else 0
            end as daily_revenue
        from
            {{ ref("stg_rental_property__calendar") }}
    )

select * from updated_data
