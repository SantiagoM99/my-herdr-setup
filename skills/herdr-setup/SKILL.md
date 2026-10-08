---
name: herdr-setup
description: "Change the user's Herdr mini-IDE setup (the herdr-setup repo): add, move or remove a shortcut, add a viewer or tool, change what yazi opens a file type with, change the background-job status bar, or update the installer and README. Use when the user asks to add a Herdr shortcut or keybinding, open something in a pane or popup, change which program opens .md/.pdf/.csv/parquet files, configure job-status, or edit herdr-setup. Not for driving panes or agents in a live session (that is the `herdr` skill)."
---

# herdr-setup

The user's Herdr configuration is a git repo that is installed by symlinks, so the repo is the single source of truth. Never edit the installed copies; edit the repo.

## Find the repo

```bash
REPO=$(dirname "$(dirname "$(readlink ~/.config/herdr/config.toml)")")
```

If `~/.config/herdr/config.toml` is not a symlink, the setup is not installed: ask the user where the repo is, or offer to run its `install.sh`.

| Path in the repo | Installed as | Holds |
|---|---|---|
| `config/config.toml` | `~/.config/herdr/config.toml` | Prefix, shortcuts, tab bar entry |
| `config/yazi/yazi.toml` | `~/.config/yazi/yazi.toml` | What Enter opens each file type with |
| `config/micro/settings.json` | `~/.config/micro/settings.json` | micro editor settings |
| `bin/*` | `~/.local/bin/*` | Helper scripts |
| `install.sh` | — | Installs programs, links configs or merges into existing ones |
| `lib/merge-herdr-config.py` | — | Merges the shortcuts into an existing Herdr config |
| `lib/filter-yazi-config.py` | — | yazi config without the openers of components left out |
| `README.md` | — | The user's cheat sheet |

Per-machine values never go in the repo. `job-status` reads `~/.config/herdr-setup/job-status.conf`; follow the same pattern for anything else that names a machine, project, path or credential.

## Two install modes

