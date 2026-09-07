# Editor - multi-neovim config via NVIM_APPNAME
alias vim=nvim
alias v='nvim'
alias vtest='NVIM_APPNAME=nvim-test nvim'
alias vkick='NVIM_APPNAME=nvim-kickstart nvim'
alias vlazy='NVIM_APPNAME=nvim-lazyvim nvim'
alias vmin='NVIM_APPNAME=nvim-minimal nvim'

# Misc
alias c="clear"
alias cat="bat"

# File listing (eza)
alias ls="eza"
alias l="eza -l --icons --git -a"
alias lt="eza --tree --level=2 --long --icons --git"
alias ltree="eza --tree --level=2 --icons --git"

# Navigation shortcuts
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias -- -="cd -"

# Navigation helpers
cx() { cd "$@" && l; }
fcd() { cd "$(fd --type d --hidden --follow --exclude .git | fzf)" && l; }
f() { echo "$(fd --type f --hidden --follow --exclude .git | fzf)" | pbcopy; }
fv() { nvim "$(fd --type f --hidden --follow --exclude .git | fzf)"; }

# Herdr IDE workspace (Claude 20% left, nvim 80% right top, terminal 20% right bottom)
# Usage: ide [dir]  -- creates a workspace named after the dir and attaches
ide() {
  local dir
  dir="$(cd "${1:-.}" 2>/dev/null && pwd)" || { echo "ide: no such directory: $1" >&2; return 1; }
  local name="${dir:t}"

  # Make sure the Herdr server is up (it keeps running after detach)
  if ! herdr status server 2>/dev/null | grep -q 'status: running'; then
    (nohup herdr server >/dev/null 2>&1 &)
    local i
    for i in {1..50}; do
      herdr status server 2>/dev/null | grep -q 'status: running' && break
      sleep 0.1
    done
  fi

  local ws root right
  ws="$(herdr workspace create --cwd "$dir" --label "$name" --focus)" || return 1
  root="$(printf '%s' "$ws" | jq -r '.result.root_pane.pane_id')"
  right="$(herdr pane split "$root" --direction right --ratio 0.2 --cwd "$dir" --no-focus | jq -r '.result.pane.pane_id')"
  herdr pane split "$right" --direction down --ratio 0.8 --cwd "$dir" --no-focus >/dev/null
  herdr pane run "$root" "claude" >/dev/null
  herdr pane run "$right" "nvim ." >/dev/null
  herdr pane focus --direction right --pane "$root" >/dev/null

  # Attach unless we are already inside Herdr
  [ "${HERDR_ENV:-}" = 1 ] || herdr
}

# Rename tab/window title
tab() {
  if [ "${HERDR_ENV:-}" = 1 ] && [ -n "${HERDR_TAB_ID:-}" ]; then
    herdr tab rename "$HERDR_TAB_ID" "$1" >/dev/null
  else
    echo -ne "\033]1;$1\007"
  fi
}

# Git - the oh-my-zsh git plugin aliases actually in use, owned here so they
# survive dropping the plugin. Expansions copied verbatim from git.plugin.zsh;
# sourced after oh-my-zsh, so these shadow the plugin's identical definitions.
alias gst="git status"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gcB="git checkout -B"
alias gb="git branch"
alias gl="git pull"          # NB: oh-my-zsh's gl is pull, not log
alias gf="git fetch"
alias gp="git push"
alias gpu="git push upstream"
alias ga="git add"
alias gc="git commit --verbose"
alias gd="git diff"
alias glo="git log --oneline --decorate"
alias glog="git log --oneline --decorate --graph"
alias gstp="git stash pop"
alias gts="git tag --sign"

# Networking
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias flush="dscacheutil -flushcache && killall -HUP mDNSResponder"

# Cleanup & maintenance
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl"
alias update="sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup"

# macOS toggles
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"
alias stfu="osascript -e 'set volume output muted true'"
alias pumpitup="osascript -e 'set volume output volume 100'"
alias afk="pmset displaysleepnow"

# Shell functions
mkd() { mkdir -p "$@" && cd "$_"; }
server() { open "http://localhost:${1:-8000}" && python3 -m http.server "${1:-8000}"; }
fs() { du -sh -- "$@" | sort -h; }
gz() { local orig=$(wc -c < "$1"); local gzipped=$(gzip -c "$1" | wc -c); echo "orig: $(echo "$orig" | numfmt --to=iec) / gzip: $(echo "$gzipped" | numfmt --to=iec) / ratio: $(echo "scale=2; $gzipped * 100 / $orig" | bc)%"; }

# User manual
alias manual="bat ~/USER_MANUAL.md"

# Yazi shell wrapper - use y to start, q to quit and change CWD, Q to quit without changing
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}
