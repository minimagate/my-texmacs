#!/bin/sh
# Installs my-texmacs for the current user. Run it from a clone of the
# repository, with TeXmacs closed:
#
#   sh install.sh
#
# Run it again after pulling changes. The TeXmacs app is not modified: the
# installer builds a modified copy of its resources in ~/.my-texmacs and
# points TeXmacs at it (see README.md). sh uninstall.sh undoes everything.
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
H="$HOME/.my-texmacs"
APP="${TEXMACS_APP:-/Applications/TeXmacs.app}"
AGENT_ID=org.texmacs.my-texmacs
AGENT="$HOME/Library/LaunchAgents/$AGENT_ID.plist"
DOMAIN="gui/$(id -u)"

[ "$(uname)" = Darwin ] || { echo "my-texmacs is for macOS." >&2; exit 1; }
[ -d "$APP/Contents/Resources/share/TeXmacs" ] || {
  echo "TeXmacs not found at $APP (set TEXMACS_APP to its location)." >&2
  exit 1
}
if pgrep -xq TeXmacs; then
  echo "TeXmacs is running: close it first, then run this again." >&2
  exit 1
fi

step () { printf '\n==> %s\n' "$1"; }

step "Copying my-texmacs to $H"
mkdir -p "$H"
rm -rf "$H/src" "$H/scripts"
cp -R "$HERE/src" "$HERE/scripts" "$H/"

step "Building the modified copy of the resources of TeXmacs"
TEXMACS_APP="$APP" sh "$H/scripts/build.sh" "$H/TeXmacs"

step "Installing the interface font (Fira Sans)"
FONTS="$APP/Contents/Resources/share/TeXmacs/fonts/truetype/fira"
mkdir -p "$HOME/Library/Fonts"
for f in FiraSans-Regular FiraSans-Bold FiraSans-Italic FiraSans-BoldItalic; do
  if [ -f "$HOME/Library/Fonts/$f.otf" ]; then
    echo "$f: already installed"
  elif [ -f "$FONTS/$f.otf" ]; then
    cp "$FONTS/$f.otf" "$HOME/Library/Fonts/" && echo "$f: installed"
  else
    echo "$f: not found in TeXmacs (the interface falls back to the system font)"
  fi
done

step "Letting the title bar follow the appearance of macOS"
defaults write org.texmacs.TeXmacs NSRequiresAquaSystemAppearance -bool false

# earlier versions of this setup were called "TeXmacs Sleek"
OLD_AGENT="$HOME/Library/LaunchAgents/org.texmacs.sleek-path.plist"
if [ -f "$OLD_AGENT" ]; then
  step "Removing the earlier TeXmacs Sleek setup"
  launchctl bootout "$DOMAIN" "$OLD_AGENT" 2>/dev/null || true
  rm -f "$OLD_AGENT"
  echo "Removed $OLD_AGENT"
fi
OLD_INIT="$HOME/.TeXmacs/progs/my-init-texmacs.scm"
if grep -q 'sleek-delete-motion' "$OLD_INIT" 2>/dev/null; then
  mv "$OLD_INIT" "$OLD_INIT.before-my-texmacs"
  echo "Its keyboard shortcuts are now part of my-texmacs: moved"
  echo "$OLD_INIT to $OLD_INIT.before-my-texmacs"
fi

step "Pointing TeXmacs at the copy, now and at every login"
mkdir -p "$HOME/Library/LaunchAgents"
cat > "$AGENT" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <!-- my-texmacs: sets TEXMACS_PATH to $H/TeXmacs (rebuilding it after an
       update of TeXmacs). Installed by install.sh, removed by uninstall.sh. -->
  <key>Label</key><string>$AGENT_ID</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/sh</string><string>$H/scripts/login.sh</string>
  </array>
  <key>RunAtLoad</key><true/>
</dict>
</plist>
EOF
launchctl bootout "$DOMAIN" "$AGENT" 2>/dev/null || true
launchctl bootstrap "$DOMAIN" "$AGENT"
launchctl setenv TEXMACS_PATH "$H/TeXmacs"
echo "TEXMACS_PATH=$(launchctl getenv TEXMACS_PATH)"

cat <<EOF

my-texmacs is installed. Open TeXmacs from the Dock, Finder or Spotlight.

The interface follows Edit > Preferences > General > User interface theme:
  Default   follows the appearance of macOS (checked when TeXmacs starts)
  Dark      always dark, with a dark page on the screen
  Bright    always light, with a white page
EOF
