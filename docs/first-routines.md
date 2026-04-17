# First-Routine Archetypes

When the [bootstrap scan](bootstrap.md) finishes, it ranks automation candidates and classifies each by **execution context**:

- **Claude Code trigger** — remote agent, runs in Anthropic's cloud on a cron schedule, operates on git-hosted repos, can use MCP connectors. Created at [claude.ai/code/scheduled](https://claude.ai/code/scheduled). This doc covers these.
- **GitHub Actions** — event-driven inside a specific repo. Lives in `.github/workflows/`. See [`docs/routines.md`](routines.md) for a ritual-voice example.
- **Local cron / launchd** — needs local files, scripts, or tools. Lives on your Mac in `~/Library/LaunchAgents/` or `crontab`. Out of scope for Ritual's drafting — the scan will flag the pattern and point you at the right tool.

Before building any of these, read [`how-routines-work.md`](how-routines-work.md) so you understand what a remote agent can and cannot do. Especially: **it has no access to your local machine, so any routine that needs local files is not a Claude Code trigger.**

Each archetype below is a full trigger prompt, ready to paste. Each ships with `suggest` mode — auto-fix never runs unsupervised.

---

## Archetype 1 — Voice sweep (content operator) ✓ Claude Code trigger

**When the scan recommends this:** You edit markdown/MDX across 3+ repos. Shared patterns include `brand-config.json` or similar. Shell history shows `git status → edit → git diff → commit` sequences on content files 15+ times a month per repo.

**Cron:** `0 10 * * 1` (6:00 AM America/New_York Monday; UTC 10:00).

**Repos:** Every brand repo with a `ritual.config.json`.

**MCP connectors:** None required.

**What it does:** Clones each attached repo, runs `ritual-voice` in `suggest` mode on content, opens one draft PR per repo with fixes. Posts a single summary to the run output.

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

**First-run expectation:** On a mature content repo, expect 5–15 violations on the first sweep. Most will be P3/P4 accumulated hype words. Signal-to-noise improves after a few passes as the config stabilizes.

---

## Archetype 2 — Fact freshness digest ✓ Claude Code trigger

**When the scan recommends this:** You have a mature `ritual.config.json` with 20+ `provenFacts` entries. Scan shows content files updated more often than the facts behind them.

**Cron:** `0 13 * * 1` (9:00 AM America/New_York Monday; UTC 13:00).

**Repos:** The single repo containing the `ritual.config.json` you want audited.

**MCP connectors:** None required for the base version. Add Gmail if you want the digest mailed; add Notion if you want it written to a page.

**What it does:** Walks `provenFacts`, marks any fact older than `staleness.maxAgeDays` as due for re-verification, and outputs a digest. Does not touch content. Does not modify the config. Reminder routine, not an edit routine.

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

**First-run expectation:** You'll immediately see which facts have aged past `maxAgeDays`. Pair the trigger with a 15-minute weekly slot to re-verify flagged facts against their sources and update the config.

---

## Archetype 3 — Dependency + security digest ✓ Claude Code trigger

**When the scan recommends this:** You maintain 5+ repos with `package.json` / `requirements.txt` / `go.mod`. Scan shows dependency bumps happening manually and inconsistently. No GitHub Actions handling it yet.

**Cron:** `0 14 * * 1` (10:00 AM America/New_York Monday; UTC 14:00).

**Repos:** Every active code repo you want tracked.

**MCP connectors:** None required.

**What it does:** Clones each attached repo, reads the lockfile and manifest, checks for outdated packages and known advisories. Opens one grouped draft PR per repo with safe patch-level bumps. Flags major-version bumps in the summary without applying.

```
## Context Reset
Disregard prior conversation state. Your scope is defined entirely below.

## Task
For each attached repo:

1. Detect the package manager (npm, pnpm, yarn, pip, poetry, go modules).
2. Read the manifest and lockfile.
3. Identify dependencies where the installed version is behind the latest
   non-major release.
4. Identify any dependencies flagged in the project's security advisories
   (npm audit, pip-audit, govulncheck).
5. For patch-level and safe minor bumps, apply them and open a single
   draft PR titled "Dependency sweep [YYYY-MM-DD]" with the lockfile update.
6. For major-version bumps, list them in the summary but do not apply.
7. For security advisories, note them at the top of the PR body with
   severity and remediation path.

## Rules
- One draft PR per repo. Never merge.
- Never commit a major-version bump.
- Skip repos with no lockfile (likely boilerplate or empty).
- If the repo has Dependabot or Renovate already active, skip it and
  note "handled by existing bot" in the summary.

## Termination
After the summary is posted, stop.
```

**First-run expectation:** Use this only on repos NOT already covered by Dependabot/Renovate. Running two dependency updaters on the same repo creates noise.

---

## Archetype 4 — Content calendar sync ✓ Claude Code trigger

**When the scan recommends this:** You track a content calendar in Notion, Google Sheets, or a markdown file. Scan shows a repeated Sunday/Monday pattern of "check what's shipping this week" manual reviews.

**Cron:** `0 23 * * 0` (7:00 PM America/New_York Sunday; UTC 23:00).

**Repos:** The repo containing the content calendar (if a markdown file) OR none (if the calendar lives in Notion/Drive).

**MCP connectors:** **Notion** if the calendar is a Notion page. **Google Drive** if it's a sheet. Both are already on your connected-connectors list.

**What it does:** Pulls the next 7 days of scheduled content from the calendar source. Checks each scheduled item for (a) a draft existing in the attached repo, (b) required assets linked, (c) any blockers flagged. Emits a "week ahead" digest.

