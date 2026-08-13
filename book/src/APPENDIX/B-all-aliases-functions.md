# Appendix B: All Aliases and Functions

> Every shell alias and function from dot_aliases.zsh, with usage examples and explanations.

---

All aliases and functions are defined in `~/.aliases.zsh`, which chezmoi manages as `dot_aliases.zsh` in the source directory. The file is sourced from `~/.zshrc` with:

```bash
[ -f ~/.aliases.zsh ] && source ~/.aliases.zsh
```

---

## Editor Aliases

These aliases support the multi-Neovim configuration setup, where different `NVIM_APPNAME` values load different Neovim configurations from `~/.config/<appname>/`.

| Alias    | Expansion                               | Purpose                                |
|----------|-----------------------------------------|----------------------------------------|
| `vim`    | `nvim`                                  | Muscle memory compatibility            |
| `v`      | `nvim`                                  | Short alias for Neovim                 |
| `vtest`  | `NVIM_APPNAME=nvim-test nvim`           | Launch test Neovim configuration       |
| `vkick`  | `NVIM_APPNAME=nvim-kickstart nvim`      | Launch Kickstart Neovim configuration  |
| `vlazy`  | `NVIM_APPNAME=nvim-lazyvim nvim`        | Launch LazyVim configuration           |
| `vmin`   | `NVIM_APPNAME=nvim-minimal nvim`        | Launch minimal Neovim configuration    |

### Usage

```bash
v .                    # Open Neovim in current directory
v src/index.ts         # Open a specific file
vmin                   # Open Neovim with minimal config (for testing)
vlazy                  # Open Neovim with LazyVim config
```

The multi-config setup is useful for testing plugins, experimenting with configurations, or using a stripped-down editor when the full config is not needed.

---

## Miscellaneous Aliases

| Alias    | Expansion | Purpose                                       |
|----------|-----------|-----------------------------------------------|
| `c`      | `clear`   | Clear the terminal screen                     |
| `cat`    | `bat`     | Replace cat with bat (syntax highlighting)    |
| `manual` | `bat ~/USER_MANUAL.md` | View personal user manual          |

### Usage

```bash
c                      # Clear screen
cat package.json       # View file with syntax highlighting and line numbers
manual                 # Read the user manual
```

The `cat=bat` alias means every time you would use `cat` to view a file, you get syntax highlighting, line numbers, and git integration automatically. To use the real `cat`, escape the alias: `\cat file.txt`.

---

## File Listing Aliases (eza)

| Alias    | Expansion                                    | Purpose                                |
|----------|----------------------------------------------|----------------------------------------|
| `ls`     | `eza`                                        | Replace ls with eza                    |
| `l`      | `eza -l --icons --git -a`                    | Long list, all files, icons, git status|
| `lt`     | `eza --tree --level=2 --long --icons --git`  | Tree view (2 levels deep) with details |
| `ltree`  | `eza --tree --level=2 --icons --git`         | Tree view (2 levels deep) without long |

### Usage

```bash
ls                     # Simple file listing with eza
l                      # Detailed listing with icons and git markers
lt                     # Two-level tree with file details
ltree                  # Two-level tree (compact)
lt src/                # Tree view of a specific directory
```

The `l` alias is the workhorse. It shows file permissions and sizes, git status per file (modified, untracked, staged), file type icons (requires Nerd Font), and hidden files (the `-a` flag).

---

## Navigation Shortcuts

| Alias    | Expansion              | Purpose                                |
|----------|------------------------|----------------------------------------|
| `..`     | `cd ..`                | Go up one directory                    |
| `...`    | `cd ../..`             | Go up two directories                  |
| `....`   | `cd ../../..`          | Go up three directories                |
| `.....`  | `cd ../../../..`       | Go up four directories                 |
| `-`      | `cd -`                 | Go to previous directory               |

### Usage

```bash
..                     # Go to parent directory
...                    # Go to grandparent directory
-                      # Toggle between last two directories
```

These are simple but heavily used. Combined with zoxide's `cd` override, navigation rarely requires typing full paths.

---

## Navigation Functions

### cx() -- Change Directory and List

```bash
cx() { cd "$@" && l; }
```

Changes to a directory and immediately lists its contents with the detailed `l` alias.

```bash
cx ~/Projects           # cd to Projects and show file listing
cx src/components       # cd and list in one step
```

### fcd() -- Fuzzy Directory Picker

```bash
fcd() { cd "$(fd --type d --hidden --follow --exclude .git | fzf)" && l; }
```

Uses `fd` to find all directories, pipes them through `fzf` for fuzzy selection, then changes to the selected directory and lists contents.

```bash
fcd                    # Launch fuzzy directory picker
# Type partial name -> select -> Enter
```

### f() -- Fuzzy File to Clipboard

```bash
f() { echo "$(fd --type f --hidden --follow --exclude .git | fzf)" | pbcopy; }
```

Finds a file with fuzzy search and copies its path to the macOS clipboard.

```bash
f                      # Pick a file, path goes to clipboard
# Now Cmd+V to paste the path anywhere
```

### fv() -- Fuzzy File to Neovim

