# Bootstrap — run this in Claude Code on your Mac

Paste the prompt below into a Claude Code session **at your home directory** (`cd ~` first). It does four things in sequence:

1. Scans your Mac for repeated work patterns
2. Writes the results to `~/ritual-patterns.json`
3. Installs the Ritual skill
4. Generates a personalized first-routine recommendation based on what it found

Run time: about 5–10 minutes depending on your repo count.

---

## The prompt

Copy everything between the `===` lines into Claude Code.

```
===

You are going to help me set up Ritual — a voice-audit skill for Claude Code —
and find the best first routine to wrap around it, based on an actual scan of
my work patterns.

Work through this in four phases. Announce each phase when you start it so I
can follow along.

## Phase 1 — Pattern scan

Scan my home directory for patterns of repeated work. Sources:

- Shell history: ~/.zsh_history, ~/.bash_history (last 180 days)
- Git repos under ~/ (any directory with a .git folder, scanned recursively
  but not past 4 levels deep to stay fast)
- Recent VS Code workspaces and project folders
- Config files (JSON, YAML) — look for similar schemas across repos
- Markdown files — look for similar section headers across repos

Exclusions — never read or report on:
- /Library, /System, /Applications, /private
- node_modules, .next, dist, build, .git/objects
- Any folder or file containing: bbn, rtx, darpa, defense, classified, itar, ear
- .ssh, .aws, .gpg, .gnupg, any password manager files
- Anything with .private in the path

When you hit something uncertain, skip it. Log what you skipped.

Look for:

1. Shell commands run 10+ times in the last 90 days. Group by root command.
2. Directory structures repeated across 3+ projects (shared folder shapes).
3. File names that appear in 3+ repos (voice-lint.js, brand-config.json, etc.).
4. Commit messages that repeat 5+ times across repos.
5. JSON/YAML configs with 60%+ key overlap across different repos.
6. Markdown files with similar section structure across repos.
7. Commands that appear in sequence (A always followed by B = workflow).

Write results to ~/ritual-patterns.json with this shape:

{
  "scanned_at": "<ISO timestamp>",
  "scope": { "repos_scanned": N, "files_sampled": N, "history_days": 180 },
  "patterns": [
    {
      "id": "pattern-001",
      "name": "short human name",
      "category": "command|directory|file|commit|schema|workflow",
      "frequency": N,
      "examples": ["..."],
      "confidence": "high|medium|low",
      "automation_candidate": "routine|skill|both|neither",
      "proposed_trigger": "scheduled|api|github|manual",
      "estimated_time_saved_per_month_minutes": N,
      "notes": "why this is interesting"
    }
  ],
  "top_5_recommendations": [
    {
      "pattern_id": "pattern-001",
      "rank": 1,
      "rationale": "why this is #1 to automate",
      "implementation_sketch": "2-3 sentences on how"
    }
  ],
  "skipped": [
    { "path": "...", "reason": "..." }
  ]
}

Print the top 5 to the console when done.

## Phase 2 — Install Ritual

Clone the Ritual repo into ~/code/ritual (or wherever I keep my tools —
ask me if you're not sure):

  git clone https://github.com/whystrohm/ritual.git ~/code/ritual

Then build and install the skill:

  cd ~/code/ritual
  ./scripts/install.sh

Tell me to install the resulting dist/ritual-voice.skill via
Claude Code → Settings → Skills → Install Skill.

## Phase 3 — Scaffold a config for my primary brand

Based on what you found in Phase 1, identify my primary brand or project
(the one with the most activity, recent commits, or shared structure). Ask
me to confirm before proceeding.

Then scaffold a ritual.config.json at the root of that repo. Start from
~/code/ritual/examples/minimal/ritual.config.json and fill in:

- brand.name — based on the repo name or package.json
- canonicalNames — extract names that appear repeatedly in content files
- voice.examples — pick 3 real sentences from existing README or content
  that sound like the brand's voice (don't invent them)
- provenFacts — leave empty. I will populate this manually. Set
  staleness.metricsRequireVerification to false for now.
- exemptPaths — add any defense/regulated paths you detected in Phase 1

Show me the scaffolded config before writing it. I will edit it with you.

## Phase 4 — Recommend my first routine

Using the top 5 patterns from Phase 1 and what you now know about my primary
brand, recommend one routine to build first. Specifically:

- Which pattern does it automate?
- What trigger (scheduled, API, GitHub)?
- What's the routine prompt? (draft it, ready to paste into /schedule)
- What repos should be attached?
- Expected monthly time saved based on the pattern frequency?

Do not create the routine yourself. Show me the draft and let me create it
through the Claude Code UI.

## Output

When you're done with all four phases, give me a summary:
- Phase 1: top 5 patterns found, total monthly time savings if all were automated
- Phase 2: confirmed skill installed (yes/no)
- Phase 3: config scaffolded at <path>
- Phase 4: first routine recommendation with the paste-ready prompt

Keep the summary tight. Five sentences or fewer per phase.

===
```

## What to do after

1. **Review `~/ritual-patterns.json`.** This is gold. Even the patterns you don't automate are useful to know about.

2. **Sanitize before sharing.** The `skipped` section tells you what was avoided. If anything in `patterns[]` mentions a file or command you don't want public, remove it before contributing examples back to the Ritual repo.

3. **Create the first routine.** Take the Phase 4 draft, paste it into Claude Code → Code → Routines → New routine → Remote. Attach the repos. Set the schedule. Fire it once manually before letting it run on schedule.

4. **After two weeks of use:** re-run Phase 1 only. Compare the new patterns against the old. What's still repetitive? That's your second routine.

## If something breaks

- **The scan takes too long.** Add tighter exclusions to Phase 1. Cut history to 90 days.
- **Too many false-positive patterns.** Raise the frequency threshold (10+ → 25+ for commands, 3+ → 5+ for repos).
- **The config scaffold misses something.** Edit it. The config is yours — the skill just reads it.
