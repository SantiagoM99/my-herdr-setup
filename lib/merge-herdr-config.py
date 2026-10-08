#!/usr/bin/env python3
"""Merge this repo's Herdr shortcuts into a config.toml that someone already has.

Herdr cannot include other config files, so for a user with their own config the installer
does not replace it: it writes our [[keys.command]] entries into a marked block at the end
and leaves everything else alone. Running it again replaces only that block.

    merge-herdr-config.py <repo config.toml> <user config.toml> [--dry-run]

- The user's prefix, theme and options are never changed.
- A shortcut of ours whose key is already bound (by the user, or by a Herdr default the user
  has not changed) is skipped with a warning; the user's binding wins.
- rename_tab moves to prefix+comma only if the user has not set rename_tab themselves,
  because our tables popup uses prefix+shift+t, Herdr's default for rename_tab.
- The result is parsed as TOML before writing; if it does not parse, nothing is written.
"""

import re
import subprocess
import sys
import tomllib
from pathlib import Path

BEGIN = "# >>> herdr-setup >>>"
END = "# <<< herdr-setup <<<"
RENAME_TAB = 'rename_tab = "prefix+comma"  # added by herdr-setup'


def herdr_default_bindings() -> dict[str, str]:
    """Action -> key for Herdr's prefix bindings, read from `herdr --default-config`."""
    try:
        text = subprocess.run(["herdr", "--default-config"], capture_output=True, text=True, check=True).stdout
    except (OSError, subprocess.CalledProcessError):
        return {}
    keys_section = re.search(r"^\[keys\]$(.*?)^\[(?!\[)", text, re.S | re.M)
    if not keys_section:
        return {}
    return dict(re.findall(r'^# ([a-z_]+) = "(prefix\+[^"]+)"', keys_section.group(1), re.M))


def strip_block(text: str) -> str:
    """The user's config without our managed block or the rename_tab line we added."""
    text = re.sub(rf"\n*{re.escape(BEGIN)}.*?{re.escape(END)}\n?", "\n", text, flags=re.S)
    text = "\n".join(line for line in text.splitlines() if line.strip() != RENAME_TAB)
    return text.rstrip() + "\n"


def shortcut_blocks(repo_text: str) -> list[tuple[str, str]]:
    """(key, block text) for each [[keys.command]] in the repo config, with its comments."""
    start = repo_text.index("[[keys.command]]")
    # Keep a comment directly above the first entry with it.
    start = repo_text.rfind("\n\n", 0, start) + 2
    chunks = re.split(r"\n(?=(?:#[^\n]*\n)*\[\[keys\.command\]\])", repo_text[start:])
    blocks = []
    for chunk in chunks:
        key = re.search(r'^key = "([^"]+)"', chunk, re.M)
        if key:
            blocks.append((key.group(1), chunk.strip() + "\n"))
    return blocks


def main() -> int:
    args = [a for a in sys.argv[1:] if a != "--dry-run"]
    dry_run = "--dry-run" in sys.argv
    if len(args) != 2:
        print(__doc__.strip().splitlines()[0], file=sys.stderr)
        return 2
    repo_cfg, user_cfg = Path(args[0]), Path(args[1])

    user_text = strip_block(user_cfg.read_text())
    try:
        user = tomllib.loads(user_text)
    except tomllib.TOMLDecodeError as e:
        print(f"   your config does not parse as TOML ({e}); not touching it", file=sys.stderr)
        return 1
    user_keys = user.get("keys", {})

    bindings = herdr_default_bindings()
    bindings.update({k: v for k, v in user_keys.items() if isinstance(v, str)})
    add_rename_tab = "rename_tab" not in user_keys
    if add_rename_tab:
        bindings["rename_tab"] = "prefix+comma"
    taken = {v: f"Herdr's {k}" for k, v in bindings.items() if v}
    for cmd in user_keys.get("command", []):
        taken[cmd.get("key", "")] = f"your command '{cmd.get('command', '?')}'"

    kept, skipped = [], []
    for key, block in shortcut_blocks(repo_cfg.read_text()):
        (skipped if key in taken else kept).append((key, block))

    managed = [BEGIN, "# Managed by herdr-setup/install.sh: changes inside this block are overwritten.", ""]
    if add_rename_tab and "[keys]" not in user_text.splitlines():
        managed += ["[keys]", RENAME_TAB, ""]
    managed += [block for _, block in kept] + [END]
    result = user_text
    if add_rename_tab and "[keys]" in result.splitlines():
        result = result.replace("[keys]\n", f"[keys]\n{RENAME_TAB}\n", 1)
    result = result.rstrip() + "\n\n" + "\n".join(managed) + "\n"

    try:
        tomllib.loads(result)
    except tomllib.TOMLDecodeError as e:
        print(f"   the merged config would not parse ({e}); not touching it", file=sys.stderr)
        return 1

    print(f"   {len(kept)} shortcuts added inside the '{BEGIN}' block")
    if add_rename_tab:
        print("   rename_tab moved to prefix+comma (prefix+shift+t opens tables)")
    for key, block in skipped:
        what = re.search(r'^command = "([^"]+)"', block, re.M).group(1).split("/")[-1]
        print(f"   skipped {key} ({what}): already used by {taken[key]}")
    if dry_run:
        print(result)
    else:
        user_cfg.write_text(result)
    return 0


if __name__ == "__main__":
    sys.exit(main())
