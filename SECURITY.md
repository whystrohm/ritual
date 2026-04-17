# Security Policy

## Reporting a vulnerability

Email **security@whystrohm.com** with details. Please don't open public issues for security concerns.

Expect a response within 3 business days.

## Scope

This project is a Claude Code skill — a set of instructions Claude follows. It has no executable code, no network calls of its own, and no data storage outside the user's repository.

Security concerns that are in scope:

- **Exempt-path bypass.** If a pattern in `ritual.config.json → exemptPaths` fails to prevent the skill from reading or reporting on a file it should skip.
- **Prompt injection via config.** If a malicious `ritual.config.json` can cause the skill to behave outside its documented scope.
- **Data leakage in reports.** If the skill's output includes content from exempt paths or from files outside the scan target.

Concerns that are out of scope (report to Anthropic):

- Issues with Claude Code itself
- Issues with Claude's model behavior that aren't specific to this skill
- Issues with Claude Code routines infrastructure

## Safe defaults

The skill ships with exempt-path defaults that cover common sensitive directories: `node_modules/`, `.next/`, `dist/`, `build/`, `.git/`, and any path containing `defense`, `darpa`, `bbn`, `rtx`, `classified`, `itar`, `ear`.

If you operate in a regulated environment, extend `exemptPaths` in your config. The skill treats these as prefixes and skips matching paths entirely — it does not send their contents to the model.

## Supply chain

The skill is distributed as a `.skill` file containing only markdown. There are no dependencies, no package manager, no transitive trust.

Releases are signed. Verify the SHA256 on each release against the published value.
