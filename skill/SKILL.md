---
name: ritual-voice
description: "Audit written content against a brand's voice guardrails defined in a ritual.config.json file. Use this skill whenever the user asks to review, check, audit, lint, or enforce brand voice on any content surface — landing pages, blog posts, testimonials, case studies, emails, social posts, or marketing copy. Also trigger when the user mentions voice lint, brand guardrails, hype words, AI slop, stale stats, unverified claims, or asks whether copy sounds on-brand. Works across any brand that has a ritual.config.json in the repo. Six priority checks — stale metrics, missing specificity, AI-slop markers, banned hype words, name/attribution mismatches, and generic corporate voice. Part of Ritual — pair with Claude Code routines for scheduled enforcement across repos."
---

# Ritual — Voice

Audit written content against a brand's voice guardrails.

This skill is brand-agnostic. It reads rules from a `ritual.config.json` file in the repo and applies them to content. Any brand can use it by dropping in their own config.

Part of **Ritual** — routines run, Ritual proves. Make every claim earn its place.

## When to trigger

Trigger when the user:
- Asks to "check," "audit," "review," "lint," or "enforce" brand voice
- Mentions a specific piece of copy and asks if it's on-brand
- Asks about hype words, AI slop, stale stats, or voice guardrails
- Drops a URL, markdown file, or block of copy and asks for a voice pass
- Is preparing content to publish and wants a sanity check first

Do not trigger for:
- Generative writing requests ("write me a blog post") — this is an audit skill, not a writing skill
- General proofreading (spelling, grammar) — this is voice-specific
- Questions about voice strategy or positioning — this enforces voice, doesn't design it

## Three modes — always ask which one

Every invocation, ask the user which mode they want:

1. **Flag** — List violations with file + line + rationale. Don't edit anything.
2. **Suggest** — Flag violations AND propose a rewrite in the brand's voice. User decides whether to apply.
3. **Fix** — Apply rewrites directly and show a diff. For use when the user trusts the skill or is running it as part of a routine.

If the skill is invoked from a routine with no user present, default to **Suggest** and emit the output as a structured report (never auto-fix without explicit instruction in the routine prompt).

## Workflow

### Step 1: Locate the brand config

Look for the config in this order:
1. `ritual.config.json` at repo root
2. `.brand/config.json`
3. `config/brand.json`
4. `voice-lint.config.json`

If none exists, tell the user and offer to scaffold one using `references/config-schema.md`. Do not proceed without a config — a generic scan produces generic results.

### Step 2: Load the content

The user will point at one of:
- A single file (`.md`, `.mdx`, `.txt`, `.tsx`, `.jsx`, `.html`)
- A directory (scan all supported files inside)
- A URL (fetch and extract the main content)
- A pasted block of text in the conversation

For component files (`.tsx`, `.jsx`), extract only string literals and JSX text nodes — ignore imports, logic, and variable names.

### Step 3: Run checks in priority order

Run all six check classes, but report them in this priority order. This ordering matters: **specificity and staleness are more important than hype words.** Do not reorder.

**Priority 1 — Stale stats / outdated metrics.** See `references/checks.md` section 1.

**Priority 2 — Missing specificity.** Claims without numbers, proof, or named subjects. See `references/checks.md` section 2.

**Priority 3 — AI-slop markers.** Em-dash seasoning, "it's not X — it's Y" construction, "delve," "tapestry," "testament to," "navigate the landscape," "in today's fast-paced world." See `references/checks.md` section 3.

**Priority 4 — Hype words.** Pull the list from `ritual.config.json → voice.bannedWords`. Default list in `references/checks.md` section 4.

**Priority 5 — Name/attribution mismatches.** Cross-reference every name mentioned against `ritual.config.json → canonicalNames`. Flag informal variants, misspellings, and inconsistencies. See `references/checks.md` section 5.

**Priority 6 — Generic corporate voice.** Passive voice, hedging ("may," "might," "could potentially"), vague benefits ("better results," "improved performance"). See `references/checks.md` section 6.

### Step 4: Emit the report

Structure every report the same way regardless of mode:

```
## Voice Lint Report — [file or URL]
Mode: [flag | suggest | fix]
Config: [path to ritual.config.json used]

### Summary
- Total violations: N
- By priority: P1=n, P2=n, P3=n, P4=n, P5=n, P6=n
- Verdict: [clean | minor | needs-revision | republish]

### Violations (in priority order)

#### P1 — Stale stats
[file:line] [quoted text]
  Why: [reason]
  Suggested fix: [rewrite, if mode is suggest or fix]

[... continue through all priorities ...]

### Notes
[Anything that needed human judgment and was skipped]
```

**Verdict thresholds:**
- `clean` — zero P1/P2 violations, ≤2 total
- `minor` — zero P1, ≤1 P2, ≤5 total
- `needs-revision` — any P1 or >1 P2 or >5 total
- `republish` — any P1 + multiple P2 (content is actively misleading or voice-breaking)

### Step 5: Apply fixes (fix mode only)

If the user chose `fix`:
1. Apply all P3–P6 rewrites directly.
2. For P1 and P2, apply only when the fix is mechanical (e.g., updating a stat the user provided a new value for, or adding a specific number from the config's `provenFacts` field). If the fix requires new information the skill doesn't have, leave it as a suggestion with a clear `TODO(voice-lint):` marker in the content.
3. Show a unified diff. Never commit or push.

## Key principles

**Fix, don't flag** — when the user asked for fixes. A scanner that only flags creates more work for the user. The "flag" mode exists for auditing; the "fix" mode exists for shipping.

**Preserve voice when rewriting.** Pull tone examples from `ritual.config.json → voice.examples` and match them. If the brand writes like Yurr — short sentences, specific numbers, no fluff — rewrites should too. Never substitute generic corporate language.

**Respect direct quotes.** If a hype word or AI-slop marker appears inside a direct client quote (testimonial, interview, case study), flag it in the notes but leave the quote untouched. The user can decide whether to re-interview the client for cleaner copy.

**Never touch flagged-exempt directories.** If `ritual.config.json → exemptPaths` is set, skip those paths entirely. Default exempt: `node_modules/`, `.next/`, `dist/`, `build/`, and any path containing `defense`, `darpa`, `bbn`, `rtx`.

**Provenance-first on P1/P2.** For staleness and specificity, always check `ritual.config.json → provenFacts` before flagging. If a claim is backed by a fact in the config with a recent `verifiedAt` date, it passes even without inline proof in the content.

## Reference files

Read these when running checks — do not inline the full rules in SKILL.md:

- `references/config-schema.md` — The schema for `ritual.config.json`, with example. Read when scaffolding a new config or when a config is malformed.
- `references/checks.md` — The full rule set for all six check priorities, with examples of violations and acceptable rewrites. Read before running any check.

## Termination

After the report is emitted (and diffs applied, if fix mode), stop. Do not continue into related work. Do not call other skills or routines. Do not suggest next steps unless the user asks.
