# dotfiles

macOS development environment managed with [chezmoi](https://www.chezmoi.io/). Auto-syncs across machines via a LaunchAgent that runs `chezmoi update` on login.

## Stack overview

| Layer | Tool | Config file |
|---|---|---|
| Shell | Zsh + Oh My Zsh + Powerlevel10k | `~/.zshrc`, `~/.p10k.zsh` |
| Shell plugins | zsh-syntax-highlighting, zsh-autosuggestions | (via Oh My Zsh) |
| Editor | Neovim (LazyVim) | `~/.config/nvim/` |
| Terminal multiplexer | tmux + Catppuccin Mocha + tmuxinator | `~/.tmux.conf`, `~/.config/tmuxinator/` |
| Fuzzy finder | fzf | `~/.fzf.zsh` |
| File manager | yazi | (aliased as `y`) |
| File listing | eza | (aliased as `ls`, `l`, `lt`) |
| Directory jumping | zoxide (replaces `cd`) | (eval in zshrc) |
| Shell history | atuin | (eval in zshrc) |
| File search | fd + ripgrep | (used via fzf, nvim) |
| Git | git + lazygit + gh | `~/.gitconfig` |
| Version control (experimental) | jj (Jujutsu) | (in Brewfile) |
| Node.js | NVM + Node 22 + Bun | `~/.nvm`, `~/.bun` |
| AI | Claude Code, 99.nvim (custom) | Brewfile, nvim plugins |
| Packages | Homebrew (43 formulae, 22 casks, 19 VSCode extensions) | `Brewfile` |
| Backup | rsync post-commit hook | `~/.githooks/post-commit` |
| Sync | Syncthing | (brew service) |

---

## Fresh machine setup

```bash
# One-liner
curl -fsSL https://raw.githubusercontent.com/zero-dev001/dotfiles/main/install.sh | bash

# Or step by step
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
brew install chezmoi
chezmoi init --apply zero-dev001/dotfiles
```

Open a new terminal after applying.

---

## Development workflow

### Daily startup

```bash
tmux                          # start tmux (sessions persist across terminal closes)
# or attach to existing:
tmux a                        # attach to last session
```

Once inside tmux, use **prefix + o** to open the session picker (sessionx with zoxide integration), or create new sessions per project.

### Navigating your system

| Command | What it does |
|---|---|
| `cd <dir>` | Jump to directory (powered by zoxide -- learns your habits) |
| `cd <partial>` | Zoxide fuzzy match -- e.g. `cd proj` jumps to `~/Projects` |
| `cx <dir>` | `cd` + auto `ls -la` |
| `fcd` | Fuzzy-find a directory with fzf, then cd into it |
| `f` | Fuzzy-find a file, copy its path to clipboard |
| `fv` | Fuzzy-find a file, open it in Neovim |
| `y` | Open yazi file manager (q to quit and cd, Q to quit in place) |
| `l` | Detailed file listing with icons and git status |
| `lt` / `ltree` | Tree view (2 levels deep) with icons and git status |

### Editing code

| Command | What it does |
|---|---|
| `nvim` / `vim` | Open Neovim (LazyVim distro) |
| `fv` | Fuzzy-find + open in Neovim |
| `cursor .` | Open current dir in Cursor IDE |

### Git workflow

```bash
lazygit                       # TUI for git -- stage, commit, push, rebase, etc.
gh pr create                  # create PR from terminal
gh pr view --web              # open PR in browser
gh pr checkout <number>       # check out a PR locally
```

Your git config uses `~/.githooks/` for custom hooks (post-commit rsync backup) and `~/.gitignore` as a global ignore file.

### Search and find

| Command | What it does |
|---|---|
| `rg <pattern>` | Ripgrep -- fast recursive search in files |
| `fd <pattern>` | Find files/dirs by name (faster than `find`) |
| `ast-grep <pattern>` | Structural code search (AST-aware) |
| `fzf` | Interactive fuzzy finder (pipe anything into it) |
| `tldr <command>` | Quick cheat sheet for any command |

### Node.js development

```bash
nvm use 22                    # switch Node version
nvm install <version>         # install a new version
bun install                   # fast package install (alternative to npm)
bun run dev                   # run scripts via bun
```

### Shell history (atuin)

```bash
# Press Ctrl+R for interactive history search (powered by atuin)
# atuin syncs history across machines and provides full-text search
atuin search <query>          # search history
atuin stats                   # see shell usage stats
```

---

## Shell aliases

Defined in `~/.aliases.zsh`:

| Alias | Expands to | Purpose |
|---|---|---|
| `vim` | `nvim` | Always use Neovim |
| `ls` | `eza` | Modern ls replacement |
| `l` | `eza -l --icons --git -a` | Detailed listing with icons + git |
| `lt` | `eza --tree --level=2 --long --icons --git` | Tree view |
| `ltree` | `eza --tree --level=2 --icons --git` | Tree view (compact) |

### Shell functions

| Function | Usage | Purpose |
|---|---|---|
| `cx <dir>` | `cx ~/Projects` | cd + auto list |
| `fcd` | `fcd` | Fuzzy directory picker |
| `f` | `f` | Fuzzy file picker -> clipboard |
| `fv` | `fv` | Fuzzy file picker -> Neovim |
| `y` | `y` | Yazi file manager with cwd sync |
| `ide [dir]` | `ide ~/Projects/myapp` | tmuxinator IDE layout (Claude + nvim + terminal) |

---

## Tmux keybindings

**Prefix key:** `Ctrl+b` (default)

### Pane navigation

| Keybinding | Action |
|---|---|
| `prefix + h` | Move to left pane |
| `prefix + j` | Move to pane below |
| `prefix + k` | Move to pane above |
| `prefix + l` | Move to right pane |
| `Alt + Arrow keys` | Switch panes (no prefix needed) |

### Window navigation

| Keybinding | Action |
|---|---|
| `Shift + Left` | Previous window |
| `Shift + Right` | Next window |
| `Alt + H` | Previous window (vim style) |
| `Alt + L` | Next window (vim style) |

### Splits and sessions

| Keybinding | Action |
|---|---|
| `prefix + "` | Split horizontal (in current path) |
| `prefix + %` | Split vertical (in current path) |
| `prefix + o` | Open sessionx (session picker with zoxide) |
| `prefix + p` | Open floax (floating terminal, 80% size) |

### Copy mode (vi-style)

| Keybinding | Action |
|---|---|
| `prefix + [` | Enter copy mode |
| `v` | Start selection |
| `Ctrl+v` | Toggle rectangle selection |
| `y` | Copy selection and exit |

### Plugins

| Plugin | What it does |
|---|---|
| **vim-tmux-navigator** | Seamless `Ctrl+h/j/k/l` between vim and tmux panes |
| **tmux-yank** | System clipboard integration |
| **tmux-resurrect** | Save/restore sessions across restarts |
| **tmux-continuum** | Auto-save sessions (restored on tmux start) |
| **sessionx** | Fuzzy session picker with zoxide |
| **floax** | Floating terminal overlay |
| **tmux-fzf-url** | Open URLs from terminal output with fzf |
| **tmux-fzf** | Fuzzy finder for tmux objects |
| **tmux-thumbs** | Quick copy of text patterns (paths, hashes, etc.) |

---

## Neovim (LazyVim)

LazyVim provides a batteries-included Neovim config. Key highlights:

| Keybinding | Action |
|---|---|
| `Space` | Leader key (opens which-key menu) |
| `Space + f + f` | Find files |
| `Space + f + g` | Live grep (search in files) |
| `Space + e` | File explorer (neo-tree) |
| `Space + b + b` | Switch buffer |
| `Space + /` | Search in current buffer |
| `Space + s + g` | Grep across project |

### Custom plugins

| Plugin | Keybinding | Action |
|---|---|---|
| **99.nvim** | `<leader>mm` | Select AI model |
| **99.nvim** | `<leader>9v` (visual) | AI on visual selection |
| **99.nvim** | `<leader>9s` | Stop all AI requests |

---

## Chezmoi management

### Day-to-day

```bash
chezmoi add ~/.some-config     # track a new file
chezmoi edit ~/.zshrc          # edit through chezmoi
chezmoi diff                   # preview changes before applying
chezmoi apply                  # apply changes from source to home
chezmoi update                 # pull remote changes and apply
chezmoi cd                     # cd into the source directory
```

### Adding a new brew package

```bash
chezmoi cd
echo 'brew "package-name"' >> Brewfile
exit
chezmoi apply                  # triggers brew bundle automatically
```

### Changing Node version

```bash
chezmoi cd
echo "23" > .node-version
exit
chezmoi apply                  # triggers NVM install automatically
```

### Auto-install scripts

These run via `chezmoi apply` when their source content changes:

| Script | Trigger | What it does |
|---|---|---|
| `run_onchange_before_install-brew-packages.sh.tmpl` | Brewfile hash changes | Runs `brew bundle` |
| `run_onchange_install-nvm-and-node.sh.tmpl` | `.node-version` changes | Installs NVM + specified Node version |
| `run_onchange_install-zsh-plugins.sh` | Script content changes | Installs/updates Oh My Zsh, P10k, plugins |
| `run_onchange_install-tmux-plugins.sh` | Script content changes | Installs/updates TPM + tmux plugins |

### Auto-sync

A LaunchAgent (`~/Library/LaunchAgents/com.chezmoi.update.plist`) runs `chezmoi update` at login, keeping your dotfiles in sync across machines automatically.

---

## Managed files

### Shell
- `~/.zshrc` -- Zsh config (Oh My Zsh, plugins, tool init, PATH)
- `~/.aliases.zsh` -- All aliases and shell functions
- `~/.zshenv` -- Environment (Cargo, dfx)
- `~/.zprofile` -- Login shell (Homebrew)
- `~/.p10k.zsh` -- Powerlevel10k prompt
- `~/.fzf.zsh` / `~/.fzf.bash` -- fzf integration

### Git
- `~/.gitconfig` -- User, editor, hooks path, global ignore
- `~/.gitignore` -- Global gitignore (Node, Next.js, env files, etc.)
- `~/.githooks/post-commit` -- Rsync backup on every commit

### Tmux
- `~/.tmux.conf` -- Full tmux config with Catppuccin theme and 12 plugins

### Neovim
- `~/.config/nvim/` -- LazyVim configuration with custom 99.nvim AI plugin

### Sync
- `~/.stignore-global` -- Syncthing global ignore patterns

### System
- `~/Library/LaunchAgents/com.chezmoi.update.plist` -- Auto-sync on login

---

## Useful combos

| Scenario | Commands |
|---|---|
| Jump to a project and start coding | `cd proj` then `nvim` |
| Browse files visually | `y` (yazi) or `fcd` (fzf directory picker) |
| Find and edit a specific file | `fv` (fzf -> nvim) |
| Search for text across a project | `rg "pattern"` or Neovim `<Space>sg` |
| Git operations | `lazygit` for TUI, `gh` for GitHub |
| Quick terminal in tmux | `prefix + p` (floax floating terminal) |
| Switch tmux sessions | `prefix + o` (sessionx with zoxide) |
| Look up a command you forgot | `tldr <command>` or `Ctrl+R` (atuin history) |
| Copy a file path quickly | `f` (fzf -> clipboard) |

---

## Cheatsheet

### How finding works

Three tools power all searching across terminal, yazi, and neovim:

| Tool | Role | Finds |
|---|---|---|
| **fd** | Locates files and directories by name | Files and folders |
| **ripgrep (rg)** | Searches text inside files | Text content |
| **fzf** | Interactive fuzzy picker -- filters any list you pipe into it | Nothing on its own |

The pattern is always: **find** (fd/rg) → **pick** (fzf) → **act** (cd, nvim, copy...).

---

### Terminal (Bash/Zsh)

#### Find files and folders (fd)

```bash
fd                          # list all files recursively
fd "pattern"                # find files matching pattern
fd --type f                 # files only
fd --type d                 # directories only
fd --extension ts           # find all .ts files
fd --hidden                 # include hidden files
fd --exclude node_modules   # exclude a directory
fd "test" --type f --extension ts   # find .ts files with "test" in name
```

#### Search text in files (ripgrep)

```bash
rg "pattern"                # search for pattern in all files
rg "pattern" --type ts      # search only in TypeScript files
rg "pattern" -i             # case insensitive
rg "pattern" -l             # list only filenames (not matches)
rg "pattern" -C 3           # show 3 lines of context
rg "TODO|FIXME"             # regex search
rg "pattern" src/           # search in specific directory
rg "pattern" --glob "*.tsx" # search only in .tsx files
```

#### Fuzzy pick (fzf)

**Built-in keybindings** (from `fzf --zsh`):

| Keybinding | Action |
|---|---|
| `Ctrl+T` | Fuzzy-find a file/directory, paste path into command line |
| `Alt+C` | Fuzzy-find a directory, cd into it |
| `Ctrl+R` | Fuzzy search shell history (overridden by atuin) |

**Custom functions** (from `~/.aliases.zsh`):

| Command | Action |
|---|---|
| `fcd` | fd dirs → fzf → cd + list contents |
| `f` | fd files → fzf → copy path to clipboard |
| `fv` | fd files → fzf → open in Neovim |

#### Combining them (piping patterns)

```bash
nvim $(fzf)                 # pick any file, open in nvim
cd $(fd --type d | fzf)     # pick a directory, cd into it
git checkout $(git branch | fzf)   # pick a branch, check it out
kill -9 $(ps aux | fzf | awk '{print $2}')   # pick a process, kill it

# preview files while picking
fzf --preview 'bat --color=always {}'

# search text with rg, pick match, open in nvim at that line
rg --line-number . | fzf --delimiter : --preview 'bat --color=always {1} --highlight-line {2}' | awk -F: '{print "+"$2, $1}' | xargs nvim
```

---

### Yazi

All three tools are available inside yazi through keybindings:

#### Find files and folders (fd)

| Keybinding | Action |
|---|---|
| `s` | Search files by name (via fd) |
| `Ctrl+S` | Cancel ongoing search |

#### Search text in files (ripgrep)

| Keybinding | Action |
|---|---|
| `S` | Search files by content (via ripgrep) |

#### Fuzzy pick / navigate (fzf + zoxide)

| Keybinding | Action |
|---|---|
| `z` | Jump to a file/directory via fzf |
| `Z` | Jump to a directory via zoxide |

#### Filter and find (built-in)

| Keybinding | Action |
|---|---|
| `f` | Filter files in current directory (smart case) |
| `/` | Find next file (smart case) |
| `?` | Find previous file (smart case) |
| `n` / `N` | Next / previous match |

---

### Neovim (Telescope)

Telescope uses fd to find files and ripgrep to search text, with fzf-style fuzzy matching built in.

#### Find files (fd-powered)

| Keybinding | Action |
|---|---|
| `<Space>ff` | Find files in project |
| `<Space>fr` | Find recent files |
| `<Space>fb` | Browse open buffers |
| `<Space>fp` | Find plugin files |

#### Search text (ripgrep-powered)

| Keybinding | Action |
|---|---|
| `<Space>sg` | Live grep across project |
| `<Space>sw` | Search word under cursor |
| `<Space>/` | Fuzzy search in current buffer |
| `<Space>ss` | Search document symbols (LSP) |
| `<Space>sS` | Search workspace symbols (LSP) |

#### Navigate and explore

| Keybinding | Action |
|---|---|
| `<Space>bb` | Switch buffer |
| `<Space>gc` | Search git commits |
| `<Space>gs` | Search git status (changed files) |
| `<Space>sH` | Search help tags |
| `<Space>sk` | Search keymaps |
| `<Space>s"` | Search registers |
| `<Space>sm` | Search marks |
| `<Space>sc` | Search command history |
| `<Space>sa` | Search autocommands |
| `<Space>sR` | Resume last telescope picker |

---

### Tmux

#### IDE layout (tmuxinator)

```
┌──────┬─────────────────────────────────┐
│      │                                 │
│      │          Neovim (80%)           │
│      │                                 │
│ 20%  │                                 │
│Claude├─────────────────────────────────┤
│      │        Terminal (20%)           │
└──────┴─────────────────────────────────┘
```

Launch it with one command:

```bash
ide ~/Projects/myapp          # opens the layout in that directory
ide                           # opens in current directory

# or directly:
tmuxinator start ide ~/Projects/myapp
```

Template lives at `~/.config/tmuxinator/ide.yml` (managed by chezmoi).

**Manual setup** (without tmuxinator):

```bash
tmux                          # start tmux (or tmux a to reattach)
claude                        # pane 1 -- claude
prefix + %                    # vertical split (left/right)
nvim .                        # pane 2 -- nvim
prefix + "                    # horizontal split (top/bottom)
                              # pane 3 -- terminal
```

#### Moving between panes

| Keybinding | Action |
|---|---|
| `Ctrl+h` | Move left (works from nvim too -- vim-tmux-navigator) |
| `Ctrl+j` | Move down |
| `Ctrl+k` | Move up |
| `Ctrl+l` | Move right |
| `Alt+Arrow` | Move between panes (no prefix needed) |

#### Resizing panes

| Keybinding | Action |
|---|---|
| `prefix + z` | Zoom current pane to full screen (toggle) |
| `prefix + Arrow` | Resize pane in that direction |
| Mouse drag | Drag pane borders to resize |

#### Windows and sessions

| Keybinding | Action |
|---|---|
| `prefix + c` | Create new window (like a new tab) |
| `Shift+Left/Right` | Switch between windows |
| `Alt+H` / `Alt+L` | Switch windows (vim style) |
| `prefix + o` | Session picker (sessionx + zoxide) |
| `prefix + p` | Floating terminal (floax) |
| `prefix + d` | Detach from session (it keeps running) |

#### Copy mode (vi-style)

| Keybinding | Action |
|---|---|
| `prefix + [` | Enter copy mode (scroll/select) |
| `v` | Start selection |
| `Ctrl+v` | Rectangle selection |
| `y` | Copy and exit |
| `/` | Search forward |
| `?` | Search backward |

#### Useful extras

| Keybinding / Command | Action |
|---|---|
| `prefix + I` | Install tmux plugins (after adding to conf) |
| `tmux-fzf-url` | Opens URLs from terminal output with fzf |
| `tmux-thumbs` | Quick-copy paths, hashes, IPs from output |
| Sessions auto-save | tmux-continuum saves every 15 min, resurrect restores on start |
