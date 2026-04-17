# Expected Output — p4-hype-words.md

## Summary
- Total violations: 10+
- By priority: P1=0, P2=1–2, P3=0–1, P4=9+, P5=0, P6=0
- Verdict: needs-revision

## Violations (P4 primary)

P4 — Hype words
  L1 comprehensive, seamless
  L1 revolutionary, game-changing, empower, unlock, cutting-edge
  L3 leverage, innovative

Some P2 ("drive transformative outcomes") expected. The point of this fixture is to confirm the banned-words list in test-config.json fires cleanly on literal body-copy use.

## Mention-vs-use note

None of the hype words here appear inside enumeration cues, quotation marks, or under a heading about bad writing. All should fire. If any are skipped, Patch A's cue-word list or heading-detection logic is over-broad.
