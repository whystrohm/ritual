# Contributing to Ritual

Thanks for considering a contribution. This project is small by design — the leverage is in people's `ritual.config.json` files, not in the skill itself.

## What we want

**Example configs.** If you run content for a specific niche (SaaS, DTC, recovery, healthcare, real estate), a well-shaped example config is more valuable than a new feature. See `examples/whystrohm/` for the shape.

**Scan top-5 contributions.** If you run the bootstrap scan and your top-5 recommendations include a pattern that does not match any of the [four archetypes](docs/first-routines.md), open an issue with the relevant entries from `~/ritual-patterns.json` (sanitized of anything private). That is the signal we use to decide whether a new archetype belongs in the repo.

**Bug reports on false positives and false negatives.** The P1–P6 checks are judgment calls. If a check misses something obvious or flags something legitimate, open an issue with a minimal reproduction.

**Better rules for existing checks.** If you have a cleaner detection pattern for AI-slop (P3) or a better hype-word default list (P4), open a PR against `skill/references/checks.md`.

**Documentation fixes.** Clarity wins over cleverness.

## Contributing an example config

The single most valuable contribution for most people. Shape:

1. Create a new folder under `examples/` named for your niche or brand: `examples/saas-growth/`, `examples/dtc-skincare/`, `examples/recovery-nonprofit/`.
2. Add a `ritual.config.json` with your brand's canonical names, banned words, voice examples, and — if you can — 2–3 verified facts with sources. If the facts are private, leave `provenFacts` empty and flip `metricsRequireVerification` to `false`.
3. Add a short `README.md` explaining what niche the config is for, what is distinctive about the banned words / voice examples, and what is intentionally left out.
4. Open a PR. We will ask about anything unclear but we will not block on polish — a rough example config is more valuable than a perfect one that does not exist.

The example folder tree:

```
examples/your-niche/
├── ritual.config.json
└── README.md
```

That is it. No build step, no tests required beyond `scripts/validate_config.py examples/your-niche/ritual.config.json` passing (which CI runs automatically).

## What we'd probably reject

**A new priority.** The six checks are ordered deliberately. Adding P7 dilutes the skill. If you have a new check, make a case for why it belongs in P1–P6 and which existing check it replaces.

**Config features that leak brand-specific logic into the skill.** The rule is: if a brand needs it, it goes in the config. If every brand needs it, we can discuss.

**Scope creep into writing.** This is an audit skill, not a generative one. "ritual-voice that writes your blog posts" is a different skill.

## Development

The skill is three markdown files. No build step.

```bash
git clone https://github.com/whystrohm/ritual.git
cd ritual
./scripts/test.sh  # runs the example configs through a dry validation
./scripts/package.sh  # builds ritual-voice.skill from skill/
```

## Pull request checklist

- [ ] Changes to `skill/SKILL.md` or `skill/references/*.md` are under 500 lines per file
- [ ] A test case in `tests/` covers the change (for rule changes)
- [ ] `examples/minimal/ritual.config.json` still validates
- [ ] CHANGELOG.md has an entry under "Unreleased"
- [ ] No brand-specific logic outside `examples/`

## Code of conduct

Be decent. Critique the work, not the person. We're all trying to ship better content.

## License

By contributing, you agree your contributions are licensed under the MIT License.
