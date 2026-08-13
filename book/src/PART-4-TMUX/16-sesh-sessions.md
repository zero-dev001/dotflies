# Session Management: sesh

> A smart tmux session manager that combines named configurations, zoxide frecency, and fzf fuzzy finding into a single session picker.

## Your Setup

Sesh is configured in two places: `~/.config/sesh/sesh.toml` defines named sessions, and `~/.tmux.conf` defines the keybinding that launches the sesh picker.

The named sessions in `sesh.toml`:

```toml
[[session]]
name = "dotfiles"
path = "~/.local/share/chezmoi"
startup_command = "nvim"
preview_command = "bat --color=always ~/.local/share/chezmoi/dot_zshrc.tmpl"

[[session]]
name = "tmux config"
path = "~/.local/share/chezmoi"
startup_command = "nvim dot_tmux.conf"
preview_command = "bat --color=always ~/.local/share/chezmoi/dot_tmux.conf"

[[session]]
name = "nvim config"
path = "~/.config/nvim"
startup_command = "nvim lua/config/lazy.lua"
preview_command = "eza --tree --level=2 --icons ~/.config/nvim"

[[session]]
name = "Downloads"
path = "~/Downloads"
startup_command = "ls"
```

The tmux keybinding that launches the picker (`prefix + T`):

```bash
bind-key "T" run-shell "sesh connect \"$(
  sesh list | fzf-tmux -p 55%,60% \
    --no-sort --ansi --border-label ' sesh ' --prompt '  ' \
    --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
    --bind 'tab:down,btab:up' \
    --bind 'ctrl-a:change-prompt(  )+reload(sesh list)' \
    --bind 'ctrl-t:change-prompt(  )+reload(sesh list -t)' \
    --bind 'ctrl-g:change-prompt(  )+reload(sesh list -c)' \
    --bind 'ctrl-x:change-prompt(  )+reload(sesh list -z)' \
    --bind 'ctrl-f:change-prompt(  )+reload(fd -H -d 2 -t d . ~)' \
    --bind 'ctrl-d:execute(tmux kill-session -t {})+change-prompt(  )+reload(sesh list)'
)\""
```

## Core Concepts

### What sesh Does

Sesh sits between you and tmux session management. Instead of manually creating sessions with `tmux new -s name`, setting the working directory, and running startup commands, sesh handles all of this from a single picker interface. It knows about three sources of sessions:

1. **Named config sessions** -- defined in `sesh.toml`, these are persistent bookmarks for your most important contexts. They always appear in the picker, whether a tmux session exists for them or not.
2. **Running tmux sessions** -- any tmux session that is currently active.
3. **Zoxide directories** -- directories ranked by frecency from your zoxide database, available as potential new sessions.

When you select a named session that is not currently running, sesh creates the tmux session, sets the working directory, and runs the startup command. When you select a running session, sesh switches to it. When you select a zoxide directory, sesh creates a new session named after the directory.

### Named Session Anatomy

Each `[[session]]` entry in `sesh.toml` has four fields:

- **name**: The display name and tmux session name. This is what appears in the picker and the tmux status bar.
- **path**: The working directory for the session. Tilde expansion works.
- **startup_command**: The command to run when the session is first created. Typically `nvim` or `nvim <file>` to open directly into the editor.
- **preview_command**: What to show in the fzf preview pane when the session is highlighted. This gives you a quick look at the session's content before switching.

### The Picker Modes

The sesh picker is an fzf-tmux popup with multiple modes, switchable via Ctrl keybindings:

| Keybinding | Mode | What It Lists |
|------------|------|---------------|
| `Ctrl+a` | All | Everything: config sessions + tmux sessions + zoxide |
| `Ctrl+t` | Tmux | Only running tmux sessions |
| `Ctrl+g` | Configs | Only named sessions from sesh.toml |
| `Ctrl+x` | Zoxide | Directories from zoxide database |
| `Ctrl+f` | Find | Directories found by fd (depth 2 from home) |
| `Ctrl+d` | Kill | Kills the selected tmux session and reloads |

