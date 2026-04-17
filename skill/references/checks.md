# Voice Lint Checks — Full Rule Set

The six check classes, in priority order. Run all six. Report them in this order.

---

## Priority 1 — Stale stats / outdated metrics

**What this catches:** Numbers and metrics in content that are either (a) older than the brand's `staleness.maxAgeDays`, (b) don't match the current verified value, or (c) contradict the `provenFacts` list.

**Why it's P1:** Stale stats are worse than hype words because they're actively misleading. A blog post saying "75 subscribers" when the brand now has 400 makes the brand look inactive. A case study claiming "$200K raised" when the number is $500K sells the brand short.

### Detection rules

1. Extract every numeric claim from content. A numeric claim is any sentence containing a number followed by a unit or noun (subscribers, videos, clients, dollars, percent, months, etc.).

2. For each claim:
   - Look up matching entries in `ritual.config.json → provenFacts`. Match on semantic similarity of the claim, not exact string.
   - If no match found and `staleness.metricsRequireVerification` is `true`: flag as unverified (this overlaps with P2 — report under P1 if the file is older than maxAgeDays, under P2 otherwise).
   - If match found but `verifiedAt` is older than `maxAgeDays`: flag as stale.
   - If match found and current verified value differs from content value: flag as outdated.

3. Check file-level freshness using **git history, not filesystem mtime**. Filesystem mtime is unreliable — it resets on clone, on CI checkout, on any automated sync. Use git as the source of truth:

   - For each content file, get the timestamp of the last commit that touched it:
     `git log -1 --format=%at -- <file>`
   - That UNIX timestamp is the file's real last-modified date.
   - If the file contains any numeric claims AND its git-tracked age exceeds `maxAgeDays`, flag the file as stale.

4. Fallback for untracked files: if `git log` returns empty (file is new or outside a git repo), use filesystem mtime and note "file age derived from filesystem, not git history" in the report.

5. Fallback for missing git: if the `git` command is not available or the file is not in a git repo at all, use mtime without the note. The skill still runs, just with weaker staleness signal.

### Violation examples

**Stale:**
> "Our YouTube channel has grown to 75 subscribers."
> *provenFacts shows 400 subscribers verified 2 days ago.*
> Fix: Update to "400 subscribers" or pull the latest from the source.

**Outdated file:**
> `/case-studies/nvus-hearts.md` — last modified 92 days ago, contains 6 numeric claims.
> Fix: Full refresh pass. Flag for human review, don't auto-rewrite.

**Unverified metric:**
> "We've shipped over 1,000 videos for clients this year."
> *No matching proven fact. metricsRequireVerification is true.*
> Fix: Add to provenFacts with source, or remove the claim.

### Acceptable rewrites

When the user supplies an updated number (or the config has a fresh proven fact):
> "Our YouTube channel has grown from 6 to 400 subscribers in six months."

Pull specificity from the proven fact. "Grown to 400" is fine. "Grown from 6 to 400 in six months" is better because it uses more of the verified data.

---

## Priority 2 — Missing specificity

**What this catches:** Claims without numbers, proof, or named subjects. The "we help founders grow their businesses" class of statement.

**Why it's P2:** Specificity is what separates a brand that knows what it does from a brand that's hiding behind jargon. Missing specificity doesn't mislead (that's P1), but it fails to convince.

### Detection rules

Flag a sentence if it makes a benefit or outcome claim and contains none of:
- A number (percent, count, dollar amount, time duration)
- A named person, client, or entity
- A specific mechanism (named tool, process, or methodology)
- A verifiable artifact (URL, filename, repo, video, publication)

Trigger words that often precede vague claims:
- "helps," "supports," "enables," "empowers"
- "better," "faster," "stronger," "more effective"
- "solutions," "results," "outcomes," "value"
- "businesses," "founders," "teams," "organizations" (when ungrounded)

A sentence passes if the claim is grounded even if one of the trigger words appears. "We helped Tyshaun Perryman ship 9 microsites in 60 days" contains "helped" but is specific.

### Violation examples

