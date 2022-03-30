## large-dataset-workflow

[![postgres:latest](https://github.com/jeremyyeo/dbt-playbook/actions/workflows/postgres.yml/badge.svg)](https://github.com/jeremyyeo/dbt-playbook/actions/workflows/postgres.yml) [![snowflake](https://github.com/jeremyyeo/dbt-playbook/actions/workflows/snowflake.yml/badge.svg)](https://github.com/jeremyyeo/dbt-playbook/actions/workflows/snowflake.yml) [![bigquery](https://github.com/jeremyyeo/dbt-playbook/actions/workflows/bigquery.yml/badge.svg)](https://github.com/jeremyyeo/dbt-playbook/actions/workflows/bigquery.yml)

This is an example workflow when you're dealing with really large datasets/tables that you do not want individual developers to update (perhaps unless they pass in a override via a variable). We will also be raising a compiler error if the `+schema` config is not set for any node - this is because we want tight control of the various schemas that our tables will be built into.

> Note that this example is written for the base `table` materialization - you should be able to learn from this and apply it to other default materialization types in your project too (e.g. `incremental`).

### Production job run

These jobs are expected to have `target.name == 'prod'` and when we invoke `dbt run` - all models are built / rebuilt into the custom schema without any prefix:

- `shared`
- `marketing`
- `sales`

### Development runs

These jobs are expected to have `target.name == 'dev'` and can be invoked in two ways:

#### Command: `dbt run`

- Large models are set to have the custom schema name without prefix. Models ARE NOT built.
  - `shared`
- Normal models are set to have the custom schema name with the individual developer prefix. Models ARE built.
  - `dbt_jdoe_marketing`
  - `dbt_jdoe_sales`

#### Command: `dbt run --vars 'include_large_tables: true'`

- Large models are set to have the custom schema name with the individual developer prefix. Models ARE built.
  - `dbt_jdoe_shared`
- Normal models are set to have the custom schema name with the individual developer prefix. Models ARE built.
  - `dbt_jdoe_marketing`
  - `dbt_jdoe_sales`

### Setup

1. Depending on the datawarehouse that you're using, you will need to copy over the new `large_table` materialization macro from the [example project folder](./my_dbt_project/macros/large_table.sql) to your project.

2. Add the generate schema name macro as shown in [this example](./my_dbt_project/macros/generate_schema_name.sql) to your project.

3. Then use the newly added `large_table` materialization to a model in it's config block or in the `dbt_project.yml` file as shown in the [example project](./my_dbt_project/dbt_project.yml).
