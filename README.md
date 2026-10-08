# my-herdr-setup

My Herdr configuration for using it as a mini-IDE: files, Markdown, PDFs, tables, logs, SQL, git and Docker open in a pane on the right or in a popup. Useful when an agent keeps updating a document while you work on it.

## Install (macOS)

```bash
git clone https://github.com/SantiagoM99/my-herdr-setup.git
cd my-herdr-setup && ./install.sh
```

Requires Homebrew and Herdr. PDFs and images display only in terminals with image support, such as Ghostty, Kitty or WezTerm; Apple Terminal does not.

To install only some tools, pick components (`./install.sh --list`): `files`, `markdown`, `pdf`, `tables`, `logs`, `sql`, `git`, `docker`, `vscode`.

```bash
./install.sh --only files,markdown,git
./install.sh --without docker,sql
```

The installer backs up any file it changes as `<file>.bak-<timestamp>`. `--skip-programs` skips installing programs; `--replace` replaces existing configs instead of merging.

**Already using Herdr?** Your config is kept: the shortcuts are added in a marked block at the end of your `config.toml`, your prefix stays, and any shortcut whose key you already use is skipped (the installer says which). An existing `yazi.toml` is left alone. Run `./install.sh` again to update.

## Prefix

Every shortcut starts with the prefix `` ` `` (backtick). Herdr's default is `ctrl+b`; I find a single key easier. To change it, edit `prefix` in `config/config.toml` and reload with `` ` `` `Shift+R`.

## Shortcuts

Lowercase opens a pane on the right; Shift opens a popup. The pane or popup closes when the program exits.

| What | Pane | Popup | Exit |
|---|---|---|---|
| Files (yazi) | `` ` `` `f` | `` ` `` `Shift+F` | `q` |
| Markdown (glow) | `` ` `` `m` | `` ` `` `Shift+M` | `q` |
| PDF (tdf) | `` ` `` `a` | `` ` `` `Shift+A` | `q` |
| Tables: CSV, parquet, xlsx (VisiData) | `` ` `` `t` | `` ` `` `Shift+T` | `q` |
| Latest log, live | `` ` `` `u` | `` ` `` `Shift+U` (pick one) | Ctrl+C |
| SQL (Harlequin) | `` ` `` `y` | `` ` `` `Shift+Y` | Ctrl+Q |
| Git (lazygit) | — | `` ` `` `Shift+J` | `q` |
| Docker (lazydocker) | — | `` ` `` `Shift+K` | `q` |
| VS Code in the current directory | `` ` `` `i` | — | — |

Markdown, PDF, tables and `Shift+U` start with a file picker: type part of a name, Enter to open, Esc to cancel.

In the Markdown viewer: `e` edits the file in micro (Ctrl+S saves, Ctrl+Q returns), `r` re-renders after resizing, `/` searches.

`rename_tab` moves from `` ` `` `Shift+T` to `` ` `` `,` to make room for tables.

## yazi

Enter opens each file in the terminal; `O` offers other programs.

| File | Enter |
|---|---|
| `.pdf` | tdf |
| `.csv` `.tsv` `.parquet` `.xlsx` `.json` | VisiData |
| `.md` | glow |
| `.log` | `tail -F` |
| Anything else | `$EDITOR` |

Search: `z` jumps to a file by name, `s` searches names, `S` searches contents, `f` filters the current directory.

## Status bar

`job-status` shows in the tab bar whether a background job is running or wrote output recently: `⚠ ETL running`, `⚠ ETL wrote <15 min ago`, `ETL idle`. Configure it in `~/.config/herdr-setup/job-status.conf`; without that file it shows nothing.

```zsh
LABEL="ETL"                  # name shown in the bar
PROCESS="etl.py"             # pgrep -f pattern
DIR="$HOME/path/to/output"   # directory the job writes to
PATTERN="*.parquet"          # optional, default: all files
MINUTES=15                   # optional, default: 15
```

## Changing the setup with an agent

`skills/herdr-setup/SKILL.md` describes the layout and conventions so Claude Code can add or change shortcuts. `install.sh` links it into `~/.claude/skills/`; `AGENTS.md` points other agents to it.

## Support the tools

These are open source. If one earns a place in your workflow, consider sponsoring it or giving it a star.

| Tool | Support |
|---|---|
| [Herdr](https://github.com/herdrdev/herdr) | [Star](https://github.com/herdrdev/herdr) |
| [yazi](https://github.com/sxyazi/yazi) | [Star](https://github.com/sxyazi/yazi) |
| [glow](https://github.com/charmbracelet/glow) | [Star](https://github.com/charmbracelet/glow) |
| [micro](https://github.com/micro-editor/micro) | [Star](https://github.com/micro-editor/micro) |
| [tdf](https://github.com/itsjunetime/tdf) | [GitHub Sponsors](https://github.com/sponsors/itsjunetime) |
| [VisiData](https://github.com/saulpw/visidata) | [GitHub Sponsors](https://github.com/sponsors/saulpw) · [Patreon](https://www.patreon.com/saulpw) |
| [Harlequin](https://github.com/tconbeer/harlequin) | [GitHub Sponsors](https://github.com/sponsors/tconbeer) |
| [lazygit](https://github.com/jesseduffield/lazygit) | [GitHub Sponsors](https://github.com/sponsors/jesseduffield) · [Donorbox](https://donorbox.org/lazygit) |
| [lazydocker](https://github.com/jesseduffield/lazydocker) | [GitHub Sponsors](https://github.com/sponsors/jesseduffield) |
