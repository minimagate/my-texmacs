#!/bin/sh
# Removes my-texmacs: TeXmacs starts again as it came. Run it with TeXmacs
# closed:
#
#   sh uninstall.sh
#
# Your documents and your TeXmacs preferences are not touched. The Fira Sans
# fonts stay in ~/Library/Fonts (other apps may use them); delete them there
# if you want.
set -e
H="$HOME/.my-texmacs"
AGENT="$HOME/Library/LaunchAgents/org.texmacs.my-texmacs.plist"
TM_HOME="${TEXMACS_HOME_PATH:-$HOME/.TeXmacs}"

if pgrep -xq TeXmacs; then
  echo "TeXmacs is running: close it first, then run this again." >&2
  exit 1
fi

launchctl bootout "gui/$(id -u)" "$AGENT" 2>/dev/null || true
rm -f "$AGENT"
launchctl unsetenv TEXMACS_PATH
defaults delete org.texmacs.TeXmacs NSRequiresAquaSystemAppearance 2>/dev/null || true
rm -rf "$H"

# the cached styles and icon lists were made with the my-texmacs copy
rm -f "$TM_HOME/system/cache/stat_cache.scm"
rm -f "$TM_HOME/system/cache/"__*

echo "my-texmacs removed. TeXmacs starts as it came."