`install.sh` links the configs on a clean machine (and on the user's), but **merges** into a Herdr config someone already has: `lib/merge-herdr-config.py` writes the repo's `[[keys.command]]` entries into a `# >>> herdr-setup >>>` block at the end of their file, skips any key they already use, and never changes their prefix or options. Existing yazi configs are left alone; micro settings get missing keys added. Keep both modes working:

- Every shortcut must be a self-contained `[[keys.command]]` entry in `config/config.toml` (that is what the merge copies). Settings outside those entries, like `prefix` or `tab_bar_right`, do not reach merged installs; if one is needed, handle it in the merge script.
- After changing `config/config.toml`, `install.sh` or the merge script, test the merge in a fake home: `env HOME=$(mktemp -d) PATH="$HOME/.local/bin:$PATH" zsh ./install.sh --skip-programs` with a sample `~/.config/herdr/config.toml` inside it, then `env XDG_CONFIG_HOME=<that home>/.config herdr config check`. Re-run it to confirm the block is replaced, not duplicated.

## Components

`install.sh --only` / `--without` install a subset. Each component in `install.sh` lists its Homebrew formulas (`BREW`), the word that identifies its shortcuts in `config/config.toml` (`SHORTCUT`, matched against `command`), and its opener in `yazi.toml` (`OPENER`). A selective install copies a filtered config instead of linking (`lib/filter-yazi-config.py` for yazi, `merge-herdr-config.py --exclude` for Herdr). When adding a tool, add it to an existing component or create one in all three maps, add it to `DESC`, and list it in the README's component line. Test with `--only` and `--without` in a fake home.

## Rules

1. **English only** in the repo: code, comments, prompts, messages, README, commit messages. The user may talk to you in Spanish; the repo stays English.
2. **Nothing project-specific.** No project names, private paths or script names from other repos. Use a local config file outside the repo instead, and generic examples in the README.
3. **Shortcut scheme.** The prefix is whatever `[keys] prefix` says (the user's is a backtick). The letter says what opens; Shift says where:
   - `prefix+<letter>`: a pane on the right, through `herdr-side <command>` with `type = "shell"`.
   - `prefix+shift+<letter>`: a popup, `type = "popup"`, `width`/`height` around 90–95%.
   - A tool that only makes sense full screen (git, Docker) gets the popup only.
4. **No collisions.** Before choosing a key, list Herdr's defaults and the repo's bindings:
   ```bash
   herdr --default-config | grep -oE '"prefix\+[^"]+"' | sort -u
   grep -n 'key = \|_tab = \|_pane = ' "$REPO/config/config.toml"
   ```
   Prefer a letter whose lowercase and Shift forms are both free. Never use `d`: `prefix+shift+d` closes the whole workspace, one missed Shift away. The user accepted Shift+H/J/K/L (lowercase is pane focus) for popup-only tools. If no letter fits, propose options and ask; moving a Herdr default (as `rename_tab` went to `prefix+comma`) needs the user's consent.
5. **Panes must close when the program exits.** `herdr-side` runs the command with `exec`; keep it that way. Programs that need a picker go through `herdr-pick '<Prompt>> ' '<glob>' …` (fzf, newest first).
6. **Reuse before adding.** A new viewer is usually a line in `yazi.toml` plus, if it deserves a key, a pair of bindings. Logic used by two scripts goes in its own script in `bin/`.

## Workflow for a change

1. Read the README's shortcut table and `config/config.toml` to see the current state.
2. Make the change in the repo. New programs go into `install.sh` (`brew install …` line, or `uv tool install` for Python tools).
3. New script: add it under `bin/`, `chmod +x`, and link it now with `ln -s "$REPO/bin/<name>" ~/.local/bin/<name>` (the installer does this on other machines). Renamed script: remove the old link in `~/.local/bin`.
4. Reload and check diagnostics are empty: `herdr server reload-config`.
5. Test in a temporary pane you create and close yourself (requires `HERDR_ENV=1`; see the `herdr` skill). Never touch the user's panes:
   ```bash
   NEW=$(herdr pane split --current --direction right --ratio 0.5 --cwd "$PWD" --no-focus | jq -r '.result.pane.pane_id')
   herdr pane run "$NEW" "exec <command>"
   herdr pane wait-output "$NEW" --regex '<something it prints>' --timeout 10000
   herdr pane read "$NEW" --source visible
   herdr pane close "$NEW"
   ```
   You cannot press the prefix shortcut itself from here. Say so, and say what you tested instead (the command behind it). Do test-edits on throwaway files in a temp directory, never on the user's documents, and do not run commands that regenerate the user's outputs.
6. Update `README.md`: the shortcut table (with the Exit column), the yazi table, or the support list, whichever applies. Keep it short: no explanations of internals, and the support list holds only tools the user runs directly, not their dependencies.
7. Search for leftovers: `grep -rnIiE '[áéíóúñ¿]' --exclude-dir=.git .` and any old names you replaced.
8. Before committing, reread every line you wrote (README, comments, messages) and cut filler, sales phrases, repeated explanations and anything a user does not need. Check that requirements and claims are still true after the change.
9. Commit in English: imperative summary under 72 characters, bullets for what changed. Push only if the user asks.
10. Report to the user: the new shortcut or behaviour, what you tested, what you could not test.

## Known traps

- glow's own viewer treats the left arrow as "back to file list"; that is why `herdr-md` renders glow into `less`. Do not switch it back to `glow -t`.
- `type = "shell"` commands run without the user's interactive PATH; use full paths (`~/.local/bin/...`) in `config.toml`.
- Apple Terminal cannot show images; PDF and image previews need Herdr running inside Ghostty, Kitty or WezTerm. A blank tdf page there is not a bug.
- Harlequin quits with Ctrl+Q, the log viewer with Ctrl+C, everything else with `q`. Keep the README's Exit column accurate.
