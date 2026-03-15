{% macro has_amenity(amenity_name, column='amenities_at_timestamp') %}
    array_contains({{ "'" ~ amenity_name ~ "'" }}::variant, {{ column }})
{% endmacro %}
