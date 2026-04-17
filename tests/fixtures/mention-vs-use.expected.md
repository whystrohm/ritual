# Expected Output — mention-vs-use.md

## Summary
- Total violations: 0–1
- By priority: P1=0, P2=0, P3=0, P4=0, P5=0, P6=0–1
- Verdict: clean (or minor)

## Why nothing should fire on P3 or P4

This fixture verifies the **mention-vs-use exemption** from Patch A of `skill/references/checks.md`. Every banned word in this fixture appears in one of the exempt contexts:

1. **Under a heading with cue words** ("Hype words we avoid") — the list items underneath are exempt until the next heading of equal/higher level.
2. **Inside quotation marks with cue words in the same paragraph** ("banned phrases ... include \"in today's fast-paced world\"")
3. **Inside a definition context** ("The term \"delve\" is a classic tell")
4. **Inside a blockquote** (the `>` block near the bottom)
5. **Inside a code block** (the JSON example at the bottom)
6. **Inside inline code** (`` `leverage` `` and `` `empower` ``)

If the skill flags any banned word in this file as a P3 or P4 violation, the mention-vs-use detection is not working correctly.

## P6 possibility

The skill may legitimately flag the final sentence ("The JSON above is configuration, not copy.") as mild passive — acceptable; P6 requires density or high-visibility location, neither of which this fixture triggers.

## What this fixture protects

This was the largest single risk in v0.1: the skill embarrassing itself by flagging your own anti-slop blog posts. This fixture is the regression guard for that class of bug.
