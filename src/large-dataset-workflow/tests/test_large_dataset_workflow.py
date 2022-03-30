import os
from pathlib import Path

tests_path = Path(__file__).parent.resolve()
cwd = os.getcwd()


def test_prod_run():
    assert (
        os.system(
            f"dbt run --target prod --profiles-dir {cwd}/.dbt --project-dir {tests_path}/../my_dbt_project"
        )
        == 0
    )


def test_dev_run():
    assert (
        os.system(
            f"dbt run --target dev --profiles-dir {cwd}/.dbt --project-dir {tests_path}/../my_dbt_projec"
        )
        == 0
    )


def test_dev_run_with_include_large_table():
    assert (
        os.system(
            f"dbt run --target dev --vars 'include_large_tables: true' --profiles-dir {cwd}/.dbt --project-dir {tests_path}/../my_dbt_project"
        )
        == 0
    )
