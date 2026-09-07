# dotfiles

macOS development environment managed with [chezmoi](https://www.chezmoi.io/). Auto-syncs across machines via a LaunchAgent that runs `chezmoi update` on login.

## Stack overview

| Layer | Tool | Config file |
|---|---|---|
| Shell | Zsh + Oh My Zsh + Powerlevel10k | `~/.zshrc`, `~/.p10k.zsh` |
| Shell plugins | zsh-syntax-highlighting, zsh-autosuggestions | (via Oh My Zsh) |
| Editor | Neovim (LazyVim) | `~/.config/nvim/` |
| Terminal multiplexer | Herdr + Catppuccin | `~/.config/herdr/config.toml` |
| Fuzzy finder | fzf | `~/.fzf.zsh` |
| File manager | yazi | (aliased as `y`) |
| File listing | eza | (aliased as `ls`, `l`, `lt`) |
| Directory jumping | zoxide (replaces `cd`) | (eval in zshrc) |
| Shell history | atuin | (eval in zshrc) |
| File search | fd + ripgrep | (used via fzf, nvim) |
| Git | git + lazygit + gh | `~/.gitconfig` |
| Version control (experimental) | jj (Jujutsu) | (in Brewfile) |
| Node.js | NVM + Node 22 + Bun | `~/.nvm`, `~/.bun` |
| AI | Claude Code | Brewfile |
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

### Optional per-machine settings

Some templates read optional values from chezmoi's own external config (`~/.config/chezmoi/chezmoi.toml`), which lives outside this repo and is never committed. Add a `[data]` table there to set them:

```toml
[data]
projectSrcPath = "Developer/myproject"   # source dir watched by the post-commit backup hook
backupDestPath = "Backups/myproject"     # backup destination for that hook
projectBinPath = "Developer/myproject/bin"  # extra dir appended to $PATH
excludeOrgs = ["some-org", "another-org"]   # orgs hidden from gh-dash's PR/issue sections
```

All are optional; templates fall back to sane defaults (empty/no-op) when unset.

---

## Development workflow

### Daily startup

```bash
herdr                         # start Herdr, or re-attach (workspaces persist across terminal closes)
ide ~/Projects/myapp          # or jump straight into the IDE layout for a project
```

Once inside Herdr, use **prefix + w** to open the workspace picker, or `ide <dir>` to add a workspace per project.

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
| `ide [dir]` | `ide ~/Projects/myapp` | Herdr IDE workspace (Claude + nvim + terminal) |

---

## Herdr keybindings

Herdr is the terminal workspace manager (replaces tmux). It runs a background server so panes, shells, and Claude sessions survive closing the terminal. Config: `~/.config/herdr/config.toml`.

**Prefix key:** `Ctrl+b`

### Panes

| Keybinding | Action |
|---|---|
| `prefix + h/j/k/l` | Move to pane left/down/up/right |
| `prefix + v` | Split side by side |
| `prefix + -` | Split stacked |
| `prefix + z` | Zoom current pane (toggle) |
| `prefix + x` | Close pane |
| `prefix + r` | Resize mode (then h/j/k/l) |
| `Alt + Arrow` | Resize pane directly |
| `prefix + e` | Open scrollback in Neovim (replaces copy mode) |

### Tabs (were tmux windows)

| Keybinding | Action |
|---|---|
| `prefix + c` | New tab |
| `prefix + n` / `prefix + p` | Next / previous tab |
| `prefix + 1..9` | Jump to tab N |
| `prefix + Shift+T` | Rename tab |
| `prefix + Shift+X` | Close tab |

### Workspaces (were tmux sessions)

| Keybinding | Action |
|---|---|
| `prefix + w` | Workspace picker |
| `prefix + Shift+N` | New workspace |
| `prefix + Shift+W` | Rename workspace |
| `prefix + Shift+D` | Close workspace |
| `Alt + Shift+H/L` | Previous / next workspace |
| `prefix + b` | Toggle sidebar |
| `prefix + d` | Detach (server keeps running) |

### Popups

| Keybinding | Action |
|---|---|
| `prefix + g` | lazygit in a floating popup |
| `prefix + f` | Floating scratch terminal |
| `prefix + ?` | Keybinding help |
| `prefix + s` | Settings |

### CLI

```bash
herdr                         # launch or re-attach
herdr status                  # client + server status
herdr workspace list          # JSON list of workspaces
herdr session list            # named sessions (default is "default")
herdr server reload-config    # after editing config.toml
herdr update                  # self-update
```

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
| `run_once_install-herdr.sh` | First apply only | Installs Herdr (terminal workspace manager) to `~/.local/bin` |

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

### Herdr
- `~/.config/herdr/config.toml` -- Herdr keybindings, Catppuccin theme, lazygit/terminal popups

### Neovim
- `~/.config/nvim/` -- LazyVim configuration

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
| Floating terminal / lazygit | `prefix + f` / `prefix + g` (Herdr popups) |
| Switch workspaces | `prefix + w` (Herdr workspace picker) |
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

### Herdr

#### IDE layout

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
ide ~/Projects/myapp          # new workspace named "myapp" with this layout, then attach
ide                           # same, in the current directory
```

`ide` is a shell function in `~/.aliases.zsh`. It starts the Herdr server if needed, creates a workspace via the socket API (`herdr workspace create`, `herdr pane split`, `herdr pane run`), starts Claude on the left and Neovim on the top right, and attaches. Run it again for another project: each call adds a workspace, switch with `prefix + w`.

**Manual setup** (without `ide`):

```bash
herdr                         # start or attach
claude                        # pane 1 -- claude
prefix + v                    # split side by side
nvim .                        # pane 2 -- nvim
prefix + -                    # split stacked
                              # pane 3 -- terminal
```

#### Moving between panes

| Keybinding | Action |
|---|---|
| `prefix + h/j/k/l` | Move left / down / up / right |
| `prefix + Tab` | Cycle to next pane |
| `prefix + z` | Zoom pane (toggle) |

#### Resizing panes

| Keybinding | Action |
|---|---|
| `Alt + Arrow` | Resize in that direction |
| `prefix + r` | Enter resize mode, then h/j/k/l |
| Mouse drag | Drag pane borders |

#### Tabs and workspaces

| Keybinding | Action |
|---|---|
| `prefix + c` | New tab |
| `prefix + n` / `prefix + p` | Next / previous tab |
| `prefix + w` | Workspace picker |
| `prefix + Shift+N` | New workspace |
| `prefix + d` | Detach (everything keeps running) |

#### Scrollback and copy

| Keybinding | Action |
|---|---|
| Mouse select | Copies to clipboard automatically |
| `prefix + e` | Open pane scrollback in Neovim (search, yank, etc.) |
| Mouse wheel | Scroll pane history |

#### Persistence

| What | How |
|---|---|
| Detach / close terminal | Server keeps running, `herdr` re-attaches with everything intact |
| Reboot / server restart | Workspaces, tabs, panes, cwd, and layout restore as fresh shells |
| Claude Code sessions | Resumed automatically after a server restart |
| Update without losing panes | `herdr update --handoff` |
