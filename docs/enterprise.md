# Enterprise Brief

A one-page brief for the security, IT, and compliance decision-makers reviewing Ritual for use inside their organization.

## What Ritual is, technically

Ritual is a **Claude Code skill** — a `.skill` file that is a zip archive containing markdown instructions and a JSON schema reference. When invoked inside Claude Code, it causes Claude to read and analyze content files in your repository against a brand-specific configuration.

Ritual has no executable code of its own. No binary, no package install, no network daemon, no dependency tree.

The bootstrap scan is a **paste-in prompt** — a block of text you paste into Claude Code that asks Claude to read specific files in your home directory and write findings to `~/ritual-patterns.json`. It is not an installed tool; it runs once, inside your Claude Code session, on demand.

## What data Ritual reads

**`ritual-voice` (the skill):**

- Files and directories you explicitly point it at (single file, directory, pasted block, or URL)
- The brand's `ritual.config.json`
- Git history for the target file (via `git log -1 --format=%at -- <file>`) to determine freshness

It does not read anything outside the scan target. It does not open arbitrary files, traverse the filesystem, or scan siblings.

**The bootstrap scan:**

- `~/.zsh_history`, `~/.bash_history` (last 180 days, configurable)
- `.git` metadata for repos under `~/` (up to 4 levels deep)
- Config files (JSON, YAML) across repos it finds
- Markdown files for shared-section-structure detection

It does not read anything in:

- `/Library`, `/System`, `/Applications`, `/private`
- `node_modules`, `.next`, `dist`, `build`, `.git/objects`
- Any folder or file containing `bbn`, `rtx`, `darpa`, `defense`, `classified`, `itar`, `ear`
- `.ssh`, `.aws`, `.gpg`, `.gnupg`, any path with `.private`
- Anything matched by `ritual.config.json → exemptPaths`

The skipped-path list is applied before any file is opened, so exempt content is never read into Claude's context, let alone sent to the model.

## What data leaves the machine

Only content Claude Code would already be sending. Ritual is a skill — it structures Claude's behavior inside an existing Claude Code session. The files Claude reads during a Ritual run are subject to the same data posture as any other Claude Code interaction on your plan.

The bootstrap scan writes its findings to `~/ritual-patterns.json` **locally**. No upload. If you choose to contribute a config example back to the Ritual repo, that is a manual pull request you create — nothing is pushed automatically.

## Fix mode and supervision

The skill supports three modes: `flag`, `suggest`, `fix`. Fix mode applies rewrites directly to files. It exists for trusted, interactive use.

**Routine runs default to `suggest` mode.** The recommended routine patterns in `docs/routines.md` produce draft pull requests — they never auto-merge, never commit to `main`, never push without a human in the loop.

If your organization wants to disable fix mode entirely, remove the fix-mode section from `skill/SKILL.md` and rebuild the `.skill` artifact. The skill will still support flag and suggest modes without further changes.

## Supply chain

- **No npm/pip/cargo dependencies.** The skill is markdown. There is no `package.json`, no `requirements.txt`, no lock file.
- **Distribution.** A single `.skill` file (zip of markdown). Released under semantic versioning on GitHub Releases.
- **Integrity.** Each release publishes a SHA-256. Verify before installing:
  ```bash
  shasum -a 256 ritual-voice.skill
  ```
- **Source.** Everything in this repository is under MIT license. No closed-source components, no call-home, no telemetry.

## Network posture

Ritual makes no network calls on its own. The skill runs inside Claude Code's sandbox. Network calls that happen during a Ritual run are calls Claude Code itself would be making to reach Anthropic's API — the Ritual skill does not originate any of them.

The bootstrap scan runs shell commands (`rg`, `fd`, `git`, `jq`, `wc`, `find`, `history`) against the local filesystem. It does not call external services.

## Configuration review

The brand-specific configuration (`ritual.config.json`) is stored in the repository, version-controlled, and code-reviewable like any other config file. There is no external dashboard, no per-brand API key, no secret to rotate.

The file contains:

- Brand name, tagline, tone
- Canonical names and variants
- Banned words and phrases
- Verified facts with sources and dates
- Staleness thresholds
- Exempt paths

It does **not** contain credentials, API keys, or private URLs. A config file is intended to be committable to a public repository if the brand's content is public.

## Audit trail

Every flagged violation in a Ritual report cites the priority class (P1–P6), the file and line, the matched text, and — for P1 and P2 — the `provenFacts` entry (or absence) that drove the flag. Reports are deterministic enough that the same content against the same config will produce substantially the same report across runs, with variance in phrasing of suggestions but not in what is flagged.

For enterprise audit requirements, reports can be captured and stored alongside content. The recommended routine pattern in `docs/routines.md` opens a draft PR per run — the PR body is the persistent audit trail.

## Exempt paths in regulated environments

If your organization operates in regulated domains (defense, classified, healthcare PII, financial compliance, client NDA data), configure `exemptPaths` in your `ritual.config.json`:

```json
"exemptPaths": [
  "defense/",
  "darpa/",
  "classified/",
  "client-nda/",
  "phi/",
  "pii/"
]
```

Matched paths are treated as prefixes. The skill skips them entirely — the contents of files under these paths are never opened and never sent to the model.

## Vulnerability disclosure

Email **security@whystrohm.com**. Expected response: 3 business days. See [`SECURITY.md`](../SECURITY.md) for full scope.

## Getting approval to try it

For a controlled evaluation:

1. Install the `.skill` on a single engineer's Claude Code install
2. Run `ritual-voice` in `flag` mode only, against a single non-sensitive content directory
3. Review the output and compare against your data-handling standards
4. Expand scope after validation

The skill cannot cause content changes in `flag` mode. That mode is the correct starting point for any evaluation.

## Questions

Open an issue on GitHub, or email the security contact above. Specific enterprise questions (data residency, custom exempt-path behavior, on-prem Claude Code configurations) are answered case by case.
