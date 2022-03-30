import os
from pathlib import Path

tests_path = Path(__file__).parent.resolve()


def test_debug():
    assert os.system("dbt --help") == 0
    # f = open(f"{tests_path}/text.txt")
    # assert f.readline() == "hello"
    # assert Path(__file__).parent.resolve() == "test"