### sesh vs. sessionx

Both tools manage tmux sessions, but they serve different purposes:

**sesh** (`prefix + T`) is the full-featured session manager. It understands named configurations, can create sessions from scratch with startup commands, integrates with zoxide for directory discovery, and can find new directories with fd. Use sesh when you want to jump to a project that may or may not have a tmux session yet.

**sessionx** (`prefix + o`) is a lighter session picker. It lists existing tmux sessions and zoxide directories in a simpler interface. Use sessionx for quick switching between sessions that are already running.

In practice, `prefix + T` is the primary session management keybinding, and `prefix + o` is the quick-switch alternative.

## Essential Commands

### Launching the Picker

| Keybinding | Action |
|------------|--------|
| `prefix + T` | Open sesh picker |
| `prefix + o` | Open sessionx picker (alternative) |

### Inside the sesh Picker

| Keybinding | Action |
|------------|--------|
| Type text | Filter sessions by name |
| `Enter` | Connect to selected session |
| `Tab` / `Shift+Tab` | Move down / up in list |
| `Ctrl+a` | Show all sources |
| `Ctrl+t` | Show tmux sessions only |
| `Ctrl+g` | Show config sessions only |
| `Ctrl+x` | Show zoxide directories |
| `Ctrl+f` | Find directories with fd |
| `Ctrl+d` | Kill selected session |
| `Escape` | Cancel and close picker |

### sesh CLI Commands

| Command | Action |
|---------|--------|
| `sesh list` | List all sessions (config + tmux + zoxide) |
| `sesh list -t` | List running tmux sessions only |
| `sesh list -c` | List config sessions only |
| `sesh list -z` | List zoxide directories |
| `sesh connect <name>` | Connect to or create a session |
| `sesh clone <repo> [name]` | Clone a git repo and create a session for it |

## Practical Recipes

### Jump to your dotfiles from anywhere

1. Press `prefix + T`
2. Type `dot` to filter
3. Select "dotfiles" and press Enter

Sesh creates the session (if not running) in `~/.local/share/chezmoi`, runs `nvim`, and switches you there. The preview pane shows the contents of `dot_zshrc.tmpl` via bat with syntax highlighting.

### Edit tmux config quickly

1. Open the sesh picker with `prefix + T`
2. Press `Ctrl+g` to filter to config sessions only
3. Select "tmux config" and press Enter

This opens Neovim directly on `dot_tmux.conf` in the chezmoi directory. After making changes, you can source the config with `tmux source-file ~/.tmux.conf` from within Neovim's terminal or a separate pane.

### Start a session for a project you recently visited

1. Open the sesh picker with `prefix + T`
2. Press `Ctrl+x` to switch to zoxide mode
3. Type the project name to filter
4. Select the directory and press Enter

Sesh creates a new tmux session named after the directory and sets the working directory. Because zoxide tracks frecency, your most-used projects appear near the top.

### Discover and open a new project

1. Open the sesh picker with `prefix + T`
2. Press `Ctrl+f` to switch to find mode
3. The picker now shows directories found by `fd -H -d 2 -t d . ~` -- all directories up to 2 levels deep from your home directory, including hidden ones
4. Select a directory and press Enter

