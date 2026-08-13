# Introduction

> A terminal-first macOS development environment, unified by Catppuccin Mocha and vim-style navigation.

---

## What This Book Is

This is a comprehensive, print-ready reference for zero.dev001's development environment. It is not a tutorial that walks you through installation step by step. It is a field manual -- the kind of book you keep on your desk, flip open to a chapter, and find the exact keybinding, command, or configuration snippet you need.

Every tool in this environment was chosen deliberately. Every keybinding was tested against real workflows. Every configuration option was tuned for speed, clarity, and consistency. This book documents all of it.

## Who This Book Is For

This book is written for one person: zero.dev001. But it is useful for anyone who wants to understand how a modern, terminal-centric macOS development setup fits together. If you are building your own environment, you will find ideas worth stealing. If you are pair programming with zero.dev001, you will understand why his screen looks and behaves the way it does.

## The Unifying Principles

Three principles hold this entire environment together.

### Catppuccin Mocha Everywhere

Every tool in this setup uses the Catppuccin Mocha color palette. The terminal, the editor, the prompt, the file manager, the git interface, the system bar -- all of them render in the same warm, low-contrast palette. This is not cosmetic vanity. Consistent colors reduce cognitive switching cost. When a filename is cyan in the terminal, it is cyan in Neovim, and it is cyan in Yazi. When a git addition is green in lazygit, it is the same green in delta, and the same green in the Neovim gutter.

The Catppuccin Mocha palette used throughout:

| Role       | Color Name | Hex       | Usage                        |
|------------|------------|-----------|------------------------------|
| Rosewater  | rosewater  | `#f5e0dc` | Cursor, subtle highlights    |
| Flamingo   | flamingo   | `#f2cdcd` | Warnings, paired brackets    |
| Pink       | pink       | `#f5c2e7` | Git branches, keywords       |
| Mauve      | mauve      | `#cba6f7` | Prompt user, time, vim mode  |
| Red        | red        | `#f38ba8` | Errors, deletions            |
| Maroon     | maroon     | `#eba0ac` | Secondary errors             |
| Peach      | peach      | `#fab387` | Git status, numbers          |
| Yellow     | yellow     | `#f9e2af` | Warnings, cmd duration       |
| Green      | green      | `#a6e3a1` | Success, additions, hostname |
| Teal       | teal       | `#94e2d5` | Info, secondary highlights   |
| Sky        | sky        | `#89dceb` | Directory paths, Go          |
| Sapphire   | sapphire   | `#74c7ec` | Links                        |
| Blue       | blue       | `#89b4fa` | Docker, functions            |
| Lavender   | lavender   | `#b4befe` | Headings                     |
| Text       | text       | `#cdd6f4` | Default foreground           |
| Base       | base       | `#1e1e2e` | Background                   |

### Vim-Style Navigation Everywhere

The `h`, `j`, `k`, `l` keys mean the same thing in every context:

| Key | Direction | In Neovim      | In tmux        | In Yazi     | In lazygit  | In Aerospace |
|-----|-----------|----------------|----------------|-------------|-------------|--------------|
| `h` | Left      | Move left      | Pane left      | Parent dir  | Prev panel  | Focus left   |
| `j` | Down      | Move down      | Pane down      | Next item   | Next item   | Focus down   |
| `k` | Up        | Move up        | Pane up        | Prev item   | Prev item   | Focus up     |
| `l` | Right     | Move right     | Pane right     | Open/enter  | Next panel  | Focus right  |

This consistency is not accidental. When you internalize hjkl in one tool, you have internalized it in every tool. The same applies to `/` for search, `q` for quit, `G` for go-to-bottom, and `gg` for go-to-top.

## How This Book Is Organized

The book is divided into nine parts plus an appendix, ordered from the lowest layer of the stack (keyboard input) to the highest (complete workflows).

### Part 1: Foundations

Chapters 2--3 cover the base layer that everything else depends on.

- **Chapter 2: Shell: Zsh + Starship** -- Oh My Zsh plugins, environment variables, tool initialization order, and the two-line Starship prompt.
- **Chapter 3: macOS Defaults** -- The `defaults write` commands that make macOS behave like a development OS: fast key repeat, no autocorrect, no animations, sensible Finder and Dock settings.

### Part 2: Navigation

Chapters 5--8 cover how to move through the filesystem and find things.

- **Chapter 5: Zoxide** -- Frecency-based directory jumping that replaces `cd`.
- **Chapter 6: fzf** -- Fuzzy finding for files, history, processes, and anything else that produces lines of text.
- **Chapter 7: fd + ripgrep** -- Modern replacements for `find` and `grep` that respect `.gitignore` and run in parallel.
- **Chapter 8: Yazi** -- Terminal file manager with vim keybindings and image preview.

### Part 3: Editor

Chapters 9--13 cover Neovim from fundamentals to AI-assisted coding.

