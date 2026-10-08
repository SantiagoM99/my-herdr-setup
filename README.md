# herdr-setup

Mi configuración de Herdr para usarlo como un mini-IDE: archivos, Markdown, PDF, tablas, logs, SQL, git y Docker a un atajo de distancia, en un panel a la derecha o en un popup.

## El prefijo es `` ` ``

Todos los atajos empiezan con el **prefijo** `` ` `` (backtick, la tecla a la izquierda del 1 en teclado US). Se aprieta y se suelta, y después la letra: `` ` `` `f` es "backtick, luego f". El prefijo por defecto de Herdr es `ctrl+b`; este setup lo cambia en `config/config.toml`:

```toml
[keys]
prefix = "`"
```

Para usar otro prefijo, cambiar esa línea y recargar. Los atajos de abajo funcionan igual con cualquier prefijo.

## Atajos

La letra dice qué se abre; Shift dice dónde: minúscula, panel a la derecha (mitad del ancho); Shift, popup flotante.

| Qué | Panel a la derecha | Popup | Cómo se sale |
|---|---|---|---|
| Archivos (yazi) | `` ` `` `f` | `` ` `` `Shift+F` | `q` |
| Markdown (glow) | `` ` `` `m` | `` ` `` `Shift+M` | `q` |
| PDF (selector + tdf) | `` ` `` `a` | `` ` `` `Shift+A` | `q` |
| Tablas CSV / parquet / xlsx (visidata) | `` ` `` `t` | `` ` `` `Shift+T` | `q` |
| Logs en vivo | `` ` `` `u` (el más reciente) | `` ` `` `Shift+U` (elegir) | Ctrl+C |
| SQL (harlequin) | `` ` `` `y` | `` ` `` `Shift+Y` | Ctrl+Q |
| Git (lazygit) | — | `` ` `` `Shift+J` | `q` |
| Docker (lazydocker) | — | `` ` `` `Shift+K` | `q` |
| VS Code en la carpeta actual | `` ` `` `i` | — | — |

Al salir del programa, el panel o el popup se cierra solo. En glow, `e` edita el documento con micro en el mismo panel: Ctrl+S guarda, Ctrl+Q vuelve a glow. micro solo se usa ahí; el editor de todo lo demás sigue siendo VS Code.

**Los selectores** (PDF, tablas, logs con `Shift+U`) listan los archivos de la carpeta y sus subcarpetas, el más reciente justo encima del cursor. Se escribe parte del nombre para filtrar (`dosmod` encuentra `2026-10_dos_modelos.pdf`; varias palabras separadas por espacio filtran por todas), flechas para moverse, Enter abre, Esc sale.

### Atajos de Herdr que conviene saber

| Atajo | Qué hace |
|---|---|
| `` ` `` `?` | Ayuda con todos los atajos |
| `` ` `` `Shift+R` | Recargar la config |
| `` ` `` `v` / `` ` `` `-` | Dividir el panel a la derecha / abajo |
| `` ` `` `h` `j` `k` `l` | Moverse al panel de la izquierda, abajo, arriba, derecha |
| `` ` `` `z` | Zoom: el panel actual a pantalla completa y de vuelta |
| `` ` `` `x` | Cerrar el panel |
| `` ` `` `c` | Nueva pestaña |
| `` ` `` `,` | Renombrar pestaña (en Herdr por defecto es `Shift+T`; se movió para dejar `t` a las tablas) |
| `` ` `` `Shift+D` | **Cerrar el workspace entero.** Por eso ningún atajo de este setup usa la `d` |

## yazi como centro

`config/yazi/yazi.toml` hace que Enter abra cada archivo en su programa, sin salir de la terminal; `O` (mayúscula) deja elegir otro. Al salir con `q` se vuelve a yazi; otro `q` cierra yazi.

| Archivo | Enter | Otras opciones (`O`) |
|---|---|---|
| `.pdf` | tdf | Preview |
| `.csv` `.tsv` `.parquet` `.xlsx` `.json` `.jsonl` | visidata | editor, app por defecto |
| `.md` | glow (`e` edita con micro) | VS Code |
| `.log` | `tail -F` (Ctrl+C sale) | editor |
| Código y texto | `$EDITOR` (VS Code) | — |

| Tecla en yazi | Qué hace |
|---|---|
| `z` | Saltar a un archivo escribiendo parte del nombre |
| `s` | Buscar archivos por nombre (fd) |
| `S` | Buscar archivos por contenido (ripgrep) |
| `f` | Filtrar la carpeta actual mientras se escribe |
| `,` `m` | Ordenar por fecha de modificación |
| Esc | Salir de la búsqueda o el filtro |

## SQL con harlequin

harlequin abre DuckDB por defecto, que consulta parquet y CSV directamente; las rutas son relativas a la carpeta donde se abrió. Ctrl+Enter corre la consulta.

```sql
select PRIMER_PERIODO, count(*)
from 'data/datasets/archivo.parquet'
group by 1 order by 1;
```

Trae también los adaptadores de Postgres y SQLite. Las contraseñas van en `~/.pgpass`, nunca en este repo.

## Barra de estado: ETL

`etl-estado` muestra en la barra de pestañas si el ETL de Observatory-Data-Flow está escribiendo parquets (`⚠ ETL corriendo`, `⚠ ETL escribió hace <15 min` o `ETL quieto`), cada 10 segundos. Si la carpeta del ETL no existe no muestra nada; `ETL_DIR` cambia la carpeta.

## Instalación (macOS)

```bash
git clone <este repo> ~/Projects/Personal/herdr-setup
~/Projects/Personal/herdr-setup/install.sh
```

`install.sh` instala los programas con Homebrew y `uv`, enlaza `bin/*` en `~/.local/bin`, `config/config.toml` en `~/.config/herdr/` y `config/yazi/yazi.toml` en `~/.config/yazi/`, y pone VS Code como `$EDITOR` si no había uno. Lo que ya exista se respalda como `<archivo>.bak-<fecha>`.

Como son enlaces, editar el repo cambia la instalación en vivo; tras editar la config, recargar con `` ` `` `Shift+R`.

Necesita Homebrew, Herdr y VS Code con el comando `code` en el PATH. Para ver PDF e imágenes dentro de la terminal, abrir Herdr desde Ghostty, Kitty o WezTerm: Apple Terminal no muestra imágenes.

## Scripts

| Script | Qué hace |
|---|---|
| `herdr-lado <comando>` | Abre el comando en un panel nuevo a la derecha del panel enfocado, en su carpeta |
| `herdr-elegir <prompt> <patrones…>` | Selector fzf de archivos de la carpeta, recientes primero |
| `herdr-pdf` | Elige un PDF y lo abre con tdf (se recarga solo si el PDF cambia) |
| `herdr-datos` | Elige una tabla y la abre en visidata |
| `herdr-md` | glow con micro como editor para la tecla `e` |
| `herdr-log [--elegir]` | `tail -F` del `.log` más reciente |
| `etl-estado` | Línea de la barra de pestañas con el estado del ETL |
