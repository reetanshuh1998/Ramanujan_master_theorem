"""Versioned, JSON-compatible explanations of supported sunset RMT calculations."""
import hashlib
from importlib import resources
import json
from pathlib import Path

import mpmath as mp
import sympy as sp

from .sunset_rmt import compile_sunset_rmt, RMTSeriesConvergenceError
from .multiloop import _integer

__all__ = ['explain_sunset_rmt', 'sunset_rmt_schema']


def sunset_rmt_schema():
    """Return a fresh copy of the bundled JSON Schema for explanation version 1."""
    return json.loads(resources.files('ramanujan_qft').joinpath(
        'schemas/sunset-rmt-v1.json').read_text(encoding='utf-8'))


def _number(value, digits):
    """Exact binary mpf plus a readable decimal, independent of global precision."""
    if not mp.isfinite(value):
        raise ValueError('only finite numbers can be exported')
    sign, mantissa, exponent, _ = value._mpf_
    return dict(decimal=mp.nstr(value, digits), sign=int(sign),
                mantissa_hex=format(mantissa, 'x'), exponent2=int(exponent))


def _diagnostics(result, dps):
    if result is None:
        return None
    return dict(value=_number(result.value, dps+8),
                error_estimate=_number(result.error_estimate, dps+8),
                truncation_bound=_number(result.truncation_bound, dps+8),
                convergence_ratio=_number(result.convergence_ratio, dps+8),
                terms=result.terms, shells=result.shells, working_dps=result.working_dps,
                converged=result.converged, chart=result.chart, method=result.method)


def explain_sunset_rmt(graph, D=2, *, chart='auto', evaluate=False, dps=30,
                       max_shells=128, max_terms=250000, max_dps=None):
    """Explain a supported D=2 sunset chart as JSON-compatible data.

    The default compiles without summing. ``evaluate=True`` attaches a value
    and diagnostics; budget failures are explicitly labeled and retain partial
    diagnostics. Unsupported graphs/charts raise the compiler's existing
    exceptions. No numerical fallback or expression deserialization is used.

    Symbolic expressions are display strings. Numerical values retain an exact
    binary encoding as well as readable decimals; see the explanation guide.
    Schema version 1 is provisional until the 0.3.0 release qualification.
    """
    if not isinstance(evaluate, bool):
        raise TypeError('evaluate must be a bool')
    from . import __version__
    series = compile_sunset_rmt(graph, D=D, chart=chart)
    system = series.bracket_system
    parameters, U, F = graph.symanzik()
    vertex_index = {v: i for i, v in enumerate(graph.vertices)}
    momentum = graph.external_momenta[graph.vertices[0]]
    q2 = sum((q*q for q in momentum), sp.S.Zero)
    source_files = ('explain.py', 'sunset_rmt.py', 'brackets.py', 'multiloop.py', '__init__.py')
    sources = {}
    for name in source_files:
        # Installed distributions normally retain source; unavailable hashes
        # are explicit rather than silently identifying a different checkout.
        path = Path(__file__).with_name(name)
        sources[name] = hashlib.sha256(path.read_bytes()).hexdigest() if path.is_file() else None
    result = dict(
        schema_version=1, kind='sunset-rmt-explanation',
        provenance=dict(package_version=__version__, sympy_version=sp.__version__,
                        mpmath_version=mp.__version__, source_sha256=sources),
        conventions=dict(dimension='2', propagators='positive Euclidean',
                         loop_measure='d^D k / pi^(D/2)', masses='squared'),
        graph=dict(vertices=list(range(len(graph.vertices))),
                   edges=[dict(source=vertex_index[e.source], target=vertex_index[e.target],
                               mass_squared=str(e.mass_squared), power=str(e.power)) for e in graph.edges],
                   external_momenta=[[str(q) for q in graph.external_momenta[v]] for v in graph.vertices]),
        polynomials=dict(parameters=list(map(str, parameters)), U=str(U), F=str(F)),
        bracket_system=dict(matrix=[[str(x) for x in row] for row in system.matrix.tolist()],
                            offsets=list(map(str, system.offsets)), indices=list(map(str, system.indices)),
                            coefficients=list(map(str, system.coefficients)),
                            gamma_denominator=str(system.gamma_denominator), normalization=str(system.normalization)),
        families=[dict(status='formal regulated family; use the combined pole limit',
                       bound_columns=list(f.bound_columns), free_columns=list(f.free_columns),
                       determinant=str(f.determinant), solved_indices=list(map(str, f.values)),
                       gamma_term=str(term)) for f, term in zip(series.families, series.gamma_terms)],
        pole_limit=dict(regulator=str(series.regulator), limit='regulator -> 0 after combining families',
                        summation_indices=list(map(str, series.summation_indices)),
                        coefficient_expression=str(series.coefficient_expression)),
        convergence=dict(status='justified sunset chart', requested_chart=chart, chart=series.chart,
                         condition=('Q > m1 + m2 + m3' if series.chart == 'momentum' else 'M > ma + mb + Q'),
                         momentum_squared=str(q2), mass_order=list(series.mass_order),
                         scale=str(series.scale), ratios=list(map(str, series.ratios)),
                         rho_upper=str(series.rho_upper), domain_digits=series.domain_digits,
                         criterion='rho_upper < 1; exact rational enclosure',
                         derivation='docs/user_guide/sunset_rmt.md'),
        limitations=['An invertible bracket basis alone does not prove convergence.',
                     'Individual regulated families can have poles; the combined finite limit is evaluated.',
                     'The tail bound is analytic; arithmetic error estimates are not interval enclosures.'],
        evaluation=dict(status='not_requested', requested_dps=None, budgets=None, diagnostics=None, exception=None))
    if evaluate:
        dps = _integer(dps, 'dps', 10)
        max_shells = _integer(max_shells, 'max_shells', 1)
        max_terms = _integer(max_terms, 'max_terms', 1)
        max_dps = None if max_dps is None else _integer(max_dps, 'max_dps', dps)
        evaluation = result['evaluation']
        evaluation.update(requested_dps=dps, budgets=dict(max_shells=max_shells, max_terms=max_terms, max_dps=max_dps))
        try:
            value = series.evaluate(dps=dps, max_shells=max_shells, max_terms=max_terms, max_dps=max_dps)
            evaluation.update(status='converged', diagnostics=_diagnostics(value, dps))
        except RMTSeriesConvergenceError as exc:
            evaluation.update(status='budget_exceeded', diagnostics=_diagnostics(exc.result, dps), exception=str(exc))
    return result