This is useful for projects you have not visited yet (so they are not in zoxide's database) but that exist in a standard location like `~/Projects/` or `~/Work/`.

### Kill a session you no longer need

1. Open the sesh picker with `prefix + T`
2. Navigate to the session you want to remove
3. Press `Ctrl+d` to kill it

The session is killed and the list reloads. This is faster than running `tmux kill-session -t name` manually.

### Use sesh from the command line

You do not have to use the tmux keybinding. Sesh works as a standalone CLI tool:

```bash
# List all available sessions
sesh list

# Connect directly to a named session
sesh connect dotfiles

# Connect to a directory as a session
sesh connect ~/Projects/webapp
```

This is useful in scripts or when you are outside tmux and want to start a specific session.

## Advanced Usage

### How sesh connect Works

When you run `sesh connect <name>`:

1. Sesh checks if a tmux session with that name already exists. If yes, it switches to it.
2. If not, sesh checks if the name matches a `[[session]]` entry in `sesh.toml`. If yes, it creates a new tmux session with the configured path and runs the startup command.
3. If not, sesh treats the name as a directory path. If the directory exists, it creates a session named after the directory basename with that directory as the working directory.
4. If none of the above match, the command fails.

This cascading logic means `sesh connect` does the right thing regardless of whether you pass a session name, a config name, or a path.

### Preview Commands

The `preview_command` field in `sesh.toml` controls what fzf shows in the preview pane when a session is highlighted. Choosing good preview commands makes the picker much more useful:

- **bat** for file previews: Shows syntax-highlighted file contents. Good for sessions focused on a specific config file, like the "tmux config" session previewing `dot_tmux.conf`.
- **eza --tree** for directory overviews: Shows the directory structure with icons. Good for sessions focused on a project directory, like the "nvim config" session showing the Neovim config tree.
- **ls** or other simple commands: For sessions where a quick listing is sufficient.

The preview command runs every time you move the cursor in the picker, so keep it fast. Avoid commands that take more than a second to execute.

### The fd-Based Find Mode

The find mode (`Ctrl+f`) runs `fd -H -d 2 -t d . ~`, which finds:

- `-H`: Hidden directories (like `.config`, `.local`)
- `-d 2`: Up to 2 levels deep from home
- `-t d`: Only directories (not files)
- `. ~`: Starting from the home directory

This gives you a broad but manageable list of project directories. The depth limit of 2 means you see `~/Projects/webapp` but not `~/Projects/webapp/src/components`. Adjust the depth if your project layout is deeper.

### Session Naming from Zoxide Directories

When sesh creates a session from a zoxide directory, it uses the directory's basename as the session name. If you select `~/Projects/my-webapp`, the session is named `my-webapp`. This means the tmux status bar shows the project name, which is exactly what you want.

Be aware that tmux session names cannot contain dots or colons. If a directory name contains these characters, sesh may modify the name or the session creation may fail. Stick to alphanumeric names with hyphens and underscores for project directories.

### Combining sesh with the IDE Layout

The sesh picker and the `ide()` function (covered in the IDE Layout chapter) serve different purposes but complement each other:

- **sesh** creates simple sessions with a single window and a startup command. Use it for quick access to config files, downloads, or lightweight tasks.
- **ide()** creates a full three-pane layout with Claude Code, Neovim, and a terminal. Use it for development work where you want the complete IDE experience.

A common workflow: use sesh to jump between project sessions for quick checks, and use `ide` when you are sitting down for focused development on a project.

### Startup Command Limitations

The `startup_command` runs once when the session is first created. If you switch away from the session and come back, the startup command does not re-run -- you return to whatever state the session is in. This is by design: sesh creates the session, and tmux-resurrect/continuum handle persistence from there.

If the startup command fails (for example, if `nvim` is not installed), the session is still created but the command's error output appears in the terminal. The session's working directory is still set correctly.

### Customizing the Picker Appearance

The fzf-tmux popup is configured with `-p 55%,60%`, which creates a centered floating window at 55% width and 60% height. The `--no-sort` flag preserves sesh's native ordering (config sessions first, then tmux sessions, then zoxide). The `--ansi` flag enables color output in the session list.

The header line shows the available mode-switching keybindings as a quick reference. The border label shows "sesh" to identify the picker.

### When to Use sesh vs. tmux Directly

Use sesh for:

- Switching between known projects and config contexts
- Creating sessions with specific working directories and startup commands
- Discovering directories via zoxide or fd
- Killing sessions from a unified interface

Use tmux directly for:

- Creating ad-hoc sessions for one-off tasks: `tmux new -s scratch`
- Renaming sessions: `prefix + $`
- Moving windows between sessions: `prefix + :` then `move-window`
- Advanced session manipulation that sesh does not cover

Sesh is the 90% case -- most session management flows through the picker. Fall back to raw tmux commands for the remaining 10%.

\newpage
