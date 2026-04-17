# First-Routine Archetypes

When the [bootstrap scan](bootstrap.md) finishes, it ranks automation candidates by frequency × time cost × feasibility. The top recommendation is usually one of the four archetypes below. Each archetype is a full Claude Code routine prompt, ready to paste into `/schedule` or the [routines UI](https://claude.ai/code/routines).

Pick the one that matches your top recommendation, fill in the bracketed values with what the scan found, and ship it. Each archetype has been written for `suggest` mode — auto-fix is deliberately not in any of these prompts. See [`limitations.md`](limitations.md) for why.

---

## Archetype 1 — Voice sweep (content operator)

**When the scan recommends this:** You edit markdown/MDX across 3+ repos, the shared pattern is `brand-config.json` or similar, and your shell history shows `git status → edit → git diff → commit` sequences on content files 15+ times a month per repo.

**Cadence:** Scheduled, daily at 6:00 AM local.

**What it does:** Sweeps every attached brand repo, runs `ritual-voice` in `suggest` mode on all content, opens one draft PR per repo with violations found, posts a single summary.

```
## Context Reset
Disregard prior conversation state. Your scope is defined entirely below.

## Task
For each attached repo, invoke the ritual-voice skill.

1. Locate ritual.config.json. If missing, skip the repo and note it in the summary.
2. Run ritual-voice in "suggest" mode on all content files in:
   - /content, /blog, /posts, /case-studies (markdown and MDX)
   - /app, /pages (extract string literals and JSX text only)
   - README.md and any /docs markdown
3. For each repo with P1 or P2 violations, open a draft PR titled
   "Ritual sweep [YYYY-MM-DD]: [N] fixes" with suggested edits applied.
4. For repos with only P3–P6 violations, open a draft PR only if
   total violations exceed 3. Otherwise just log them in the summary.
5. Never auto-merge. All PRs stay as drafts.
6. Post a summary listing: repos scanned, repos clean, repos with PRs
   opened, repos skipped (and why).

## Rules
- Respect ritual.config.json → exemptPaths on every repo.
- Never touch directories containing defense, darpa, bbn, rtx, classified.
- Preserve direct quotes from named speakers — flag in notes, don't edit.

## Termination
After the summary is posted, stop. Do not continue into related work.
Do not call other routines.
```

**Attach:** Every brand repo you want audited.

**First-run expectation:** On a mature content repo, expect 5–15 violations on the first sweep. Most will be P3/P4 (hype words, AI-slop) that accumulated. The signal-to-noise ratio improves after the first few passes as the config stabilizes.

---

## Archetype 2 — PR voice review (team repo)

**When the scan recommends this:** You review PRs that include content changes 5+ times a week, and your history shows comments on the same class of issue repeatedly (hype words, passive voice, stale numbers).

**Cadence:** Triggered, on `pull_request.opened` and `pull_request.synchronize`.

**What it does:** Runs on every PR. Reads the diff. Leaves inline comments on violations. Adds a summary comment at the top of the PR with a violations-by-priority table. Never approves, never requests changes — comments only.

```
## Context Reset
Disregard prior conversation state. Your scope is defined entirely below.

## Task
A pull request has just been opened. Load the diff and invoke the
ritual-voice skill on every file changed in the PR that matches:
- *.md, *.mdx
- *.tsx, *.jsx (extract string literals only)
- README changes

Run in "flag" mode. For each violation, leave an inline review comment
on the affected line with:
- The priority (P1–P6)
- The violation quoted
- A suggested fix (if P3 or P4; higher priorities require human judgment)

After all inline comments are posted, add a single summary comment at
the top of the PR with a table of violations by priority.

If the PR has zero violations, add a single comment: "Ritual: clean."

## Rules
- Do not approve or request changes. You are commenting only.
- Do not comment on files outside the PR's diff.
- Do not comment on files in ritual.config.json → exemptPaths.

## Termination
After the summary comment is posted, stop.
```

**Attach:** The single repo whose PRs you want reviewed.

**First-run expectation:** Your next PR will get comments. Decide whether the comments are useful. If too noisy, tune `ritual.config.json → voice.bannedWords` and `bannedPhrases` to fit the brand's actual standards. The routine prompt should not change — the config does the work.

---

## Archetype 3 — Pre-publish gate (CMS or CI integration)

**When the scan recommends this:** You have a CMS or a content pipeline that pushes posts to production, and your history shows repeated "pulled and fixed after publishing" patterns (`git revert`, `git commit -m "typo"`, `git commit -m "fix stat"`).

**Cadence:** API-triggered. Call it from your CMS publish button, your CI pipeline, or a manual webhook.

**What it does:** Accepts a URL or content block. Returns structured JSON — `pass`, `warn`, or `block`. Designed for inline use in a publish pipeline.

```
## Context Reset
Disregard prior conversation state. Your scope is defined entirely below.

## Task
The trigger payload contains a URL or a block of content to audit.
Invoke the ritual-voice skill in "flag" mode on that content.

If any P1 or P2 violations are found, respond with:
{ "verdict": "block", "violations": [...], "reason": "..." }

If only P3–P6 violations are found, respond with:
{ "verdict": "warn", "violations": [...] }

If clean, respond with:
{ "verdict": "pass" }

## Rules
- The caller expects a structured JSON response.
- Do not open PRs or edit files — this is a check, not a fix.
- Respond within 60 seconds or the caller will treat it as a timeout.

## Termination
After returning the JSON response, stop.
```

**Attach:** Nothing — the content comes in with the trigger.

**First-run expectation:** Calibrate thresholds. If the gate is too aggressive ("block" on every post), relax `metricsRequireVerification` to `false` until your `provenFacts` library is populated. A gate that always blocks becomes a gate that is always bypassed.

---

## Archetype 4 — Fact freshness audit (config-aware scheduled run)

**When the scan recommends this:** Your config has 20+ `provenFacts` entries and your scan shows content files being updated more often than the facts behind them. This is the "stale metric in a case study" failure mode, caught before it embarrasses you.

**Cadence:** Scheduled, weekly on Monday 9:00 AM.

**What it does:** Walks `ritual.config.json → provenFacts`. For each fact, checks `verifiedAt` against today. For facts older than `maxAgeDays`, sends a digest. Does not open PRs. Does not touch content. This is a reminder routine, not an edit routine.

```
## Context Reset
Disregard prior conversation state. Your scope is defined entirely below.

## Task
Read ritual.config.json from the attached repo. Walk the provenFacts array.

For each fact:
1. Compare verifiedAt to today's date.
2. If (today - verifiedAt) > staleness.maxAgeDays, mark as due.

Emit a digest in this format:

## Fact freshness — [repo name] — [YYYY-MM-DD]

### Due for re-verification ([N] facts)
- [claim] — verified [verifiedAt], source: [source]
- ...

### Still fresh ([N] facts)
- (just a count, not a list)

## Rules
- Do not touch content files.
- Do not modify ritual.config.json.
- Do not open PRs.
- The digest is the entire output.

## Termination
After the digest is emitted, stop.
```

**Attach:** Every repo with a populated `ritual.config.json`.

**First-run expectation:** This routine is an alarm clock. Its value is in pointing you at facts that need re-verification before someone else catches that the number is stale. Pair with a manual 15-minute weekly slot to re-verify flagged facts against their sources.

---

## How to pick between these four

Run the bootstrap. Read `~/ritual-patterns.json → top_5_recommendations[0]`. Match the shape:

- **"skill+routine combo"** targeting content files with daily or near-daily edit frequency → Archetype 1
- **"GitHub routine"** on a repo where PRs frequently touch content → Archetype 2
- **"API routine"** triggered from a CMS or CI pipeline → Archetype 3
- **Pattern mentions a growing `provenFacts` list and content refresh cadence** → Archetype 4

If your top recommendation doesn't match any of these shapes, open an issue with the pattern JSON — that's signal that a new archetype should exist.

## What not to routine-ify

**Don't wrap fix mode in a routine.** The skill's fix mode is for interactive use where a human clicks "apply." A scheduled routine that auto-fixes content is a supply-chain vector into your published copy.

**Don't stack multiple Ritual routines on the same repo.** One routine per repo maximum. If you need different cadences for different file types, that's different file globs in the same routine — not different routines.

**Don't routine-ify exploration.** The bootstrap scan is a one-shot. Don't schedule it to re-scan your machine weekly — your patterns don't change that fast, and the scan surfaces your work habits which don't need repeated exposure to the model.

**Don't routine-ify anything touching `exemptPaths`.** If the config tells the skill not to read a path, the routine should never even try. This is enforced by the skill, but double-check your routine prompts don't override it.
