import os
from pathlib import Path

tests_path = Path(__file__).parent.resolve()


def test_debug():
    assert (
        os.system(
            f"dbt debug --profiles-dir {tests_path}/my_dbt_project --project-dir {tests_path}/my_dbt_project"
        )
        == 0
    )
