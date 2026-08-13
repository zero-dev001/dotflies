# Tmux Plugins

> Twelve plugins that transform tmux from a terminal multiplexer into a session-persistent, clipboard-aware, fzf-powered development environment.

## Your Setup

Plugins are managed by TPM (Tmux Plugin Manager) and declared at the bottom of `~/.tmux.conf`. The full plugin list:

```bash
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @plugin 'dreamsofcode-io/catppuccin-tmux'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'omerxx/tmux-sessionx'
set -g @plugin 'omerxx/tmux-floax'
set -g @plugin 'wfxr/tmux-fzf-url'
set -g @plugin 'sainnhe/tmux-fzf'
set -g @plugin 'fcsonline/tmux-thumbs'
```

TPM is loaded at the very end of the config:

```bash
run '~/.tmux/plugins/tpm/tpm'
```

Plugin-specific settings are grouped together:

```bash
set -g @continuum-restore 'on'
set -g @resurrect-strategy-nvim 'session'
set -g @sessionx-bind 'o'
set -g @sessionx-zoxide-mode 'on'
set -g @sessionx-filter-current 'false'
set -g @floax-width '80%'
set -g @floax-height '80%'
set -g @floax-border-color 'magenta'
set -g @floax-text-color 'blue'
set -g @floax-bind 'p'
set -g @floax-change-path 'true'
set -g @fzf-url-fzf-options '-p 60%,30% --prompt="   " --border-label=" Open URL "'
set -g @fzf-url-history-limit '2000'
```

## Core Concepts

### TPM: The Plugin Manager

TPM clones plugin repositories into `~/.tmux/plugins/` and sources them when tmux starts. After adding a new plugin line to `tmux.conf`, press `prefix + I` (capital I) to install it. TPM fetches the repository and activates the plugin immediately.

### Plugin Categories

The twelve plugins fall into four functional groups:

**Foundation**: tpm, tmux-sensible -- provide the plugin infrastructure and a set of universally accepted defaults.

**Navigation**: vim-tmux-navigator -- the single most important plugin, enabling seamless movement between tmux panes and Neovim splits.

**Persistence**: tmux-resurrect, tmux-continuum -- save and restore your entire tmux environment across reboots.

**Productivity**: sessionx, floax, tmux-fzf-url, tmux-fzf, tmux-thumbs, tmux-yank, catppuccin -- enhance session management, clipboard, search, and visual appearance.

### Why vim-tmux-navigator Is Critical

Without this plugin, moving between a Neovim split and an adjacent tmux pane requires completely different keybindings. With it, `Ctrl+h/j/k/l` moves in the expected direction regardless of whether the boundary is a Vim split or a tmux pane. The plugin detects which program is running in the active pane and routes the key event accordingly.

## Essential Commands

### TPM Management

| Keybinding | Action |
|------------|--------|
| `prefix + I` | Install new plugins |
| `prefix + U` | Update all plugins |
| `prefix + Alt+u` | Uninstall removed plugins |

### vim-tmux-navigator

