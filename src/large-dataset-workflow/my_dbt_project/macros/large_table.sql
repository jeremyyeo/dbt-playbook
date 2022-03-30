{% materialization large_table, adapter='postgres' -%}
{#- /* Adapted from https://github.com/dbt-labs/dbt-bigquery/blob/main/dbt/include/bigquery/macros/materializations/table.sql */ -#}

  {%- set identifier = model['alias'] -%}
  {%- set tmp_identifier = model['name'] + '__dbt_tmp' -%}
  {%- set backup_identifier = model['name'] + '__dbt_backup' -%}
  {%- set old_relation = adapter.get_relation(database=database, schema=schema, identifier=identifier) -%}
  {%- set target_relation = api.Relation.create(identifier=identifier,
                                                schema=schema,
                                                database=database,
                                                type='table') -%}
  {%- set intermediate_relation = api.Relation.create(identifier=tmp_identifier,
                                                      schema=schema,
                                                      database=database,
                                                      type='table') -%}
  {%- set preexisting_intermediate_relation = adapter.get_relation(identifier=tmp_identifier,
                                                                   schema=schema,
                                                                   database=database) -%}
  {%- set backup_relation_type = 'table' if old_relation is none else old_relation.type -%}
  {%- set backup_relation = api.Relation.create(identifier=backup_identifier,
                                                schema=schema,
                                                database=database,
                                                type=backup_relation_type) -%}
  {%- set preexisting_backup_relation = adapter.get_relation(identifier=backup_identifier,
                                                             schema=schema,
                                                             database=database) -%}
  {%- if var('include_large_tables', False) -%}

    {{ drop_relation_if_exists(preexisting_intermediate_relation) }}
    {{ drop_relation_if_exists(preexisting_backup_relation) }}

    {{ run_hooks(pre_hooks, inside_transaction=False) }}

    {{ run_hooks(pre_hooks, inside_transaction=True) }}

    {% call statement('main') -%}
      {{ get_create_table_as_sql(False, intermediate_relation, sql) }}
    {%- endcall %}

    {% if old_relation is not none %}
        {{ adapter.rename_relation(old_relation, backup_relation) }}
    {% endif %}

    {{ adapter.rename_relation(intermediate_relation, target_relation) }}

    {% do create_indexes(target_relation) %}

    {{ run_hooks(post_hooks, inside_transaction=True) }}

    {% do persist_docs(target_relation, model) %}

    {{ adapter.commit() }}

    {{ drop_relation_if_exists(backup_relation) }}

    {{ run_hooks(post_hooks, inside_transaction=False) }}
  {%- else -%}

    {%- do log('[SKIPPING <large_table> materialization ' ~ target_relation ~ ' | var("include_large_tables") is False]', True) -%}

    -- dont build model
    {% call statement('main') -%}
      select 1 limit 0;
    {% endcall -%}

  {%- endif -%}
  
  {{ return({'relations': [target_relation]}) }}

{% endmaterialization %}


{% materialization large_table, adapter='bigquery' -%}
{#- /* Adapted from https://github.com/dbt-labs/dbt-bigquery/blob/main/dbt/include/bigquery/macros/materializations/table.sql */ -#}

  {%- set identifier = model['alias'] -%}
  {%- set target_relation = api.Relation.create(database=database, schema=schema, identifier=identifier, type='table') -%}

  {%- if var('include_large_tables', False) -%}

      {%- set old_relation = adapter.get_relation(database=database, schema=schema, identifier=identifier) -%}
      {%- set exists_not_as_table = (old_relation is not none and not old_relation.is_table) -%}

      {{ run_hooks(pre_hooks) }}

      {#
          We only need to drop this thing if it is not a table.
          If it _is_ already a table, then we can overwrite it without downtime
          Unlike table -> view, no need for `--full-refresh`: dropping a view is no big deal
      #}
      {%- if exists_not_as_table -%}
          {{ adapter.drop_relation(old_relation) }}
      {%- endif -%}

      -- build model
      {%- set raw_partition_by = config.get('partition_by', none) -%}
      {%- set partition_by = adapter.parse_partition_by(raw_partition_by) -%}
      {%- set cluster_by = config.get('cluster_by', none) -%}
      {% if not adapter.is_replaceable(old_relation, partition_by, cluster_by) %}
        {% do log("Hard refreshing " ~ old_relation ~ " because it is not replaceable") %}
        {% do adapter.drop_relation(old_relation) %}
      {% endif %}
      {% call statement('main') -%}
        {{ create_table_as(False, target_relation, sql) }}
      {% endcall -%}

      {{ run_hooks(post_hooks) }}

      {% do persist_docs(target_relation, model) %}

  {%- else -%}

    {%- do log('[SKIPPING <large_table> materialization ' ~ target_relation ~ ' | var("include_large_tables") is False]', True) -%}

    -- dont build model
    {% call statement('main') -%}
      select 1 limit 0;
    {% endcall -%}

  {%- endif -%}

  {{ return({'relations': [target_relation]}) }}

{% endmaterialization %}


{% materialization large_table, adapter='snowflake' %}
{#- /* Adapted from https://github.com/dbt-labs/dbt-bigquery/blob/main/dbt/include/bigquery/macros/materializations/table.sql */ -#}

  {%- set original_query_tag = set_query_tag() -%}
  {%- set identifier = model['alias'] -%}
  {%- set old_relation = adapter.get_relation(database=database, schema=schema, identifier=identifier) -%}
  {%- set target_relation = api.Relation.create(identifier=identifier, schema=schema, database=database, type='table') -%}

  {%- if var('include_large_tables', False) -%}

    {{ run_hooks(pre_hooks) }}

    {#-- Drop the relation if it was a view to "convert" it in a table. This may lead to
      -- downtime, but it should be a relatively infrequent occurrence  #}
    {% if old_relation is not none and not old_relation.is_table %}
      {{ log("Dropping relation " ~ old_relation ~ " because it is of type " ~ old_relation.type) }}
      {{ drop_relation_if_exists(old_relation) }}
    {% endif %}

    --build model
    {% call statement('main') -%}
      {{ create_table_as(false, target_relation, sql) }}
    {%- endcall %}

    {{ run_hooks(post_hooks) }}

    {% do persist_docs(target_relation, model) %}

    {% do unset_query_tag(original_query_tag) %}
  {%- else -%}
    {%- do log('[SKIPPING <large_table> materialization ' ~ target_relation ~ ' | var("include_large_tables") is False]', True) -%}

    -- dont build model
    {% call statement('main') -%}
      select 1 limit 0;
    {% endcall -%}

  {%- endif -%}

  {{ return({'relations': [target_relation]}) }}

{% endmaterialization %}
