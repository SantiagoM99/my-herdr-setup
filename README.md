# herdr-setup

Mi configuración de Herdr para usarlo como un mini-IDE: archivos, Markdown, PDF, tablas, logs, láminas, git y Docker a un atajo de distancia, en un panel a la derecha o en un popup.

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
| Tablas CSV / parquet / xlsx (visidata) | `t` | `Shift+V` |
| Logs en vivo | `u` (el más reciente) | `Shift+U` (elegir) |
| Láminas que se recompilan al guardar | `y` | — |
| Git (lazygit) | — | `Shift+C` |
| Docker (lazydocker) | — | `Shift+B` |
| VS Code en la carpeta actual | `i` | — |

Todo se cierra con `q`; los logs y las láminas, con Ctrl+C. Las letras evitan los atajos de Herdr: `Shift+D` cierra el workspace y `Shift+T` renombra la pestaña, por eso el PDF va en `a` y el popup de tablas en `Shift+V`.

## Scripts

| Script | Qué hace |
|---|---|
| `herdr-lado <comando>` | Abre el comando en un panel nuevo a la derecha del panel enfocado, en su carpeta |
| `herdr-elegir <prompt> <patrones…>` | Selector fzf de archivos de la carpeta, recientes primero |
| `herdr-pdf` | Elige un PDF y lo abre con tdf (se recarga solo si el PDF cambia) |
| `herdr-datos` | Elige una tabla y la abre en visidata |
| `herdr-log [--elegir]` | `tail -F` del `.log` más reciente |
| `herdr-laminas` | Elige un `generar_presentacion_*.py` y lo vuelve a correr con watchexec al guardar |
| `etl-estado` | Estado del ETL del observatorio para la barra de pestañas; sin esa carpeta no muestra nada (`ETL_DIR` la cambia) |
