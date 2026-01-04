{% macro calculate_date_diff(start_date, end_date, unit='day') %}
    date_diff({{ end_date }}, {{ start_date }}, {{ unit }})
{% endmacro %}