- **Chapter 9: Neovim Fundamentals** -- Modes, motions, text objects, registers, and macros.
- **Chapter 10: LazyVim** -- The plugin framework, lazy-loading, and the `lua/` directory structure.
- **Chapter 11: Plugins Deep Dive** -- Telescope, Treesitter, Harpoon, Oil, and the rest of the plugin stack.
- **Chapter 12: LSP and Completion** -- Language servers, Mason, nvim-cmp, and diagnostics.
- **Chapter 13: AI with 99.nvim** -- AI-assisted coding inside Neovim.

### Part 4: Tmux

Chapters 14--17 cover terminal multiplexing and session management.

- **Chapter 14: Tmux Core** -- Windows, panes, the prefix key, and copy mode.
- **Chapter 15: Tmux Plugins** -- TPM, Catppuccin status bar, vim-tmux-navigator, and tmux-resurrect.
- **Chapter 16: Sesh Sessions** -- Fuzzy session management with sesh and its integration with zoxide.
- **Chapter 17: IDE Layout** -- Scripted pane layouts for different project types.

### Part 5: Git

Chapters 18--21 cover the complete git workflow.

- **Chapter 18: Git Workflow** -- Branching strategy, commit conventions, and rebase workflows.
- **Chapter 19: Delta** -- A syntax-highlighting pager for diffs with Catppuccin colors.
- **Chapter 20: Lazygit** -- A terminal UI for git that makes interactive rebasing, staging hunks, and resolving conflicts visual.
- **Chapter 21: GitHub CLI** -- `gh` for PRs, issues, actions, and `gh dash` for a dashboard.

### Part 6: Window Management

- **Chapter 22: Aerospace** -- A tiling window manager for macOS with vim-style workspace switching and window movement.

### Part 7: CLI Toolbox

Chapters 23--25 cover the modern CLI replacements and utilities.

- **Chapter 23: Modern Replacements** -- `bat` (cat), `eza` (ls), `dust` (du), `procs` (ps), and `sd` (sed).
- **Chapter 24: Data Processing** -- `jq`, `curl`/`wget`, `grep`/`sed`/`awk`, and `pandoc`/`ffmpeg`.
- **Chapter 25: System Monitoring** -- `btop`, `fastfetch`, `atuin` shell history.

### Part 8: Dev Environment

Chapters 26--28 cover language runtimes, dotfile management, and package management.

- **Chapter 26: Node, NVM, and Bun** -- JavaScript runtime management and the Bun bundler/runtime.
- **Chapter 27: mise** -- Polyglot runtime version management (the successor to asdf).
- **Chapter 28: Chezmoi and Brewfiles** -- Dotfile management across machines and tiered Homebrew bundles.

### Part 9: Workflows

Chapters 29--32 tie everything together into complete workflows.

- **Chapter 29: Daily Startup** -- From opening the laptop to a fully loaded development session.
- **Chapter 30: New Project Setup** -- Scaffolding a project, initializing git, setting up the dev environment.
- **Chapter 31: Code Review** -- Reviewing PRs with lazygit, delta, and Neovim.
- **Chapter 32: Debugging with AI** -- Using AI tools in the terminal and editor to diagnose and fix issues.

### Appendix

- **Complete Keybinding Reference** -- Every keybinding in every tool, organized by context.
- **Alias Quick Reference** -- All shell aliases and what they expand to.
- **Configuration File Index** -- Where every config file lives and what it controls.

## How to Use This Book

**At your desk:** Keep it open to the chapter you are learning. The "Essential Commands" tables in each chapter are designed for quick scanning.

**When you forget a keybinding:** Flip to the appendix. Every keybinding is listed by tool and by action.

**When configuring a new machine:** Follow Parts 1 and 8 in order. The chezmoi chapter explains how to bootstrap everything from the dotfiles repository.

**When onboarding someone:** Hand them the book. The Foundations chapters explain the "why" behind every choice, not just the "what."

## The Dotfiles

Every configuration file referenced in this book lives in a chezmoi-managed dotfiles repository. The source of truth is:

```
~/.local/share/chezmoi/
```

Chezmoi templates (files ending in `.tmpl`) allow machine-specific customization while keeping a single source of truth. The actual configuration files are deployed to their standard locations under `~/.config/` and `~/`.

When this book references a config file path like `~/.config/starship.toml`, the chezmoi source is `~/.local/share/chezmoi/dot_config/starship.toml`. Both paths are noted where relevant.

## Conventions Used in This Book

| Convention                | Meaning                                                |
|---------------------------|--------------------------------------------------------|
| `Ctrl+a`                 | Hold Ctrl, press a                                    |
| `<leader>`               | Space key (Neovim leader)                              |
| `<prefix>`               | Tmux prefix key (Ctrl+a)                              |
| `$ command`              | Run in a shell                                         |
| `:command`               | Run in Neovim command mode                             |
| **Bold text**            | UI element or important term                           |
| `monospace`              | Code, file paths, keybindings                          |
| Lines starting with `>`  | Tips or important notes                                |

---

This environment is a living system. Tools get updated, configurations evolve, and new workflows replace old ones. But the principles -- Catppuccin Mocha everywhere, vim-style navigation, and chezmoi-managed dotfiles -- remain constant. This book captures the system as it stands today: a fast, ergonomic, visually consistent development environment built for someone who lives in the terminal.

\newpage
