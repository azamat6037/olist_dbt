{% macro get_column_info() %}
  {% set query %}
    SELECT table_name, column_name, data_type
    FROM `peak-seat-479300-h4.olist.INFORMATION_SCHEMA.COLUMNS`
    ORDER BY table_name, ordinal_position
  {% endset %}

  {% set results = run_query(query) %}

  {% if execute %}
    {% for row in results %}
      {{ log(row['table_name'] ~ '|' ~ row['column_name'] ~ '|' ~ row['data_type'], info=True) }}
    {% endfor %}
  {% endif %}
{% endmacro %}