```
## Context Reset
Disregard prior conversation state. Your scope is defined entirely below.

## Task
Pull scheduled content items for the next 7 days from the Notion
database at [NOTION_DATABASE_URL] (or the attached Drive sheet at
[SHEET_URL] — one or the other, not both).

For each scheduled item:
1. Check if a draft exists in the attached repo under /content or
   /drafts. Match by the item's slug or title.
2. Check if required assets (hero image, video, OG image) are linked
   in the item's properties.
3. Flag any item tagged "blocked" or with empty required fields.

Output a digest:

## Week ahead — [this week's dates]

### Ready to ship ([N])
- [date] · [title] · draft: ✓ · assets: ✓

### Needs drafts ([N])
- [date] · [title] · missing draft

### Needs assets ([N])
- [date] · [title] · missing [asset type]

### Blocked ([N])
- [date] · [title] · reason from calendar

## Rules
- Do not edit the calendar.
- Do not create drafts.
- The digest is the entire output.

## Termination
After the digest is emitted, stop.
```

**First-run expectation:** The first digest tells you what's about to ship late. Act on the blockers manually; the trigger is a weekly alarm clock, not a doer.

---

## Archetype 5 — Inbox triage (Gmail-backed) ✓ Claude Code trigger

**When the scan recommends this:** Your shell history shows frequent pivots between email and code (dozens of `open mail.app` or browser tabs). Claude Code memory indicates "check emails" as a recurring task. You use Gmail.

**Cron:** `0 11 * * 1-5` (7:00 AM America/New_York weekdays; UTC 11:00).

**Repos:** None required.

**MCP connectors:** **Gmail** (connected on your account).

**What it does:** Reads unread inbox threads from the last 24 hours. Summarizes each thread. Classifies into action-required / informational / discardable. Emits a digest.

```
## Context Reset
Disregard prior conversation state. Your scope is defined entirely below.

## Task
Using the Gmail MCP connector, list unread threads in the inbox from
the last 24 hours (label: UNREAD, in:inbox, newer_than:1d).

For each thread:
1. Read the latest message.
2. Classify:
   - "action-required" — a human is waiting on me
   - "informational" — FYI, no action
   - "discardable" — marketing, automated, ignorable
3. Summarize the thread in one sentence.

Emit a digest grouped by classification, newest first:

## Inbox triage — [YYYY-MM-DD]

### Action required ([N])
- [From] · [subject] · [1-sentence summary]
- ...

### Informational ([N])
- [From] · [subject] · [1-sentence summary]

### Discardable ([N])
- (just a count)

## Rules
- Do not reply, archive, label, or mark anything as read.
- Do not open attachments.
- The digest is the entire output.

## Termination
After the digest is emitted, stop.
```

**First-run expectation:** Expect noise on day one. Tune the prompt after a week — "treat these senders as automated," "always elevate threads from these domains," etc.

---

## Archetype 6 — Deploy verification (GitHub Actions, NOT a Claude Code trigger)

**Why not a Claude Code trigger:** Event-driven (fires on push to main). Claude Code triggers are cron-based. This pattern belongs in `.github/workflows/`.

Skeleton workflow:

```yaml
# .github/workflows/deploy-guard.yml
name: Deploy Guard
on:
  push:
    branches: [main]
jobs:
  guard:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run ritual-voice pre-deploy
        run: |
          # Clone Ritual, run ritual-voice against content, fail CI if verdict is republish
          ...
```

Full example lives in [`docs/routines.md`](routines.md). If the scan recommends this, the bootstrap's Phase 4 output will tell you to set it up in GitHub Actions, not in Claude Code's trigger UI.

---

## Archetype 7 — Local filesystem digest (launchd, NOT a Claude Code trigger)

**Why not a Claude Code trigger:** Needs to read local filesystem (`~/brands/*/renders/`, local tool output, local notification script). Claude Code triggers run remotely with no local access.

If the scan recommends this pattern, the bootstrap will point you at:

- `launchctl` + a `.plist` in `~/Library/LaunchAgents/`
- A Python or shell script that does the filesystem walk
- Optional iMessage via AppleScript for notifications

The bootstrap will not draft the plist or script. It will tell you that the pattern belongs in local automation and link to Apple's launchd docs. This is honest scoping — forcing a Claude Code trigger for this pattern does not work.

---

## How to pick between these

Read `~/ritual-patterns.json → top_5_recommendations[0]`. Match the shape:

- Operates on git-hosted content, runs on cadence → Archetype 1, 2, or 3
- Needs external service (Notion, Gmail, Drive) → Archetype 4 or 5
- Fires on repo events (PR open, push) → Archetype 6 (GitHub Actions)
- Needs local machine access → Archetype 7 (launchd)

If your top recommendation doesn't match any of these shapes, open an issue with the pattern JSON — that's signal that a new archetype should exist.

## What not to routine-ify (all contexts)

**Don't wrap fix mode in a scheduled routine.** Fix mode applies rewrites directly. A scheduled trigger that auto-fixes content is a supply-chain vector into your published copy. Archetype prompts here default to `suggest` mode for that reason.

**Don't stack multiple Ritual triggers on the same repo.** One trigger per repo maximum. Different cadences for different file types? Use different globs in the same prompt, not different triggers.

**Don't routine-ify the bootstrap scan.** The scan is a one-shot. Your work patterns don't change fast enough to justify a weekly re-scan, and scheduling the scan burns routine slots on low-change signal.

**Don't routine-ify anything touching `exemptPaths`.** If the config tells the skill not to read a path, the routine should never even try. This is enforced by the skill, but double-check your prompts don't override it.
