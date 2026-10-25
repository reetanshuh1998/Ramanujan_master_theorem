"""Exact finite binary numbers for independently rechecking audit decisions."""
import mpmath as mp


def exact_number(value):
    # Preserve mpf bits rather than rounding them through the current context.
    value = value if hasattr(value, '_mpf_') else mp.mpf(value)
    if not mp.isfinite(value):
        raise ValueError('audit encoding requires a finite number')
    sign, mantissa, exponent, _ = value._mpf_
    return dict(sign=int(sign), mantissa_hex=format(mantissa, 'x'), exponent2=int(exponent))


def exact_fields(**values):
    return {name: exact_number(value) for name, value in values.items()}
