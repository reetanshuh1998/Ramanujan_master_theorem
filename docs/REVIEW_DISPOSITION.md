# Stable-development review findings and disposition

The supplementary Claude report on development version 0.3.0rc1.dev1 recommends
changes before qualification. It found no materially wrong accepted value in
its resolved-reference checks, but identified a major defect in the reviewer
packet and several smaller issues. It is an automated assessment, not human
scientific approval. The reviewed snapshot is commit `d998357235083d2cb83ca6175245e4ecb46680f1`.

The [original report](reviews/CLAUDE_STABLE_REVIEW.md) is retained byte-for-byte.
Its SHA-256 is `1cf51a6797483e56f66c6bf8ec92573fed4811608eb8ab600382c271b9c7e31c`.
The original packet and reviewer evidence remain unchanged at their local paths:

- `/home/reet/ramanujan-stable-development-review`
- `/home/reet/ramanujan-stable-development-claude-review`

The report's manifest and audit hashes were independently checked against the
packet. The code inspection confirmed the missing benchmark imports, unguarded
dispatch ref, excessive value-display digits and sorted-mass refusal message.
Numerical and workflow regression checks below validate the corrections; they
do not turn an automated review into a human assessment.

## Findings

| ID | Disposition | Correction or rationale |
|---|---|---|
| R1 | Corrected; isolated packet validation required | Include benchmark modules and reference reports, plus root setup/requirements files. Collect the complete test suite in a subprocess inside a freshly generated packet with `PYTHONPATH` removed. The earlier copy/manifest-only regression did not catch missing imports. |
| R2 | Accuracy and coverage separated; hybrid remains experimental | Schema-v2 audit acceptance checks resolved references and requested accuracy. Report coverage independently as counts per graph and overall, list every miss, and set `hybrid_coverage_requires_review`. Retain all failures separately. Do not fit a permissive threshold to observed misses, imply IID trials across different graphs, or change the estimator to force coverage. |
| R3 | Corrected; tag/ref tests added | TestPyPI upload requires a `refs/tags/v*` ref. Shared validation checks both the tag version and the full ref for release and TestPyPI-dispatch events. A branch named `v0.3.0rc1` is still refused. |
| R4 | Corrected | The human-readable value has at most the requested significant digits. Binary fields retain every stored bit. Examples compare references using the exact binary value instead of the rounded display string. |
| R5 | Corrected | Domain errors show masses in the caller's edge order; internal chart sorting is unchanged. |
| R6 | Implemented | Both numerical audits retain exact finite binary fields for values, references, uncertainties, errors and comparison allowances. Display decimals remain for readability. |
| R7 | Corrected; hosted verification pending | The guide says the notebook is intended for Colab and explicitly identifies hosted execution as unverified. |

The hybrid distinction in R2 is deliberate: a statistical estimate is not a
bound guaranteed on every seed. An accuracy pass with a coverage alert is not
an error-estimate validation pass. Packet creation preserves the alerts for
review; it is not release approval. A Clopper–Pearson interval was not added,
because treating this heterogeneous fixed-graph experiment as IID Bernoulli
trials would require assumptions not established by the review. The
[NIST exact-binomial procedure](https://www.itl.nist.gov/div898/software/dataplot/refman2/auxillar/exacbici.htm)
targets a binomial success probability; this fixed-graph audit has not specified
a calibrated sampling model for a general coverage probability. The report's
Student-t calculation is a heuristic explanation, not a calibrated confidence
claim for the adaptive estimator.

## Source-archive follow-up

The corrected checkout packet contains the missing benchmarks. A further check
found that the sdist also needed the root requirements/setup/ignore files and
workflow definitions now read by release tests. Candidate rc2 explicitly ships
these, and `tools/check_sdist_contents.py` checks the built archive's review
support files. The rc1 rehearsal was stopped before upload; its tag is unchanged.

## Validation and remaining decisions

Forty focused correction checks passed. Both default (32 samples) and additional
(128 samples, seeds 1000–1031) hybrid audits met their accuracy targets. The
additional block reproduced the three reported coverage misses: one-loop seeds
1010/1011 and three-loop seed 1004. They remain listed as coverage alerts
(125/128 covered); no seed was discarded and no estimator was widened.
All series checks passed. Coverage decisions were independently recomputed with
exact rational arithmetic from the new binary audit fields. The documentation
build passed with warnings treated as errors.


Relevant checks include packet-only collection/execution, decimal-display and
binary round trips, caller-order diagnostics, tag/ref refusal tests, audit
recomputation from exact fields, and default plus additional hybrid seed blocks.
Results must identify the corrected source and regenerated reports, rather than
reuse approval or audit hashes from the reviewed snapshot.

The release is **not yet cleared for stable publication**. The report explicitly
leaves the momentum-chart continuation argument unverified by its reviewer
(U1), and the accepted plan still has pending human scientific assessment,
actual outside-user/interactive-Colab feedback and final candidate qualification.
The earlier successful browser/platform CI does address some execution omissions
in Claude's report; it does not provide those external assessments.

After correction checks, prepare a fresh review packet and freeze a candidate
for TestPyPI rehearsal. Before publishing 0.3.0, resolve or explicitly disposition
the remaining scientific and qualification questions with the release owner.
Never mark a missing review, user session or upload rehearsal as completed.

```{toctree}
:hidden:

reviews/CLAUDE_STABLE_REVIEW
```
