import os
from pathlib import Path

tests_path = Path(__file__).parent.resolve()
cwd = os.getcwd()


def test_prod_run():
    assert (
        os.system(
            f"dbt --profiles-dir {cwd}/.dbt --project-dir {tests_path}/../my_dbt_project run --target prod"
        )
        == 0
    )


def test_dev_run():
    assert (
        os.system(
            f"dbt --profiles-dir {cwd}/.dbt --project-dir {tests_path}/../my_dbt_project run --target dev"
        )
        == 0
    )


def test_dev_run_with_include_large_table():
    assert (
        os.system(
            f"dbt --profiles-dir {cwd}/.dbt --project-dir {tests_path}/../my_dbt_project run --target dev --vars 'include_large_tables: true'"
        )
        == 0
    )
