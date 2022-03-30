{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set is_large = node.config.materialized == 'large_table' -%}

    {%- set default_schema = target.schema -%}


    {#- /* Always error if schema is unspecified */ -#}
    {%- if custom_schema_name is none -%}
        {%- do exceptions.raise_compiler_error("Schema name is unspecified for node in path: " ~ node.path) -%}
    {%- endif -%}


    {#- /* Apply production logic */ -#}
    {%- if target.name == 'prod' -%}

        {{ custom_schema_name | trim }}


    {#- /* Apply devlopment logic */ -#}
    {%- else -%}
        {%- if is_large -%}

            {%- if var('include_large_tables', False) -%}
                {{ default_schema }}_{{ custom_schema_name | trim }}
            {%- else -%}
                {{ custom_schema_name | trim }}
            {%- endif -%}

        {%- else -%}

            {{ default_schema }}_{{ custom_schema_name | trim }}

        {%- endif -%}
    {%- endif -%}

{%- endmacro %}
