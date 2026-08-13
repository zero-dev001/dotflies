# Tmux Core

> A terminal multiplexer that lets you run persistent sessions with multiple windows and panes -- the backbone of every terminal workflow.

## Your Setup

The tmux configuration lives in `~/.tmux.conf`, managed by chezmoi as `dot_tmux.conf`. It is tuned for speed, modern terminal features, and Vim-style navigation.

Terminal and display settings:

```bash
set-option -sa terminal-overrides ",xterm*:Tc"   # True color support
set -g mouse on                                   # Full mouse support
set -g escape-time 0                              # No delay after Escape
set -g history-limit 1000000                      # 1 million lines of scrollback
set -g detach-on-destroy off                      # Stay in tmux when session closes
set -g set-clipboard on                           # OSC 52 clipboard integration
set -g status-position top                        # Status bar at the top
set -g set-titles on                              # Terminal title updates
set -g set-titles-string "#S"                     # Title shows session name
```

Indexing starts at 1, not 0, and windows renumber automatically when one is closed:

```bash
set -g base-index 1
set -g pane-base-index 1
set-window-option -g pane-base-index 1
set-option -g renumber-windows on
```

The prefix key is the default `Ctrl+b`.

Passthrough is enabled for tools like Neovim image protocols and terminal features that need to send escape sequences through tmux:

```bash
set -g allow-passthrough on
set -ga update-environment TERM
set -ga update-environment TERM_PROGRAM
```

The theme is Catppuccin Mocha, providing a consistent dark palette that matches the Neovim and terminal themes.

## Core Concepts

### The Tmux Hierarchy: Sessions, Windows, and Panes

Tmux organizes your work in three levels:

- **Session**: A named collection of windows. Each project or context gets its own session. Sessions persist even when you disconnect, so you can resume exactly where you left off.
- **Window**: A full-screen tab within a session. Think of these as tabs in a browser. Each window has its own set of panes.
- **Pane**: A split within a window. Panes divide a window into rectangular regions, each running an independent shell or process.

A typical structure looks like this:

```
Session: "webapp"
  Window 1: "editor"       -- nvim in a single pane
  Window 2: "servers"      -- two panes: API server | log tail
  Window 3: "database"     -- psql in a single pane

Session: "dotfiles"
  Window 1: "config"       -- nvim editing config files
```

### The Prefix Key

Most tmux commands start with the prefix key. The default is `Ctrl+b`. The prefix is a chord -- press and release it, then press the command key. It is not held down during the command key.

Example: to split horizontally, the sequence is:

1. Press `Ctrl+b` (prefix fires)
2. Release
3. Tap `"` (split command)

### Detach and Attach

The defining feature of tmux is that sessions survive disconnection. When you close your terminal or SSH connection, your tmux sessions continue running. You can reattach at any time and find everything exactly as you left it.

- **Detach**: `prefix + d` disconnects from the current session without stopping it.
- **Attach**: `tmux attach -t session-name` reconnects to a running session.
- **detach-on-destroy off**: When you close the last window in a session, tmux switches you to another session instead of dumping you back to the bare terminal. This keeps you inside tmux.

### Naming Conventions

Name sessions after projects or contexts: `webapp`, `dotfiles`, `api`. Name windows after their purpose: `editor`, `servers`, `tests`. This makes the status bar immediately readable and session switching intuitive.

## Essential Commands

### Starting and Managing Sessions

| Command | Action |
|---------|--------|
| `tmux` | Start a new unnamed session |
| `tmux new -s name` | Start a new session named "name" |
| `tmux ls` | List all running sessions |
| `tmux attach -t name` | Attach to session "name" |
| `tmux kill-session -t name` | Kill session "name" |
| `tmux kill-server` | Kill tmux entirely |
| `prefix + d` | Detach from current session |
| `prefix + $` | Rename current session |

### Window Management

| Keybinding | Action |
|------------|--------|
| `prefix + c` | Create new window |
| `prefix + ,` | Rename current window |
| `prefix + &` | Close current window (confirm) |
| `prefix + n` | Next window |
| `prefix + p` | Previous window |
| `prefix + 1-9` | Switch to window by number |
| `Shift+Left` | Previous window (no prefix) |
| `Shift+Right` | Next window (no prefix) |
| `Alt+H` | Previous window (no prefix) |
| `Alt+L` | Next window (no prefix) |

Note: `Shift+Left/Right` and `Alt+H/L` do not require the prefix key. They are bound with `-n` (no prefix) for rapid window switching.

### Pane Management

| Keybinding | Action |
|------------|--------|
| `prefix + "` | Split horizontally (current path) |
| `prefix + %` | Split vertically (current path) |
| `prefix + x` | Close current pane (confirm) |
| `prefix + z` | Toggle pane zoom (fullscreen) |
| `prefix + !` | Break pane into its own window |
| `prefix + q` | Show pane numbers (tap number to switch) |

### Pane Navigation

| Keybinding | Action |
|------------|--------|
| `prefix + h` | Select pane left |
| `prefix + j` | Select pane below |
| `prefix + k` | Select pane above |
| `prefix + l` | Select pane right |
| `Alt+Left` | Select pane left (no prefix) |
| `Alt+Right` | Select pane right (no prefix) |
| `Alt+Up` | Select pane above (no prefix) |
| `Alt+Down` | Select pane below (no prefix) |
| `Ctrl+h/j/k/l` | Navigate panes and Vim splits (vim-tmux-navigator) |

