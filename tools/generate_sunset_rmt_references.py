"""Generate independent D=2 sunset references using simplex quadrature only.

Run from the repository root. No ramanujan_qft code is imported. Each reference
must agree at 40 and 55 working digits before it is written to the test fixture.
This script is intentionally separate from both series and sector evaluators.
"""
import json
from pathlib import Path
import mpmath as mp

CASES = [([1, 1, 1], 100), ([1, 4, 9], 400), ([1, 4, 100], 0), ([1, 4, 100], 1)]


def reference(masses, q2, dps):
    with mp.workdps(dps):
        m = list(map(mp.mpf, masses))
        q = mp.mpf(q2)
        def outer(u):
            def inner(v):
                x, y, z = u*v, u*(1-v), 1-u
                F = (x*y+x*z+y*z)*(m[0]*x+m[1]*y+m[2]*z)+q*x*y*z
                return u/F if F else mp.mpf(0)
            return mp.quad(inner, [0, mp.mpf('0.5'), 1])
        return mp.quad(outer, [0, mp.mpf('0.5'), 1])


def main():
    rows = []
    for masses, q2 in CASES:
        a, b = reference(masses, q2, 40), reference(masses, q2, 55)
        with mp.workdps(60):
            delta = abs(a-b)
            if delta > mp.mpf('1e-38')*abs(b):
                raise ArithmeticError('independent quadrature precision check failed')
            rows.append({'mass_squared': masses, 'p_e_squared': q2,
                         'value': mp.nstr(b, 50), 'precision_check_difference': mp.nstr(delta, 8)})
        print(masses, q2, rows[-1]['value'], flush=True)
    output = {'method': 'independent simplex quadrature, x=u*v, y=u*(1-v), z=1-u',
              'working_dps': [40, 55], 'cases': rows}
    target = Path(__file__).resolve().parents[1] / 'tests/data/sunset_rmt_reference.json'
    target.write_text(json.dumps(output, indent=2) + '\n')


if __name__ == '__main__':
    main()
