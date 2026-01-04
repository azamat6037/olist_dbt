{% macro bucket_description_length(length_col) %}
    case
        when {{ length_col }} is null then 'Unknown'
        when {{ length_col }} < 100 then 'Short'
        when {{ length_col }} < 500 then 'Medium'
        when {{ length_col }} < 1000 then 'Long'
        else 'Very Long'
    end
{% endmacro %}
