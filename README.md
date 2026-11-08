# my-herdr-setup

My Herdr configuration for using it as a mini-IDE: browse files with yazi or find any file by name or contents, and it opens in a pane on the right or in a popup with the right viewer (Markdown, PDF, tables, logs, code). Plus local dictation in Spanish and English. Useful when an agent keeps updating a document while you work on it.

## Install (macOS)

```bash
git clone https://github.com/SantiagoM99/my-herdr-setup.git
cd my-herdr-setup && ./install.sh
```

Requires Homebrew and Herdr. PDFs and images display only in terminals with image support, such as Ghostty, Kitty or WezTerm; Apple Terminal does not.

To install only some tools, pick components (`./install.sh --list`): `files`, `markdown`, `pdf`, `tables`, `logs`, `dictation`, `vscode`.

```bash
./install.sh --only files,markdown,pdf
./install.sh --without tables
```

The installer backs up any file it changes as `<file>.bak-<timestamp>`. `--skip-programs` skips installing programs; `--replace` replaces existing configs instead of merging.

**Already using Herdr?** Your config is kept: the shortcuts are added in a marked block at the end of your `config.toml`, your prefix stays, and any shortcut whose key you already use is skipped (the installer says which). An existing `yazi.toml` or `keymap.toml` is left alone. Run `./install.sh` again to update.

## Prefix

Every shortcut starts with the prefix `` ` `` (backtick). Herdr's default is `ctrl+b`; I find a single key easier. To change it, edit `prefix` in `config/config.toml` and reload with `` ` `` `Shift+R`.

## Shortcuts

Lowercase opens a pane on the right; Shift opens a popup. The pane or popup closes when the program exits.

| What | Pane | Popup | Exit |
|---|---|---|---|
| Files (yazi) | `` ` `` `f` | `` ` `` `Shift+F` | `q` |
| Find a file and open it | `` ` `` `a` | `` ` `` `Shift+A` | Esc |
| Latest log, live | `` ` `` `u` | — | Ctrl+C |
| Dictate (press again to stop) | `` ` `` `m` | — | `` ` `` `m` |
| VS Code in the current directory | `` ` `` `i` | — | — |

## Finder

`` ` `` `a` lists the files under the current directory, newest first, and opens the one you pick with the program for its type (table below). `Ctrl+T` switches to searching contents; Enter then opens the file at that line. Gitignored files are included; hidden directories, `node_modules`, `venv` and `__pycache__` are not.

## Dictation

`` ` `` `m` starts recording; `` ` `` `m` again stops it, transcribes it on your Mac and types the text into the focused pane without pressing Enter, so you can review it first. The tab bar shows a blinking `🔴 REC 0:12` while recording and `⏳ Transcribing` after (a second or two); the job status is hidden meanwhile. Recording stops by itself after 5 minutes.

- **Model:** Whisper large-v3-turbo through whisper.cpp, with Silero voice detection so silence does not turn into invented text. The installer downloads both (about 550 MB) to `~/.local/share/herdr-setup/`. Nothing leaves the computer.
- **Languages:** detected per dictation. English works best; Spanish works well and keeps most English terms, and the vocabulary fixes the rest.
- **Vocabulary:** words it should spell right (names, jargon) go comma-separated in `~/.config/herdr-setup/dictate-words.txt`, for example `ChatGPT, fine-tuning, learning rate`. Keep it short: Whisper reads about 220 tokens of it.
- **Tuning:** each dictation is logged with its language and audio (the last 50) in `~/.local/share/herdr-setup/dictations/`. Ask Claude Code to "review my dictation vocabulary": the `dictation-vocab` skill finds the words being mis-transcribed, re-transcribes your audio to show each fix works, and edits the list after you approve.

The first time, macOS asks for microphone access for your terminal.

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

Besides the dictation indicator, `job-status` shows in the tab bar whether a background job is running or wrote output recently: `⚠ ETL running`, `⚠ ETL wrote <15 min ago`, `ETL idle`. Configure it in `~/.config/herdr-setup/job-status.conf`; without that file it shows nothing.

```zsh
LABEL="ETL"                  # name shown in the bar
PROCESS="etl.py"             # pgrep -f pattern
DIR="$HOME/path/to/output"   # directory the job writes to
PATTERN="*.parquet"          # optional, default: all files
MINUTES=15                   # optional, default: 15
```

## How it works

- `install.sh` symlinks the configs (`config/`) into `~/.config` and the scripts (`bin/`) into `~/.local/bin`, so editing this repo changes the live setup.
- `herdr-open` decides which program opens each file type. yazi and the finder both call it, so a change there applies to both.
- `herdr-side` opens a command in a new pane to the right; each pane runs its program with `exec`, so it closes when the program exits.
- `herdr-find` (finder), `herdr-dictate` (dictation, and its tab bar status), `herdr-log` and `job-status` back the other shortcuts.

## Changing the setup with an agent

Two Claude Code skills come with the repo; `install.sh` links them into `~/.claude/skills/`:

- `herdr-setup` describes the layout and conventions, so Claude Code can add or change shortcuts, viewers and installer components. `AGENTS.md` points other agents to it.
- `dictation-vocab` tunes the dictation vocabulary (see Dictation).

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
