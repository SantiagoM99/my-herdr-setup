# herdr-setup

My Herdr configuration for using it as a mini-IDE: files, Markdown, PDF, tables, logs, SQL, git and Docker one shortcut away, in a pane on the right or in a popup.

## The prefix is `` ` ``

Every shortcut starts with the **prefix** `` ` `` (backtick, the key left of 1 on a US keyboard). Press and release it, then the letter: `` ` `` `f` means "backtick, then f". Herdr's default prefix is `ctrl+b`; this setup changes it in `config/config.toml`:

```toml
[keys]
prefix = "`"
```

To use another prefix, change that line and reload. The shortcuts below work the same with any prefix.

## Shortcuts

The letter says what opens; Shift says where: lowercase opens a pane on the right (half the width), Shift opens a floating popup.

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

When the program exits, its pane or popup closes by itself. **Reading Markdown** (`m`, `Shift+M`, or Enter on a `.md` in yazi): glow renders the file to the pane width (wide tables wrap to fit) and `less` shows it. Arrows or `j`/`k` scroll, `/` searches, `e` edits the file with micro in the same pane (Ctrl+S saves, Ctrl+Q comes back to the rendered view), `r` re-renders after resizing the pane, `q` quits. micro is only used there; VS Code stays the editor for everything else. glow's own viewer is not used because its left arrow means "back to the file list", so a table scrolled right could not be scrolled back.

**The pickers** (Markdown, PDF, tables, logs with `Shift+U`) list the files in the current directory and its subdirectories, newest just above the cursor. Type part of the name to filter (`q3rep` finds `2026_q3_report.pdf`; several space-separated words must all match), arrows to move, Enter to open, Esc to leave.

### Herdr shortcuts worth knowing

| Shortcut | What it does |
|---|---|
| `` ` `` `?` | Help with every shortcut |
| `` ` `` `Shift+R` | Reload the config |
| `` ` `` `v` / `` ` `` `-` | Split the pane to the right / down |
| `` ` `` `h` `j` `k` `l` | Move to the pane on the left, below, above, right |
| `` ` `` `z` | Zoom: current pane full screen and back |
| `` ` `` `x` | Close the pane |
| `` ` `` `c` | New tab |
| `` ` `` `,` | Rename tab (Herdr's default is `Shift+T`; moved to leave `t` to tables) |
| `` ` `` `Shift+D` | **Close the whole workspace.** That is why no shortcut in this setup uses `d` |

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

## Status bar: ETL

`etl-status` shows in the tab bar whether the Observatory-Data-Flow ETL is writing parquets (`⚠ ETL running`, `⚠ ETL wrote <15 min ago` or `ETL idle`), every 10 seconds. If the ETL directory does not exist it shows nothing; `ETL_DIR` changes the directory.

## Installation (macOS)

```bash
git clone <this repo> ~/Projects/Personal/herdr-setup
~/Projects/Personal/herdr-setup/install.sh
```

`install.sh` installs the programs with Homebrew and `uv`, symlinks `bin/*` into `~/.local/bin`, `config/config.toml` into `~/.config/herdr/` and `config/yazi/yazi.toml` into `~/.config/yazi/`, and sets VS Code as `$EDITOR` if none is set. Anything already there is backed up as `<file>.bak-<timestamp>`.

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
| `etl-status` | Tab bar line with the ETL status |
