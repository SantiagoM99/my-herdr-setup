# my-herdr-setup

My Herdr mini-IDE setup: browse and search files, open Markdown, PDFs, tables, logs and code in panes or popups, and dictate locally in Spanish and English.

## Install (macOS)

```bash
git clone https://github.com/SantiagoM99/my-herdr-setup.git
cd my-herdr-setup && ./install.sh
```

Requires Homebrew and Herdr. PDFs and images display only in terminals with image support, such as Ghostty, Kitty or WezTerm; Apple Terminal does not.

To install only some tools, pick components (`./install.sh --list`): `files`, `markdown`, `pdf`, `tables`, `dictation`, `vscode`.

```bash
./install.sh --only files,markdown,pdf
./install.sh --without tables
```

The installer backs up replaced or merged configs as `<file>.bak-<timestamp>`. `--skip-programs` skips installing programs; `--replace` replaces existing configs instead of merging.

Existing Herdr configs keep their prefix and settings. The installer merges shortcuts, reports key conflicts and leaves existing yazi configs alone. Rerun the installer to update merged shortcuts; selective installs also use merging. A full install with no existing configs links them to this repo.

## Prefix

The shortcuts below use this setup's prefix, `` ` `` (backtick). If you kept an existing config, use your own prefix instead. To change it, edit `prefix` in `config/config.toml` for a linked install, or in your own Herdr config for a merged install, then reload with your current prefix followed by `Shift+R`.

## Shortcuts

Lowercase opens a pane on the right; Shift opens a popup. The pane or popup closes when the program exits.

| What | Pane | Popup | Exit |
|---|---|---|---|
| Files (yazi) | `` ` `` `f` | `` ` `` `Shift+F` | `q` |
| Find a file and open it | `` ` `` `a` | `` ` `` `Shift+A` | Esc |
| Dictate (press again to stop) | `` ` `` `m` | — | `` ` `` `m` |
| VS Code in the current directory | `` ` `` `i` | — | — |

## Finder

`` ` `` `a` lists files under the current directory, newest first. `Ctrl+T` switches to searching contents. Enter opens the selected file with its viewer (table below); files opened in the editor jump to the matching line. Gitignored files are included; hidden directories, `node_modules`, `venv` and `__pycache__` are not.

## Dictation

Press `` ` `` `m` to record and again to transcribe locally into the focused pane, without pressing Enter. Language is detected automatically. Recording is limited to 5 minutes; macOS asks for microphone access on first use.

The installer downloads Whisper and voice-detection models (about 550 MB). Audio stays on your Mac. Transcripts and language are logged in `~/.local/share/herdr-setup/dictations/`, alongside the last 50 audio recordings.

Add names and jargon to `~/.config/herdr-setup/dictate-words.txt`, comma-separated, for example `ChatGPT, fine-tuning, learning rate`. Keep it under about 220 tokens. Ask Claude Code to "review my dictation vocabulary" to test corrections against saved audio and propose changes for approval.

## yazi

Enter opens each file with the program for its type; `O` offers `$EDITOR`, the default app or Finder instead. The finder uses the same table.

| File | Enter |
|---|---|
| `.pdf` | tdf |
| `.csv` `.tsv` `.parquet` `.xlsx` `.json` | VisiData |
| `.md` | glow |
| `.log` | `tail -F` |
| Other text files | `$EDITOR` |
| Anything else (images, Office files, ...) | default macOS app |

In the Markdown viewer: `e` edits the file in micro (Ctrl+S saves, Ctrl+Q returns), `r` re-renders after resizing, `/` searches.

Search: `z` jumps to a file by name, `s` searches names, `S` searches contents, `f` filters the current directory.

`V` (Shift+V) copies the files copied in Finder (Cmd+C) into the current directory. It never overwrites. It replaces yazi's visual unselect mode.

## Status bar

The tab bar shows `🔴 REC 0:12` or `⏳ Transcribing` during dictation. If you kept an existing Herdr config, add the optional status bar entry printed by the installer.

Between dictations, `job-status` can show `⚠ ETL running`, `⚠ ETL wrote <15 min ago` or `ETL idle`. Enable it with `~/.config/herdr-setup/job-status.conf`:

```zsh
LABEL="ETL"                  # name shown in the bar
PROCESS="etl.py"             # pgrep -f pattern
DIR="$HOME/path/to/output"   # directory the job writes to
PATTERN="*.parquet"          # optional, default: all files
MINUTES=15                   # optional, default: 15
```

## Changing the setup with an agent

Two Claude Code skills come with the repo; `install.sh` links them into `~/.claude/skills/`:

- `herdr-setup` describes the layout and conventions, so Claude Code can add or change shortcuts, viewers and installer components. `AGENTS.md` points other agents to it.
- `dictation-vocab` tunes the dictation vocabulary (see Dictation).

`install.sh` also adds a short block to `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md` (`agents/herdr-agents.md`, between `herdr-setup` markers; the rest of each file is left alone). It tells Claude Code and Codex, in any project, that "spin up some agents" means agents in Herdr panes: one goes next to the caller, several go in a new tab of the current workspace, of the caller's own kind unless you name another, and they never touch panes they did not create.

## Support the tools

These are open source. If one earns a place in your workflow, consider sponsoring it or giving it a star.

| Tool | Support |
|---|---|
| [Herdr](https://github.com/herdrdev/herdr) | [Star](https://github.com/herdrdev/herdr) |
| [yazi](https://github.com/sxyazi/yazi) | [Star](https://github.com/sxyazi/yazi) |
| [glow](https://github.com/charmbracelet/glow) | [Star](https://github.com/charmbracelet/glow) |
| [micro](https://github.com/micro-editor/micro) | [Star](https://github.com/micro-editor/micro) |
| [tdf](https://github.com/itsjunetime/tdf) | [GitHub Sponsors](https://github.com/sponsors/itsjunetime) |
| [whisper.cpp](https://github.com/ggml-org/whisper.cpp) | [Star](https://github.com/ggml-org/whisper.cpp) |
| [VisiData](https://github.com/saulpw/visidata) | [GitHub Sponsors](https://github.com/sponsors/saulpw) · [Patreon](https://www.patreon.com/saulpw) |
