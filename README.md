# herdr-setup

Mi configuración de Herdr para usarlo como un mini-IDE: archivos, Markdown, PDF, tablas, logs, git y Docker a un atajo de distancia, en un panel a la derecha o en un popup.

## Instalación (macOS)

```bash
git clone <este repo> ~/Projects/Personal/herdr-setup
~/Projects/Personal/herdr-setup/install.sh
```

`install.sh` instala los programas con Homebrew y `uv`, y enlaza `bin/*` en `~/.local/bin` y `config/config.toml` en `~/.config/herdr/`. Lo que ya exista se respalda como `<archivo>.bak-<fecha>`. Como son enlaces, editar el repo cambia la instalación en vivo; tras editar la config, recargar con `` ` `` `Shift+R`.

Necesita Homebrew, Herdr y VS Code con el comando `code` en el PATH. Para ver PDF e imágenes dentro de la terminal, abrir Herdr desde Ghostty, Kitty o WezTerm (Apple Terminal no muestra imágenes).

## Atajos

El prefijo es `` ` ``. La letra dice qué se abre; Shift dice dónde.

| Qué | Panel a la derecha | Popup |
|---|---|---|
| Archivos (yazi) | `f` | `Shift+F` |
| Markdown (glow) | `m` | `Shift+M` |
| PDF (selector + tdf) | `a` | `Shift+A` |
| Tablas CSV / parquet / xlsx (visidata) | `t` | `Shift+T` |
| Logs en vivo | `u` (el más reciente) | `Shift+U` (elegir) |
| Git (lazygit) | — | `Shift+J` |
| Docker (lazydocker) | — | `Shift+K` |
| VS Code en la carpeta actual | `i` | — |

Todo se cierra con `q`; los logs, con Ctrl+C. Las letras evitan los atajos de Herdr: `Shift+D` cierra el workspace, por eso el PDF va en `a`. Renombrar pestaña se movió de `Shift+T` a `` ` `` `,` (coma) para dejar `t`/`Shift+T` a las tablas.

## yazi como centro

`config/yazi/yazi.toml` hace que Enter abra cada archivo en su programa, sin salir de la terminal; `O` (mayúscula) deja elegir otro. Al salir con `q` se vuelve a yazi.

| Archivo | Enter | Otras opciones (`O`) |
|---|---|---|
| `.pdf` | tdf | Preview |
| `.csv` `.tsv` `.parquet` `.xlsx` `.json` `.jsonl` | visidata | editor, app por defecto |
| `.md` | glow | VS Code |
| `.log` | `tail -F` (Ctrl+C sale) | editor |
| Código y texto | `$EDITOR` (VS Code) | — |

## Scripts

| Script | Qué hace |
|---|---|
| `herdr-lado <comando>` | Abre el comando en un panel nuevo a la derecha del panel enfocado, en su carpeta |
| `herdr-elegir <prompt> <patrones…>` | Selector fzf de archivos de la carpeta, recientes primero |
| `herdr-pdf` | Elige un PDF y lo abre con tdf (se recarga solo si el PDF cambia) |
| `herdr-datos` | Elige una tabla y la abre en visidata |
| `herdr-log [--elegir]` | `tail -F` del `.log` más reciente |
| `etl-estado` | Estado del ETL del observatorio para la barra de pestañas; sin esa carpeta no muestra nada (`ETL_DIR` la cambia) |
