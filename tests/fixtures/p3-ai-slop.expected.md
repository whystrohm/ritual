# Expected Output — p3-ai-slop.md

## Summary
- Total violations: 8+
- By priority: P1=0, P2=1–2, P3=6+, P4=0–1, P5=0, P6=0
- Verdict: needs-revision

## Violations (P3 primary)

P3 — AI-slop markers
  L1 "In today's fast-paced world"          exact bannedPhrases match
  L1 "testament to"                          bannedPhrases match
  L1 "delve"                                 bannedPhrases match
  L1 "rich tapestry" / "tapestry"            bannedPhrases match
  L3 "It's not just X — it's Y"              structural match, "not just" bannedPhrases
  L3 "This isn't just X — it's Y"            structural match, "this isn't just" bannedPhrases
  L5 "at the end of the day"                 bannedPhrases match
  L5 "navigate the landscape"                bannedPhrases match
  L5 em-dash density: 4 em-dashes / ~30 words = exceeds 1-per-150 threshold

Some P2 fires expected (ungrounded "businesses are grappling with unprecedented challenges") but the primary intent of this fixture is P3 coverage.
