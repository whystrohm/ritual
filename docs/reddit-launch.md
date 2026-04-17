# Reddit Launch Post

Three variants — r/ClaudeAI (primary), r/Entrepreneur, r/SideProject. The primary variant is written for the Claude Code / routines audience, because routines are the fresh news hook and that's the subreddit where "what's my first routine?" is actually a live question.

## Why this tone

Reddit smells marketing from three comments away. The post has to be a story about a real problem with a real fix, not a product launch. Rules followed:

- First person, past tense. "I kept shipping..." not "Users experience..."
- Concrete examples of the class of failure, not one dramatized incident someone can fact-check against a live site
- Show the thing, don't pitch the thing
- Link to the repo once, at the end
- No emoji, no bold headers in the body, no call to action
- Admit what it doesn't do

---

## For r/ClaudeAI (primary)

**Title:** I built a Claude Code skill that reads my shell history and drafts my first routine for me. Here's what it found.

**Body:**

Routines launched and I sat there for 20 minutes trying to figure out what my first one should be. Scheduled scan? PR review? Pre-publish gate? The feature is powerful, the starting point is blank. I run content infrastructure across 11 founder-led brands, so I knew I had repeated work — but the part I actually repeat versus the part that just feels busy is hard to see from inside the work.

So I wrote a scan. Not a product. A paste-in Claude Code prompt that reads my shell history (last 180 days), inventories every git repo under ~/, finds config files with 60%+ schema overlap across 3+ repos, and flags command sequences that run together 5+ times. Then it writes the findings to a JSON file and ranks the top 5 automation candidates by frequency times time cost times feasibility.

It took five minutes to run. The top recommendation was exactly the thing I had been doing manually three days a week: sweep every brand repo for stale stats, drift in voice, and inconsistent client names. Scan found 47 sessions in 90 days where I manually opened a content file, ran git status, made edits, and committed. That's the ritual. That's what the routine should be.

So I built the skill that backs it — a voice audit that reads a ritual.config.json per brand (verified facts with sources and dates, canonical name maps, banned words, voice examples) and flags content against six priorities:

1. Stale stats — numbers that don't match your verified facts, or facts older than 30 days
2. Missing specificity — claims without numbers, proof, or named subjects
3. AI-slop markers — em-dash density, "it's not X — it's Y," delve, tapestry
4. Hype words — comprehensive, seamless, revolutionary
5. Name/attribution mismatches — the classic nickname-vs-legal-name inconsistency in one file
6. Generic corporate voice — passive headlines, hedged claims

The wedge that matters: the config is the brain, the skill is the mechanism, the routine is the scheduler. The skill has zero brand-specific logic. You drop a config in any repo and it works. The config schema is the whole contribution surface area.

The scan + skill together is what I'm calling Ritual. The scan is a paste-in prompt you run once. The skill is a .skill file you install once. The routine you build from the scan's recommendation is yours — tailored to what your machine actually does.

What's working in v0.1: the priority ordering is editorially correct. Misleading beats ugly. Most voice linters lead with style (hype words, passive voice). This one leads with provenance — does the claim have a receipt? If yes, passes. If no or stale, flagged.

What it doesn't do: write copy for you, replace an editor, verify facts against the live internet, or auto-fix in scheduled runs. Garbage config in, garbage audit out. The config is the work.

Repo: https://github.com/whystrohm/ritual
License: MIT
Works with: any Claude Code Pro/Max/Team/Enterprise plan

If you run the scan and the top recommendation is a routine shape that doesn't match anything in the repo, open an issue with the JSON — that's signal that a new archetype should exist. I documented four archetypes so far (voice sweep, PR review, pre-publish gate, fact-freshness audit) based on my own patterns plus what I've seen in consulting work.

Happy to answer questions. If you build on it, I'd love to see what your scan's top 5 looked like.

---

## For r/Entrepreneur

**Title:** I spent 20 minutes staring at Claude Code's new routines feature trying to figure out what to automate first. Then I wrote a scan.

**Body:**

If you run more than one thing — your company, a side project, a freelance book of work — you know the tax. You repeat yourself. You catch yourself running the same five commands in the same three folders on the same two days every week. The usual answer is "just be more careful" or "hire someone." Both break the moment you scale past one operator watching one domain.

Claude Code released routines last month. Scheduled Claude sessions that run without you. The obvious next question: what's the right first routine? I stared at the feature blank for 20 minutes.

