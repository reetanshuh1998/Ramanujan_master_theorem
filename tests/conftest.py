import csv
import os

import pytest

DATA = os.path.join(os.path.dirname(__file__), "data", "looptools_reference.csv")


def _load():
    rows = []
    with open(DATA) as fh:
        for line in fh:
            if line.startswith("#") or not line.strip():
                continue
            f, x, m1, m2, m3, re, im = next(csv.reader([line]))
            args = [float(x), float(m1), float(m2)] + ([float(m3)] if m3 else [])
            rows.append((f, tuple(args), complex(float(re), float(im))))
    return rows


@pytest.fixture(scope="session")
def looptools_reference():
    return _load()


def pytest_generate_tests(metafunc):
    if "lt_case" in metafunc.fixturenames:
        cases = _load()
        metafunc.parametrize("lt_case", cases, ids=[f"{f}{a}" for f, a, _ in cases])
