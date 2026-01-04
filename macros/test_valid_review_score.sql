{% test valid_review_score(model, column_name) %}
    select *
    from {{ model }}
    where {{ column_name }} is not null
      and {{ column_name }} not between 1 and 5
{% endtest %}
