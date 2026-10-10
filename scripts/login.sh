#!/bin/sh
# Run at every login by ~/Library/LaunchAgents/org.texmacs.my-texmacs.plist.
# Points TeXmacs at the my-texmacs copy of its resources (TEXMACS_PATH). If
# TeXmacs was updated since the copy was built, the copy is rebuilt first;
# if that fails, TEXMACS_PATH is cleared so TeXmacs starts as it came.
H="$HOME/.my-texmacs"
T="$H/TeXmacs"
STAMP="$T/.my-texmacs-built-for"
APP=$(sed -n 2p "$STAMP" 2>/dev/null)
APP="${APP:-/Applications/TeXmacs.app}"

exec >> "$H/login.log" 2>&1
echo "--- $(date '+%Y-%m-%d %H:%M:%S')"

app_version () {
  /usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" \
    "$APP/Contents/Info.plist" 2>/dev/null
}

built=$(sed -n 1p "$STAMP" 2>/dev/null)
current=$(app_version)
if [ -z "$current" ]; then
  echo "TeXmacs not found at $APP"
elif [ "$built" != "$current" ]; then
  echo "TeXmacs is $current, the copy was built for ${built:-nothing}: rebuilding"
  TEXMACS_APP="$APP" sh "$H/scripts/build.sh" "$T" || rm -f "$STAMP"
fi

if [ -n "$current" ] && [ "$(sed -n 1p "$STAMP" 2>/dev/null)" = "$current" ]; then
  /bin/launchctl setenv TEXMACS_PATH "$T"
  echo "TEXMACS_PATH=$T"
else
  /bin/launchctl unsetenv TEXMACS_PATH
  echo "TEXMACS_PATH cleared: TeXmacs starts without my-texmacs"
fi
