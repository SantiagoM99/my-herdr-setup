# herdr-setup

This is my Herdr configuration for using it as a mini-IDE. It allows visualizing files, Markdown, PDF, tables, logs, SQL, git and Docker, in a pane on the right or in a popup. This is very useful when working continously on a document or other product that keeps being updated by the agent. 

## The prefix is `` ` ``

Every shortcut starts with the **prefix** `` ` `` (backtick, the key left of 1 on a US keyboard). Herdr's default prefix is `ctrl+b`, however I find having a single key much easier to work with; this setup changes it in `config/config.toml`:

```toml
[keys]
prefix = "`"
```

If it's not for you, change that line and reload. The shortcuts below work the same with any prefix.

## Shortcuts

The shortcuts are designed so when the lowercase is pressed it opens a pane on the right (half the width), and Shift opens a floating popup.

| What | Pane on the right | Popup | How to exit |
|---|---|---|---|
| Files (yazi) | `` ` `` `f` | `` ` `` `Shift+F` | `q` |
| Markdown (picker + glow) | `` ` `` `m` | `` ` `` `Shift+M` | `q` |
| PDF (picker + tdf) | `` ` `` `a` | `` ` `` `Shift+A` | `q` |
| CSV / parquet / xlsx tables (visidata) | `` ` `` `t` | `` ` `` `Shift+T` | `q` |
| Live logs | `` ` `` `u` (most recent) | `` ` `` `Shift+U` (pick one) | Ctrl+C |
| SQL (harlequin) | `` ` `` `y` | `` ` `` `Shift+Y` | Ctrl+Q |
| Git (lazygit) | — | `` ` `` `Shift+J` | `q` |
| Docker (lazydocker) | — | `` ` `` `Shift+K` | `q` |
| VS Code in the current directory | `` ` `` `i` | — | — |

When the program exits, its pane or popup closes by itself. 

**Reading Markdown** (`m`, `Shift+M`, or Enter on a `.md` in yazi): glow renders the file to the pane width (wide tables wrap to fit) and `less` shows it. Arrows or `j`/`k` scroll, `/` searches, `e` edits the file with micro in the same pane (Ctrl+S saves, Ctrl+Q comes back to the rendered view), `r` re-renders after resizing the pane, `q` quits.

**The pickers** (Markdown, PDF, tables, logs with `Shift+U`) list the files in the current directory and its subdirectories, newest just above the cursor. Type part of the name to filter, arrows to move, Enter to open, Esc to leave.

## yazi as the hub

`config/yazi/yazi.toml` makes Enter open each file in its program without leaving the terminal; `O` (capital) lets you pick another. Quitting with `q` returns to yazi; another `q` closes yazi.

| File | Enter | Other options (`O`) |
|---|---|---|
| `.pdf` | tdf | Preview |
| `.csv` `.tsv` `.parquet` `.xlsx` `.json` `.jsonl` | visidata | editor, default app |
| `.md` | glow (`e` edits with micro) | VS Code |
| `.log` | `tail -F` (Ctrl+C exits) | editor |
| Code and text | `$EDITOR` (VS Code) | — |

| Key in yazi | What it does |
|---|---|
| `z` | Jump to a file by typing part of its name |
| `s` | Search files by name (fd) |
| `S` | Search files by content (ripgrep) |
| `f` | Filter the current directory as you type |
| `,` `m` | Sort by modification time |
| Esc | Leave the search or filter |

## SQL with harlequin

harlequin opens DuckDB by default, which queries parquet and CSV files directly; paths are relative to the directory it was opened in. Ctrl+Enter runs the query.

```sql
select cohort, count(*)
from 'data/students.parquet'
group by 1 order by 1;
```

It also ships the Postgres and SQLite adapters. Passwords go in `~/.pgpass`, never in this repo.

## Status bar: background job

`job-status` shows in the tab bar, every 10 seconds, whether a background job you care about (an ETL, a build, a long script) is running or has just written its output: `⚠ ETL running`, `⚠ ETL wrote <15 min ago` or `ETL idle`. It is handy when you should not read files that job is in the middle of rewriting.

It reads `~/.config/herdr-setup/job-status.conf`, which lives outside the repo so each machine watches its own job. Without that file the bar shows nothing.

```zsh
LABEL="ETL"                    # name shown in the bar
PROCESS="etl.py"               # pgrep -f pattern
DIR="$HOME/path/to/output"     # directory the job writes to
PATTERN="*.parquet"            # files that count (default: all)
MINUTES=15                     # how recent counts as "just wrote" (default: 15)
```

## Installation (macOS)

```bash
git clone <this repo> herdr-setup
cd herdr-setup && ./install.sh
```

`install.sh` installs the programs with Homebrew and `uv`, symlinks `bin/*` into `~/.local/bin`, `config/config.toml` into `~/.config/herdr/` `config/yazi/yazi.toml` into `~/.config/yazi/` and `config/micro/settings.json` into `~/.config/micro/`, and sets VS Code as `$EDITOR` if none is set. Anything already there is backed up as `<file>.bak-<timestamp>`.

Because they are symlinks, editing the repo changes the live install; after editing the config, reload with `` ` `` `Shift+R`.

Requires Homebrew, Herdr and VS Code with the `code` command on the PATH. To see PDFs and images inside the terminal, run Herdr from Ghostty, Kitty or WezTerm: Apple Terminal does not display images.

## Scripts

| Script | What it does |
|---|---|
| `herdr-side <command>` | Opens the command in a new pane to the right of the focused pane, in its directory |
| `herdr-pick <prompt> <patterns…>` | fzf picker over files in the current directory, newest first |
| `herdr-pdf` | Picks a PDF and opens it with tdf (reloads by itself when the PDF changes) |
| `herdr-data` | Picks a table and opens it in visidata |
| `herdr-md [file]` | Renders Markdown with glow inside less; `e` edits in micro |
| `herdr-log [--pick]` | `tail -F` of the most recent `.log` |
| `job-status` | Tab bar line with the status of a background job |
