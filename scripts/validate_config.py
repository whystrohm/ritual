#!/usr/bin/env python3
"""Validate a ritual.config.json file against the expected schema."""

import json
import sys
from pathlib import Path

REQUIRED_TOP_LEVEL = ["brand"]
REQUIRED_BRAND_FIELDS = ["name"]
KNOWN_TOP_LEVEL = {
    "brand",
    "canonicalNames",
    "voice",
    "provenFacts",
    "staleness",
    "exemptPaths",
}


def validate(path: Path) -> list[str]:
    errors: list[str] = []

    try:
        with path.open() as f:
            config = json.load(f)
    except json.JSONDecodeError as e:
        return [f"Invalid JSON: {e}"]
    except OSError as e:
        return [f"Could not read file: {e}"]

    if not isinstance(config, dict):
        return ["Config must be a JSON object at the top level"]

    for field in REQUIRED_TOP_LEVEL:
        if field not in config:
            errors.append(f"Missing required field: {field}")

    unknown = set(config.keys()) - KNOWN_TOP_LEVEL
    if unknown:
        errors.append(f"Unknown top-level fields: {', '.join(sorted(unknown))}")

    brand = config.get("brand")
    if isinstance(brand, dict):
        for field in REQUIRED_BRAND_FIELDS:
            if field not in brand:
                errors.append(f"Missing required brand field: {field}")
    elif brand is not None:
        errors.append("'brand' must be an object")

    proven = config.get("provenFacts", [])
    if not isinstance(proven, list):
        errors.append("'provenFacts' must be an array")
    else:
        for i, fact in enumerate(proven):
            if not isinstance(fact, dict):
                errors.append(f"provenFacts[{i}] must be an object")
                continue
            for required in ("claim", "verifiedAt", "source"):
                if required not in fact:
                    errors.append(f"provenFacts[{i}] missing '{required}'")

    voice = config.get("voice", {})
    if not isinstance(voice, dict):
        errors.append("'voice' must be an object")
    else:
        for field in ("bannedWords", "bannedPhrases", "examples"):
            value = voice.get(field)
            if value is not None and not isinstance(value, list):
                errors.append(f"voice.{field} must be an array")

    return errors


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: validate_config.py <path-to-ritual.config.json>", file=sys.stderr)
        return 2

    path = Path(sys.argv[1])
    errors = validate(path)

    if errors:
        print(f"FAIL: {path}", file=sys.stderr)
        for err in errors:
            print(f"  - {err}", file=sys.stderr)
        return 1

    print(f"OK: {path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
