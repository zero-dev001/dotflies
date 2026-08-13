# Package Management: Brewfiles

> Four tiers of packages, from survival essentials to specialty tools -- install exactly what you need.

---

## Overview

This environment uses a tiered Brewfile system to manage Homebrew packages. Instead of a single monolithic Brewfile, packages are organized into four tiers based on how essential they are to daily work. This design serves two purposes: on a new machine, you can install only the base tier to get a functional environment in minutes, then add tiers as needed. On an existing machine, the tier structure makes it clear which packages are critical and which are optional.

All Brewfiles live in the chezmoi source directory under `brewfiles/`:

```
~/.local/share/chezmoi/brewfiles/
    00-base.Brewfile
    10-essential.Brewfile
    15-nice-to-have.Brewfile
    20-optional.Brewfile
```

A master `Brewfile` in the repository root aggregates all tiers for a full install.

---

## Tier 0: Base (00-base.Brewfile)

Core CLI tools that form the foundation of the development environment. Without these, basic navigation, editing, and shell functionality would be degraded. Every machine gets this tier.

| Package      | Purpose                                    |
|--------------|--------------------------------------------|
| `chezmoi`    | Dotfiles manager (manages itself)          |
| `git`        | Version control                            |
| `fzf`        | Fuzzy finder for files, history, anything  |
| `bat`        | `cat` replacement with syntax highlighting |
| `btop`       | System monitor (replaces htop/top)         |
| `eza`        | `ls` replacement with icons and git status |
| `fd`         | `find` replacement, respects .gitignore    |
| `ripgrep`    | `grep` replacement, extremely fast         |
| `zoxide`     | `cd` replacement with frecency ranking     |
| `starship`   | Cross-shell prompt with git integration    |
| `neovim`     | The editor                                 |
| `tmux`       | Terminal multiplexer                       |
| `tmuxinator` | Tmux session layouts in YAML               |
| `curl`       | HTTP client                                |
| `wget`       | File downloader                            |
| `jq`         | JSON processor                             |
| `grep`       | GNU grep (for extended regex support)      |
| `atuin`      | Shell history with sync and search         |
| `sesh`       | Tmux session manager with fzf integration  |
| `git-delta`  | Syntax-highlighting diff pager             |

These 21 packages are the absolute minimum for a productive terminal session. If you had to rebuild your environment on a plane with limited bandwidth, this is the tier to install.

### Installing Base Only

```bash
brew bundle --file=~/.local/share/chezmoi/brewfiles/00-base.Brewfile
```

---

## Tier 1: Essential (10-essential.Brewfile)

Daily driver tools and GUI applications. These are not strictly required for basic functionality, but working without them would mean constant friction. Most development days use every tool in this tier.

### CLI Tools

| Package        | Purpose                                      |
|----------------|----------------------------------------------|
| `lazygit`      | Terminal UI for git (staging, rebasing, etc.) |
| `gh`           | GitHub CLI (PRs, issues, actions)            |
| `ast-grep`     | Structural code search and replace           |
| `fastfetch`    | System info display                          |
| `diffnav`      | Interactive diff navigator                   |
| `yazi`         | Terminal file manager with previews          |
| `tldr`         | Simplified man pages with examples           |
| `imagemagick`  | Image processing from the command line       |
| `luarocks`     | Lua package manager (for Neovim plugins)     |
| `stow`         | Symlink farm manager (backup dotfile tool)   |
| `mise`         | Polyglot runtime version manager             |

### GUI Applications (Casks)

| Cask                              | Purpose                               |
|-----------------------------------|---------------------------------------|
| `nikitabobko/tap/aerospace`       | Tiling window manager for macOS       |
| `iterm2`                          | Terminal emulator                     |
| `alt-tab`                         | Windows-style Alt+Tab with previews   |
| `hiddenbar`                       | Hide menu bar icons                   |
| `font-symbols-only-nerd-font`     | Nerd Font icons (for eza, starship)   |
| `stats`                           | Menu bar system monitor               |
| `claude-code`                     | Claude AI desktop application         |
| `cursor`                          | AI-enhanced code editor               |

### Installing Essentials

```bash
brew bundle --file=~/.local/share/chezmoi/brewfiles/10-essential.Brewfile
```

---

## Tier 2: Nice-to-Have (15-nice-to-have.Brewfile)

Useful tools and applications that enhance the workflow but are not needed every day. You might not notice their absence for a few days, but you would eventually miss them.

### CLI Tools

| Package               | Purpose                                    |
|-----------------------|--------------------------------------------|
| `aria2`               | Multi-connection download accelerator      |
| `ffmpeg`              | Video/audio processing                     |
| `ffmpegthumbnailer`   | Video thumbnail generator (for Yazi)       |
| `fish`                | Friendly Interactive Shell (for testing)   |
| `ghostscript`         | PostScript/PDF interpreter                 |
| `jj`                  | Jujutsu VCS (experimental git alternative) |
| `llvm`                | Compiler infrastructure (clangd, etc.)     |
| `mermaid-cli`         | Render Mermaid diagrams from CLI           |
| `pandoc`              | Universal document converter               |
| `poppler`             | PDF rendering library (for previews)       |
| `sevenzip`            | Archive manager                            |
| `syncthing`           | File synchronization between devices       |
| `yt-dlp`              | Video downloader                           |

