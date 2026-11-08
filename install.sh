#!/bin/zsh
# Installs the Herdr setup: programs, scripts and config.
#
#   ./install.sh                     install everything; merge into configs you already have
#   ./install.sh --only files,pdf    install only these components
#   ./install.sh --without tables    install everything except these components
#   ./install.sh --list              list the components
#   ./install.sh --replace           replace existing configs with links to this repo (backs them up)
#   ./install.sh --skip-programs     do not install or upgrade programs with Homebrew/uv
#
# Clean machine, everything selected: configs are symlinked to this repo, so editing the repo
# changes the live install. Otherwise the Herdr shortcuts go into a marked block at the end of
# your config.toml (see lib/merge-herdr-config.py): your prefix, options and bindings are kept,
# a shortcut whose key you already use is skipped, and components you left out get no shortcuts.
# Run the installer again to update that block. Anything replaced is backed up as <file>.bak-<timestamp>.
set -euo pipefail
REPO=${0:A:h}
STAMP=$(date +%Y%m%d-%H%M%S)
BIN=$HOME/.local/bin
CFG=${XDG_CONFIG_HOME:-$HOME/.config}/herdr

COMPONENTS=(files markdown pdf tables dictation vscode)
typeset -A DESC=(
  files    "File manager (yazi) and finder by name or contents (fd, ripgrep)"
  markdown "Markdown viewer and editor (glow, micro)"
  pdf      "PDF viewer (tdf)"
  tables   "CSV, parquet and Excel tables (VisiData)"
  dictation "Dictation in Spanish and English, transcribed locally (whisper.cpp, sox)"
  vscode   "VS Code as \$EDITOR and the i shortcut"
)
typeset -A BREW=(files "yazi fd ripgrep" markdown "glow micro" pdf tdf dictation "whisper-cpp sox")
# Words (comma-separated) that identify a component's shortcuts in config/config.toml (matched against `command`).
typeset -A SHORTCUT=(files yazi,herdr-find dictation herdr-dictate vscode "code .")

REPLACE=false PROGRAMS=true ONLY= WITHOUT=
while (( $# )); do
  case $1 in
    --replace) REPLACE=true ;;
    --skip-programs) PROGRAMS=false ;;
    --only) ONLY=${2:?--only needs a list}; shift ;;
    --without) WITHOUT=${2:?--without needs a list}; shift ;;
    --list) for c in $COMPONENTS; do printf '  %-9s %s\n' $c "${DESC[$c]}"; done; exit 0 ;;
    *) echo "unknown option: $1 (see the top of install.sh)"; exit 2 ;;
  esac
  shift
done

for c in ${(s:,:)ONLY} ${(s:,:)WITHOUT}; do
  (( ${COMPONENTS[(Ie)$c]} )) || { echo "unknown component: $c (./install.sh --list)"; exit 2; }
