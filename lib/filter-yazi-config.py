#!/usr/bin/env python3
"""Write a copy of config/yazi/yazi.toml without the openers of components that are not installed.

    filter-yazi-config.py <repo yazi.toml> <output> <opener>[,<opener>...]

Each [opener] entry starts with `<name> = [` and ends with `]`; each rule in prepend_rules names
its opener first in `use = [ "<name>", ...`. Both are dropped for the openers listed.
"""

import re
import sys
import tomllib
from pathlib import Path


def main() -> int:
    src, out, drop = Path(sys.argv[1]), Path(sys.argv[2]), set(sys.argv[3].split(","))
    lines, kept, skipping = src.read_text().splitlines(), [], False
    for line in lines:
        start = re.match(r"^([a-z_]+) = \[$", line)
        if start and start.group(1) in drop:
            skipping = True
        if not skipping:
            rule = re.search(r'use = \[ "([a-z_]+)"', line)
            if not (rule and rule.group(1) in drop):
                kept.append(line)
        if skipping and line == "]":
            skipping = False
    text = "\n".join(kept) + "\n"
    tomllib.loads(text)
    out.write_text(text)
    return 0


if __name__ == "__main__":
    sys.exit(main())
