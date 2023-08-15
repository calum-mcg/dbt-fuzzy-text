{% macro create_udfs() %}
    {{ return(adapter.dispatch('create_udfs', 'fuzzy_text')()) }}
{% endmacro %}

-- For non-supported adapters
{% macro default__create_udfs() %}
    {{ print("Creating UDFs not required. Skipping...") }}
{% endmacro %}

{% macro synapse__create_udfs() %}
    {{ print("Creating Levenshtein function...") }}
    {{synapse_create_levenshtein()}}
{% endmacro %}