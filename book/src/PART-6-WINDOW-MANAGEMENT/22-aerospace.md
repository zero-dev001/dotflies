# Window Management: Aerospace

> A tiling window manager for macOS that organizes windows into workspaces with vim-style keybindings, so you never drag, resize, or hunt for a window again.

## Your Setup

Aerospace is configured in `~/.config/aerospace/aerospace.toml` (chezmoi source: `dot_config/aerospace/aerospace.toml`):

```toml
start-at-login = true

enable-normalization-flatten-containers = true
enable-normalization-opposite-orientation-for-nested-containers = true

accordion-padding = 0
default-root-container-layout = 'tiles'
default-root-container-orientation = 'auto'
key-mapping.preset = 'qwerty'

on-focused-monitor-changed = ['move-mouse monitor-lazy-center']
on-focus-changed = ['move-mouse window-lazy-center']
```

Gaps between windows:

```toml
[gaps]
inner.horizontal = 10
inner.vertical = 10
outer.left = 0
outer.right = 0
outer.bottom = 0
outer.top = [
    { monitor."built-in" = 10 },
    { monitor.main = 38 },
    20,
]
```

The outer top gap varies by monitor: 10px on the built-in MacBook display, 38px on the main external monitor (to leave room for a menu bar or status bar), and 20px as the default for any other monitors.

Window rules automatically assign applications to workspaces:

```toml
# WS1: Browsers
[[on-window-detected]]
if.app-name-regex-substring = 'Firefox'
run = 'move-node-to-workspace 1'

# WS2: Terminals
[[on-window-detected]]
if.app-id = 'com.googlecode.iterm2'
run = 'move-node-to-workspace 2'

# WS3: Communication
[[on-window-detected]]
if.app-id = 'com.tinyspeck.slackmacgap'
run = 'move-node-to-workspace 3'

[[on-window-detected]]
if.app-id = 'com.hnc.Discord'
run = 'move-node-to-workspace 3'

[[on-window-detected]]
if.app-id = 'ru.keepcoder.Telegram'
run = 'move-node-to-workspace 3'

# WS4: Other/Media
[[on-window-detected]]
if.app-id = 'com.spotify.client'
run = 'move-node-to-workspace 4'
```

Workspace-to-monitor assignments:

```toml
[workspace-to-monitor-force-assignment]
1 = 'main'
2 = 'main'
3 = 'main'
4 = 'secondary'
```

Workspaces 1 through 3 live on the main monitor. Workspace 4 (media and other apps) is sent to the secondary monitor, keeping Spotify and auxiliary apps off the primary screen.

## Core Concepts

### Tiling vs. Floating

Traditional macOS window management is floating: windows overlap, you drag them around, you resize them by grabbing corners, and you lose windows behind other windows. Tiling window managers eliminate all of this. Every window occupies a non-overlapping tile. When you open a new window, existing windows shrink to make room. When you close a window, remaining windows expand. You never manually position anything.

Aerospace defaults to tiling mode (`default-root-container-layout = 'tiles'`). Individual windows can be toggled to floating mode when needed (via service mode).

### Workspaces

Workspaces are virtual desktops. This setup uses four:

| Workspace | Purpose | Applications |
|-----------|---------|-------------|
| 1 | Browsers | Firefox |
| 2 | Terminals | iTerm2 |
| 3 | Communication | Slack, Discord, Telegram |
| 4 | Media / Other | Spotify |

Switching workspaces is instant. Press `Alt+1` to see your browser, `Alt+2` to see your terminals, `Alt+3` to check messages. You never use `Cmd+Tab` to hunt through a list of windows. You know exactly where everything is.

### Container Layouts

Aerospace supports two container layouts:

- **Tiles** -- windows are placed side by side horizontally or vertically, each taking a proportional share of space. This is the default.
- **Accordion** -- windows are stacked in the same space, and you focus through them one at a time. The focused window takes up the full container area.

Toggle between them with `Alt+/` (tiles) or `Alt+,` (accordion).

### Container Orientation

Within a tiles layout, the orientation determines how new windows split:

- **Horizontal** -- new windows are placed to the right.
- **Vertical** -- new windows are placed below.
- **Auto** -- Aerospace chooses based on the available space (wider containers split horizontally, taller ones split vertically).

The default is `auto`, which produces intuitive layouts without manual intervention.

