#!/bin/bash
set -euo pipefail

# iTerm2 appearance.
#
# The colours, font and window settings live in a Dynamic Profile at
#   ~/Library/Application Support/iTerm2/DynamicProfiles/catppuccin-mocha.json
# which chezmoi manages as a plain file. iTerm2 watches that folder and reloads
# it within a second, so profile changes need no restart and no `defaults` write.
#
# What a Dynamic Profile cannot do is set app-level preferences: the default
# profile pointer, tab bar style, window chrome and the text margins all live in
# com.googlecode.iterm2.plist. iTerm2 keeps that plist cached in memory and
# rewrites it on quit, so writing to it while iTerm2 is running is silently
# clobbered. Hence the guard below: write the app-level keys only when iTerm2 is
# not running (a fresh machine, or a `chezmoi apply` from another terminal), and
# otherwise print the one manual step.
#
# This is a plain run_ script rather than run_onchange_, so it re-checks on every
# apply. It has to: on a machine where iTerm2 has never launched there is no
# plist yet, and iTerm2 creates its own default profile on first run, which can
# overwrite the pointer set here. Re-asserting each apply makes that self-healing
# instead of a one-shot that silently loses. It stays quiet when nothing changes.

PROFILE_GUID="FA516BFD-8F6D-4C09-94EA-217F0E5E5CDF"
PROFILE_NAME="Catppuccin Mocha"

# App-level appearance keys, as "key type value". Kept in one place so the
# drift check and the write loop cannot disagree.
#   TabStyleWithAutomaticOption 5 = Minimal tab bar
#   TerminalMargin / TerminalVMargin = side and top/bottom text padding in px
#     (iTerm2 defaults are 5 and 2; text otherwise hugs the window edge)
APP_PREFS=(
  "TabStyleWithAutomaticOption int 5"
  "HideScrollbar bool true"
  "UseBorder bool false"
  "TerminalMargin int 12"
  "TerminalVMargin int 8"
)

iterm_running() {
  # lsappinfo, not pgrep: the GUI app runs in a different session from a shell
  # started by chezmoi, so pgrep does not see it, and iTermServer-* lingers
  # after iTerm2 quits, which makes process-name matching wrong in both
  # directions.
  [ -n "$(lsappinfo find bundleid=com.googlecode.iterm2 2>/dev/null)" ]
}

# Normalise `defaults read` output so "1"/"0" compare equal to "true"/"false".
current_value() {
  local v
  v="$(defaults read com.googlecode.iterm2 "$1" 2>/dev/null || true)"
  case "$v" in
    1) [ "$2" = bool ] && v=true ;;
    0) [ "$2" = bool ] && v=false ;;
  esac
  printf '%s' "$v"
}

stale=()
[ "$(current_value "Default Bookmark Guid" string)" = "$PROFILE_GUID" ] || stale+=("Default Bookmark Guid")
for entry in "${APP_PREFS[@]}"; do
  read -r key type value <<<"$entry"
  [ "$(current_value "$key" "$type")" = "$value" ] || stale+=("$key")
done

if [ ${#stale[@]} -eq 0 ]; then
  : # Everything already set. Say nothing, so a login-time apply stays quiet.
elif iterm_running; then
  echo "iTerm2 is running, so its app-level preferences were left alone (${stale[*]})."
  echo "To finish: quit iTerm2 and run \`chezmoi apply\` from another terminal, or set"
  echo "Settings -> Profiles -> \"$PROFILE_NAME\" -> Other Actions... -> Set as Default"
  echo "and Settings -> Appearance -> Theme: Minimal by hand."
else
  defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "$PROFILE_GUID"
  for entry in "${APP_PREFS[@]}"; do
    read -r key type value <<<"$entry"
    defaults write com.googlecode.iterm2 "$key" "-$type" "$value"
  done
  echo "Set \"$PROFILE_NAME\" as the default iTerm2 profile and applied app-level appearance (${stale[*]})."
fi
