# Research-alpha release plan

Work proceeds in this order. A completed implementation is distinct from
independent scientific review and from publication.

```mermaid
flowchart TD
    A[1. Equal-mass coverage: implemented and tested]
    B[2. Local audit passed: external review pending]
    C[3. Capabilities and guarantees: documented]
    D[4. Hosted CI and TestPyPI rehearsal passed]
    E[5. Alpha candidate prepared: publication pending]
    A --> B --> C --> D --> E
    classDef ready fill:#d8f3dc,stroke:#2d6a4f,color:#102a1b
    classDef pending fill:#fff3cd,stroke:#997404,color:#332701
    class A,C,D ready
    class B,E pending
```

| Order | Objective | Completion criteria | Status |
|---|---|---|---|
| 1 | Close the equal-mass Euclidean gap | Derived convergent series, documented normalization and tail bound; vacuum, quadrature and overlap checks; bounded work | Implemented; validation recorded below |
| 2 | Audit the numerical backend | Reproducible benchmark grid, independent references, actual versus reported errors, boundary and budget failures, review packet | Local audit passed; external scientific review pending |
| 3 | Make capabilities explicit | One capability table; distinguish RMT, analytic continuation and numerical integration; describe all error guarantees | Implemented |
| 4 | Gate publication on validation | Release-commit tests, wheel and source-distribution checks outside checkout, platform smoke tests, TestPyPI rehearsal workflow | Hosted validation and TestPyPI upload/install passed for `3b00bd6`; changed candidates must be revalidated |
| 5 | Prepare the public research alpha | Runnable notebook, versioned release notes, citation/contribution instructions and release checklist | Candidate 0.3.0a1 prepared; public release pending |

External scientific review needs a human reviewer. Repository changes cannot
stand in for that review. TestPyPI contains the rehearsed `0.3.0a1` candidate;
production PyPI publication remains pending.

## Scope

The first release targets a credible, reproducible research tool. General
topology-specific convergence selection, epsilon expansions, overlapping
subtractions, massless integrals and physical-region continuation remain later
research objectives. Existing user changes are preserved throughout.

## Evidence log

- Initial state: graph-derived RMT sunset charts require momentum dominance or
  mass dominance. Equal-mass vacuum is explicitly refused.
- Existing release workflow builds and publishes but does not depend on a
  validation job. CI currently runs on Linux only.
- Objective 1: added a separately named equal-mass Taylor backend. Its
  transformed parameter-integral series converges for every finite Euclidean
  momentum, subject to work budgets. It is not presented as a new RMT family.
  The derivation includes a tail bound and the recurrence's precision hazard.
- Objective 1: all 15 dedicated tests passed, including independent parameter
  quadrature and overlap with the generated RMT series.
- Objective 2: the fixed-seed audit passed all cases after resolving an
  inadequate-reference-precision finding. Source hashes and individual results
  are in `benchmarks/data/sunset_audit.json`; external review is explicitly
  pending in [the review packet](SCIENTIFIC_REVIEW.md).
- Objective 3: [the capability table](CAPABILITIES.md) describes each method,
  accepted domain and error contract, including the unequal-mass gap.
- Objective 4: publication now depends on a reusable validation workflow:
  tests, audit, documentation and isolated wheel/sdist checks on Linux, Windows
  and macOS. A manual-only TestPyPI rehearsal workflow is prepared.
- Full local regression suite: 440 tests passed, including the slow quadrature
  checks; one existing SciPy reference-quadrature roundoff warning was emitted.
- Final local checks: 19 doctests, all six research-notebook code cells, all 67
  documentation examples, a warning-free Sphinx build with the rendered
  plan chart, actionlint and strict distribution metadata checks passed.
- The 0.3.0a1 wheel and source distribution installed successfully into fresh
  environments outside the checkout. Both numerical series APIs passed with
  SciPy unavailable. The source archive contains the reproduction material.
- The candidate notebook, citation version, contribution guide and draft
  release notes are prepared. Follow [the release checklist](RELEASING.md);
  external review and production PyPI publication remain pending.
- Hosted validation for candidate `b224380` passed: [tests, audit and six
  platform/artifact combinations](https://github.com/reetanshuh1998/Ramanujan_master_theorem/actions/runs/39865347949)
  and [full documentation/gallery checks](https://github.com/reetanshuh1998/Ramanujan_master_theorem/actions/runs/39865347891).
  Subsequent changes must pass CI again; current results are tracked in
  [merged PR #3](https://github.com/reetanshuh1998/Ramanujan_master_theorem/pull/3)
  and the main-branch workflow runs.
- Candidate `3b00bd6` passed the [TestPyPI rehearsal](https://github.com/reetanshuh1998/Ramanujan_master_theorem/actions/runs/39924746748):
  validation, trusted-publisher upload and fresh installation from the index.
  Published wheel/source hashes matched the validated artifacts. Later changes
  require another frozen candidate and an unused version for a repeat upload.
