#!/bin/zsh
# Instala el setup de Herdr: programas, scripts y config.
# Los scripts y la config quedan como enlaces a este repo, así que editar aquí cambia la
# instalación en vivo (después de editar la config: prefix+shift+r o `herdr server reload-config`).
# Lo que ya exista y no sea un enlace a este repo se respalda como <archivo>.bak-<fecha>.
set -euo pipefail
REPO=${0:A:h}
SELLO=$(date +%Y%m%d-%H%M%S)
BIN=$HOME/.local/bin
CFG=$HOME/.config/herdr

paso() { print -P "%B==> $*%b"; }

enlazar() { # enlazar <origen> <destino>
  local src=$1 dst=$2
  if [[ -L $dst && ${dst:A} == ${src:A} ]]; then return; fi
  if [[ -e $dst || -L $dst ]]; then mv "$dst" "$dst.bak-$SELLO"; echo "   respaldo: $dst.bak-$SELLO"; fi
  ln -s "$src" "$dst"; echo "   $dst -> $src"
}

paso "Comprobaciones"
command -v brew >/dev/null || { echo "Falta Homebrew (https://brew.sh)"; exit 1; }
command -v herdr >/dev/null || [[ -x $BIN/herdr ]] || { echo "Falta herdr"; exit 1; }

paso "Programas (Homebrew)"
brew install yazi glow neovim tdf fzf jq lazygit lazydocker fd ripgrep

paso "visidata con soporte de parquet (uv)"
command -v uv >/dev/null || brew install uv
uv tool install --upgrade visidata --with pyarrow --with openpyxl

paso "harlequin (editor SQL: DuckDB y Postgres)"
uv tool install --upgrade 'harlequin[postgres]'

paso "Scripts en $BIN"
mkdir -p "$BIN"
for f in "$REPO"/bin/*; do chmod +x "$f"; enlazar "$f" "$BIN/${f:t}"; done

paso "Config en $CFG"
mkdir -p "$CFG"
enlazar "$REPO/config/config.toml" "$CFG/config.toml"

paso "Config de yazi (con qué abre cada archivo)"
mkdir -p "$HOME/.config/yazi"
enlazar "$REPO/config/yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml"

paso "Editor por defecto (VS Code) en ~/.zshrc"
if ! grep -q '^export EDITOR=' ~/.zshrc 2>/dev/null; then
  printf '\n# Editor por defecto: VS Code (--wait hace que yazi, git, etc. esperen a que cierres la pestaña)\nexport EDITOR="code --wait"\nexport VISUAL="code --wait"\n' >> ~/.zshrc
  echo "   agregado"
else
  echo "   ya había un EDITOR; no lo toco"
fi
command -v code >/dev/null || echo "   ojo: falta el comando 'code' (VS Code: Cmd+Shift+P > Shell Command: Install 'code' command in PATH)"
[[ :$PATH: == *:$BIN:* ]] || echo "   ojo: $BIN no está en el PATH"

paso "Recargar Herdr"
if herdr server reload-config 2>/dev/null; then echo; else echo "   Herdr no está corriendo; la config se lee al abrirlo"; fi
echo "Listo. Atajos en README.md. Si tu prefijo no es \`, cámbialo en config/config.toml."
