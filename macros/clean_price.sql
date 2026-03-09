{% macro clean_price(column_name) %}
    cast(replace(replace({{ column_name }}, '$', ''), ',', '') as numeric(18, 2))
{% endmacro %}