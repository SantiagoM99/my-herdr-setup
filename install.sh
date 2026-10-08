#!/bin/zsh
# Installs the Herdr setup: programs, scripts and config.
#
#   ./install.sh                  install; merge into configs you already have
#   ./install.sh --replace        replace existing configs with links to this repo (backs them up)
#   ./install.sh --skip-programs  do not install or upgrade programs with Homebrew/uv
#
# Clean machine: configs are symlinked to this repo, so editing the repo changes the live install.
# Existing Herdr config: our shortcuts go into a marked block at the end of it (see
# lib/merge-herdr-config.py); your prefix, options and bindings are kept, and a shortcut of ours
# whose key you already use is skipped. Run the installer again to update that block.
# Anything replaced is backed up as <file>.bak-<timestamp>.
set -euo pipefail
REPO=${0:A:h}
STAMP=$(date +%Y%m%d-%H%M%S)
BIN=$HOME/.local/bin
CFG=${XDG_CONFIG_HOME:-$HOME/.config}/herdr
REPLACE=false PROGRAMS=true
for arg in "$@"; do
  case $arg in
    --replace) REPLACE=true ;;
    --skip-programs) PROGRAMS=false ;;
    *) echo "unknown option: $arg"; exit 2 ;;
  esac
done

step() { print -P "%B==> $*%b"; }

link() { # link <source> <target>
  local src=$1 dst=$2
  if [[ -L $dst && ${dst:A} == ${src:A} ]]; then return; fi
  if [[ -e $dst || -L $dst ]]; then mv "$dst" "$dst.bak-$STAMP"; echo "   backup: $dst.bak-$STAMP"; fi
  ln -s "$src" "$dst"; echo "   $dst -> $src"
}

ours() { [[ -L $1 && ${1:A} == ${2:A} ]]; }   # ours <target> <source>: already linked to this repo?

step "Checks"
command -v brew >/dev/null || { echo "Homebrew is missing (https://brew.sh)"; exit 1; }
command -v herdr >/dev/null || [[ -x $BIN/herdr ]] || { echo "herdr is missing"; exit 1; }
ORIG_PATH=$PATH
export PATH=$BIN:$PATH

if $PROGRAMS; then
  step "Programs (Homebrew)"
  brew install yazi glow neovim tdf fzf jq lazygit lazydocker fd ripgrep micro

  step "visidata with parquet support (uv)"
  command -v uv >/dev/null || brew install uv
  uv tool install --upgrade visidata --with pyarrow --with openpyxl

  step "harlequin (SQL editor: DuckDB and Postgres)"
  uv tool install --upgrade 'harlequin[postgres]'
fi

step "Scripts in $BIN"
mkdir -p "$BIN"
for f in "$REPO"/bin/*; do chmod +x "$f"; link "$f" "$BIN/${f:t}"; done

step "Herdr config"
mkdir -p "$CFG"
if $REPLACE || [[ ! -e $CFG/config.toml ]] || ours "$CFG/config.toml" "$REPO/config/config.toml"; then
  link "$REPO/config/config.toml" "$CFG/config.toml"
else
  echo "   you already have $CFG/config.toml: merging our shortcuts into it"
  cp "$CFG/config.toml" "$CFG/config.toml.bak-$STAMP"; echo "   backup: $CFG/config.toml.bak-$STAMP"
  python3 "$REPO/lib/merge-herdr-config.py" "$REPO/config/config.toml" "$CFG/config.toml"
  if ! herdr config check >/dev/null 2>&1; then
    cp "$CFG/config.toml.bak-$STAMP" "$CFG/config.toml"
    echo "   Herdr rejected the merged config; restored yours. See: herdr config check"
    exit 1
  fi
  echo "   optional status bar entry (see README, 'Status bar'): add under [ui]"
  echo "     tab_bar_right = [{ type = \"command\", command = \"~/.local/bin/job-status\", interval_seconds = 10, timeout_seconds = 5 }]"
fi

step "yazi config (what opens each file)"
mkdir -p "$HOME/.config/yazi"
YAZI=$HOME/.config/yazi/yazi.toml
if $REPLACE || [[ ! -e $YAZI ]] || ours "$YAZI" "$REPO/config/yazi/yazi.toml"; then
  link "$REPO/config/yazi/yazi.toml" "$YAZI"
else
  echo "   you already have $YAZI: not touching it"
  echo "   to open PDFs, tables and Markdown in the terminal, copy the [opener] entries and"
  echo "   prepend_rules from $REPO/config/yazi/yazi.toml into yours"
fi

step "micro config (wrap long lines to the pane)"
mkdir -p "$HOME/.config/micro"
MICRO=$HOME/.config/micro/settings.json
if $REPLACE || [[ ! -e $MICRO ]] || ours "$MICRO" "$REPO/config/micro/settings.json"; then
  link "$REPO/config/micro/settings.json" "$MICRO"
else
  echo "   you already have $MICRO: adding softwrap and wordwrap unless you set them"
  cp "$MICRO" "$MICRO.bak-$STAMP"
  python3 - "$REPO/config/micro/settings.json" "$MICRO" <<'PY'
import json, sys
ours, theirs = (json.load(open(p)) for p in sys.argv[1:3])
json.dump({**ours, **theirs}, open(sys.argv[2], "w"), indent=4)
PY
fi

step "Claude Code skill (how to change this setup)"
mkdir -p "$HOME/.claude/skills"
link "$REPO/skills/herdr-setup" "$HOME/.claude/skills/herdr-setup"

step "Default editor (VS Code) in ~/.zshrc"
if ! grep -q '^export EDITOR=' ~/.zshrc 2>/dev/null; then
  printf '\n# Default editor: VS Code (--wait makes yazi, git, etc. wait until you close the tab)\nexport EDITOR="code --wait"\nexport VISUAL="code --wait"\n' >> ~/.zshrc
  echo "   added"
else
  echo "   an EDITOR is already set; leaving it alone"
fi
command -v code >/dev/null || echo "   note: the 'code' command is missing (VS Code: Cmd+Shift+P > Shell Command: Install 'code' command in PATH)"
[[ :$ORIG_PATH: == *:$BIN:* ]] || echo "   note: $BIN is not on your PATH"

step "Reload Herdr"
if herdr server reload-config 2>/dev/null; then echo; else echo "   Herdr is not running; the config is read when it starts"; fi
echo "Done. Shortcuts are in README.md; they use your prefix (prefix+f, prefix+shift+f, ...)."
