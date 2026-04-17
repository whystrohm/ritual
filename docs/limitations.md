# What Ritual Will Not Do

An honest scoping document. Every content-audit tool drifts toward "trust me" marketing — this one commits to the opposite. The clearer the scope, the more useful the tool.

## Ritual will not write content

Ritual is an audit skill, not a generative one. It can propose rewrites in `suggest` and `fix` modes, but those rewrites are constrained by the config's `provenFacts` and `voice.examples` — the skill does not invent claims, generate proof, or produce original copy.

If you want a generative skill ("write me a blog post in this brand voice"), that is a different skill and not in this repo.

## Ritual will not replace an editor

A human editor makes structural decisions: does the argument hold, is the story clear, does the opening earn its place. Ritual operates below that layer — it enforces that individual claims have receipts and individual sentences don't drift into AI-slop. The strategic edit is a human job.

Use Ritual to catch the class of errors a careful editor would flag on a third pass. Do not use it in place of the first two passes.

## Ritual will not catch claims the config does not know about

The skill is only as good as `ritual.config.json`. If your content makes a claim and no entry in `provenFacts` supports or contradicts it, the skill will flag it as unverified (with `metricsRequireVerification: true`) or pass it through (with the flag `false`). It will not go fetch the truth — that is your responsibility.

Garbage config in, garbage audit out.

## Ritual will not verify facts against the live internet

`provenFacts` is a local record of claims you verified elsewhere. The skill does not call external APIs to check numbers against analytics dashboards, CRM systems, or public sources. If a number in a proven fact is wrong, the skill will pass content that matches it — because the skill trusts the config.

This is a deliberate trust model: the config is the source of truth, because anything else requires trust in an external system that may be wrong, down, or out of scope.

## Ritual will not understand context beyond the file

Voice consistency inside a single file: yes. Voice consistency across a whole brand's content corpus: partial — the skill reads the config, not the corpus. If your homepage uses "Tyshaun" and your blog uses "Tye" and the two files are never linted together, the skill will not catch the cross-file inconsistency. (A scheduled routine that sweeps both files catches it.)

## Ritual will not substitute for brand strategy

Ritual enforces voice. It does not design voice. If you don't know what your voice should be, the skill has no opinion — it just reads the rules you write. If you write weak rules, you will get weak audits.

The work upstream of Ritual is voice extraction: deciding what your brand sounds like, what words are off-limits, what claims you can back up. Ritual takes it from there.

## Ritual will not work well with an empty config

New configs start with `provenFacts: []` and `metricsRequireVerification: false`. In that state, the skill only catches P3 (AI-slop) and P4 (hype words) meaningfully. P1 (stale stats) and P2 (specificity) require a populated fact library. P5 (name mismatches) requires `canonicalNames`.

Ritual becomes more valuable as your config matures. A three-month-old config with 40 proven facts catches more than a week-old config with five.

## Ritual will not guarantee false-positive or false-negative rates

The checks are judgment calls expressed in natural language and executed by Claude. Two runs against the same content with the same config will produce substantially similar reports, but not identical ones. The priority ordering is stable. The flagged violations are stable. The wording of suggestions varies.

If you need deterministic output for compliance or audit, capture the structured report fields (priority, file, line, quoted text) — those are stable. Do not treat the suggested rewrites as a deterministic artifact.

## Ritual will not replace Grammarly, Hemingway, or a style guide

Those tools check grammar, readability, and style. Ritual checks claims against verified facts and voice against a config. Different problems. Run them alongside each other if you want; they do not conflict.

## Ritual will not auto-fix in a routine

Fix mode exists in the skill. Routine prompts in `docs/routines.md` explicitly default to `suggest` mode. This is a deliberate choice — auto-fix on a scheduled run is a supply-chain vector into your brand's published content, and we will not ship a recommendation that encourages it. If you route around this in your own routine, you own the outcome.

## Ritual will not read across repositories on its own

A single skill invocation scans a single file, directory, or URL. Cross-repo sweeps happen through a Claude Code routine that invokes the skill once per repo and aggregates. The skill itself has no multi-repo awareness.

## Ritual will not track what was fixed and what was ignored

There is no persistent "dismissed violations" store. If you ignore a flag once, it will fire again on the next run unless you fix the content or add a provenFact that covers it. This is deliberate — a dismissal store would become stale and silently hide issues.

## Ritual will not keep secrets

If a secret, credential, or private URL appears in a content file that Ritual scans, the skill may include it in its report. Do not put secrets in content files. The `exemptPaths` list exists specifically to keep credential-adjacent paths out of the scan.

## When Ritual is the wrong tool

- **You have one brand and ten pages of content.** You don't need a config-driven system; you need a careful read-through. Ritual adds overhead that doesn't pay off at that scale.
- **Your content is mostly generated, not written.** Ritual is designed to catch drift in human writing. Fully-generated content needs a different layer (a generation-time guardrail, not an audit-time one).
- **You want a one-shot launch QA, not an ongoing system.** Use `ritual-voice` in flag mode once; you don't need the routine machinery.
- **Your "voice" is the default corporate voice.** Ritual's philosophy is that voice is specific and earned. If your brand voice is "like every other B2B SaaS," Ritual will add friction without catching anything meaningful.

## What Ritual is genuinely good at

- Catching stale numbers in case studies and landing pages
- Enforcing canonical names across a multi-brand content surface
- Blocking AI-slop drift in copy that uses Claude or GPT for drafting
- Forcing the "every claim needs a receipt" discipline across a team
- Shipping alongside Claude Code routines as a nightly sweep with PR output

If that list describes your actual problem, Ritual will repay the config-maintenance cost within a month.
