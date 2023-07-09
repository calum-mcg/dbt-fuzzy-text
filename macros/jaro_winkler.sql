{% macro jaro_winkler(str1, str2) %}
    -- Check inputs are not None or empty
    -- Max can be empty
    {% if str1 is none or str2 is none or str1 == "" or str2 == ""%}
        {{ exceptions.raise_compiler_error("Both input strings must contain text.") }}
    {% endif %}
    -- Use Dispatch to handle nuances in syntax across DWs
    {{ return(adapter.dispatch('jaro_winkler', 'fuzzy_text')(str1, str2)) }}
{% endmacro %}

-- For non-supported adapters
{% macro default__jaro_winkler() %}
    {{ exceptions.raise_compiler_error("Jaccard index is not yet implemented for this adapter. Currently it is only available for Snowflake and BigQuery. Please raise an issue on the Github repo to request expanding coverage.") }}
{% endmacro %}

{% macro snowflake__jaro_winkler(str1, str2) %}
    -- Built-in support for Snowflake
    JAROWINKLER_SIMILARITY({{str1}}, {{str2}})
{% endmacro %}

-- {% macro bigquery__jaro_winkler(str1, str2) %}
-- -- TODO
-- {% endmacro %}