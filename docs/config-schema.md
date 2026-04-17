# Config Schema

The `ritual.config.json` file is the heart of Ritual. Everything the skill knows about your brand lives here.

Put the file at the root of any repo you want audited. The skill also looks in `.ritual/config.json`, `config/ritual.json`, and `ritual.config.json` (all at repo root).

## Full schema

```json
{
  "brand": {
    "name": "string (required)",
    "tagline": "string (optional)",
    "tone": "string (optional)"
  },
  "canonicalNames": {
    "variant or informal name": "canonical form"
  },
  "voice": {
    "bannedWords": ["..."],
    "bannedPhrases": ["..."],
    "preferredLanguage": {"old": "new"},
    "examples": ["...", "..."]
  },
  "provenFacts": [
    {
      "claim": "string",
      "verifiedAt": "YYYY-MM-DD",
      "source": "string",
      "brand": "string (optional)"
    }
  ],
  "staleness": {
    "maxAgeDays": 30,
    "metricsRequireVerification": true
  },
  "exemptPaths": ["path/prefix/"]
}
```

## Field reference

### `brand` (required)

Who this config is for.

- `name` — canonical brand name. Used in report headers.
- `tagline` — one sentence. Optional. Useful context for the skill when generating rewrites.
- `tone` — short description of the voice. Not a style guide — a fingerprint. E.g., "direct, specific, no fluff" is better than three paragraphs of brand strategy.

### `canonicalNames`

Drives P5 (name/attribution) checks. Maps every informal or variant name to its canonical form.

```json
"canonicalNames": {
  "Ty": "Tyler Robinson",
  "Tyler": "Tyler Robinson",
  "Robinson": "Tyler Robinson"
}
```

The skill flags inconsistency within a single piece of content. If a page uses both "Tyler" and "Ty," that's the violation. In formal contexts (attribution lines, titles, case study headers), any non-canonical variant gets flagged regardless.

Include misspellings your team tends to make. The skill uses edit distance to catch "Tylor" and suggest "Tyler."

### `voice.bannedWords`

Drives P4 (hype words). Case-insensitive, whole-word match only.

The skill ships with a default list (comprehensive, seamless, revolutionary, leverage, robust, etc.). Your list is added on top — it doesn't replace the defaults. Add words that are uniquely bad for your brand.

### `voice.bannedPhrases`

Drives P3 (AI-slop). Same layering: defaults plus your additions.

The defaults catch the most common AI tells (`delve`, `tapestry`, `in today's fast-paced world`, `it's not just X`). Add phrases specific to your brand's anti-voice.

### `voice.preferredLanguage`

Substitution map. When the skill rewrites in `suggest` or `fix` mode, it uses these substitutions first.

```json
"preferredLanguage": {
  "utilize": "use",
  "implement": "build"
}
```

Only include substitutions that are always right for your brand. Don't add "customers" → "users" unless that's truly a blanket rule — otherwise you'll break legitimate uses.

### `voice.examples`

Two to five sentences that exemplify your brand voice. Used as a style reference when the skill rewrites.

These are not marketing copy. They're a fingerprint — the kind of sentences you'd write in a draft, not a tagline.

Good:
```json
"examples": [
  "We shipped 400 units in six weeks.",
  "Three people. No agency. One config file."
]
```

Less useful:
```json
"examples": [
  "Empowering founders to unlock their potential.",
  "Innovation that drives results."
]
```

### `provenFacts`

The most important section. A list of claims your brand has verified.

```json
"provenFacts": [
  {
    "claim": "400 videos shipped in Q1",
    "verifiedAt": "2026-04-10",
    "source": "Remotion render logs",
    "brand": "WhyStrohm"
  }
]
```

- `claim` — what you're claiming, in the form you'd write it in copy
- `verifiedAt` — when you last verified the number. ISO date format.
- `source` — where the verification came from. A system of record, a report, a URL.
- `brand` — optional. Use when one config covers multiple brand contexts.

When the skill finds a numeric claim in content, it checks against this list. Match found and recent → pass. Match found but old → P1 violation. No match → P1 or P2 depending on `staleness.metricsRequireVerification`.

The skill gets more valuable the more you invest here. Start with 3–5 facts. Add to it every time you verify a new number. After six months you'll have a ledger of everything your brand can legitimately claim.

### `staleness`

- `maxAgeDays` — default 30. How old a verification can be before the skill flags it as stale.
- `metricsRequireVerification` — default `true`. If `true`, any number/metric in content must map to a proven fact, or it's flagged as unverified. If `false`, unverified numbers are allowed; only matched-but-stale ones are flagged.

Start with `metricsRequireVerification: false` if you haven't populated `provenFacts` yet. Flip to `true` once your fact list is representative.

### `exemptPaths`

Paths the skill will never read. Prefix match.

Default exempt paths (always applied, even if you don't list them):

```
node_modules/
.next/
dist/
build/
.git/
```

Also automatically exempt: any path containing `defense`, `darpa`, `bbn`, `rtx`, `classified`, `itar`, `ear`.

Add your own. If you work in a regulated space, list every directory the skill should not see. The skill treats these as a hard boundary — contents are never sent to the model.

## Minimal starter

Copy this into `ritual.config.json` at your repo root and edit:

```json
{
  "brand": {
    "name": "Your Brand",
    "tone": "direct, specific, no fluff"
  },
  "canonicalNames": {},
  "voice": {
    "bannedWords": [],
    "bannedPhrases": [],
    "examples": []
  },
  "provenFacts": [],
  "staleness": {
    "maxAgeDays": 30,
    "metricsRequireVerification": false
  }
}
```

You can run the skill against this — it'll use defaults for P3 and P4. You'll get more value as you fill in `provenFacts`, `canonicalNames`, and `examples`.

## Validating your config

```bash
python3 scripts/validate_config.py ritual.config.json
```

Prints errors if the schema is malformed. CI runs this automatically on every PR.
