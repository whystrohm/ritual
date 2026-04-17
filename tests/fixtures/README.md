# Test Fixtures

These are intentionally imperfect content files used to verify that `ritual-voice` catches what it claims to catch. Each fixture ships with an `expected.md` describing the violations the skill should find when run against the `test-config.json` in this directory.

## Contents

| Fixture | What it tests | Priority classes fired |
|---|---|---|
| `clean.md` | No violations; verifies the skill does not false-positive on well-written content | (none) |
| `p1-stale-stats.md` | Numbers that don't match `provenFacts` | P1 |
| `p2-missing-specificity.md` | Vague benefits, ungrounded outcomes, abstract subjects | P2 |
| `p3-ai-slop.md` | Em-dash density, `delve`, `tapestry`, "it's not X — it's Y" construction | P3 |
| `p4-hype-words.md` | `comprehensive`, `seamless`, `revolutionary`, etc. | P4 |
| `p5-name-mismatch.md` | `Ty` in one paragraph, `Tyler Robinson` in another | P5 |
| `p6-generic-voice.md` | Passive headlines, hedging in claims, vague benefits | P6 |
| `mention-vs-use.md` | Content that *talks about* banned words (under Patch A rules) should NOT trigger P3/P4 | (none expected; verifies mention-vs-use exemption) |

## How to use

These are for manual verification today. Run the skill against each fixture in a Claude Code session and compare the output against the fixture's `expected.md`. A fully-automated runner that validates skill output against expectations is on the roadmap once Claude Code exposes a stable programmatic skill-invocation API.

```bash
# In Claude Code, in this repo:
# "Run ritual-voice on tests/fixtures/p3-ai-slop.md in flag mode."
# Then compare against tests/fixtures/p3-ai-slop.expected.md
```

## Contributing new fixtures

If you find a case the skill misses, add a fixture:

1. Create `tests/fixtures/<name>.md` with the problematic content
2. Create `tests/fixtures/<name>.expected.md` describing what the skill should flag
3. Open a PR with a one-line description of the class of bug

Fixtures are load-bearing documentation — they show what the skill is supposed to do better than any prose can.