**Vague benefit:**
> "We help founders grow their brands."
> Fix (suggest mode): "We run content infrastructure for 11 founder-led brands — voice extraction, Remotion video, automated publishing — in 30 minutes a week of founder time."

**Ungrounded outcome:**
> "Our clients see better engagement."
> Fix: Name a client, cite a number from provenFacts, or remove the claim.

**Abstract subject:**
> "Businesses that partner with us scale faster."
> Fix: "NVUS Hearts went from 6 to 400 subscribers in six months." Name them. Show it.

### Acceptable rewrites

Pull from `provenFacts` whenever possible. If no proven fact supports the claim, suggest removing the sentence rather than rewriting it. A deleted vague sentence is better than a rewritten one that invents proof.

---

## Priority 3 — AI-slop markers

**What this catches:** The specific linguistic tics that make copy read as AI-generated. These aren't banned because they're wrong — they're banned because they're *tells*.

**Why it's P3:** Copy that reads as AI-generated loses trust even when the content is accurate. Especially important for brands selling AI-adjacent services, where the copy has to prove the operator has taste.

### The list

**Em-dash seasoning.** AI-generated copy uses em-dashes as a tic, often 2–3 per paragraph where a human would use none. Rule: flag any file with more than 1 em-dash per 150 words. Don't flag individual uses unless the density is high. Don't flag en-dashes or hyphens.

**"It's not X — it's Y" construction.** Also its variants: "This isn't just X, it's Y." "Not only X, but Y." Flag structurally, not by exact match. Any sentence following the pattern `[negation] + [noun] + [conjunction/punctuation] + [contrast noun]` is suspect.

**Specific words:**
- `delve`, `delving`, `delved`
- `tapestry`, `rich tapestry`
- `testament to`
- `navigate the landscape` (and variants: navigate the complexities, navigate the challenges)
- `in today's fast-paced world`
- `at the end of the day`
- `unlock` (as verb for abstract benefits: "unlock growth," "unlock potential")
- `unleash` (same)
- `harness` (same: "harness the power of")
- `seamlessly integrate`
- `elevate your [anything]`

**Cliché phrases:**
- "the sky's the limit"
- "think outside the box"
- "move the needle"
- "circle back"
- "deep dive" (as noun)
- "low-hanging fruit"
- "game-changer"

### Detection rules

1. Scan content for direct matches (case-insensitive) against the lists above and the brand's `voice.bannedPhrases`.

2. For em-dash density: count em-dashes (`—`, not `-`), divide by word count, multiply by 150. If >1, flag the file.

3. For the "not X — it's Y" construction: flag any sentence matching the structural pattern. Use judgment on false positives (legitimate contrasts exist).

### Violation examples

**Em-dash seasoning:**
> "Our system is fast — really fast — and it's built for founders — the kind who don't have time — to manage content themselves."
> Density: 4 em-dashes in 24 words = 25 per 150 words. Flag.
> Fix: "Our system is fast. It's built for founders who don't have time to manage content themselves."

**Not-X-but-Y:**
> "This isn't just content creation — it's brand infrastructure."
> Fix: "This is brand infrastructure." Drop the contrast. State the claim.

**Specific word:**
> "Let's delve into how this works."
> Fix: "Here's how this works."

### Acceptable rewrites

Remove the tic. Don't replace it with a fancier construction. AI-slop is about surface texture, and the fix is almost always *less* ornamentation, not different ornamentation.

---

## Priority 4 — Hype words

**What this catches:** Unearned superlatives and empty intensifiers.

**Why it's P4 (not higher):** Hype words are annoying but not misleading. A "comprehensive solution" is vague; a stale stat is wrong. Hype words are below specificity and AI-slop because they're more about taste than substance.

### Default banned list

```
comprehensive, seamless, revolutionary, game-changing, cutting-edge,
leverage, robust, synergy, holistic, best-in-class, world-class,
next-generation, innovative, transformative, empower, unlock,
streamline, optimize, elevate, unleash, pioneering, groundbreaking,
disruptive, scalable (when used as a filler adjective), powerful
```

