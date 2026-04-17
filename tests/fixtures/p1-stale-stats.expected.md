# Expected Output — p1-stale-stats.md

## Summary
- Total violations: 5 (all P1)
- By priority: P1=5, P2=0, P3=0, P4=0, P5=0, P6=0
- Verdict: republish

## Violations

P1 — Stale stats
  L1 "250 videos in Q1 2026"
    Why: contradicts provenFacts entry "400 videos shipped in Q1 2026"
    Verdict: outdated
  L1 "team grew to 14 people"
    Why: contradicts provenFacts entry "11 active clients" (semantic mismatch)
    Verdict: outdated
  L1 "Revenue is up 40% year over year"
    Why: no matching provenFact; metricsRequireVerification is true
    Verdict: unverified
  L3 "6,000 assets a week"
    Why: no matching provenFact
    Verdict: unverified
  L3 "12 hours"
    Why: no matching provenFact
    Verdict: unverified
