"""Keep the notebook/browser walkthrough identical to the executed gallery source."""
import json
from pathlib import Path
import re

import pytest
from ramanujan_qft import (ScalarEdge, ScalarGraph, compile_sunset_rmt,
                           compile_sunset_taylor, RMTDomainError, RMTSeriesConvergenceError)

ROOT = Path(__file__).resolve().parents[1]


def test_shared_walkthrough():
    example = (ROOT/'examples/08_first_calculations.py').read_text()
    code = example[example.index('import json'):]
    notebook = json.loads((ROOT/'notebooks/stable_walkthrough.ipynb').read_text())
    assert ''.join(notebook['cells'][-1]['source']) == code
    javascript = (ROOT/'docs/_static/try_it.js').read_text()
    match = re.search(r'title: "Three reference-checked calculations",\s+code: ("[^\n]+"),', javascript)
    assert match and json.loads(match.group(1)) == code


def test_domain_error_names_inputs_and_explicit_alternative():
    graph = ScalarGraph([ScalarEdge(0, 1, 1)]*3)
    with pytest.raises(RMTDomainError, match='squared masses=.*p_E\\^2=0.*integrate_sunset_taylor'):
        compile_sunset_rmt(graph)
    graph = ScalarGraph([ScalarEdge(0, 1, m) for m in (1, 4, 9)])
    with pytest.raises(NotImplementedError, match='equal masses.*squared masses=.*compile_sunset_rmt'):
        compile_sunset_taylor(graph)


def test_precision_refusal_names_adjustable_budget():
    graph = ScalarGraph([ScalarEdge(0, 1, 1)]*3, {0: [10], 1: [-10]})
    with pytest.raises(RMTSeriesConvergenceError, match='max_dps=30.*dps=30.*Increase max_dps'):
        compile_sunset_rmt(graph).evaluate(dps=30, max_dps=30)
