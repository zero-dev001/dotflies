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

# tmuxinator IDE layout (Claude 20% left, nvim 80% right top, terminal 20% right bottom)
ide() {
  local dir="${1:-.}"
  local name=$(basename "$(cd "$dir" 2>/dev/null && pwd)")
  tmuxinator start ide "$dir" --no-attach
  tmux resize-pane -t "$name:1.0" -x '20%'
  tmux resize-pane -t "$name:1.2" -y '20%'
  tmux select-pane -t "$name:1.1"
  tmux rename-window -t "$name:1" "$name"
  tmux attach-session -t "$name"
}

# Rename tab/window title
tab() {
  if [ -n "$TMUX" ]; then
    tmux rename-window "$1"
  else
    echo -ne "\033]1;$1\007"
  fi
}

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