| Keybinding | Action |
|------------|--------|
| `Ctrl+h` | Move left (pane or Vim split) |
| `Ctrl+j` | Move down (pane or Vim split) |
| `Ctrl+k` | Move up (pane or Vim split) |
| `Ctrl+l` | Move right (pane or Vim split) |
| `Ctrl+\` | Move to previous pane/split |

These bindings work identically whether you are in a tmux pane, a Neovim split, or crossing the boundary between them. Neovim must also have the vim-tmux-navigator plugin installed for this to work.

### Session Persistence (resurrect + continuum)

| Keybinding | Action |
|------------|--------|
| `prefix + Ctrl+s` | Save session state |
| `prefix + Ctrl+r` | Restore saved session |

Continuum automatically saves every 15 minutes and restores on tmux server start. No manual action needed for day-to-day use.

### Session Picker (sessionx)

| Keybinding | Action |
|------------|--------|
| `prefix + o` | Open session picker |

Inside the session picker, zoxide mode is on, meaning you can search for directories by frecency as well as existing tmux sessions. `filter-current` is off, so the current session appears in the list.

### Floating Terminal (floax)

| Keybinding | Action |
|------------|--------|
| `prefix + p` | Toggle floating terminal |

The floating terminal occupies 80% of the screen width and height, with a magenta border and blue text. It opens in the current pane's working directory (`change-path true`), making it ideal for quick commands without disrupting your layout.

### URL and Pattern Extraction

| Keybinding | Action |
|------------|--------|
| `prefix + u` (fzf-url default) | Open URLs from terminal output in fzf popup |
| `prefix + Space` (thumbs default) | Highlight copyable patterns in terminal output |

### Clipboard (tmux-yank)

| Action | Behavior |
|--------|----------|
| `y` in copy mode | Copies selection to system clipboard and cancels copy mode |
| Mouse selection | Copies to system clipboard (when mouse mode is on) |

## Practical Recipes

### First-time plugin installation

After cloning your dotfiles to a new machine:

```bash
# Clone TPM if not present
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Start tmux, then install all plugins
tmux
# Press prefix + I
```

TPM reads the plugin declarations from tmux.conf and clones each repository into `~/.tmux/plugins/`.

### Seamless Vim-Tmux navigation workflow

With the IDE layout (covered in a later chapter), you have three panes: Claude Code on the left, Neovim top-right, terminal bottom-right. Moving between them:

- From Neovim to terminal below: `Ctrl+j`
- From terminal to Claude on the left: `Ctrl+h`
- From Claude to Neovim on the right: `Ctrl+l`

The key insight is that you never think about whether the boundary is a Vim split or a tmux pane. The same four keys navigate everywhere.

### Surviving a reboot with resurrect and continuum

The typical flow:

1. Work normally in tmux with multiple sessions, windows, and panes.
2. Continuum saves state every 15 minutes automatically.
3. Reboot the machine.
4. Start tmux. Continuum detects saved state and restores automatically (`continuum-restore on`).
5. All sessions, windows, and pane layouts are restored. Neovim sessions are restored via the `resurrect-strategy-nvim session` setting, which tells resurrect to save and restore Neovim's session files.

To force a manual save before a planned reboot: `prefix + Ctrl+s`.

### Quick session switching with sessionx

Press `prefix + o` to open the session picker. Type to filter sessions by name. Because zoxide mode is on, you can also type a directory name you have visited before, and sessionx will offer to create a new session in that directory.

### Pop open a floating terminal

Mid-task in Neovim, you need to run a quick command without leaving your editor or creating a new pane. Press `prefix + p`. A floating terminal appears at 80% screen size, already in the current directory. Run your command, then press `prefix + p` again to dismiss it.

### Grab a URL from terminal output

A build log or command output contains a URL you need to open. Press the fzf-url trigger to scan the visible terminal output for URLs. An fzf popup (60% wide, 30% tall) appears with all detected URLs. Select one and it opens in your default browser.

### Quick-copy a hash, path, or IP with thumbs

tmux-thumbs scans the visible terminal output for common patterns: file paths, git hashes, IP addresses, UUIDs, and more. When triggered, it highlights each match with a letter hint. Press the letter to copy that pattern to the clipboard instantly. This is faster than entering copy mode, navigating to the text, selecting it, and yanking.

## Advanced Usage

### How vim-tmux-navigator Detects the Active Program

The plugin works by checking the name of the process running in the current tmux pane. When the active process is `vim`, `nvim`, or another configured name, key presses are forwarded to Vim's own split navigation. Otherwise, tmux handles the navigation directly. This detection uses `pane_current_command` in a tmux `if-shell` conditional.

If you run Neovim inside a wrapper script or through a non-standard binary name, you may need to configure the detection pattern. The Neovim side of the plugin must also be installed -- typically via lazy.nvim as `christoomey/vim-tmux-navigator`.

### Resurrect Save Strategy for Neovim

The setting `@resurrect-strategy-nvim 'session'` tells tmux-resurrect to save Neovim's state using Neovim's built-in `:mksession` command. When restoring, resurrect launches Neovim with `nvim -S` to reload the session file. This restores open buffers, split layouts, and cursor positions within Neovim.

For this to work reliably, Neovim must have session support enabled and the session file must be written to a predictable location. If you use an auto-session plugin in Neovim, it coordinates with this mechanism.

### Continuum Save Interval

Continuum saves every 15 minutes by default. This interval is a good balance between safety and disk activity. Save files are stored in `~/.tmux/resurrect/`. Each save creates a new file with a timestamp, so you can manually restore from an older state if needed by symlinking the `last` file to a previous save.

### Catppuccin Theme Customization

The Catppuccin Mocha theme from the dreamsofcode fork provides status bar styling that matches the Neovim and terminal color schemes. The theme colors the status bar, pane borders, and mode indicators. The mocha flavor uses warm, muted tones with good contrast for readability.

### sessionx vs. sesh

Both sessionx and sesh provide session management. They complement each other:

| Feature | sessionx (`prefix + o`) | sesh (`prefix + T`) |
|---------|------------------------|---------------------|
| Trigger | Single keybinding popup | fzf-tmux popup with mode switching |
| Zoxide integration | Yes (zoxide-mode on) | Yes (Ctrl+x for zoxide list) |
| Named config sessions | No | Yes (from sesh.toml) |
| Kill sessions | Via sessionx interface | Ctrl+d in sesh picker |
| Find new directories | No | Yes (Ctrl+f uses fd) |

Use sessionx for quick switching between existing sessions. Use sesh when you want access to named config sessions, zoxide directories, or directory discovery via fd.

### floax Working Directory

With `@floax-change-path true`, the floating terminal starts in the working directory of the current pane. This is especially useful when you are in a project-specific session and want to run a quick `git status` or `npm test` without navigating to the right directory.

### fzf-url History Limit

The `@fzf-url-history-limit 2000` setting tells the plugin to scan the last 2000 lines of terminal output for URLs. This is generous enough to capture URLs from long build logs or verbose command output. Increase it if you work with tools that produce very long output with URLs scattered throughout.

### Plugin Load Order

TPM loads plugins in the order they are declared. The order matters for plugins that modify the same keybindings or hooks. In this config, `tpm` and `tmux-sensible` are first (providing the foundation), `vim-tmux-navigator` is early (setting up navigation before anything else), and the theme is loaded before plugins that display in the status bar.

### Troubleshooting Plugins

If a plugin stops working after an update:

```bash
# Check that plugins are installed
ls ~/.tmux/plugins/

# Reinstall all plugins
prefix + I

# Check tmux for errors
tmux show-messages

# Source the config manually
tmux source-file ~/.tmux.conf
```

If vim-tmux-navigator stops working, verify that both the tmux plugin and the Neovim plugin are installed and that the process name detection is matching correctly.

\newpage