Merge with `ritual.config.json → voice.bannedWords`. Case-insensitive. Whole-word match only (don't flag "empowering" if "empower" is banned — flag it separately if the user added the -ing form).

### Detection rules

1. Scan for exact matches (whole-word, case-insensitive).
2. For each match, flag the sentence with the word highlighted.
3. In "fix" mode, remove the hype word and reconstruct the sentence if needed. Don't substitute another word — usually the sentence is stronger without any adjective.

### Violation examples

**Hype word:**
> "A comprehensive approach to brand voice."
> Fix: "A brand voice system." (Drop the adjective. If the "comprehensive" is doing real work, replace with a specific number: "Voice guardrails for 11 client brands.")

**Multiple hype words:**
> "Our innovative, scalable solution empowers founders to unlock their brand's full potential."
> Fix: "We run content for 11 founder-led brands in 30 minutes of founder time per week." (Wholesale rewrite — the original is 0% substance.)

### Acceptable rewrites

When removing a hype word leaves the sentence broken, the fix is almost always to add a specific claim from `provenFacts`, not another adjective. If no proven fact supports a specific claim, suggest cutting the sentence.

---

## Priority 5 — Name/attribution mismatches

**What this catches:** Inconsistent references to people, products, or brands within a single piece of content.

**Why it's P5:** Annoying and unprofessional, but rarely misleading. The Tyshaun/Tye mismatch on the WhyStrohm homepage is the canonical example of this class.

### Detection rules

1. Load `ritual.config.json → canonicalNames`.

2. For each piece of content:
   - Find every proper noun that maps to an entry in canonicalNames.
   - If multiple variants of the same canonical name appear in the same file, flag as inconsistent.
   - If a variant appears in a formal context (testimonial attribution, case study title, about page) where canonical form is expected, flag.

3. Spelling check: if a name in content is close to but not exactly a canonical form (edit distance ≤ 2), flag as possible misspelling.

### Violation examples

**Inconsistent within file:**
> Line 12: "Tyshaun Perryman, founder of Insightful Recovery..."
> Line 490: "Tye and his team are..."
> Fix: Use canonical form (Tyshaun) consistently, unless a section is explicitly informal/quoted.

**Wrong form in formal context:**
> Testimonial attribution: "— Tye, Insightful Recovery"
> Fix: "— Tyshaun Perryman, Founder, Insightful Recovery Solutions"

**Possible misspelling:**
> "Tyshuan Perryman" (edit distance 1 from canonical "Tyshaun")
> Fix: Correct to "Tyshaun Perryman"

### Acceptable rewrites

Always use the canonical form unless the context is explicitly informal (body of a quote, direct message). In attribution lines, titles, and meta content, never use variants.

---

## Priority 6 — Generic corporate voice

**What this catches:** Passive voice, hedging, and vague benefit language. The stuff that isn't technically wrong but makes the brand sound like every other brand.

**Why it's P6:** Lowest priority because a single instance is usually fine and fixes require the most judgment. Don't over-flag.

### Patterns to flag

**Passive voice in high-visibility copy.** Flag passive construction in:
- Headlines and subheads
- Testimonial attributions and case study pull-quotes
- CTA buttons and form labels
- First sentence of any paragraph

Body copy passive voice is fine — don't flag it unless it's dominant (>30% of sentences in a section).

**Hedging in claims.** Flag:
- "may," "might," "could potentially"
- "can help," "could help" (when stronger claim is warranted)
- "often," "typically," "generally" (when stating the brand's own behavior)

A brand shouldn't hedge about what it does. "We often deliver in 30 days" is weaker than "We deliver in 30 days."

**Vague benefits.** Already covered under P2, but flag here when the sentence is specific-adjacent but still fluffy:
- "improved performance"
- "better results"
- "stronger outcomes"
- "enhanced productivity"

### Detection rules

1. Use basic pattern matching for passive voice (forms of "to be" + past participle) in target contexts only.

2. Scan for hedge words in first-person claims about the brand.

3. Flag vague benefit phrases.

4. **Density threshold:** don't flag individual instances of P6 in body copy. Only flag if a file crosses 3+ P6 violations, at which point report them all together.

### Violation examples

**Passive in headline:**
> H1: "Brands Are Transformed by Our System"
> Fix: "Our system rebuilds brand voice in 30 days."

**Hedging in claim:**
> "We can help founders spend less time on content."
> Fix: "We cut founder content time to 30 minutes a week."

**Vague benefit:**
> "Expect improved performance across all channels."
> Fix: "Expect 4x more published content per month." (Pull from provenFacts; if no fact, cut.)

### Acceptable rewrites

P6 fixes require the most judgment. In "suggest" mode, always propose the rewrite but tag it as lower-confidence. In "fix" mode, apply only when the fix is mechanical (hedge removal, passive-to-active in a headline). For vague benefits, prefer to cut and flag for human attention over rewriting with invented specifics.

---

## Cross-priority rules

**Don't double-count.** If a sentence triggers both P2 and P6 (e.g., vague benefit with passive voice), report it once under the higher priority.

**Respect quoted content.** Any text inside quotation marks attributed to a named speaker is exempt from P3, P4, P6 checks. P1 (stale stats) and P5 (name attribution) still apply. Flag in notes for human review if a client quote contains bad voice.

**Exempt directories.** Always respect `ritual.config.json → exemptPaths`. Default exempt paths are listed in the schema.

**Config-less fallback.** If no config exists and the user insists on running the skill anyway, use defaults for P3 and P4 only. Skip P1, P2, P5, P6 — they require config data to be meaningful. Tell the user what was skipped and why.

## Mention vs. use detection (critical)

Content that discusses bad writing is not the same as content that commits bad writing. The skill must distinguish between a sentence *using* a banned word and a sentence *talking about* that word.

**Skip P3 (AI-slop) and P4 (hype words) detection when the banned token appears in any of these contexts:**

### 1. Inside code blocks or inline code

Anything between triple backticks, or inside single backticks, is code or a literal example. Do not scan these for voice violations.

Examples that must be skipped:
- `"delve"` — inline code
- ```
  const banned = ["comprehensive", "seamless"];
  ```

### 2. Inside quoted lists of banned words

When a banned word appears inside quotation marks in the same paragraph as a cue word that indicates enumeration of bad language, skip it. Cue words (case-insensitive):

- "banned", "forbidden", "avoid", "never use"
- "AI-slop", "AI slop", "hype word", "hype words"
- "flag", "flagged", "violation", "violations"
- "don't use", "do not use"
- "smell", "smells of", "gives off"

Example that must be skipped:
> Banned words include "comprehensive," "seamless," and "revolutionary."

Example that must NOT be skipped (no cue words, no quotes):
> Our comprehensive approach delivers seamless results.

### 3. Inside markdown list items under a heading about bad writing

When a list item appears under a heading (any level) whose text contains a cue word from the list above, skip detection on items in that list until the next heading of equal or higher level.

Example that must be skipped:

```
## Hype words we avoid
- comprehensive
- seamless
- revolutionary
```

### 4. Inside explicit citation or definition contexts

When a banned word is prefixed by a citation or definition marker in the same clause:

- "the word X"
- "the term X"
- "X-style language"
- "like 'X'" or "such as 'X'"
- "words like X"
- "phrases like X"

Example that must be skipped:
> The term "comprehensive" is a classic hype word tell.

### 5. Inside blockquotes

Text inside markdown blockquotes (lines starting with `>`) is treated as quoted content and exempt from P3/P4, consistent with the "respect quoted content" rule above.

## What still gets flagged

These contexts do NOT qualify for the mention-vs-use exemption:
- Banned words in body copy without any citation or enumeration marker
- Banned words in headings, unless the heading itself is about bad writing
- Banned words in testimonial attributions
- Banned words in component prop values, alt text, or meta descriptions

When in doubt, flag it and note in the report that the context was ambiguous. Human reviewers can close false positives faster than they can catch false negatives.

## Implementation note for P1 and P5

P1 (stale stats) and P5 (name mismatches) are NOT subject to the mention-vs-use exemption. A stale stat is wrong regardless of whether the surrounding text is "talking about" the claim. A name mismatch is wrong regardless of context. Only P3, P4, and the quoted-content rule in P6 use this exemption.
