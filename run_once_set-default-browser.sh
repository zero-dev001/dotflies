#!/bin/bash
set -euo pipefail

# Make Brave the default browser.
#
# macOS has no supported way to set this silently: the underlying
# LSSetDefaultHandlerForURLScheme call requires user consent, so macOS shows a
# confirmation dialog no matter which tool asks. This script only makes the
# request -- expect one "Use Brave Browser as your default browser?" prompt.
#
# Brave's own --make-default-browser flag is used rather than a helper CLI.
# The `defaultbrowser` tool derives its names from bundle ids, so Brave
# (com.brave.Browser) is addressed as the ambiguous "browser", which is easy to
# get silently wrong.

BUNDLE_ID="com.brave.browser"
APP="/Applications/Brave Browser.app"

current_default() {
  python3 - <<'PY' 2>/dev/null || true
import plistlib, os
p = os.path.expanduser(
    "~/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist"
)
try:
    with open(p, "rb") as f:
        data = plistlib.load(f)
except Exception:
    raise SystemExit
for h in data.get("LSHandlers", []):
    if h.get("LSHandlerURLScheme") == "https":
        print((h.get("LSHandlerRoleAll") or "").lower())
        break
PY
}

if [ ! -d "$APP" ]; then
  echo "Brave not found at $APP -- skipping default browser setup." >&2
  exit 0
fi

if [ "$(current_default)" = "$BUNDLE_ID" ]; then
  echo "Brave is already the default browser."
  exit 0
fi

echo "Requesting Brave as the default browser..."
open -a "$APP" --args --make-default-browser

echo "Confirm the macOS prompt to finish. Verify with:"
echo "  System Settings > Desktop & Dock > Default web browser"
