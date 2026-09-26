# WhyStrohm Reference Implementation

This is the starting config for the [WhyStrohm](https://whystrohm.com) site itself. WhyStrohm builds content infrastructure for founder-led brands.

It's here as a reference for the **shape** of a mature `ritual.config.json`: canonical names for a person and a brand, an expanded banned-words list, tone notes, defense-aware exempt paths, and one verified fact drawn from the WhyStrohm site. It holds no client names or client data.

## Why only one `provenFacts` entry?

The whole point of Ritual is that every claim needs a receipt. The fact shipped here is the core offer, sourced from whystrohm.com on the `verifiedAt` date. Anyone with a browser can check it.

Unverified numbers do not ship in this file, because shipping an example config with claims you can't back up would contradict the skill's own philosophy.

You'll populate your own `provenFacts` with the claims that matter to your brand: subscriber counts, case-study outcomes, launch dates. Each one gets a source and a verification date. Facts older than `staleness.maxAgeDays` re-verify or drop out of the file.

## What to notice

**`canonicalNames` covers both people and brands.** "Yurr" maps to "Yuri Strohm" and "Why Strohm" maps to "WhyStrohm", because the skill should flag inconsistency when a page uses a nickname or variant in one paragraph and the full name in another. The canonical-name check fires when variants collide in the same piece of content, not on every mention.

**`exemptPaths` includes defense-related directories.** Any config for an operator working across regulated domains should explicitly tell the skill not to read those paths. The skill treats them as prefixes and skips matching files entirely: their contents are never sent to the model.

**`voice.examples` are not marketing copy.** They are short, specific, and sound like one person talking. The skill uses these as a style reference when generating rewrites, which means they need to read like your voice, not like your website header.

**`staleness.metricsRequireVerification` is `true`.** This is the strict setting: every numeric claim in your content must map to an entry in `provenFacts`. Start with `false` on a new config; flip to `true` once your fact library is populated enough that the signal-to-noise ratio is worth it.

**`preferredLanguage` does not include `"solutions"`.** That word has too many legitimate uses (saline solutions, math solutions) to safely rewrite on sight. Substitutions in this map should be low-context swaps; if a word needs judgment, leave it to the suggest/fix-mode pass, not the mechanical substitution.

## What's missing from this example

- **Per-brand configs.** In practice, each brand has its own `ritual.config.json` in its own repo. This config is for the WhyStrohm site itself. Don't try to cram multiple brands into one config.
- **Client-specific hype words.** A recovery-sector brand would add "journey" and "wellness" to `bannedWords`. A SaaS brand would add "AI-powered" and "platform." Tune per brand.
- **Internal metrics.** Client-specific numbers, internal KPIs, anything that shouldn't be public. Those go in the private config on the brand's own repo, not in this public example.

## Using this config

```bash
# Copy to your repo
cp examples/whystrohm/ritual.config.json ./ritual.config.json

# Then edit:
# - Change the brand name and tagline
# - Replace provenFacts with your own verified claims
# - Update canonicalNames with the people and brands you write about
# - Rewrite voice.examples in your actual voice
```

Do not ship this file as-is. These are WhyStrohm's facts. Use your own.
