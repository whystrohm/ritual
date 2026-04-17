# Minimal Example

The smallest config that makes `ritual-voice` useful.

## Get started

1. Copy `ritual.config.json` to the root of your brand's repo.
2. Edit `brand.name` and `brand.tagline`.
3. Replace the placeholder `voice.examples` with 2–3 real sentences in your voice.
4. Add your canonical names to `canonicalNames` (nicknames, misspellings, variants → canonical form).
5. Start populating `provenFacts` as you verify claims.

## What this config enables

With this minimal setup, the skill runs:
- **P3** (AI-slop) with defaults plus your `bannedPhrases`
- **P4** (hype words) with defaults plus your `bannedWords`
- **P6** (generic corporate voice) with defaults

P1 (stale stats), P2 (specificity), and P5 (name mismatches) need you to populate `provenFacts` and `canonicalNames` to be fully useful. Start empty — they still run, they just have less to compare against.

## When to graduate to a richer config

See `examples/whystrohm/` for what a production config looks like after 6 months of use.
