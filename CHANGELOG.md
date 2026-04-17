# Changelog

All notable changes to Ritual are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-04-17

### Added
- Initial release of the `ritual-voice` skill
- Six-priority voice audit: stale stats, specificity, AI-slop, hype words, name mismatches, generic voice
- Three-mode operation: flag, suggest, fix
- `ritual.config.json` schema with `provenFacts`, `canonicalNames`, `voice`, `staleness`, `exemptPaths`
- Bootstrap scan prompt (`docs/bootstrap.md`) — reads shell history + git repos, proposes first routine
- Four routine archetypes (`docs/first-routines.md`) — voice sweep, PR review, pre-publish gate, fact-freshness audit
- Enterprise brief (`docs/enterprise.md`) — security posture, data handling, supply chain, configuration review
- Limitations doc (`docs/limitations.md`) — explicit scope of what Ritual will and will not do
- Minimal example config (`examples/minimal/`) — empty `provenFacts`, lenient verification
- Reference config for WhyStrohm (`examples/whystrohm/`) — three verified facts sourced from live site, strict verification
- Test fixtures (`tests/fixtures/`) — seven fixtures covering all six priorities plus a mention-vs-use regression guard
- Context-aware detection — mention-vs-use exemption prevents false-positives on content that discusses banned words
- Git-based file-age detection — uses `git log -1 --format=%at` instead of unreliable filesystem mtime
- Routine integration guide for scheduled enforcement (`docs/routines.md`)
- Reddit launch copy for r/ClaudeAI, r/Entrepreneur, r/SideProject (`docs/reddit-launch.md`)

### Changed
- README restructured: routine-builder wedge as the lead, voice-audit as the first example of what the bootstrap recommends
- Removed `"solutions": "tools"` substitution from preferredLanguage defaults — too many legitimate uses of "solutions" for a whole-word swap
- Example WhyStrohm config's `provenFacts` now contains only facts verifiable against the live whystrohm.com site (pricing, client count, offer)
- Bootstrap scan hardened for modern macOS: reads `~/.zsh_sessions/*.history` (per-session history where most command data actually lives on default macOS zsh configs). Without this fix, users with `HISTSIZE=0` see ~40x undercounted frequencies.
- Bootstrap scan adds a Phase 0 prior-context pass: reads `~/CLAUDE.md`, `~/.claude/memory/`, and repo-level CLAUDE.md files before analyzing history, so recommendations weight stated intent alongside observed behavior.
- Bootstrap scan detects existing automations (launchd, cron, GitHub Actions) and excludes them from recommendation candidates, so the scan does not propose work that is already running.
- Bootstrap output JSON adds `prior_context` and `existing_automations` fields; `scope` now tracks `history_lines_analyzed` and `history_sources[]` for provenance.
- Bootstrap README adds a "what good results require" section setting honest expectations about machines with no memory, <90 days of history, or single-repo setups.
