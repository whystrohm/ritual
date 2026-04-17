# Pattern Discovery Prompt

Run this in a Claude Code session on your Mac. It scans your home directory
for repeated work patterns and outputs candidates for routines and skills.

## What it does

1. Scans your repos, shell history, recent files, and configs
2. Identifies work you do repeatedly (the "rote" part)
3. Flags patterns that would benefit from a `rote` skill or a Claude Code routine
4. Outputs a structured `patterns.json` you can review and act on

## The prompt

Copy this into a Claude Code session at the root of your home directory:

```
I want you to scan my home directory for patterns of repeated work that
are candidates for Claude Code routines or skills.

## Scope

Scan these sources:
- Shell history: ~/.zsh_history, ~/.bash_history (last 180 days)
- Git repos under ~/: look at commit patterns, repeated file names, shared config shapes
- Recent files: VS Code workspace files, recent project folders
- JSON/YAML configs: find configs with similar schemas across repos
- Markdown files: find files with similar section headers across repos

## Exclusions

Never scan or read:
- /Library, /System, /Applications
- node_modules, .next, dist, build, .git/objects
- Any folder or file containing: bbn, rtx, darpa, defense, classified, itar, ear
- Any folder marked .private or with a .gitignore entry for the folder itself
- Password managers, keychain, .ssh, .aws, .gpg

If you encounter a file you're unsure about, skip it and log it in the
"skipped" section of the output. Err on the side of skipping.

## What to look for

1. Shell commands run 10+ times in the last 90 days. Group by command root
   (e.g., all `npm run render:*` count together). For each: the command, the
   count, the contexts (which directories it was run in).

2. Directory structures repeated across projects. If 5+ client repos all
   have /assets/logos, /content/testimonials, /config/brand-config.json —
   that's a pattern. Output the shared shape.

3. File-name patterns across repos. If voice-lint.js appears in 3+ repos,
   or brand-config.json appears in 7+ repos, flag it.

4. Git commit patterns. Look for "first 5 commits" that repeat across repos
   — these are onboarding rituals. Also look for commit messages that
   appear 5+ times across repos (the "fix the testimonial" class).

5. Markdown section patterns. If /content/testimonials.md exists in
   multiple repos with similar section headers, that's a template.

6. Config schema similarity. JSON/YAML configs with 60%+ overlapping keys
   across different repos — these are candidate shared schemas.

7. Tools invoked together. If Remotion renders are always followed by a
   specific publish command, that's a workflow, not two separate steps.

## Output

Write the result to ~/ritual-patterns.json with this structure:

{
  "scanned_at": "ISO timestamp",
  "scope": { "repos_scanned": N, "files_sampled": N, "history_days": 180 },
  "patterns": [
    {
      "id": "pattern-001",
      "name": "short human name",
      "category": "command | directory | file | commit | schema | workflow",
      "frequency": N,
      "examples": ["path or command", "..."],
      "confidence": "high | medium | low",
      "automation_candidate": "routine | skill | both | neither",
      "proposed_trigger": "scheduled | api | github | manual",
      "estimated_time_saved_per_month_minutes": N,
      "notes": "why this is interesting, what the routine/skill would do"
    }
  ],
  "top_10_recommendations": [
    {
      "pattern_id": "pattern-001",
      "rank": 1,
      "rationale": "why this is the #1 thing to automate first",
      "implementation_sketch": "2-3 sentences on how"
    }
  ],
  "skipped": [
    { "path": "...", "reason": "..." }
  ]
}

Then print to the console:
1. Total patterns found
2. Top 10 recommendations with one-line summaries
3. Estimated total monthly time savings if all top 10 were automated
4. Any gaps or blind spots you noticed during the scan
```

## After it runs

The `~/ritual-patterns.json` file is the input for everything else:

- Hand-pick 2-3 top patterns to turn into `rote` skills
- Hand-pick 2-3 top patterns to turn into Claude Code routines
- Share sanitized patterns in the GitHub repo as example discoveries

## Security note

The prompt tells Claude to skip anything sensitive. Review the output
before sharing. The `skipped` section tells you what was avoided.
Re-scan with tighter exclusions if anything in `patterns[]` looks
like it touched something it shouldn't have.
