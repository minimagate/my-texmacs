#!/bin/sh
# Builds the my-texmacs copy of the resources of TeXmacs: a copy of
# TeXmacs.app/Contents/Resources/share/TeXmacs with the files of src/ applied.
# TeXmacs is pointed at it through TEXMACS_PATH (see install.sh).
#
#   sh scripts/build.sh [destination]
#
# The destination defaults to ~/.my-texmacs/TeXmacs. TeXmacs must be closed.
# The app is looked for in /Applications, or wherever TEXMACS_APP says.
set -e
HERE=$(cd "$(dirname "$0")/.." && pwd)
SRC="$HERE/src"
APP="${TEXMACS_APP:-/Applications/TeXmacs.app}"
R="$APP/Contents/Resources/share/TeXmacs"
T="${1:-$HOME/.my-texmacs/TeXmacs}"
TM_HOME="${TEXMACS_HOME_PATH:-$HOME/.TeXmacs}"

if pgrep -xq TeXmacs; then
  echo "TeXmacs is running: close it first, then run this again." >&2
  exit 1
fi
[ -d "$R" ] || { echo "TeXmacs not found: $APP" >&2; exit 1; }
[ -d "$SRC" ] || { echo "Sources not found: $SRC" >&2; exit 1; }

warn () { echo "WARNING: $1 (TeXmacs has changed; this part was not applied)" >&2; }

rm -rf "${T:?}"
mkdir -p "$(dirname "$T")"
cp -cR "$R" "$T" 2>/dev/null || cp -R "$R" "$T"

# the interface style sheets (dark and light) and the neo-classical icons
for v in dark light; do
  cp "$T/misc/themes/standard-$v.css" "$T/misc/themes/standard-$v.orig.css"
  cp "$SRC/themes/standard-$v.css" "$T/misc/themes/standard-$v.css"
  cp "$SRC/icons/$v/"*.svg "$T/misc/pixmaps/$v/"
done

# one icon bar: the mode icons after the main ones, the mode bar hidden
cat "$SRC/patches/main-menu.append.scm" >> "$T/progs/texmacs/menus/main-menu.scm"
V="$T/progs/texmacs/texmacs/tm-view.scm"
sed -i '' 's/("mode dependent icons" "on" notify-icon-bar)/("mode dependent icons" "off" notify-icon-bar)/' "$V"
grep -q '("mode dependent icons" "off"' "$V" || warn "mode icon bar not hidden"

# the colours of the page: the base style takes them from my-texmacs-page.scm
S="$T/packages/standard/std.ts"
awk -v f="$SRC/patches/std-colors.ts" \
  '{print} /^  <use-package\|std-counter/ {print ""; while ((getline l < f) > 0) print l}' \
  "$S" > "$S.new" && mv "$S.new" "$S"
grep -q my-texmacs-page-bg "$S" || warn "page colours not added to std.ts"

# the page colours, the symbol search palette (Cmd+K), the keyboard shortcuts
cp "$SRC/progs/"* "$T/progs/"
cat "$SRC/patches/init-texmacs.append.scm" >> "$T/progs/init-texmacs.scm"

# what the copy was built from, for scripts/login.sh
VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$APP/Contents/Info.plist" 2>/dev/null || echo unknown)
printf '%s\n%s\n' "$VERSION" "$APP" > "$T/.my-texmacs-built-for"

# forget which icon files existed before, and the cached styles (they keep
# the page colours they were computed with)
rm -f "$TM_HOME/system/cache/stat_cache.scm"
rm -f "$TM_HOME/system/cache/"__*
echo "my-texmacs built for TeXmacs $VERSION in $T"
