# my-texmacs

A cleaner, modern look for [GNU TeXmacs](https://www.texmacs.org) 2.1.5 on macOS,
in dark and light, plus a few keyboard conveniences. It borrows the look of
[TeXmacs Vue](https://mgubi.github.io/texmacs/) (its palette, desaturated to
neutral greys, and the neo-classical icons) without building an experimental
branch.

The TeXmacs app is **not modified**. The installer builds a modified copy of
the app's resources in `~/.my-texmacs` and tells TeXmacs to load them from
there (`TEXMACS_PATH`). Uninstalling removes the copy, and TeXmacs is back to
how it came.

## What you get

- **Dark and light interface**: matching style sheets, with neutral greys,
  rounded buttons and fields, thin scrollbars and one blue accent (`#4260B4`).
  Each mode uses its own set of neo-classical icons.
- **Follows macOS**: with the theme set to *Default*, TeXmacs starts dark or
  light like the rest of the system. The title bar follows it too.
- **Dark page on screen** in dark mode (`#2b2b2b`, text `#e4e4e4`, links
  `#8ab4f8`). Light mode keeps the usual white page. Printing, PDF export and
  the pictures made for other exports always use a white page with black text,
  and documents are never changed.
- **One icon bar**: the mode icons follow the main ones on a single 20px bar.
- **Fira Sans** as the interface font.
- **Symbol search (Cmd+K)**: a small palette that searches 577 symbols by
  name, LaTeX name, Unicode name or synonym (e.g. `sub`, `not equal`, `reals`,
  `per ogni`). Use Up/Down to move, Return to insert (it opens a formula if
  you are in text) and Esc to close.
- **Keyboard shortcuts**:

  | Keys | Action |
  |---|---|
  | Cmd+Backspace | delete to the start of the line |
  | Option+Backspace | delete the previous word |
  | Cmd+Fn+Backspace | delete to the end of the line |
  | Option+Fn+Backspace | delete the next word |
  | Cmd+1 | open an inline formula (inside one: jump to its end) |
  | `$` | types a plain `$` in text |

  Deleted text does not go to the clipboard.

## Install

You need macOS and TeXmacs 2.1.5 in `/Applications`. Close TeXmacs, then run:

```sh
git clone https://github.com/minimagate/my-texmacs.git
cd my-texmacs
sh install.sh
```

Then open TeXmacs as usual (Dock, Finder, Spotlight). To choose the theme, go
to **Edit → Preferences → General → User interface theme** and restart
TeXmacs:

| Setting | Interface | Page on screen |
|---|---|---|
| Default | follows macOS when TeXmacs starts | dark or white, to match |
| Dark | dark | dark |
| Bright | light | white |

TeXmacs installed somewhere else? Run `TEXMACS_APP=/path/to/TeXmacs.app sh install.sh`.

## Update

- **my-texmacs changed**: run `git pull`, close TeXmacs, then `sh install.sh`.
- **TeXmacs updated**: nothing to do. At the next login my-texmacs notices the
  new version and rebuilds its copy. To do it right away, close TeXmacs and
  run `sh install.sh`. If a rebuild fails, TeXmacs starts as it came rather
  than from an outdated copy (see `~/.my-texmacs/login.log`).

## Uninstall

Close TeXmacs, then run:

```sh
sh uninstall.sh
```

This removes `~/.my-texmacs`, the login item and the title-bar setting. Your
documents and TeXmacs preferences are not touched. The Fira Sans fonts stay
in `~/Library/Fonts`.

## Change something

Edit the files in `src/`, close TeXmacs and run `sh install.sh` again.

```
src/
  themes/standard-dark.css    dark interface style sheet (palette in its header)
  themes/standard-light.css   light interface style sheet
  icons/{dark,light}/         neo-classical icons (copied over TeXmacs's own)
  progs/my-texmacs-page.scm   page colours, and the white page for printing
  progs/my-texmacs-symbol-search.scm   the Cmd+K palette
  progs/my-texmacs-symbols.tsv         its symbols: symbol, label, search words
  progs/my-texmacs-keys.scm   the keyboard shortcuts
  patches/                    lines added to TeXmacs's own files
scripts/
  build.sh                    builds the copy from the app and src/
  login.sh                    run at login: rebuilds after updates, sets TEXMACS_PATH
install.sh, uninstall.sh
```

## How it works

`build.sh` copies `TeXmacs.app/Contents/Resources/share/TeXmacs` to
`~/.my-texmacs/TeXmacs`, using APFS clones so the copy takes almost no space.
It then:

- replaces `misc/themes/standard-{dark,light}.css`, keeping the originals as
  `*.orig.css`;
- copies the icons over `misc/pixmaps/{dark,light}`;
- adds the icon-bar change to `progs/texmacs/menus/main-menu.scm` and hides
  the separate mode bar in `progs/texmacs/texmacs/tm-view.scm`;
- makes `packages/standard/std.ts` take the page colours from
  `my-texmacs-page.scm`;
- loads the files in `progs/` at the end of `progs/init-texmacs.scm`.

`install.sh` copies `src/` and `scripts/` to `~/.my-texmacs` and builds the
copy there. It installs Fira Sans from the app, sets
`NSRequiresAquaSystemAppearance = false` for `org.texmacs.TeXmacs` (so the
title bar can be dark), and adds a login item
(`~/Library/LaunchAgents/org.texmacs.my-texmacs.plist`). The login item runs
`login.sh`, which sets `TEXMACS_PATH` for apps opened from the Dock or Finder.

## Troubleshooting

- **A document opens with a white page in dark mode.** TeXmacs caches each
  style with the colours it was first computed with. Close TeXmacs and run
  `sh install.sh`, or delete `~/.TeXmacs/system/cache/__*`.
- **TeXmacs looks like stock TeXmacs.** Check `launchctl getenv TEXMACS_PATH`
  (it should print `~/.my-texmacs/TeXmacs`) and `~/.my-texmacs/login.log`.
  A TeXmacs started from a terminal only uses the copy if `TEXMACS_PATH` is
  set there too.
- **The theme did not change.** TeXmacs reads the theme and the macOS
  appearance only when it starts: restart it.

## Known limitations

- Menus and tooltips have square corners: they are separate windows, and a
  Qt style sheet cannot make the outside of a rounded border transparent.
- In light mode the area around the page is TeXmacs's fixed grey (`#a0a0a0`).
  Only the app itself can change it.
- Scrolling with the mouse over the grey area beside the page does not scroll
  the document. This is a TeXmacs bug (`QTMScrollView::viewportEvent`) and
  cannot be fixed from here.

## Credits and licence

TeXmacs is by Joris van der Hoeven and contributors. The neo-classical icons
come from the `maxs_texmacs` branch of
[mgubi/texmacs](https://github.com/mgubi/texmacs), and Fira Sans is copied
from the TeXmacs app at install time. The style sheets are derived from
TeXmacs's own. Like TeXmacs, my-texmacs is released under the GNU General
Public License, version 3 (see `LICENSE`).
