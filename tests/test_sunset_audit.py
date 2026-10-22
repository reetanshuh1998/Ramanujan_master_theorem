"""The audit reference is checked against separately generated 2D fixtures."""
import json
from pathlib import Path

import mpmath as mp
import pytest

from tools.audit_sunset import reference


@pytest.mark.parametrize('index', range(4))
def test_cheng_wu_reference_against_nested_simplex_fixture(index):
    data = json.loads((Path(__file__).parent/'data/sunset_rmt_reference.json').read_text())
    case = data['cases'][index]
    value = reference(case['mass_squared'], case['p_e_squared'], 45)
    with mp.workdps(55):
        assert abs(value-mp.mpf(case['value'])) < mp.mpf('1e-38')*abs(value)
