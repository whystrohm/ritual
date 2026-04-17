# ritual.config.json Schema

The config file that drives this skill. Every brand using `brand-voice-lint` needs one.

## Location

Place at repo root as `ritual.config.json`. Alternate locations checked by the skill:
- `.brand/config.json`
- `config/brand.json`
- `voice-lint.config.json`

## Full schema

```json
{
  "brand": {
    "name": "string (required) — canonical brand name",
    "tagline": "string (optional)",
    "tone": "string (optional) — short description, e.g. 'direct, specific, no fluff'"
  },
  "canonicalNames": {
    "[informal or variant name]": "canonical form"
  },
  "voice": {
    "bannedWords": ["array", "of", "strings"],
    "bannedPhrases": ["it's not X it's Y", "in today's fast-paced world"],
    "preferredLanguage": {
      "instead of this": "use this"
    },
    "examples": [
      "One or two sentences that exemplify the brand voice.",
      "Used as reference when the skill rewrites copy."
    ]
  },
  "provenFacts": [
    {
      "claim": "75 subscribers on YouTube",
      "verifiedAt": "2026-04-10",
      "source": "YouTube Studio",
      "brand": "NVUS Hearts"
    }
  ],
  "staleness": {
    "maxAgeDays": 30,
    "metricsRequireVerification": true
  },
  "exemptPaths": [
    "node_modules/",
    ".next/",
    "dist/",
    "build/"
  ]
}
```

## Field-by-field

### `brand` (required)
Identifies which brand this config is for. `name` is used in report headers and to disambiguate when multiple configs exist in a monorepo.

### `canonicalNames`
Drives P5 (name/attribution) checks. Maps every informal or variant name to its canonical form. The skill flags any reference to a variant and suggests the canonical form.

Example:
```json
"canonicalNames": {
  "Tye": "Tyshaun Perryman",
  "Tyshaun": "Tyshaun Perryman",
  "Perryman": "Tyshaun Perryman",
  "Yurr": "Yuri Strohm",
  "Yuri": "Yuri Strohm"
}
```

Note: the skill doesn't force every mention to use the canonical form — it flags *inconsistency* within a single piece of content. If a page uses both "Tye" and "Tyshaun," that's the violation.

### `voice.bannedWords`
Drives P4 (hype words). Case-insensitive. Default list applied on top of the brand's list:

```
comprehensive, seamless, revolutionary, game-changing, cutting-edge,
leverage, robust, synergy, holistic, best-in-class, world-class,
next-generation, innovative, transformative, empower, unlock,
streamline, optimize, elevate, unleash
```

Add brand-specific bans here. For a recovery-sector brand, you might add "journey" or "wellness." For a defense-adjacent brand, you might add "warfighter" if that's not how they talk.

### `voice.bannedPhrases`
Drives P3 (AI-slop). Default list:

```
"it's not X — it's Y" (matched structurally, not literally)
"delve", "tapestry", "testament to"
"navigate the landscape"
"in today's fast-paced world"
"at the end of the day"
"the sky's the limit"
"think outside the box"
"move the needle"
```

### `voice.preferredLanguage`
Substitution map. When the skill rewrites, it uses these substitutions first.

```json
"preferredLanguage": {
  "solutions": "tools",
  "utilize": "use",
  "implement": "build",
  "stakeholders": "people",
  "going forward": "next"
}
```

### `voice.examples`
2–5 sentences that exemplify the brand voice. Used as style reference when the skill generates rewrites. Keep these short and specific — they're not marketing copy, they're a fingerprint.

Example for WhyStrohm:
```json
"examples": [
  "30 minutes a week. One operator. No agency.",
  "We built 800 videos from code. Here's what we learned.",
  "Voice extraction, guardrails encoded in the repo, automated publishing. That's the whole system."
]
```

### `provenFacts`
Drives P1 (stale stats) and P2 (specificity). A list of claims the brand has verified, with dates. When the skill finds a number or metric in content, it checks against this list:
- If the claim matches a proven fact and `verifiedAt` is within `staleness.maxAgeDays`, pass.
- If the claim matches but `verifiedAt` is older, flag as stale.
- If the claim doesn't match any proven fact, flag as unverified.

This is the single most important field. Brands that invest in keeping `provenFacts` updated get the most value from the skill.

### `staleness`
- `maxAgeDays` — default 30. How old a proven fact can be before it's flagged as stale.
- `metricsRequireVerification` — default `true`. If `true`, any number/metric in content must map to a proven fact. If `false`, unverified metrics are not flagged (P1 still runs on matched claims).

### `exemptPaths`
Paths to skip entirely. Defaults shown above. Add per-brand exemptions here — e.g., a client working in defense would add `"defense/"`, `"darpa/"`, etc. Paths are matched as prefixes.

## Minimal config (to get started)

If a user is scaffolding for the first time, generate this minimal version:

```json
{
  "brand": {
    "name": "[Brand Name]",
    "tone": "direct, specific, no fluff"
  },
  "canonicalNames": {},
  "voice": {
    "bannedWords": [],
    "bannedPhrases": [],
    "preferredLanguage": {},
    "examples": []
  },
  "provenFacts": [],
  "staleness": {
    "maxAgeDays": 30,
    "metricsRequireVerification": false
  },
  "exemptPaths": []
}
```

The brand fills in `provenFacts`, `canonicalNames`, and `examples` over time. Set `metricsRequireVerification: false` initially so the skill isn't screaming about every number before the brand has populated its facts.
