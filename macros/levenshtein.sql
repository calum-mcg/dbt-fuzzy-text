{% macro levenshtein_distance(str1, str2, max=none) %}
    -- Check inputs are not None or empty
    -- Max can be empty
    {% if str1 is none or str2 is none or str1 == "" or str2 == ""%}
        {{ exceptions.raise_compiler_error("Both input strings must contain text.") }}
    {% endif %}

     -- If max is set, check int and not 0
    {% if max is not none %}
        {% if max|int == 0 %}  
            {{ exceptions.raise_compiler_error("Max distance must be more than 0.") }}
        {% endif %}   
    {% endif %}   

    -- Use Dispatch to handle nuances in syntax across DWs
    {{ return(adapter.dispatch('levenshtein_distance', 'fuzzy_text')(str1, str2)) }}
{% endmacro %}

-- For non-supported adapters
{% macro default__levenshtein_distance() %}
    {{ exceptions.raise_compiler_error("levenshtein is not yet implemented for this adapter. Currently it is only available for Snowflake and BigQuery. Please raise an issue on the Github repo to request expanding coverage.") }}
{% endmacro %}

{% macro snowflake__levenshtein_distance(str1, str2, max=none) %}
    -- Built-in support for Snowflake
    {% if max is not none %}
        EDITDISTANCE({{str1}}, {{str2}}, {{max}})
    {% else %} 
        EDITDISTANCE({{str1}}, {{str2}})
    {% endif %} 
{% endmacro %}

{% macro bigquery__levenshtein_distance(str1, str2, max=none) %}
    -- Built-in for US-regions within BigQuery
    fhoffa.x.levenshtein({{str1}}, {{str2}})
{% endmacro %}