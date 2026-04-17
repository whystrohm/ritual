# Writing That Avoids Slop

This piece is *about* the words a careful writer should avoid. It uses quotation marks, enumeration cues, and explicit definition contexts — none of which should trigger P3 or P4 violations under the mention-vs-use exemption.

## Hype words we avoid

- comprehensive
- seamless
- revolutionary
- cutting-edge

## Phrases that signal AI-generated drafts

The term "delve" is a classic tell. So is "tapestry" and "testament to." Avoid these.

Banned phrases in our brand guide include "in today's fast-paced world" and "at the end of the day."

Words like `leverage` and `empower` get flagged by our linter. The phrase "it's not X — it's Y" is another construction we do not use.

## Example of bad copy (for reference only)

> Our comprehensive, seamless platform empowers teams to unlock their full potential.

The block quote above is an example of what our linter catches. The words inside the quote are not endorsed voice — they are a deliberate sample of what to avoid.

## Code snippet showing the config

```json
{
  "bannedWords": ["comprehensive", "seamless", "revolutionary"]
}
```

The JSON above is configuration, not copy. It should not trigger voice violations.
