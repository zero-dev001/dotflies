#!/bin/bash
set -euo pipefail

# Tailscale needs three things and the Brewfile can only do the first: the app
# installed, the network system extension approved, and the machine logged in
# to the tailnet. The last two are interactive by nature -- extension approval
# is a System Settings prompt, login is browser SSO -- so they cannot live in
# the Brewfile. This script reports which one is still missing and opens the
# login page when that is the gap. It runs on every apply rather than once,
# because "already set up" is runtime state, not something a hash can answer.
# Once Tailscale is Running it prints one line and changes nothing.
#
# Never fatal: a dotfiles apply should not abort because a VPN is not up yet,
# so every failure path warns and exits 0.
#
# Set TAILSCALE_NO_BROWSER=1 to get the login URL printed and never opened.

TS="/usr/local/bin/tailscale"
TS_APP="/Applications/Tailscale.app"
BRAVE_APP="/Applications/Brave Browser.app"

[ "$(uname -s)" = "Darwin" ] || exit 0

# The tailscale-app cask is a pkg, and its installer is what drops the CLI
# wrapper at /usr/local/bin/tailscale. So a missing CLI means the cask did not
# land -- brew bundle warns rather than aborts, so this is a reachable state.
if [ ! -x "$TS" ]; then
  echo "warning: Tailscale CLI not found at $TS." >&2
  echo "  The tailscale-app cask did not install. Retry with:" >&2
  echo "    brew install --cask tailscale-app" >&2
  exit 0
fi

# An unreachable daemon makes `status` exit non-zero, which pipefail would
# propagate out of the command substitution and set -e would turn into an
# abort. Empty output is the signal we want here, not a failure, so absorb it.
backend_state() {
  { "$TS" status --json 2>/dev/null || true; } |
    sed -n 's/.*"BackendState"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' |
    head -1
}

auth_url() {
  { "$TS" status --json 2>/dev/null || true; } |
    sed -n 's|.*"AuthURL"[[:space:]]*:[[:space:]]*"\(https[^"]*\)".*|\1|p' |
    head -1
}

open_url() {
  # Print unconditionally. This is the one thing the user actually needs, and
  # whether chezmoi hands a script a TTY is not worth betting the feature on.
  echo "  Log in at: $1"

  [ -n "${TAILSCALE_NO_BROWSER:-}" ] && return 0

  # A browser only helps on the machine someone is sitting at. Over ssh the
  # window would open on the wrong screen, or nowhere.
  if [ -n "${SSH_CONNECTION:-}" ]; then
    echo "  (ssh session; not opening a browser)"
    return 0
  fi

  if [ -d "$BRAVE_APP" ] && open -a "$BRAVE_APP" "$1" 2>/dev/null; then
    echo "  Opened in Brave. Finish the sign-in there."
  elif open "$1" 2>/dev/null; then
    # brave-browser is in the Brewfile but its cask can fail like any other.
    echo "  Opened in your default browser. Finish the sign-in there."
  else
    echo "  Could not open a browser; use the URL above." >&2
  fi
  return 0
}

state="$(backend_state)"

# tailscaled unreachable. On a fresh machine this is the first state you hit:
# the pkg is installed but nothing has launched the app, so the network system
# extension is not approved and no daemon exists yet. Launching the app is what
# triggers the approval prompt.
if [ -z "$state" ]; then
  echo "Tailscale is installed but not running. Launching it..."
  open -a "$TS_APP" 2>/dev/null || true
  for _ in $(seq 1 15); do
    sleep 1
    state="$(backend_state)"
    [ -n "$state" ] && break
  done
  if [ -z "$state" ]; then
    echo "warning: tailscaled still unreachable." >&2
    echo "  macOS needs the network extension approved by hand:" >&2
    echo "  System Settings > General > Login Items & Extensions > Network Extensions" >&2
    echo "  Approve Tailscale, then run: chezmoi apply" >&2
    exit 0
  fi
fi

# Starting and NoState are transitions, not destinations. A machine that is
# already logged in passes through both while it brings the tunnel up, so
# reading them as "needs login" would pop a browser and run `tailscale login`
# on a perfectly healthy machine -- resetting any pref not passed explicitly.
# Let them settle into a real answer first.
case "$state" in
  Starting | NoState)
    echo "Tailscale is still coming up; waiting for it to settle..."
    for _ in $(seq 1 20); do
      sleep 1
      state="$(backend_state)"
      case "$state" in
        Running | NeedsLogin | NeedsMachineAuth | Stopped) break ;;
      esac
    done
    ;;
esac

case "$state" in
  Running)
    echo "Tailscale is connected."
    ;;

  Stopped)
    # Logged in, but toggled off. Re-assert the prefs this setup wants rather
    # than a bare `up`, whose --accept-routes/--accept-dns defaults would
    # quietly turn off route and DNS acceptance.
    echo "Tailscale is logged in but stopped. Starting it..."
    "$TS" up --accept-routes --accept-dns --timeout 10s || true
    if [ "$(backend_state)" = "Running" ]; then
      echo "Tailscale is connected."
    else
      echo "warning: Tailscale did not reach Running; check the menu bar icon." >&2
    fi
    ;;

  NeedsMachineAuth)
    echo "This machine is waiting for tailnet admin approval." >&2
    echo "  Approve it at: https://login.tailscale.com/admin/machines" >&2
    ;;

  NeedsLogin)
    echo "Tailscale is not logged in to a tailnet."
    url="$(auth_url)"
    if [ -z "$url" ]; then
      # No pending URL, so ask for one. --timeout keeps this from blocking the
      # apply forever; it exits non-zero when it gives up, which is expected
      # here since the login completes in the browser, not in this shell.
      login_out="$("$TS" login --accept-routes --accept-dns --timeout 1s 2>&1 || true)"
      url="$(printf '%s\n' "$login_out" |
        sed -n 's|.*\(https://login\.tailscale\.com/[A-Za-z0-9/._-]*\).*|\1|p' | head -1)"
      [ -z "$url" ] && url="$(auth_url)"
    fi
    if [ -n "$url" ]; then
      open_url "$url"
    else
      echo "warning: could not get a login URL." >&2
      echo "  Log in from the Tailscale menu bar icon, or run: tailscale login" >&2
    fi
    ;;

  Starting | NoState)
    echo "warning: Tailscale is still '$state' after waiting; leaving it alone." >&2
    echo "  Re-run 'chezmoi apply' once the menu bar icon settles." >&2
    ;;

  *)
    echo "warning: unrecognized Tailscale state '$state'; leaving it alone." >&2
    ;;
esac

exit 0
