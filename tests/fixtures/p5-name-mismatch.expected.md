# Expected Output — p5-name-mismatch.md

## Summary
- Total violations: 3–4 (P5 dominant)
- By priority: P1=0, P2=0, P3=0, P4=0, P5=3+, P6=0
- Verdict: needs-revision

## Violations

P5 — Name/attribution mismatches
  File-level: "Tyler Robinson", "Tyler", "Ty", "Robinson" all appear — variants collide.
    Canonical form: "Tyler Robinson"
    Variants used: "Tyler", "Ty", "Robinson"
    Verdict: inconsistent within file

  L7 Testimonial attribution "— Ty, Founder"
    Why: attribution lines are formal context; use canonical form.
    Fix: "— Tyler Robinson, Founder"

  L13 "Tyshaun Robison" — possible misspelling
    Why: edit distance ≤ 2 from canonical "Tyler Robinson" (partial match)
    Fix: correct to canonical form or add to canonicalNames if intentional

## What should NOT fire

The quote "We rebuilt the system from scratch. It was the right call." is a direct quote and exempt from P3/P4/P6 — P5 still applies (hence the attribution flag below the quote).
