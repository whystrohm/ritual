# Routines Integration

Ritual is a skill. Claude Code routines are the scheduler. Together, you get voice enforcement that runs without you.

## What routines add

Without a routine, Ritual runs when you ask it to. You open Claude Code, say "run ritual-voice on this," and get a report. That's useful for one-off audits.

With a routine, Ritual runs on a schedule or a trigger, against all your repos, without you present. You wake up to a set of draft PRs with voice fixes ready to review.

## Routine types for Ritual

### Scheduled sweep (most common)

Runs daily or weekly across every repo. Catches drift before anyone notices.

Paste the following into `/schedule` in any Claude Code session, or create it at [claude.ai/code/routines](https://claude.ai/code/routines):

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

**Trigger:** Scheduled, daily at 6:00 AM local. Runs before you start your day; PRs ready with coffee.

**Repos to attach:** Every brand repo you want audited.

### GitHub PR review

Runs on every new pull request. Reviews the diff before a human does.

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

**Trigger:** GitHub, on `pull_request.opened` and `pull_request.synchronize`.

### API-triggered pre-publish check

Fires from your CMS, your CD pipeline, or a manual webhook. Use this to block publishes of bad copy.

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

**Trigger:** API. POST with `{"text": "<url or content>"}` to the per-routine endpoint.

## Usage limit math

Ritual routines count against your Claude Code daily run limits:

- **Pro:** 5 routine runs/day — room for one daily sweep plus a few API checks
- **Max:** 15 routine runs/day — comfortable for daily sweeps across multiple brand repos plus ad-hoc API checks
- **Team/Enterprise:** 25 routine runs/day

A single sweep routine counts as one run regardless of how many repos are attached. API triggers count as one run per invocation.

If you run out of routine slots, scheduled sweeps will be rejected until the window resets (or you can enable metered overage in Settings → Billing).

## What not to routine-ify

**Don't routine-ify fix mode.** The skill can apply fixes directly when invoked manually. Don't let a routine do it unsupervised. Routines should open PRs; humans should merge them.

**Don't routine-ify content generation.** Ritual is an audit skill. If you're building a routine that writes copy, that's a different skill (and not yet built).

**Don't routine-ify regulated content.** If the content is in `exemptPaths`, it shouldn't be in a routine. Full stop.

## Testing a routine before trusting it

1. Build the routine.
2. Fire it manually (don't attach a schedule yet).
3. Review the output. Does it catch what you expected? Does it flag false positives?
4. Tune the skill's `ritual.config.json` — not the routine prompt.
5. Fire manually again.
6. Once you trust it, add the schedule.

The routine prompt should be almost static. The brand-specific logic lives in the config, where it belongs.
