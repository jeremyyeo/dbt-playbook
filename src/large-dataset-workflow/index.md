## large-dataset-workflow

[![postgres:latest](https://github.com/jeremyyeo/dbt-playbook/actions/workflows/postgres.yml/badge.svg)](https://github.com/jeremyyeo/dbt-playbook/actions/workflows/postgres.yml) [![snowflake](https://github.com/jeremyyeo/dbt-playbook/actions/workflows/snowflake.yml/badge.svg)](https://github.com/jeremyyeo/dbt-playbook/actions/workflows/snowflake.yml) [![bigquery](https://github.com/jeremyyeo/dbt-playbook/actions/workflows/bigquery.yml/badge.svg)](https://github.com/jeremyyeo/dbt-playbook/actions/workflows/bigquery.yml)

This is an example workflow when you're dealing with really large datasets/tables that you do not want individual developers to update (perhaps unless they pass in a override via a variable).

### Expected workflow:

By default, we will raise a compiler error if `+schema` config is not set for the node because we want tight control of the schema.

### Production job runs (`target.name == 'prod'`)

Command: `dbt run --vars 'include_large_tables: True'`

All models are built / rebuilt into the verbatim schema without any prefix:

- `shared`
- `marketing`
- `sales`

### Development runs (`target.name == 'dev'`)

Command: `dbt run`

- Large models are set to have the custom schema name without prefix. Models ARE NOT built.
  - `shared`
- Normal models are set to have the custom schema name with the individual developer prefix. Models ARE built.
  - `dbt_jyeo_marketing`
  - `dbt_jyeo_sales`

Command: `dbt run --vars 'include_large_tables: true'`

- Large models are set to have the custom schema name with the individual developer prefix. Models ARE built.
  - `dbt_jyeo_shared`
- Normal models are set to have the custom schema name with the individual developer prefix. Models ARE built.
  - `dbt_jyeo_marketing`
  - `dbt_jyeo_sales`
