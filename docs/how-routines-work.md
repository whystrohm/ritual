# How Claude Code Routines actually work

Ritual drafts routines. This doc explains how to take that draft and turn it into something that runs on a schedule in Claude Code. If you have never built a routine before, read this before Phase 4 of the bootstrap hands you a prompt.

## What a routine actually is

A Claude Code routine — called a "scheduled trigger" in the product — is a **remote Claude Code agent** that runs in Anthropic's cloud on a cron schedule. It is not a local cron job. It is not a background process on your Mac. It is a full Claude Code session that spawns in the cloud, does the work, and shuts down.

What this means in practice:

- **Remote, not local.** The agent has no access to your Mac. No local files, no local environment variables, no launchd, no cron. It cannot read `~/.zshrc` or invoke `~/.claude/notify-yuri.sh`.
- **Git-hosted repos only.** You attach one or more GitHub repos when you create the trigger. The agent clones them fresh in its sandbox on every run.
- **MCP connectors for external systems.** If the routine needs Gmail, Google Drive, Notion, Datadog, Slack, or any other service, you connect the corresponding MCP connector at [claude.ai/settings/connectors](https://claude.ai/settings/connectors) first.
- **Cron schedule, min 1 hour.** Expressions are in UTC. Sub-hourly (`*/30 * * * *`) will be rejected.

## The three execution contexts

Not every automation Ritual recommends belongs in a Claude Code trigger. Some belong in GitHub Actions. Some belong in local cron or launchd. The bootstrap scan labels each recommendation so you know which context fits:

| Context | When it's right | How to build it |
|---|---|---|
| **Claude Code trigger** | Work on git-hosted content. Runs on a cadence (daily, weekly). Uses MCP connectors for external services. | `/schedule` command or [claude.ai/code/scheduled](https://claude.ai/code/scheduled) |
| **GitHub Actions** | Event-driven (on PR open, on push to main, on release). Lives inside the repo. | Add `.github/workflows/*.yml` to the target repo. `docs/routines.md` has an example for ritual-voice. |
| **Local cron / launchd** | Needs local files, local scripts, or local tools (ffmpeg, custom shell scripts, iMessage). Runs on your machine. | `launchctl` + a `.plist` in `~/Library/LaunchAgents/` |

Ritual focuses on Claude Code triggers because they're the new Claude Code feature and the highest-leverage option for most operators. But when the scan recommends something that belongs in one of the other two contexts, it says so.

## The exact 4-click path — create a Claude Code trigger

You have a drafted routine prompt from Phase 4. Here's how it becomes a running trigger.

**Step 1 — Open a new Claude Code session.** Anywhere. The trigger does not need to be created from a specific directory.

**Step 2 — Type `/schedule`.** Claude Code will load the schedule skill and walk you through it interactively. If you prefer the web UI, go to [claude.ai/code/scheduled](https://claude.ai/code/scheduled) and click "New trigger."

**Step 3 — Paste the drafted prompt from Phase 4 into the `prompt` field.** The prompt is the entire agent instruction set. It must be self-contained — the remote agent starts with zero context, so do not edit the prompt down to a one-liner. Paste it whole.

**Step 4 — Fill in the rest:**

- **Name** — Descriptive. "Weekly voice sweep across all brand repos" is better than "ritual-1."
- **Cron expression** — Times are in UTC. Your local time converts. Example: 6:00 AM America/New_York on Monday = `0 10 * * 1` (10am UTC). Claude Code will help with this conversion.
- **Repos** — Attach the GitHub repos the agent should clone. One or more. The agent runs once per trigger; it can act on all attached repos in sequence inside that single run.
- **MCP connectors** — Attach any connectors the routine needs (Gmail, Notion, Google Drive, etc.). These come from your [connected claude.ai connectors](https://claude.ai/settings/connectors).
- **Model** — Default: `claude-sonnet-4-6`. Switch to opus for harder routines (codebase-wide refactors, complex analysis). Haiku is cheaper for trivial routines.
- **Enabled** — Leave enabled. You will test manually first.

## Test before trusting — always

**Don't let a new trigger run on schedule before you've fired it once manually.**

Before setting the cron live:

1. Save the trigger with `enabled: true`, but you're not going to wait for the schedule.
2. From the [scheduled triggers page](https://claude.ai/code/scheduled), click the trigger.
3. Hit "Run now." This fires the trigger immediately and runs the full agent end-to-end, same way it will when cron fires.
4. Review the output. Did the agent do what you expected? Did it open the right PRs, produce the right summary, respect the exempt paths?
5. If yes, the schedule is trusted. Walk away.
6. If no, update the prompt. Re-run manually. Repeat until it's clean.

This is the most common mistake people make with triggers — they create one, wait a week, wake up to fifty bad PRs across their repos. Fire once manually, review, then schedule.

## What you'll see when it runs

When a scheduled trigger fires on its cron, you see the results in three places:

- **Your repo** — Draft PRs (if the routine opens PRs), new commits (if the routine commits directly), inline PR comments (if the routine reviews an existing PR)
- **The scheduled triggers page** — Run history, logs, status (success/failed), output snapshots
- **Claude.ai notifications** — Depending on your settings, a push notification or email when a run completes or fails

For `ritual-voice` specifically, the default routine pattern opens one draft PR per brand repo with voice fixes applied. No auto-merge, no force-push. You merge the PRs manually after review.

## Usage limits

Triggers count against your Claude Code daily run limit:

| Plan | Triggers per day | Notes |
|---|---|---|
| Pro | 5 | Room for one daily sweep + a few hourly checks |
| Max | 15 | Daily sweeps across multiple brand repos + ad-hoc |
| Team / Enterprise | 25+ | Custom |

A single trigger counts as one run regardless of how many repos are attached. If you run out, scheduled triggers are rejected until the window resets. Enable metered overage in Settings → Billing if you need unpredictable volume.

## Troubleshooting

**The agent can't read my local file.**
Expected. The agent runs remotely. If you need something from local, commit it to the attached repo first.

**The agent can't connect to my service (Slack, Datadog, whatever).**
You probably need to attach an MCP connector. Go to [claude.ai/settings/connectors](https://claude.ai/settings/connectors), connect the service, then update the trigger and attach the new connector.

**The trigger ran but didn't do anything.**
Check the run output on the triggers page. The most common cause is a prompt that lets Claude say "no changes needed" when it should have done work. Tighten the prompt to be directive ("open a PR if N violations found") not permissive ("consider opening a PR").

**The trigger fires at the wrong time.**
Double-check the cron expression is in UTC. 9am ET is not `0 9 * * *`. It's `0 13 * * *` (EST) or `0 14 * * *` (EDT).

**I need to delete a trigger.**
The API does not support delete. Go to [claude.ai/code/scheduled](https://claude.ai/code/scheduled), click the trigger, and delete from the UI.

## When not to use a Claude Code trigger

Triggers are the right tool for git-hosted, cloud-friendly work on a cadence. They are the wrong tool for:

- **Local filesystem operations** — use launchd / cron
- **Event-driven repo automation** (on PR open, on push) — use GitHub Actions
- **Real-time webhooks** — build a small server, not a trigger
- **Work that needs files outside any git repo** — commit them first, or move to local automation

Ritual's first-routine recommendations call out when something belongs in a different context so you're not forcing a fit.

## Next steps after creating your first trigger

1. Let it run on schedule for one week.
2. Review what it produced.
3. Run the bootstrap scan again and compare `~/ritual-patterns.json` against the first run. What's still repetitive? That's your second routine candidate.
4. Ship that one. Repeat.

One trigger per week beats five triggers in a day. Automation is load-bearing — every routine needs a human to maintain it, so the floor on routine count is higher than it looks.