```bash
fv() { nvim "$(fd --type f --hidden --follow --exclude .git | fzf)"; }
```

Finds a file with fuzzy search and opens it directly in Neovim.

```bash
fv                     # Pick a file, opens in Neovim
```

---

## IDE Layout Function

### ide() -- Tmuxinator IDE Layout

```bash
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
```

Creates a three-pane tmux layout for development:

```
+--------------------+-----------------------------------+
|   Claude Code      |          Neovim                   |
|   (20% width)     |          (80% width)              |
|                    +-----------------------------------+
|                    |       Terminal (20% height)       |
+--------------------+-----------------------------------+
```

```bash
ide .                  # IDE layout for current directory
ide ~/Projects/app     # IDE layout for a specific directory
```

The function starts a tmuxinator template, resizes panes to the correct proportions, focuses the Neovim pane, renames the window, and attaches to the session.

---

## Tab Rename Function

### tab() -- Rename Tmux Window or Terminal Tab

```bash
tab() {
  if [ -n "$TMUX" ]; then
    tmux rename-window "$1"
  else
    echo -ne "\033]1;$1\007"
  fi
}
```

```bash
tab "api-server"       # Rename current tmux window to "api-server"
tab "frontend"         # Rename to "frontend"
```

Inside tmux, this renames the tmux window. Outside tmux, it sets the terminal tab title using an escape sequence.

---

## Yazi Wrapper Function

### y() -- Yazi with CWD Sync

```bash
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}
```

Launches Yazi file manager and syncs the working directory when you quit. If you navigate to a different directory inside Yazi and press `q`, the shell's working directory changes to match.

```bash
y                      # Open Yazi in current directory
y ~/Downloads          # Open Yazi in Downloads
# Navigate with h/j/k/l, press q to quit and stay in that directory
```

Without this wrapper, quitting Yazi would return to the original directory regardless of where you navigated inside it.

---

## Networking Aliases

| Alias     | Expansion                                                  | Purpose                      |
|-----------|------------------------------------------------------------|------------------------------|
| `ip`      | `dig +short myip.opendns.com @resolver1.opendns.com`      | Show public IP address       |
| `localip` | `ipconfig getifaddr en0`                                   | Show local network IP        |
| `flush`   | `dscacheutil -flushcache && killall -HUP mDNSResponder`   | Flush DNS cache              |

### Usage

```bash
ip                     # Print your public IP (e.g., 203.0.113.42)
localip                # Print your local IP (e.g., 192.168.1.100)
flush                  # Clear DNS cache (useful after /etc/hosts changes)
```

---

## Cleanup and Maintenance Aliases

| Alias        | Expansion                                                          | Purpose                     |
|--------------|--------------------------------------------------------------------|-----------------------------|
| `cleanup`    | `find . -type f -name '*.DS_Store' -ls -delete`                   | Delete .DS_Store files      |
| `emptytrash` | Force-remove all Trash directories and ASL logs                    | Empty all trashes           |
| `update`     | `sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup` | Update everything        |

### Usage

```bash
cleanup                # Remove .DS_Store files from current tree
emptytrash             # Nuclear option: force-empty all trashes
update                 # Update everything: macOS, Homebrew, all packages
```

The `emptytrash` alias runs: `sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl`

The `update` alias runs macOS software updates, then refreshes the Homebrew formula index, upgrades all installed packages, and cleans up old versions.

---

## macOS Toggle Aliases

| Alias          | Purpose                                               |
|----------------|-------------------------------------------------------|
| `show`         | Show hidden files in Finder                           |
| `hide`         | Hide hidden files in Finder                           |
| `showdesktop`  | Show desktop icons                                    |
| `hidedesktop`  | Hide desktop icons (clean desktop for presentations)  |
| `stfu`         | Mute system volume                                    |
| `pumpitup`     | Set system volume to 100%                             |
| `afk`          | Lock screen (put display to sleep)                    |

### Expansions

```bash
show       # defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder
hide       # defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder
showdesktop # defaults write com.apple.finder CreateDesktop -bool true && killall Finder
hidedesktop # defaults write com.apple.finder CreateDesktop -bool false && killall Finder
stfu       # osascript -e 'set volume output muted true'
pumpitup   # osascript -e 'set volume output volume 100'
afk        # pmset displaysleepnow
```

---

## Utility Functions

### mkd() -- Make Directory and Enter

```bash
mkd() { mkdir -p "$@" && cd "$_"; }
```

```bash
mkd ~/Projects/new-app/src/components
# Creates the full path and cds into the deepest directory
```

### server() -- Quick HTTP Server

```bash
server() { open "http://localhost:${1:-8000}" && python3 -m http.server "${1:-8000}"; }
```

```bash
server                 # Serve current directory on port 8000
server 3000            # Serve on port 3000
```

Opens the browser automatically and starts a Python HTTP server serving the current directory.

### fs() -- File Sizes

```bash
fs() { du -sh -- "$@" | sort -h; }
```

```bash
fs *                   # Show sizes of all items in current directory, sorted
fs node_modules dist   # Compare sizes of specific directories
```

### gz() -- Gzip Comparison