So I wrote a scan. It reads my shell history (last 180 days), inventories my git repos, finds config files with overlapping schemas across repos, and ranks what I repeat most by how much time it would save to automate. Top result on my machine: sweep every brand repo for stale stats, inconsistent client names, and AI-generated slop in copy. 47 repeat sessions in 90 days. That's the routine I should have built first.

I then built the skill that backs the routine: a voice auditor that reads a per-brand config file with verified facts (each claim has a source and a date), canonical names, and banned words. The skill runs inside any Claude Code session, the routine runs it nightly across every repo, and draft PRs show up with fixes in the morning. Never auto-merge. Human stays in the loop.

The philosophical shift: instead of "check copy before shipping," the system is "every claim needs a receipt." The receipt is the entry in provenFacts. No receipt, flagged. Stale receipt (over 30 days), flagged. Receipt that doesn't match the claim, flagged.

The wedge isn't the voice audit, though. The wedge is the scan. Almost nobody has a clear picture of what they actually repeat versus what they just feel busy doing. The scan shows you, in JSON, with frequencies, and recommends what to automate first. The voice audit is just my top result.

Repo is public, MIT licensed: https://github.com/whystrohm/ritual

This isn't a product. I'm not selling anything here. Just sharing the pattern because "be more careful" and "what's my first routine?" are the two largest silent taxes on solo operators right now.

---

## For r/SideProject

**Title:** Ritual — a Claude Code skill + scan that tells you what to automate first, then ships the voice audit most content operators should build

**Body:**

Small one. Open source. Solves a specific problem.

The problem: Claude Code routines just shipped, and most people don't know what their first routine should be. The feature is powerful, the starting point is blank.

The build: a paste-in Claude Code prompt that scans your shell history + git repos, finds repeated patterns, ranks automation candidates, and recommends your first routine. Then a skill (ritual-voice) that handles the #1 recommendation for most content operators — a voice audit with stale-stat, specificity, and AI-slop detection against a per-brand config.

The interesting part: the config is where all brand logic lives. The skill has zero brand-specific code. You can point it at any repo with any config and it works. The scan's recommendation is tailored to your actual patterns, not a generic "here's what everyone should automate" list.

The unlock: with routines (which just shipped), the scan's recommendation becomes a paste-ready prompt. You paste it into /schedule, attach your repos, set a cadence, and wake up to draft PRs with fixes.

Repo: https://github.com/whystrohm/ritual
License: MIT

Not looking for stars — looking for people to run the scan and contribute either (a) their top-5 recommendations so I can document more routine archetypes, or (b) example configs for their niche (SaaS, DTC, healthcare, real estate, whatever).

---

## Launch sequence

**Day 1 (Friday 9am ET):** Post to r/ClaudeAI. Best audience for the scan-and-routines mechanic. The title does the work.

**Day 3 (Monday):** Post to r/Entrepreneur with the entrepreneur-angled variant. Different enough to not feel like cross-posting spam.

**Day 5 (Wednesday):** Post to r/SideProject with the short variant.

**Day 7:** Post on X/LinkedIn: numbers post. "Ritual hit N stars / M scans run / Z example configs in 7 days. Here's what the scans surfaced across different operator types." Numbers posts outperform launch posts.

**Day 10:** Follow-up "how it went" post on r/ClaudeAI with actual telemetry — which archetypes got run, what the average scan surfaced, false-positive rate from your own use. Real data post-launch always outperforms the launch post itself.

**Don't post to:** r/Marketing, r/SaaS, r/startups. Wrong audience for this framing — too sales-hostile, will read as pitch.

## What to do in the comments

- Answer questions with specifics, not pitches
- If someone posts their scan's top 5, respond with a specific routine prompt drafted against their pattern — proves the scan-to-routine flow works live in the thread
- If someone asks for a feature, tell them what the config would look like to do it (proves the config model works)
- If someone says "this is just a prompt" — agree. It is. That's the point. The leverage is in the priority ordering and the config schema, not magic.
- If someone asks "why not just use Grammarly/Hemingway/X" — explain: those check style, this checks claims against verified facts and surfaces automation candidates from your actual shell history. Different problems.
- Don't argue with trolls. One polite correction, then disengage.

## Success criteria

- r/ClaudeAI post: >50 upvotes, >10 substantive comments, 3+ people post their scan output
- Repo: >30 stars in week 1, at least 1 example-config PR from the community, at least 1 scan-top-5 contribution in issues
- Traffic to whystrohm.com: not the goal. If it happens, nice. Don't optimize for it.
