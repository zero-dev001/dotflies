# User Manual

Quick reference for every tool in this dotfiles setup. No fluff — just the commands you need.

---

## Table of Contents

- [iTerm2](#iterm2)
- [Navigation (zoxide)](#navigation-zoxide)
- [File Listing (eza)](#file-listing-eza)
- [File Manager (yazi)](#file-manager-yazi)
- [Fuzzy Finder (fzf)](#fuzzy-finder-fzf)
- [Search (ripgrep & fd)](#search-ripgrep--fd)
- [Shell History (atuin)](#shell-history-atuin)
- [Git](#git)
- [Lazygit](#lazygit)
- [GitHub CLI (gh)](#github-cli-gh)
- [Herdr](#herdr)
- [Neovim](#neovim)
- [IDE Layout (Herdr)](#ide-layout-herdr)
- [Dotfiles (chezmoi)](#dotfiles-chezmoi)
- [Node.js (nvm & bun)](#nodejs-nvm--bun)
- [Misc CLI Tools](#misc-cli-tools)
- [Custom Aliases & Functions](#custom-aliases--functions)
- [macOS Utilities](#macos-utilities)

---

## iTerm2

Default keyboard shortcuts for managing tabs, panes, and navigation in iTerm2.

### Tabs

| Keys | Action |
|------|--------|
| `Cmd + t` | New tab |
| `Cmd + w` | Close tab |
| `tab "Name"` | Rename tab (shell function) |
| `Cmd + Right/Left` | Next/previous tab |
| `Cmd + <number>` | Go to tab N |
| `Cmd + Shift + ]` / `[` | Next/previous tab (alt) |

### Split Panes

| Keys | Action |
|------|--------|
| `Cmd + d` | Split vertically |
| `Cmd + Shift + d` | Split horizontally |
| `Cmd + ]` / `[` | Cycle through panes |
| `Cmd + Option + Arrow` | Navigate to pane in direction |
| `Cmd + Shift + Enter` | Maximize/restore pane |

### Text Navigation

| Keys | Action |
|------|--------|
| `Option + Left/Right` | Move word by word |
| `Cmd + Left/Right` | Jump to beginning/end of line |
| `Cmd + Delete` | Delete to beginning of line |
| `Option + Delete` | Delete previous word |
| `Ctrl + a` / `Ctrl + e` | Beginning/end of line (shell) |
| `Ctrl + w` | Delete previous word (shell) |
| `Ctrl + u` | Delete to beginning of line (shell) |
| `Ctrl + k` | Delete to end of line (shell) |

### Window & Misc

| Keys | Action |
|------|--------|
| `Cmd + n` | New window |
| `Cmd + Enter` | Toggle fullscreen |
| `Cmd + +` / `-` | Increase/decrease font size |
| `Cmd + 0` | Reset font size |
| `Cmd + ,` | Open preferences |
| `Cmd + f` | Find in terminal |
| `Cmd + Shift + h` | Paste history |
| `Cmd + Option + e` | Expose all tabs (search across tabs) |
| `Cmd + ;` | Autocomplete from history |
| `Cmd + k` | Clear terminal |
| `Cmd + /` | Highlight cursor position |

> These are iTerm2 defaults. Customize them in **Preferences → Keys**.

---

## Navigation (zoxide)

zoxide learns your habits. It replaces `cd` entirely.

```bash
z foo            # Jump to most-visited dir matching "foo"
z foo bar        # Jump to dir matching both "foo" and "bar"
zi               # Interactive picker (fzf)
z -              # Go back to previous directory
```

### Quick Navigation Aliases

```bash
..               # cd ..
...              # cd ../..
....             # cd ../../..
.....            # cd ../../../..
-                # cd - (previous directory)
```

---

## File Listing (eza)

Aliased over `ls` — modern replacement with icons and git status.

```bash
ls               # eza (basic listing)
l                # eza -l --icons --git -a  (detailed + hidden + git status)
lt               # eza --tree --level=2 --long --icons --git  (tree + details)
ltree            # eza --tree --level=2 --icons --git  (compact tree)
```

---

## File Manager (yazi)

Terminal file manager with previews. Opens with `y` (alias syncs cwd on quit).

```bash
y                # Open yazi, cd to last directory on quit
```

**Inside yazi:**

| Key | Action |
|-----|--------|
| `h/l` | Navigate parent/child |
| `j/k` | Move up/down |
| `Enter` | Open file |
| `Space` | Toggle selection |
| `d` | Trash selected |
| `D` | Permanently delete |
| `y` | Yank (copy) |
| `x` | Cut |
| `p` | Paste |
| `a` | Create file |
| `r` | Rename |
| `/` | Filter |
| `s` | Search by name |
| `S` | Search by content (rg) |
| `z` | Jump with zoxide |
| `.` | Toggle hidden files |
| `t` | Toggle tag |
| `q` | Quit |
| `~` | Go home |
| `Tab` | Switch to tasks panel |

---

## Fuzzy Finder (fzf)

Used standalone and integrated into many tools.

```bash
# Standalone
fzf                      # Pipe any list into it
cat file | fzf           # Fuzzy-pick a line

# Zsh integration (Ctrl keybindings)
Ctrl+t                   # Find file and paste path
Ctrl+r                   # Search shell history
Alt+c                    # cd into selected directory
```

### Custom fzf Functions

```bash
f                # Find file → copy path to clipboard
fv               # Find file → open in Neovim
fcd              # Find directory → cd into it + list files
```

---

## Search (ripgrep & fd)

### ripgrep (`rg`) — search file contents

```bash
rg "pattern"              # Recursive search in current dir
rg "pattern" src/         # Search in specific directory
rg -i "pattern"           # Case-insensitive
rg -l "pattern"           # List matching filenames only
rg -t js "pattern"        # Search only JavaScript files
rg -g "*.tsx" "pattern"   # Search files matching glob
rg -C 3 "pattern"         # Show 3 lines of context
rg --hidden "pattern"     # Include hidden files
rg -w "word"              # Match whole words only
rg -e "pat1" -e "pat2"   # Multiple patterns (OR)
```

### fd — find files by name

```bash
fd                        # List all files recursively
fd "pattern"              # Find files matching pattern
fd -e ts                  # Find all .ts files
fd -e ts -x wc -l         # Find .ts files → count lines each
fd -H "pattern"           # Include hidden files
fd -t d "pattern"         # Find directories only
fd -t f "pattern"         # Find files only
fd "pattern" src/         # Search in specific directory
```

---

## Shell History (atuin)

Full-text search across all shell history, synced across machines.

```bash
Ctrl+r                   # Search history (interactive)
Up arrow                 # Scroll through history
atuin search "pattern"   # Search history
atuin stats              # Usage statistics
```

---

## Git

### Basics

```bash
git status               # Show working tree status  (gst)
git add <file>           # Stage file                (ga)
git add -A               # Stage everything          (gaa)
git commit -m "msg"      # Commit                    (gc -m "msg")
git commit -am "msg"     # Stage tracked + commit    (gcam "msg")
git push                 # Push                      (gp)
git pull                 # Pull                      (gl)
git fetch                # Fetch                     (gf)
```

### Branching

```bash
git branch               # List branches             (gb)
git branch <name>        # Create branch             (gb <name>)
git checkout <branch>    # Switch branch             (gco)
git checkout -b <name>   # Create + switch           (gcb)
git merge <branch>       # Merge branch              (gm)
git branch -d <name>     # Delete branch             (gbd)
```

### Inspection

```bash
git log --oneline        # Compact log               (glo)
git log --graph          # Graph log                 (glg)
git diff                 # Unstaged changes          (gd)
git diff --staged        # Staged changes            (gds)
git blame <file>         # Line-by-line blame
git stash                # Stash changes             (gsta)
git stash pop            # Pop stash                 (gstp)
```

> Parenthesized shortcuts are Oh My Zsh git plugin aliases. Run `alias | grep git` to see them all.

---

## Lazygit

Full TUI for git. Launch with `lazygit` or `lg`.

| Key | Panel / Action |
|-----|----------------|
| `1-5` | Switch panels (Status, Files, Branches, Commits, Stash) |
| `Space` | Stage/unstage file |
| `a` | Stage all |
| `c` | Commit |
| `p` | Push |
| `P` | Pull |
| `Enter` | View diff / expand |
| `d` | Discard changes |
| `b` | Branch actions |
| `n` | New branch |
| `s` | Stash |
| `/` | Filter |
| `?` | Help |
| `q` | Quit |

---

## GitHub CLI (gh)

```bash
# Pull Requests
gh pr create             # Create PR interactively
gh pr list               # List open PRs
gh pr view <n>           # View PR details
gh pr checkout <n>       # Checkout PR locally
gh pr merge <n>          # Merge PR
gh pr review <n>         # Review PR

# Issues
gh issue create          # Create issue
gh issue list            # List issues
gh issue view <n>        # View issue

# Repo
gh repo clone <r>        # Clone repo
gh repo view             # View current repo
gh browse                # Open repo in browser

# Actions
gh run list              # List workflow runs
gh run view <id>         # View run details
gh run watch <id>        # Watch live output
```

---

## Herdr

Terminal workspace manager (replaces tmux). Background server keeps panes, shells, and Claude sessions alive when you close the terminal.

**Prefix:** `Ctrl+b` (press first, then the key)

### Workspaces (were sessions)

| Keys | Action |
|------|--------|
| `prefix + w` | Workspace picker |
| `prefix + Shift+N` | New workspace |
| `prefix + Shift+W` | Rename workspace |
| `prefix + Shift+D` | Close workspace |
| `Alt + Shift+H/L` | Previous/next workspace |
| `prefix + b` | Toggle sidebar |
| `prefix + d` | Detach (everything keeps running) |

```bash
herdr                    # Launch or re-attach
herdr status             # Client + server status
herdr workspace list     # List workspaces (JSON)
herdr session list       # Named sessions
herdr server stop        # Stop the server (kills all panes)
```

### Tabs (were windows)

| Keys | Action |
|------|--------|
| `prefix + c` | New tab |
| `prefix + Shift+T` | Rename tab |
| `prefix + Shift+X` | Close tab |
| `prefix + n` / `prefix + p` | Next/previous tab |
| `prefix + <number>` | Go to tab N |

### Panes

| Keys | Action |
|------|--------|
| `prefix + v` | Split side by side |
| `prefix + -` | Split stacked |
| `prefix + h/j/k/l` | Navigate panes (vim-style) |
| `prefix + Tab` | Cycle panes |
| `prefix + z` | Zoom (toggle fullscreen pane) |
| `prefix + x` | Close pane |
| `prefix + r` | Resize mode (h/j/k/l) |
| `Alt + Arrow` | Resize pane directly |

### Scrollback & Copy

| Keys | Action |
|------|--------|
| Mouse select | Copies to clipboard |
| Mouse wheel | Scroll history |
| `prefix + e` | Open scrollback in Neovim (search, yank) |

### Popups

| Keys | Action |
|------|--------|
| `prefix + g` | lazygit (floating, 90%) |
| `prefix + f` | Floating terminal (80%) |
| `prefix + ?` | Help |
| `prefix + s` | Settings |

### Persistence

Detaching keeps the server and every process running. After a reboot, Herdr restores workspaces, tabs, panes, cwd, and layout as fresh shells; Claude Code sessions resume automatically.

```bash
herdr update --handoff   # Update without losing running panes
herdr server reload-config   # Apply config.toml changes
```

## Neovim

Aliased: `vim` = `nvim`. Distribution: **LazyVim**. Theme: **Catppuccin Mocha**.

**Leader key:** `Space`

Press `Space` and wait — **which-key** shows all available mappings.

### Essential

| Keys | Action |
|------|--------|
| `Space + ff` | Find files |
| `Space + fr` | Recent files |
| `Space + fg` | Live grep (search in files) |
| `Space + fb` | Browse buffers |
| `Space + e` | File explorer (neo-tree) |
| `Space + /` | Search in current buffer |

### Navigation

| Keys | Action |
|------|--------|
| `Space + bb` | Switch buffer |
| `H / L` | Previous/next buffer |
| `Space + bd` | Delete buffer |
| `s` | Flash jump (type 2 chars to jump) |
| `Ctrl+h/j/k/l` | Navigate splits |

### Code (LSP)

| Keys | Action |
|------|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover documentation |
| `Space + ca` | Code actions |
| `Space + cr` | Rename symbol |
| `Space + cf` | Format file |
| `Space + cd` | Line diagnostics |
| `]d / [d` | Next/prev diagnostic |

### Search & Replace

| Keys | Action |
|------|--------|
| `Space + sg` | Grep (search in files) |
| `Space + sw` | Search word under cursor |
| `Space + ss` | Search symbols |
| `Space + sr` | Search and replace (grug-far) |

### Git

| Keys | Action |
|------|--------|
| `Space + gc` | Git commits |
| `Space + gs` | Git status |
| `]h / [h` | Next/prev git hunk |


## IDE Layout (Herdr)

Pre-configured Herdr workspace: Claude Code + Neovim + terminal.

```bash
ide                      # Open IDE in current dir
ide ~/project            # Open IDE for specific project
```

Each call creates a new workspace named after the directory. Switch between projects with `prefix + w`.

**Layout:**
```
┌──────────┬──────────────────────┐
│          │                      │
│  Claude  │       Neovim         │
│  Code    │                      │
│  (20%)   │       (80%)          │
│          ├──────────────────────┤
│          │     Terminal (20%)   │
└──────────┴──────────────────────┘
```

---

## Dotfiles (chezmoi)

```bash
chezmoi cd               # cd into source directory
chezmoi edit <file>      # Edit managed file
chezmoi diff             # See pending changes
chezmoi apply            # Apply changes to home dir
chezmoi update           # Pull + apply from remote
chezmoi status           # Show what would change
chezmoi managed          # List all managed files
```

---

## Node.js (nvm & bun)

### nvm

```bash
nvm ls                   # List installed versions
nvm use <ver>            # Switch version
node -v                  # Current version (v22)
```

### bun

```bash
bun run <script>         # Run package.json script
bun install              # Install dependencies
bun add <pkg>            # Add dependency
bun dev                  # Start dev server
bun build ./index.ts     # Bundle TypeScript
bun test                 # Run tests
bunx <pkg>               # npx equivalent
```

---

## Misc CLI Tools

### bat — syntax-highlighted cat

```bash
bat file.js              # View with syntax highlighting
bat -l json data.txt     # Force language
bat --diff a.js b.js     # Side-by-side diff
```

### jq — JSON processor

```bash
cat data.json | jq .                # Pretty-print
cat data.json | jq '.key'          # Extract key
cat data.json | jq '.items[0]'     # First array element
cat data.json | jq '.[] | .name'   # Map over array
curl api.com | jq '.data'          # Pipe API response
```

### tldr — simplified man pages

```bash
tldr tar                 # Quick usage for tar
tldr git-rebase          # Quick usage for git rebase
```

### pandoc — document converter

```bash
pandoc file.md -o file.pdf         # Markdown → PDF
pandoc file.md -o file.html        # Markdown → HTML
pandoc file.docx -o file.md        # Word → Markdown
```

### yt-dlp — download videos

```bash
yt-dlp <url>                       # Download video
yt-dlp -x --audio-format mp3 <url> # Extract audio
yt-dlp -f best <url>               # Best quality
yt-dlp --list-formats <url>        # List formats
```

### ffmpeg — multimedia processing

```bash
ffmpeg -i in.mp4 out.gif           # Video → GIF
ffmpeg -i in.mp4 -vn out.mp3      # Extract audio
ffmpeg -i in.mp4 -ss 00:01:00 -t 30 out.mp4  # Trim clip
```

### aria2 — download manager

```bash
aria2c <url>                       # Download file
aria2c -x 16 <url>                 # 16 connections
aria2c -i urls.txt                 # Download list
```

---

## Custom Aliases & Functions

```bash
# Editor
vim             → nvim

# File listing
ls              → eza
l               → eza -l --icons --git -a
lt              → eza --tree --level=2 --long --icons --git
ltree           → eza --tree --level=2 --icons --git

# Git (Oh My Zsh shortcuts)
gst             → git status
gf              → git fetch
gco <branch>    → git checkout <branch>
gcB <branch>    → git checkout -B <branch>  (create/reset branch)

# Navigation functions
cx <dir>        # cd into dir + auto-list files
f               # Fuzzy find file → copy path to clipboard
fv              # Fuzzy find file → open in Neovim
fcd             # Fuzzy find directory → cd + list
y               # Open yazi, sync cwd on quit
ide [dir]       # Launch Herdr IDE workspace
mkd <dir>       # mkdir + cd in one step

# Networking
ip              # Show public IP address
localip         # Show local IP (en0)
flush           # Flush DNS cache

# Cleanup & maintenance
cleanup         # Delete all .DS_Store files recursively
emptytrash      # Force empty trash and system logs
update          # Update macOS, Homebrew packages

# Shell functions
server [port]   # Start Python HTTP server (default: 8000)
fs <path>       # Human-readable file/directory sizes
gz <file>       # Compare original vs gzipped size
```

---

## macOS Utilities

### Toggle Aliases

```bash
show            # Show hidden files in Finder
hide            # Hide hidden files in Finder
showdesktop     # Show desktop icons
hidedesktop     # Hide desktop icons
stfu            # Mute volume
pumpitup        # Max volume
afk             # Sleep display (lock screen)
```

### macOS Defaults (run_once)

Applied automatically on first `chezmoi apply`. Key settings:

- **Keyboard**: Blazing fast key repeat, no press-and-hold, no auto-correct/smart quotes/dashes
- **Finder**: Full path in title bar, folders on top, list view, no .DS_Store on network/USB
- **Dock**: Auto-hide with zero delay, 36px icons, no recent apps, fast Mission Control
- **Dialogs**: Expanded save/print panels, save to disk by default
- **Screenshots**: PNG format, no shadow, saved to `~/Desktop/screenshots/`
- **Security**: Immediate password after sleep, Secure Keyboard Entry
- **Apps**: Activity Monitor sorted by CPU, TextEdit in plain text, Photos won't auto-open

---

## Quick Reference Card

| Task | Command |
|------|---------|
| Find a file by name | `fd "name"` or `Ctrl+t` |
| Search file contents | `rg "pattern"` |
| Jump to a directory | `z dirname` |
| Fuzzy pick anything | `fzf` |
| Open file manager | `y` |
| Open IDE layout | `ide` or `ide ~/project` |
| Git TUI | `lazygit` |
| Search history | `Ctrl+r` (atuin) |
| Quick man page | `tldr <command>` |
| Manage dotfiles | `chezmoi edit/apply/update` |
| Find Neovim commands | Press `Space` and wait |
| Herdr workspace picker | `prefix + w` |
| Herdr floating term / lazygit | `prefix + f` / `prefix + g` |
| Quick HTTP server | `server` or `server 3000` |
| Create dir + cd | `mkd new-folder` |
| Public IP address | `ip` |
| Flush DNS cache | `flush` |
| Show/hide hidden files | `show` / `hide` |
| Lock screen | `afk` |
| Update everything | `update` |