```bash
gz() {
  local orig=$(wc -c < "$1")
  local gzipped=$(gzip -c "$1" | wc -c)
  echo "orig: ... / gzip: ... / ratio: ...%"
}
```

```bash
gz bundle.js           # Show original size, gzipped size, and compression ratio
# orig: 245K / gzip: 58K / ratio: 23.67%
```

Useful for checking JavaScript bundle sizes and compression efficiency.

---

## Complete Alias Quick-Scan Table

| Alias          | What It Does                                      |
|----------------|---------------------------------------------------|
| `vim` / `v`    | Opens Neovim                                      |
| `vtest`        | Neovim with test config                           |
| `vkick`        | Neovim with Kickstart config                      |
| `vlazy`        | Neovim with LazyVim config                        |
| `vmin`         | Neovim with minimal config                        |
| `c`            | Clears the terminal                               |
| `cat`          | bat (syntax-highlighted file viewer)              |
| `ls`           | eza (modern file listing)                         |
| `l`            | Detailed eza listing with icons and git           |
| `lt`           | Two-level tree with details                       |
| `ltree`        | Two-level tree (compact)                          |
| `..`           | cd up one level                                   |
| `...`          | cd up two levels                                  |
| `....`         | cd up three levels                                |
| `.....`        | cd up four levels                                 |
| `-`            | cd to previous directory                          |
| `ip`           | Show public IP                                    |
| `localip`      | Show local IP                                     |
| `flush`        | Flush DNS cache                                   |
| `cleanup`      | Delete .DS_Store files                            |
| `emptytrash`   | Force-empty all Trash                             |
| `update`       | Update macOS + Homebrew                           |
| `show` / `hide`| Toggle hidden Finder files                        |
| `showdesktop`  | Show desktop icons                                |
| `hidedesktop`  | Hide desktop icons                                |
| `stfu`         | Mute volume                                       |
| `pumpitup`     | Max volume                                        |
| `afk`          | Lock screen                                       |
| `manual`       | View ~/USER_MANUAL.md                             |

---

## Complete Function Quick-Scan Table

| Function | Signature          | What It Does                             |
|----------|--------------------|------------------------------------------|
| `cx`     | `cx [dir]`         | cd + list contents                       |
| `fcd`    | `fcd`              | Fuzzy directory picker + cd              |
| `f`      | `f`                | Fuzzy file picker to clipboard           |
| `fv`     | `fv`               | Fuzzy file picker to Neovim              |
| `ide`    | `ide [dir]`        | Three-pane tmux IDE layout               |
| `tab`    | `tab [name]`       | Rename tmux window or terminal tab       |
| `y`      | `y [dir]`          | Yazi file manager with CWD sync          |
| `mkd`    | `mkd [path]`       | mkdir -p + cd                            |
| `server` | `server [port]`    | Python HTTP server + open browser        |
| `fs`     | `fs [files...]`    | Show file/directory sizes sorted         |
| `gz`     | `gz [file]`        | Show gzip compression ratio              |

---

## Oh My Zsh Git Aliases

These come from the Oh My Zsh `git` plugin (enabled in `.zshrc`), not from `~/.aliases.zsh`:

| Alias   | Expansion              | Alias   | Expansion                |
|---------|------------------------|---------|--------------------------|
| `gst`   | `git status`           | `gp`    | `git push`               |
| `ga`    | `git add`              | `gl`    | `git pull`               |
| `gaa`   | `git add --all`        | `gf`    | `git fetch`              |
| `gc`    | `git commit`           | `gco`   | `git checkout`           |
| `gcam`  | `git commit -am`       | `gcb`   | `git checkout -b`        |
| `gb`    | `git branch`           | `gm`    | `git merge`              |
| `gbd`   | `git branch -d`        | `gd`    | `git diff`               |
| `glo`   | `git log --oneline`    | `gds`   | `git diff --staged`      |
| `glg`   | `git log --graph`      | `gsta`  | `git stash`              |
| `grb`   | `git rebase`           | `gstp`  | `git stash pop`          |

Run `alias | grep git` to see the full list (there are many more).

---

## Environment Variables

Set in `~/.zshrc` (managed by `dot_zshrc.tmpl`):

| Variable       | Value                        | Purpose                         |
|----------------|------------------------------|---------------------------------|
| `EDITOR`       | `nvim` (local) / `vim` (SSH) | Default editor for git, etc.    |
| `MANPAGER`     | `nvim +Man!`                 | Man pages render in Neovim      |
| `NVM_DIR`      | `$HOME/.nvm`                 | NVM installation directory      |
| `BUN_INSTALL`  | `$HOME/.bun`                 | Bun installation directory      |
| `ZSH`          | `$HOME/.oh-my-zsh`           | Oh My Zsh installation          |

---

## Zsh Plugins

Enabled in `.zshrc` via the `plugins` array:

| Plugin                      | Purpose                                      |
|-----------------------------|----------------------------------------------|
| `git`                       | Git aliases and functions                    |
| `zsh-syntax-highlighting`   | Real-time command syntax highlighting        |
| `zsh-autosuggestions`       | Fish-like autosuggestions from history        |

\newpage
