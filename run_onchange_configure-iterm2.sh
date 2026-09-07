#!/bin/bash
set -euo pipefail

# iTerm2 appearance.
#
# The colours, font and window settings live in a Dynamic Profile at
#   ~/Library/Application Support/iTerm2/DynamicProfiles/catppuccin-mocha.json
# which chezmoi manages as a plain file. iTerm2 watches that folder and reloads
# it within a second, so profile changes need no restart and no `defaults` write.
#
# The one thing a Dynamic Profile cannot do is mark itself as the default -- the
# "Default Bookmark Guid" pointer lives in com.googlecode.iterm2.plist. iTerm2
# keeps that plist cached in memory and rewrites it on quit, so writing to it
# while iTerm2 is running is silently clobbered. Hence the guard below: set the
# pointer only when iTerm2 is not running (a fresh machine, or a `chezmoi apply`
# from another terminal), and otherwise print the one manual step.

PROFILE_GUID="FA516BFD-8F6D-4C09-94EA-217F0E5E5CDF"
PROFILE_NAME="Catppuccin Mocha"

# lsappinfo, not pgrep: the GUI app runs in a different session from a shell
# started by chezmoi, so pgrep does not see it, and iTermServer-* lingers after
# iTerm2 quits, which makes process-name matching wrong in both directions.
if [ -n "$(lsappinfo find bundleid=com.googlecode.iterm2 2>/dev/null)" ]; then
  echo "iTerm2 is running, so its default-profile pointer was left alone."
  echo "To finish: Settings -> Profiles -> \"$PROFILE_NAME\" -> Other Actions... -> Set as Default."
else
  defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "$PROFILE_GUID"
  echo "Set \"$PROFILE_NAME\" as the default iTerm2 profile."
fi
