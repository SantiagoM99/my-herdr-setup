#!/bin/zsh
# Installs the Herdr setup: programs, scripts and config.
# Scripts and config are symlinked to this repo, so editing here changes the live install
# (after editing the config: prefix+shift+r or `herdr server reload-config`).
# Anything already there that is not a link to this repo is backed up as <file>.bak-<timestamp>.
set -euo pipefail
REPO=${0:A:h}
STAMP=$(date +%Y%m%d-%H%M%S)
BIN=$HOME/.local/bin
CFG=$HOME/.config/herdr

step() { print -P "%B==> $*%b"; }

link() { # link <source> <target>
  local src=$1 dst=$2
  if [[ -L $dst && ${dst:A} == ${src:A} ]]; then return; fi
  if [[ -e $dst || -L $dst ]]; then mv "$dst" "$dst.bak-$STAMP"; echo "   backup: $dst.bak-$STAMP"; fi
  ln -s "$src" "$dst"; echo "   $dst -> $src"
}

step "Checks"
command -v brew >/dev/null || { echo "Homebrew is missing (https://brew.sh)"; exit 1; }
command -v herdr >/dev/null || [[ -x $BIN/herdr ]] || { echo "herdr is missing"; exit 1; }

step "Programs (Homebrew)"
brew install yazi glow neovim tdf fzf jq lazygit lazydocker fd ripgrep micro

step "visidata with parquet support (uv)"
command -v uv >/dev/null || brew install uv
uv tool install --upgrade visidata --with pyarrow --with openpyxl

step "harlequin (SQL editor: DuckDB and Postgres)"
uv tool install --upgrade 'harlequin[postgres]'

step "Scripts in $BIN"
mkdir -p "$BIN"
for f in "$REPO"/bin/*; do chmod +x "$f"; link "$f" "$BIN/${f:t}"; done

step "Herdr config in $CFG"
mkdir -p "$CFG"
link "$REPO/config/config.toml" "$CFG/config.toml"

step "yazi config (what opens each file)"
mkdir -p "$HOME/.config/yazi"
link "$REPO/config/yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml"

step "micro config (wrap long lines to the pane)"
mkdir -p "$HOME/.config/micro"
link "$REPO/config/micro/settings.json" "$HOME/.config/micro/settings.json"

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
[[ :$PATH: == *:$BIN:* ]] || echo "   note: $BIN is not on your PATH"

step "Reload Herdr"
if herdr server reload-config 2>/dev/null; then echo; else echo "   Herdr is not running; the config is read when it starts"; fi
echo "Done. Shortcuts are in README.md. If your prefix is not \`, change it in config/config.toml."
