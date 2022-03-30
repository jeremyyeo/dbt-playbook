## dbt-playbook

An experimental repo to store dbt examples and patterns as well as tests to make sure those examples actually run successfully.

Each playbook lives in it's own directory in `src/` with tests in the `src/<playbook-name>/tests/` folder.

Test are run with `pytest` and basically run `dbt` shell commands and should support the following 3 adapters / databases:

- [Postgres](.github/workflows/postgres.yml)
- [Snowflake](.github/workflows/snowflake.yml)
- [BigQuery](.github/workflows/bigquery.yml)

You can refer to the really basic [dbt-is-working](src/dbt-is-working/) example that basically does a `dbt debug` with each of the above adapters.
