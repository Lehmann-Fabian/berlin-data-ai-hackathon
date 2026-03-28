-- adapted from https://github.com/fishtown-analytics/dbt/blob/9d0eab630511723cd0bc328f6f11d3ffe6c8f879/core/dbt/include/global_project/macros/etc/get_custom_schema.sql
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}
    {%- if target.name in ('prd', 'dev') and custom_schema_name is not none -%}
        {{ custom_schema_name | trim }}
    {%- elif custom_schema_name is not none -%}
        {{ default_schema }}_{{ custom_schema_name | trim }}
    {%- else -%}
        {{ default_schema }}
    {%- endif -%}
{%- endmacro %}