The vim-tmux-navigator plugin (covered in the next chapter) overrides `Ctrl+h/j/k/l` to move seamlessly between tmux panes and Neovim splits. The same keys work whether you are in a tmux pane or a Neovim split.

### Copy Mode

Copy mode uses vi keybindings. Enter it with `prefix + [`.

| Keybinding | Action |
|------------|--------|
| `prefix + [` | Enter copy mode |
| `v` | Start selection (in copy mode) |
| `Ctrl+v` | Toggle rectangle selection |
| `y` | Copy selection and exit copy mode |
| `q` | Exit copy mode |
| `/` | Search forward (in copy mode) |
| `?` | Search backward (in copy mode) |
| `n` / `N` | Next / previous search match |

In copy mode, standard Vim motions work: `h/j/k/l`, `w/b/e`, `0/$`, `gg/G`, `Ctrl+u/d` for half-page scrolling.

## Practical Recipes

### Start a named session and split into a working layout

```bash
tmux new -s webapp
# Inside tmux:
# prefix + " to split horizontally
# prefix + % to split vertically
```

### Quickly switch between two windows

Use `Shift+Left` and `Shift+Right` to flip between adjacent windows without touching the prefix key. For Vim-style switching, `Alt+H` and `Alt+L` do the same thing.

### Zoom a pane for full-screen focus

When a pane is too small to read comfortably, `prefix + z` toggles it to full screen. Press `prefix + z` again to restore the original layout. The zoomed pane is indicated in the status bar.

### Reorder windows after closing one

Windows renumber automatically (`renumber-windows on`). If you close window 2 out of windows 1, 2, 3, the remaining windows become 1, 2 -- no gaps.

### Copy text from terminal output

1. Enter copy mode: `prefix + [`
2. Navigate to the start of the text you want (Vim motions)
3. Press `v` to begin selection
4. Move to the end of the desired text
5. Press `y` to copy and exit copy mode
6. Paste with `prefix + ]` or your system paste shortcut

The tmux-yank plugin ensures the copied text also lands in your system clipboard.

### Move a pane to a different window

To move the current pane to window 3: `prefix + :` to open the command prompt, then type `join-pane -t :3`. To break a pane out into its own new window: `prefix + !`.

### Resize panes

Hold the prefix and use arrow keys: `prefix + Up/Down/Left/Right` resizes in that direction. Alternatively, use the command prompt: `prefix + :` then `resize-pane -D 10` to shrink down by 10 rows.

## Advanced Usage

### Why escape-time Is Zero

The `escape-time` setting controls how long tmux waits after receiving an Escape character before passing it through. The default is 500ms, which creates a noticeable lag when pressing Escape in Neovim to leave insert mode. Setting it to 0 eliminates this delay entirely. If you use a slow SSH connection where key sequences might arrive in fragments, you might need to raise this slightly, but for local use, 0 is ideal.

### The 1-Million-Line Scrollback

The `history-limit 1000000` setting gives each pane a scrollback buffer of one million lines. This is generous -- a typical terminal session with active build logs might generate tens of thousands of lines per hour. With a million lines, you can scroll back through an entire day of work. The memory cost is negligible on modern machines because tmux only allocates memory for lines that actually exist.

### Status Bar Position

The status bar sits at the top (`status-position top`), which pairs well with the Catppuccin theme and keeps the bottom of the terminal clear for command output. This is a matter of preference, but top positioning avoids conflicts with shell prompts and keeps session/window information at eye level.

### Set-Titles for Terminal Tab Names

With `set-titles on` and `set-titles-string "#S"`, tmux updates the terminal's title to show the current session name. In iTerm2, this means the tab title reflects which tmux session is active, making it easy to find the right tab when you have multiple terminal windows open.

### Base Index 1

Windows and panes start at 1 instead of 0. This matches the physical keyboard layout -- the number keys `1` through `9` are easier to reach than `0`, and `prefix + 1` being the first window feels natural. The `renumber-windows on` setting ensures that closing a window does not leave gaps in the numbering.

### Detach-on-Destroy Off

The default behavior when closing the last window in a session is to detach from tmux entirely, dropping you to the bare terminal. With `detach-on-destroy off`, tmux switches to the next available session instead. This keeps you inside tmux at all times, which is important when tmux is the foundation of your workflow.

### Mouse Support

Mouse mode is on, which allows:

- Clicking to select panes
- Clicking to select windows in the status bar
- Dragging pane borders to resize
- Scrolling to enter copy mode and scroll through history
- Selecting text (though keyboard-based copy mode is usually faster)

Mouse support does not interfere with terminal applications that handle mouse events themselves -- tmux passes mouse events through to the active pane's program.

### Clipboard Integration

The `set-clipboard on` setting enables OSC 52 clipboard integration, which allows tmux to set the system clipboard directly through the terminal's escape sequences. This works across SSH connections, remote machines, and inside nested tmux sessions. Combined with the tmux-yank plugin, copying text in tmux copy mode places it directly on the system clipboard.

\newpage