### GUI Applications (Casks)

| Cask                          | Purpose                               |
|-------------------------------|---------------------------------------|
| `discord`                     | Community chat                        |
| `docker-desktop`              | Container runtime and management      |
| `firefox@developer-edition`   | Development browser                   |
| `iina`                        | Modern macOS media player             |
| `itsycal`                     | Menu bar calendar                     |
| `keka`                        | Archive utility                       |
| `slack`                       | Team communication                    |
| `spotify`                     | Music streaming                       |
| `sublime-text`                | Quick text editor (for non-code files)|
| `telegram`                    | Messaging                             |

### Installing Nice-to-Have

```bash
brew bundle --file=~/.local/share/chezmoi/brewfiles/15-nice-to-have.Brewfile
```

---

## Tier 3: Optional (20-optional.Brewfile)

Specialized tools for specific projects or roles. A frontend developer might never need `redis` or `mysql-client`. A backend developer might never need `keycastr`. Install these on demand.

### CLI Tools

| Package         | Purpose                                  |
|-----------------|------------------------------------------|
| `firebase-cli`  | Firebase project management              |
| `iredis`        | Interactive Redis CLI with autocomplete  |
| `mysql-client`  | MySQL command-line client                |
| `openvpn`       | VPN client                               |
| `redis`         | In-memory data store (local dev)         |
| `telnet`        | Network debugging                        |
| `worktrunk`     | Trunk-based development tool             |

### GUI Applications (Casks)

| Cask               | Purpose                                 |
|--------------------|-----------------------------------------|
| `kap`              | Screen recorder                         |
| `key-codes`        | Display key codes for key presses       |
| `keycastr`         | Show keystrokes on screen (for demos)   |
| `keycue`           | Shortcut cheat sheet overlay            |
| `mysqlworkbench`   | MySQL GUI client                        |
| `time-out`         | Break reminder                          |

### VS Code Extensions

The optional tier also includes VS Code extensions for when Cursor or VS Code is used alongside Neovim:

| Extension                                    | Purpose                           |
|----------------------------------------------|-----------------------------------|
| `catppuccin.catppuccin-vsc`                  | Catppuccin theme                  |
| `catppuccin.catppuccin-vsc-icons`            | Catppuccin file icons             |
| `dbaeumer.vscode-eslint`                     | ESLint integration                |
| `esbenp.prettier-vscode`                     | Prettier formatter                |
| `bradlc.vscode-tailwindcss`                  | Tailwind CSS intellisense        |
| `prisma.prisma`                              | Prisma ORM support                |
| `svelte.svelte-vscode`                       | Svelte language support           |
| `vue.volar`                                  | Vue language support              |
| `yoavbls.pretty-ts-errors`                   | Human-readable TypeScript errors  |
| `gruntfuggly.todo-tree`                      | Highlight and list TODOs          |
| `streetsidesoftware.code-spell-checker`      | Spell checking in code            |

### UV Tools

| Tool       | Purpose                                       |
|------------|-----------------------------------------------|
| `posting`  | Terminal-based HTTP client (via uv)           |

### Installing Optional

```bash
brew bundle --file=~/.local/share/chezmoi/brewfiles/20-optional.Brewfile
```

---

## The Master Brewfile

The `Brewfile` in the repository root aggregates all packages from all tiers into a single file. This is what the chezmoi run-on-change script uses:

```bash
brew bundle --file="{{ .chezmoi.sourceDir }}/Brewfile"
```

The master Brewfile is a flat list of all `brew`, `cask`, `vscode`, and `uv` entries. It is regenerated or manually maintained to include everything from all four tiers.

---

## How chezmoi Triggers Brew Bundle

The install script `run_onchange_before_install-brew-packages.sh.tmpl` is a chezmoi template. Its first line includes a hash of the Brewfile:

```bash
# Brewfile hash: {{ include "Brewfile" | sha256sum }}
```

When any package is added to or removed from the Brewfile, the SHA-256 hash changes, the rendered script content changes, and chezmoi detects the change during `chezmoi apply`. The `before_` prefix ensures Homebrew packages are installed before configuration files are written, so tools like `starship` and `fzf` are available when their configuration files land.

---

## Selective Installation

For a minimal setup on a constrained machine:

```bash
# Just the survival kit
brew bundle --file=brewfiles/00-base.Brewfile

# Add daily drivers
brew bundle --file=brewfiles/10-essential.Brewfile

# Everything
brew bundle --file=Brewfile
```

For checking what is already installed versus what a Brewfile specifies:

```bash
brew bundle check --file=brewfiles/00-base.Brewfile
```

For cleaning up packages not in any Brewfile:

```bash
brew bundle cleanup --file=Brewfile
```

---

## Quick Reference

```bash
# Install all packages
brew bundle --file=~/.local/share/chezmoi/Brewfile

# Install only base tier
brew bundle --file=~/.local/share/chezmoi/brewfiles/00-base.Brewfile

# Check what is missing
brew bundle check

# Remove packages not in Brewfile
brew bundle cleanup --force

# List installed packages
brew list
brew list --cask
```

\newpage
