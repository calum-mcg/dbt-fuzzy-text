{% macro drop_udfs() %}
    {{ return(adapter.dispatch('drop_udfs', 'fuzzy_text')()) }}
{% endmacro %}

-- For non-supported adapters
{% macro default__drop_udfs() %}
    {{ print("Dropping UDFs not required. Skipping...") }}
{% endmacro %}

{% macro synapse__drop_udfs() %}
    {{ print("Dropping levenshtein function (if already exists)...") }}
    DROP FUNCTION IF EXISTS {{target.schema}}.levenshtein;
{% endmacro %}