done
if [[ -n $ONLY ]]; then SELECTED=(${(s:,:)ONLY}); else SELECTED=($COMPONENTS); fi
WITHOUT_LIST=(${(s:,:)WITHOUT})
SELECTED=(${SELECTED:|WITHOUT_LIST})
EXCLUDED=(${COMPONENTS:|SELECTED})
SELECTIVE=$(( ${#EXCLUDED} > 0 ))
if (( SELECTIVE )) && $REPLACE; then echo "--replace installs everything; do not combine it with --only/--without"; exit 2; fi
has() { (( ${SELECTED[(Ie)$1]} )); }

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
echo "   components: ${SELECTED[*]}"

if $PROGRAMS; then
  step "Programs (Homebrew)"
  FORMULAS=(fzf jq)
  for c in $SELECTED; do FORMULAS+=(${=BREW[$c]:-}); done
  brew install $FORMULAS

  if has tables; then
    command -v uv >/dev/null || brew install uv
    step "visidata with parquet support (uv)"
    uv tool install --upgrade visidata --with pyarrow --with openpyxl
  fi
fi

if $PROGRAMS && has dictation; then
  step "Whisper models for dictation (about 550 MB, once)"
  MODELS=$HOME/.local/share/herdr-setup
  mkdir -p "$MODELS"
  for url in https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo-q5_0.bin \
             https://huggingface.co/ggml-org/whisper-vad/resolve/main/ggml-silero-v5.1.2.bin; do
    f=$MODELS/${url:t}
    if [[ -s $f ]]; then echo "   have ${url:t}"; continue; fi
    curl -L --fail --progress-bar -o "$f.part" "$url" && mv "$f.part" "$f"
  done
fi

step "Scripts in $BIN"
mkdir -p "$BIN"
for f in "$REPO"/bin/*; do chmod +x "$f"; link "$f" "$BIN/${f:t}"; done

step "Herdr config"
mkdir -p "$CFG"
HERDR_CFG=$CFG/config.toml
if ! (( SELECTIVE )) && { $REPLACE || [[ ! -e $HERDR_CFG ]] || ours "$HERDR_CFG" "$REPO/config/config.toml"; }; then
  link "$REPO/config/config.toml" "$HERDR_CFG"
else
  if [[ ! -e $HERDR_CFG ]] || ours "$HERDR_CFG" "$REPO/config/config.toml"; then
    # Selective install on a machine without a config of its own: start from our prefix and
    # status bar, then merge only the selected shortcuts.
    [[ -e $HERDR_CFG ]] && { mv "$HERDR_CFG" "$HERDR_CFG.bak-$STAMP"; echo "   backup: $HERDR_CFG.bak-$STAMP"; }
    printf '%s\n' '[ui]' \
      'tab_bar_right = [{ type = "command", command = "~/.local/bin/herdr-dictate --status", interval_seconds = 1, timeout_seconds = 1 }, { type = "command", command = "~/.local/bin/job-status", interval_seconds = 1, timeout_seconds = 5 }]' \
      '' '[keys]' 'prefix = "`"' > "$HERDR_CFG"
    echo "   created $HERDR_CFG with the selected shortcuts"
    NEW_CFG=true
  else
    echo "   you already have $HERDR_CFG: merging our shortcuts into it"
    cp "$HERDR_CFG" "$HERDR_CFG.bak-$STAMP"; echo "   backup: $HERDR_CFG.bak-$STAMP"
    NEW_CFG=false
  fi
  WORDS=(); for c in $EXCLUDED; do [[ -n ${SHORTCUT[$c]:-} ]] && WORDS+=("${SHORTCUT[$c]}"); done
  python3 "$REPO/lib/merge-herdr-config.py" "$REPO/config/config.toml" "$HERDR_CFG" --exclude "${(j:,:)WORDS}"
  if ! herdr config check >/dev/null 2>&1; then
    if $NEW_CFG; then rm "$HERDR_CFG"; else cp "$HERDR_CFG.bak-$STAMP" "$HERDR_CFG"; fi
    echo "   Herdr rejected the merged config; restored yours. See: herdr config check"
    exit 1
  fi
  if ! $NEW_CFG; then
    echo "   optional status bar entry (see README, 'Status bar'): add under [ui]"
    echo "     tab_bar_right = [{ type = \"command\", command = \"~/.local/bin/herdr-dictate --status\", interval_seconds = 1, timeout_seconds = 1 }, { type = \"command\", command = \"~/.local/bin/job-status\", interval_seconds = 1, timeout_seconds = 5 }]"
  fi
fi

if has files; then
  step "yazi config (what opens each file)"
  mkdir -p "$HOME/.config/yazi"
  YAZI=$HOME/.config/yazi/yazi.toml
  if [[ -e $YAZI ]] && ! ours "$YAZI" "$REPO/config/yazi/yazi.toml" && ! $REPLACE; then
    echo "   you already have $YAZI: not touching it"
    echo "   to open files by type, copy the [opener] entry and prepend_rules"
    echo "   from $REPO/config/yazi/yazi.toml into yours"
  else
    link "$REPO/config/yazi/yazi.toml" "$YAZI"
  fi
  KEYMAP=$HOME/.config/yazi/keymap.toml
  if [[ -e $KEYMAP ]] && ! ours "$KEYMAP" "$REPO/config/yazi/keymap.toml" && ! $REPLACE; then
    echo "   you already have $KEYMAP: not touching it"
    echo "   for V (copy here the files copied in Finder), add the entry in $REPO/config/yazi/keymap.toml"
  else
    link "$REPO/config/yazi/keymap.toml" "$KEYMAP"
  fi
fi

if has markdown; then
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
fi

step "Claude Code skills (changing this setup, tuning dictation)"
mkdir -p "$HOME/.claude/skills"
for s in "$REPO"/skills/*(/); do link "$s" "$HOME/.claude/skills/${s:t}"; done

if has vscode; then
  step "Default editor (VS Code) in ~/.zshrc"
  if ! grep -q '^export EDITOR=' ~/.zshrc 2>/dev/null; then
    printf '\n# Default editor: VS Code (--wait makes yazi, git, etc. wait until you close the tab)\nexport EDITOR="code --wait"\nexport VISUAL="code --wait"\n' >> ~/.zshrc
    echo "   added"
  else
    echo "   an EDITOR is already set; leaving it alone"
  fi
  command -v code >/dev/null || echo "   note: the 'code' command is missing (VS Code: Cmd+Shift+P > Shell Command: Install 'code' command in PATH)"
fi
[[ :$ORIG_PATH: == *:$BIN:* ]] || echo "   note: $BIN is not on your PATH"

step "Reload Herdr"
if herdr server reload-config 2>/dev/null; then echo; else echo "   Herdr is not running; the config is read when it starts"; fi
echo "Done. Shortcuts are in README.md; they use your prefix (prefix+f, prefix+shift+f, ...)."
