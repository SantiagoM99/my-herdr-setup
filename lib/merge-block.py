#!/usr/bin/env python3
"""Put a Markdown file into a marked block of an agent instructions file (CLAUDE.md, AGENTS.md).

    merge-block.py <source.md> <target.md>

The block sits between `<!-- >>> herdr-setup >>> -->` and `<!-- <<< herdr-setup <<< -->`. Running
it again replaces the block; everything outside it is the user's and stays as it is. Prints
"unchanged" when the target already holds this block.
"""

import re
import sys
from pathlib import Path

BEGIN = "<!-- >>> herdr-setup >>> -->"
END = "<!-- <<< herdr-setup <<< -->"


def main() -> int:
    source, target = Path(sys.argv[1]), Path(sys.argv[2])
    block = f"{BEGIN}\n{source.read_text().strip()}\n{END}\n"
    old = target.read_text() if target.exists() else ""
    rest = re.sub(rf"\n*{re.escape(BEGIN)}.*?{re.escape(END)}\n?", "\n", old, flags=re.S).strip()
    new = (rest + "\n\n" if rest else "") + block
    if new == old:
        print("unchanged")
        return 0
    target.write_text(new)
    print("updated")
    return 0


if __name__ == "__main__":
    sys.exit(main())
