# Workflow: Daily Startup

> From cold boot to full development session in under thirty seconds.

---

## Overview

The daily startup workflow is designed to eliminate friction between opening the laptop and writing code. Every layer of the stack -- the terminal, the multiplexer, the session manager, the window manager -- is configured to restore state automatically or to provide fast paths to the right context. There is no manual window arrangement, no hunting for project directories, no waiting for tools to initialize.

This chapter walks through the sequence from opening a terminal to having a multi-project development session running across organized workspaces.

---

## Step 1: Open the Terminal

When iTerm2 launches, attach to an existing tmux session or create a new one:

```bash
tmux attach || tmux
```

This means opening the terminal is equivalent to opening tmux. If a tmux server is already running (because the previous session was not shut down), it reattaches instantly, restoring all windows and panes exactly as they were left.

If no tmux server exists (fresh boot), tmux starts with a single window. The tmux-continuum plugin then restores the previous session layout automatically, because `@continuum-restore` is set to `on`.

**Result after this step:** You are inside tmux with your previous session state restored. Aerospace has already placed the iTerm2 window on Workspace 2 (terminals).

---

## Step 2: Pick or Create a Project Session

With tmux running, the next action is to navigate to the right project. There are two primary mechanisms:

### Option A: Sesh (prefix + T)

Press `Ctrl+b` then `T`. This launches the sesh session picker in an fzf popup:

The popup shows all available sessions and provides keyboard shortcuts to filter:

| Key        | Action                                        |
|------------|-----------------------------------------------|
| `Ctrl+a`   | Show all sessions                             |
| `Ctrl+t`   | Show only tmux sessions                       |
| `Ctrl+g`   | Show config-defined sessions (from sesh.toml) |
| `Ctrl+x`   | Show zoxide directories                       |
| `Ctrl+f`   | Find directories under home (fd search)       |
| `Ctrl+d`   | Kill the selected tmux session                |
| `Tab`       | Move down in the list                         |
| `Shift+Tab` | Move up in the list                          |

Selecting a session either attaches to an existing tmux session or creates a new one in the selected directory.

### Option B: SessionX (prefix + o)

Press `Ctrl+b` then `o`. SessionX provides a similar session picker with zoxide integration (`@sessionx-zoxide-mode` is on). The difference is stylistic: SessionX has a different UI and preview layout.

### Pre-Defined Sessions

The `sesh.toml` configuration defines named sessions that appear in the picker:

```toml
[[session]]
name = "dotfiles"
path = "~/.local/share/chezmoi"
startup_command = "nvim"

[[session]]
name = "nvim config"
path = "~/.config/nvim"
startup_command = "nvim lua/config/lazy.lua"
```

These sessions launch with a specific command already running. Selecting "dotfiles" opens the chezmoi source directory with Neovim ready to edit.

**Result after this step:** You are in a tmux session named after your project, in the project directory.

---

## Step 3: Launch the IDE Layout

For a project that needs a full development layout, run:

```bash
ide .
```

Or for a specific directory:

```bash
ide ~/Projects/my-app
```

The `ide()` function creates a tmuxinator-driven layout with three panes:

```
+--------------------+-----------------------------------+
|                    |                                   |
|   Claude Code      |          Neovim                   |
|   (20% width)     |          (80% width)              |
|                    |                                   |
|                    |                                   |
|                    |                                   |
|                    +-----------------------------------+
|                    |       Terminal (20% height)       |
+--------------------+-----------------------------------+
```

- **Left pane (20%):** Claude Code for AI-assisted development
- **Right top pane (80%):** Neovim for editing
- **Right bottom pane (20%):** Terminal for running commands, tests, dev servers

The cursor starts in the Neovim pane. The tmux window is renamed to the project directory name.

**Result after this step:** You have a three-pane IDE layout with AI, editor, and terminal ready.

---

## Step 4: Navigate Between Projects

Throughout the day, you move between project sessions. zoxide makes directory jumping fast:

```bash
cd my-app        # jumps to ~/Projects/my-app (or wherever you visit most)
cd dotfiles      # jumps to ~/.local/share/chezmoi
cd config        # jumps to ~/.config/nvim (or whichever "config" dir ranks highest)
```

Because zoxide is aliased to `cd` (`eval "$(zoxide init zsh --cmd cd)"`), every `cd` command is a frecency-weighted jump. Type a partial directory name and zoxide figures out where you mean.

To switch between tmux sessions without leaving the current one, use the sesh picker (`prefix + T`) or simply:

```bash
tmux switch-client -t session-name
```

---

## Step 5: Sessions Persist Automatically

Two tmux plugins handle session persistence:

- **tmux-resurrect:** Saves the complete tmux environment (sessions, windows, panes, working directories, and even running programs) to disk. It can restore Neovim sessions if `@resurrect-strategy-nvim` is set to `session`.

- **tmux-continuum:** Automatically saves the tmux environment at regular intervals and restores it when tmux starts. With `@continuum-restore` set to `on`, this happens transparently.

This means you can close the laptop, reboot, or even quit tmux, and the next time you open iTerm2, your full workspace is restored: every session, every window, every pane, in the right directories.

---

## Step 6: Workspace Organization with Aerospace

Aerospace manages the macOS window layer above tmux. Windows are automatically assigned to workspaces based on application rules:

| Workspace | Applications                          | Purpose             |
|-----------|---------------------------------------|---------------------|
| 1         | Firefox Developer Edition             | Browsers            |
| 2         | iTerm2                                | Terminals           |
| 3         | Slack, Discord, Telegram              | Communication       |
| 4         | Spotify                               | Media / Other       |

Switching workspaces:

| Key       | Action              |
|-----------|---------------------|
| `Alt+1`   | Switch to Workspace 1 (browsers)       |
| `Alt+2`   | Switch to Workspace 2 (terminals)      |
| `Alt+3`   | Switch to Workspace 3 (communication)  |
| `Alt+4`   | Switch to Workspace 4 (media)          |

Within a workspace, Aerospace tiles windows automatically. There is no manual dragging or resizing. When you open a new terminal window, it tiles next to the existing one. When you close one, the remaining windows fill the space.

**Result after this step:** Your screen real estate is organized by context, with instant workspace switching.

---

## The Full Sequence

Here is the entire startup sequence, from opening the laptop to productive coding:

1. **Open iTerm2** -- tmux auto-attaches, continuum restores sessions
2. **`prefix + T`** -- pick a project session from sesh
3. **`ide .`** -- launch the three-pane IDE layout (if not already set up)
4. **`Alt+1` / `Alt+2`** -- switch between browser and terminal workspaces
5. **Start coding** -- Neovim is focused, Claude Code is in the left pane, terminal is below

Total time from cold boot to coding: under thirty seconds, most of which is macOS boot time. From a warm resume (laptop lid open): under five seconds.

---

## When Things Go Wrong

| Problem                             | Solution                                        |
|-------------------------------------|-------------------------------------------------|
| tmux did not auto-restore           | Run `prefix + Ctrl+r` to manually restore       |
| Wrong session after terminal launch | Use `prefix + T` to switch                      |
| IDE layout panes wrong size         | Run `ide .` again in the project directory       |
| Aerospace not tiling                | Check if it is running: `aerospace list-windows` |
| zoxide jumps to wrong directory     | `cd -` to go back, then use full path once       |
| iTerm2 not launching on Workspace 2 | Check Aerospace window rules in aerospace.toml   |

---

## Quick Reference

```bash
# Session management
prefix + T          # sesh session picker
prefix + o          # SessionX session picker
prefix + d          # detach from tmux
prefix + $          # rename current session

# IDE layout
ide .               # three-pane layout in current dir
ide ~/Projects/app  # three-pane layout in specific dir

# Workspace switching (Aerospace)
Alt+1 through Alt+4  # switch workspaces
Alt+Shift+1 through Alt+Shift+4  # move window to workspace

# Session persistence
prefix + Ctrl+s     # manual save (tmux-resurrect)
prefix + Ctrl+r     # manual restore (tmux-resurrect)
```

\newpage