### Normalizations

Two normalizations keep the window tree clean:

- **Flatten containers** -- removes unnecessary nesting. If a container has only one child, it is collapsed.
- **Opposite orientation for nested containers** -- when you nest a container inside another, the inner container automatically uses the opposite orientation. This prevents deeply nested same-direction splits.

### Mouse Follows Focus

```toml
on-focused-monitor-changed = ['move-mouse monitor-lazy-center']
on-focus-changed = ['move-mouse window-lazy-center']
```

When you switch focus to a different window or monitor using the keyboard, the mouse cursor moves to the center of the newly focused area. The `lazy-center` variant means the mouse only moves if it is not already inside the target area, preventing jarring cursor jumps when you are already looking at the right place.

## Essential Commands

### Main Mode Bindings

#### Focus (Navigate Between Windows)

| Binding | Action |
|---------|--------|
| `Cmd+Shift+H` | Focus the window to the left |
| `Cmd+Shift+J` | Focus the window below |
| `Cmd+Shift+K` | Focus the window above |
| `Cmd+Shift+L` | Focus the window to the right |
| `Alt+O` | Toggle focus between last two windows |

#### Move Windows

| Binding | Action |
|---------|--------|
| `Ctrl+Shift+H` | Move focused window left |
| `Ctrl+Shift+J` | Move focused window down |
| `Ctrl+Shift+K` | Move focused window up |
| `Ctrl+Shift+L` | Move focused window right |

#### Layout

| Binding | Action |
|---------|--------|
| `Alt+/` | Toggle tiles: horizontal / vertical |
| `Alt+,` | Toggle accordion: horizontal / vertical |
| `Cmd+Shift+F` | Toggle fullscreen for focused window |

#### Resize

| Binding | Action |
|---------|--------|
| `Alt+Shift+-` | Shrink window by 50px |
| `Alt+Shift+=` | Grow window by 50px |

#### Workspaces

| Binding | Action |
|---------|--------|
| `Alt+1` | Switch to workspace 1 (Browsers) |
| `Alt+2` | Switch to workspace 2 (Terminals) |
| `Alt+3` | Switch to workspace 3 (Communication) |
| `Alt+4` | Switch to workspace 4 (Media) |

#### Move Window to Workspace

| Binding | Action |
|---------|--------|
| `Alt+Shift+1` | Move window to workspace 1 |
| `Alt+Shift+2` | Move window to workspace 2 |
| `Alt+Shift+3` | Move window to workspace 3 |
| `Alt+Shift+4` | Move window to workspace 4 |

#### Monitor Management

| Binding | Action |
|---------|--------|
| `Alt+Shift+Tab` | Move workspace to next monitor |

#### Mode Switch

| Binding | Action |
|---------|--------|
| `Alt+Shift+;` | Enter service mode |

### Service Mode Bindings

Service mode is for less-common operations. Enter it with `Alt+Shift+;` and it automatically returns to main mode after each action.

| Binding | Action |
|---------|--------|
| `Esc` | Reload config and return to main mode |
| `r` | Flatten the workspace tree |
| `f` | Toggle floating / tiling for focused window |
| `Backspace` | Close all windows except the current one |
| `Alt+Shift+H` | Join current window with the container to the left |
| `Alt+Shift+J` | Join with the container below |
| `Alt+Shift+K` | Join with the container above |
| `Alt+Shift+L` | Join with the container to the right |

## Practical Recipes

### Typical development layout

1. Press `Alt+2` to switch to workspace 2 (Terminals).
2. Open iTerm2 -- it automatically tiles in workspace 2.
3. Open a second iTerm2 window -- it splits the space with the first.
4. Use `Cmd+Shift+L` to focus the right terminal.
5. Use `Cmd+Shift+H` to focus the left terminal.

One terminal runs Neovim, the other runs tests or a dev server. Both are always visible, no overlapping.

### Move a misplaced window

If an application opens on the wrong workspace:

1. Focus it with `Cmd+Shift+H/J/K/L`.
2. Press `Alt+Shift+2` to send it to workspace 2.
3. Switch to workspace 2 with `Alt+2` to confirm.

### Toggle a window to floating

Some windows (system preferences, small dialogs) work better floating:

1. Focus the window.
2. Press `Alt+Shift+;` to enter service mode.
3. Press `f` to toggle it to floating.
4. Drag and resize it as needed.
5. Press `Alt+Shift+;` then `f` again to tile it back.

### Reorganize a cluttered workspace

If windows are nested oddly:

1. Press `Alt+Shift+;` to enter service mode.
2. Press `r` to flatten the workspace tree.
3. All windows return to a single-level tiled layout.

### Full-screen focus

When you need to concentrate on one window:

1. Focus the window.
2. Press `Cmd+Shift+F` to toggle fullscreen.
3. The window takes the entire workspace. Other windows in the workspace are hidden.
4. Press `Cmd+Shift+F` again to return to tiled layout.

### Move workspace to a different monitor

When you plug in or unplug a monitor, or want to rearrange:

1. Switch to the workspace you want to move (`Alt+1` through `Alt+4`).
2. Press `Alt+Shift+Tab` to move it to the next monitor.
3. Press again to cycle through monitors.

### Quick switch between two windows

Press `Alt+O` to toggle focus between the last two focused windows. This is the window management equivalent of `cd -` in the shell. You can rapidly flip between your editor and your browser, or between two terminals.

## Advanced Usage

### Understanding the Workspace-to-Monitor Assignment

```toml
[workspace-to-monitor-force-assignment]
1 = 'main'
2 = 'main'
3 = 'main'
4 = 'secondary'
```

The `force-assignment` key means these assignments are strict. Workspace 4 always lives on the secondary monitor. If the secondary monitor is disconnected, workspace 4 moves to the main monitor but returns when the secondary is reconnected.

With a two-monitor setup, the typical arrangement is:

- **Main monitor** (the one you face directly): workspaces 1-3 (browser, terminals, communications).
- **Secondary monitor** (off to the side): workspace 4 (Spotify, documentation, monitoring dashboards).

### The Outer Top Gap by Monitor

The variable top gap deserves explanation:

```toml
outer.top = [
    { monitor."built-in" = 10 },
    { monitor.main = 38 },
    20,
]
```

- **Built-in display** (MacBook screen): 10px top gap. The built-in display has a notch, and 10px provides minimal spacing.
- **Main external monitor**: 38px top gap. This leaves room for a menu bar or status bar application that occupies the top of the screen.
- **Default** (any other monitor): 20px top gap. A reasonable middle ground.

The inner gaps (10px horizontal and vertical) create visual separation between tiled windows without wasting significant screen space. Setting outer left, right, and bottom to 0 maximizes usable area.

### Normalization Behavior

The two normalization flags prevent the window tree from becoming unnecessarily complex:

**Flatten containers** (`enable-normalization-flatten-containers = true`): If you move windows around and end up with a container that has only one child window, Aerospace removes the container and promotes the window. This prevents ghost containers from accumulating.

**Opposite orientation for nested containers** (`enable-normalization-opposite-orientation-for-nested-containers = true`): When you create a nested split, Aerospace automatically makes the inner split perpendicular to the outer split. If the outer container splits horizontally, the inner container splits vertically. This produces grid-like layouts naturally without manual orientation management.

### Join Operations in Service Mode

The `join-with` commands (`Alt+Shift+H/J/K/L` in service mode) merge the focused window into the container in the specified direction, creating sub-splits for complex layouts. For example, to stack B and C vertically while keeping A on the left: focus C, enter service mode, press `Alt+Shift+K` to join C upward into B's container.

### Aerospace CLI

Aerospace includes a command-line interface for scripting:

```bash
aerospace list-windows --all           # List all windows
aerospace list-workspaces --all        # List all workspaces
aerospace workspace 2                  # Switch to workspace 2
aerospace move-node-to-workspace 3     # Move focused window
aerospace reload-config                # Reload configuration
```

### When Not to Tile

Some applications work poorly with tiling -- system dialogs, Finder windows, video calls. Toggle floating with service mode (`Alt+Shift+;` then `f`) for these cases.

### Aerospace vs. Alternatives

Aerospace uses Apple's accessibility APIs and does not require disabling System Integrity Protection (unlike yabai). It supports arbitrary container nesting (unlike Amethyst) and manages full layouts automatically (unlike Rectangle, which is snap-to-grid). The trade-off is that it is macOS-only and requires accessibility permissions in System Preferences > Privacy & Security > Accessibility.

\newpage
