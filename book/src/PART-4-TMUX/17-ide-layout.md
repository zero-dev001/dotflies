# IDE Layout

> A three-pane tmux layout that puts Claude Code, Neovim, and a terminal side by side -- the complete AI-assisted development environment in a single window.

## Your Setup

The IDE layout is defined in two places: a tmuxinator template at `~/.config/tmuxinator/ide.yml` and a shell function in `~/.aliases.zsh`.

The tmuxinator template:

```yaml
name: <%= File.basename(File.expand_path(@args[0] || ".")) %>
root: <%= @args[0] || "." %>

windows:
  - code:
      layout: main-vertical
      panes:
        - claude
        - nvim .
        - # terminal
```

The `ide()` shell function that orchestrates the layout:

```bash
ide() {
  local dir="${1:-.}"
  local name=$(basename "$(cd "$dir" 2>/dev/null && pwd)")
  tmuxinator start ide "$dir" --no-attach
  tmux resize-pane -t "$name:1.0" -x '20%'
  tmux resize-pane -t "$name:1.2" -y '20%'
  tmux select-pane -t "$name:1.1"
  tmux rename-window -t "$name:1" "$name"
  tmux attach-session -t "$name"
}
```

The resulting layout:

```
+----------+---------------------------+
|          |                           |
|  Claude  |       Neovim (80%)        |
|  Code    |                           |
|  (20%)   +---------------------------+
|          |     Terminal (20%)        |
+----------+---------------------------+
```

- **Pane 0** (left, 20% width): Claude Code -- an AI assistant in the terminal
- **Pane 1** (top-right, 80% width, 80% height): Neovim -- the primary editor
- **Pane 2** (bottom-right, 80% width, 20% height): A bare terminal for running commands

## Core Concepts

### Why This Layout

The three-pane layout is designed around a specific workflow: AI-assisted development. Each pane has a clear role:

- **Claude Code** on the left is the conversational interface. You describe what you want to build, ask questions about code, or request reviews. It occupies 20% of the width because conversation text does not need wide columns.
- **Neovim** in the top-right is where you write and edit code. It gets the largest share of screen space (80% width, 80% height) because reading and writing code demands the most visual real estate.
- **Terminal** in the bottom-right is for running commands: builds, tests, git operations, server processes. It occupies 20% of the height on the right side -- enough to see output without stealing space from the editor.

This mirrors the layout of modern IDEs like VS Code (sidebar, editor, terminal panel) but uses terminal-native tools that are faster, more configurable, and work over SSH.

### How tmuxinator Works

Tmuxinator is a tmux session manager that creates sessions from YAML templates. The `ide.yml` template uses ERB (embedded Ruby) to accept a directory argument:

- `<%= File.basename(File.expand_path(@args[0] || ".")) %>` extracts the directory name for the session name. If you run `ide ~/Projects/webapp`, the session is named `webapp`.
- `<%= @args[0] || "." %>` sets the root directory. All panes start in this directory.
- The `layout: main-vertical` arranges panes in tmux's main-vertical layout, which places one pane on the left and stacks the rest on the right.
- The three panes are defined in order: `claude` (runs the `claude` command), `nvim .` (opens Neovim in the project directory), and a blank pane (bare terminal).

### The ide() Function: Why Not Just tmuxinator?

Tmuxinator creates the session and panes, but it does not give precise control over pane sizes. The `main-vertical` layout splits space evenly among the stacked panes and uses a default main pane size. The `ide()` function fixes this:

1. **`tmuxinator start ide "$dir" --no-attach`** -- Creates the session in the background without attaching. This is critical because the resize commands need to run after the session exists but before you see it.
2. **`tmux resize-pane -t "$name:1.0" -x '20%'`** -- Shrinks the Claude pane (pane 0) to 20% width, giving the right side 80%.
3. **`tmux resize-pane -t "$name:1.2" -y '20%'`** -- Shrinks the terminal pane (pane 2) to 20% height, giving Neovim 80% of the right column.
4. **`tmux select-pane -t "$name:1.1"`** -- Sets focus on the Neovim pane. When you attach, your cursor is in the editor, ready to code.
5. **`tmux rename-window -t "$name:1" "$name"`** -- Renames the window from "code" (the tmuxinator template name) to the project name.
6. **`tmux attach-session -t "$name"`** -- Finally attaches to the session, showing the finished layout.

### Pane Addressing

Tmux addresses panes with the format `session:window.pane`:

- `$name:1.0` -- Session named after the directory, window 1 (base-index is 1), pane 0
- `$name:1.1` -- Same session and window, pane 1 (Neovim)
- `$name:1.2` -- Same session and window, pane 2 (terminal)

Panes within a window are numbered starting from 0 regardless of the `pane-base-index` setting in this context because tmuxinator creates them in order.

## Essential Commands

### Launching the IDE

| Command | Action |
|---------|--------|
| `ide` | Open IDE layout in current directory |
| `ide ~/Projects/webapp` | Open IDE layout for a specific project |
| `ide .` | Explicit current directory (same as `ide`) |

### Navigating Between Panes

| Keybinding | Direction |
|------------|-----------|
| `Ctrl+h` | Move to the pane on the left |
| `Ctrl+l` | Move to the pane on the right |
| `Ctrl+j` | Move to the pane below |
| `Ctrl+k` | Move to the pane above |

These keybindings work via vim-tmux-navigator, meaning they cross both tmux pane boundaries and Neovim split boundaries seamlessly. From Neovim, `Ctrl+h` moves to Claude Code. From the terminal, `Ctrl+k` moves up to Neovim. From Claude, `Ctrl+l` moves to Neovim.

### Managing the Layout

| Keybinding | Action |
|------------|--------|
| `prefix + z` | Zoom current pane to full screen |
| `prefix + z` (again) | Restore zoomed pane |
| `prefix + x` | Close current pane |
| `prefix + !` | Break pane into new window |

### Window Utilities

| Keybinding/Command | Action |
|--------------------|--------|
| `tab name` | Rename current tmux window |
| `prefix + c` | Create a new window |
| `Shift+Left/Right` | Switch between windows |
| `Alt+H/L` | Switch windows (vim-style) |

## Practical Recipes

### Start a new project session

```bash
ide ~/Projects/new-api
```

This creates a tmux session named `new-api` with the three-pane layout. Claude Code starts on the left, Neovim opens the project directory on the right, and a terminal sits below the editor. Your cursor starts in Neovim.

### The AI-assisted development loop

This is the primary workflow the IDE layout is built for:

1. **Discuss in Claude** (left pane): Describe the feature you want to implement, paste error messages, or ask for code review. Navigate to Claude with `Ctrl+h`.

2. **Code in Neovim** (top-right pane): Write the implementation based on Claude's suggestions. Navigate to Neovim with `Ctrl+l` from Claude, or `Ctrl+k` from the terminal.

3. **Test in terminal** (bottom-right pane): Run builds, tests, or the development server. Navigate to the terminal with `Ctrl+j` from Neovim.

4. **Iterate**: If tests fail, move back to Claude to discuss the error, then to Neovim to fix it, then to the terminal to test again. The three keybindings (`Ctrl+h`, `Ctrl+l`, `Ctrl+j`) become muscle memory.

### Zoom a pane for focused work

Sometimes you need full-screen focus. Press `prefix + z` to zoom the current pane:

- Zoom Neovim when editing a complex file and you need maximum screen space
- Zoom Claude when reading a long explanation
- Zoom the terminal when debugging verbose output

Press `prefix + z` again to snap back to the three-pane layout.

### Run a long process in the terminal pane

Navigate to the terminal pane (`Ctrl+j` from Neovim) and start a development server or test watcher:

```bash
npm run dev
# or
cargo watch -x test
# or
python manage.py runserver
```

The process runs continuously in the terminal pane. Switch back to Neovim with `Ctrl+k` to keep coding. The terminal pane is visible at the bottom, so you can glance at server output or test results without switching panes.

### Use the floating terminal for quick commands

If you need to run a one-off command without leaving your current pane, use floax: `prefix + p`. A floating terminal appears at 80% screen size, runs your command, and `prefix + p` again dismisses it. This is ideal for:

- Quick `git status` or `git diff` checks
- Installing a package
- Looking up a file path
- Running a single test

### Add a fourth pane

The IDE layout starts with three panes, but you can add more. To split the terminal pane horizontally and run two processes side by side:

```
prefix + "    # Split the terminal pane
```

Now the bottom-right has two stacked panes. Navigate between all panes with `Ctrl+h/j/k/l`. To return to the standard three-pane layout, close the extra pane with `prefix + x`.

### Open multiple IDE windows

You can create IDE sessions for multiple projects simultaneously:

```bash
ide ~/Projects/frontend
# Detach with prefix + d
ide ~/Projects/backend
```

Now you have two IDE sessions. Switch between them with the sesh picker (`prefix + T`) or sessionx (`prefix + o`). Each session maintains its own three-pane layout independently.

### Rename the window for clarity

The `ide()` function names the window after the project directory. If you want a different name:

```bash
tab api-server
```

The `tab()` function (defined in `~/.aliases.zsh`) renames the current tmux window. This updates the status bar display.

## Advanced Usage

### Why --no-attach Is Essential

The `ide()` function uses `tmuxinator start ide "$dir" --no-attach` to create the session without attaching to it. This is not just a convenience -- it is required for the resize commands to work correctly.

If tmuxinator attaches immediately, you see the default layout for a split second before the resize commands run (they cannot run because you are already inside the session and the function has not continued). By creating the session detached, the function runs all resize and focus commands against the session from outside, then attaches to the finished layout. The user sees only the final, correctly sized layout.

### Pane Size Percentages

The percentage-based resize commands (`-x '20%'` and `-y '20%'`) calculate sizes relative to the terminal window. This means the layout adapts to different screen sizes:

- On a 1920-wide terminal: Claude gets ~384 columns, Neovim gets ~1536
- On a 2560-wide ultrawide: Claude gets ~512 columns, Neovim gets ~2048
- On a smaller laptop screen: Claude gets ~256 columns, Neovim gets ~1024

The 20/80 split works well across these sizes. Claude Code renders conversation text well in narrow columns, while Neovim benefits from the extra width for code, file trees, and split views.

### The main-vertical Layout

Tmux's `main-vertical` layout places the first pane on the left as the "main" pane and stacks all remaining panes vertically on the right. This is why the order of panes in `ide.yml` matters:

1. First pane (`claude`) becomes the left column
2. Second pane (`nvim .`) becomes the top of the right column
3. Third pane (terminal) becomes the bottom of the right column

The `ide()` function then overrides the default sizing with explicit percentages.

### Customizing the Layout for Different Workflows

You can create variations of the IDE layout for different needs. For example, a documentation writing layout:

```yaml
# ~/.config/tmuxinator/docs.yml
name: <%= File.basename(File.expand_path(@args[0] || ".")) %>
root: <%= @args[0] || "." %>

windows:
  - writing:
      layout: main-vertical
      panes:
        - nvim .
        - # preview terminal
```

And a corresponding shell function with different proportions.

### Session Persistence with the IDE Layout

The tmux-resurrect and tmux-continuum plugins (covered in the Tmux Plugins chapter) save and restore the IDE layout automatically. When tmux restores after a reboot:

- The three-pane layout is recreated
- Neovim restarts with its saved session (via `resurrect-strategy-nvim session`)
- The terminal pane returns to the project directory
- Claude Code needs to be restarted manually (AI sessions are not persistent across reboots)

After restoration, navigate to the Claude pane (`Ctrl+h`) and run `claude` to restart the AI assistant.

### Integration with sesh

The IDE layout and sesh serve complementary purposes. Sesh creates simple single-window sessions from config bookmarks and zoxide directories. The IDE layout creates a structured multi-pane workspace. You might use sesh for quick config edits and the IDE layout for sustained development work.

A workflow pattern:

1. Start your day by running `ide ~/Projects/main-project` for your primary work
2. Use `prefix + T` (sesh) to quickly check dotfiles or another config
3. Use `Shift+Left/Right` or `Alt+H/L` to switch windows if you add more to the IDE session
4. At the end of the day, detach (`prefix + d`) -- tmux-continuum saves everything

### Troubleshooting the Layout

**Panes are the wrong size**: The resize commands depend on the session name matching the directory basename. If the directory name contains special characters, the `$name` variable may not match the tmux session name. Stick to alphanumeric directory names with hyphens and underscores.

**Claude pane shows an error**: If the `claude` command is not installed or not in your PATH, the pane opens a shell instead. Install Claude Code or replace `claude` in the tmuxinator template with another command.

**Neovim does not open**: If `nvim` is not in PATH, the pane shows an error. The tmuxinator template runs `nvim .` which opens Neovim in the project directory.

**Layout looks different on a small screen**: The percentage-based resizing adapts to screen size, but on very small terminals (under 120 columns), the 20% Claude pane may be too narrow to be useful. Consider increasing it to 25% or 30% by editing the `ide()` function.

### Extending the ide() Function

You can add steps to the `ide()` function for project-specific setup:

```bash
ide() {
  local dir="${1:-.}"
  local name=$(basename "$(cd "$dir" 2>/dev/null && pwd)")
  tmuxinator start ide "$dir" --no-attach
  tmux resize-pane -t "$name:1.0" -x '20%'
  tmux resize-pane -t "$name:1.2" -y '20%'
  tmux select-pane -t "$name:1.1"
  tmux rename-window -t "$name:1" "$name"

  # Optional: send a command to the terminal pane
  # tmux send-keys -t "$name:1.2" "npm run dev" Enter

  tmux attach-session -t "$name"
}
```

Uncommenting the `send-keys` line would start a dev server in the terminal pane automatically. You could also add conditional logic to detect project types (check for `package.json`, `Cargo.toml`, etc.) and run appropriate commands.

### The tab() Helper

The `tab()` function from `~/.aliases.zsh` provides a quick way to rename tmux windows:

```bash
tab() {
  if [ -n "$TMUX" ]; then
    tmux rename-window "$1"
  else
    echo -ne "\033]1;$1\007"
  fi
}
```

Inside tmux, it renames the window. Outside tmux, it sets the terminal tab title using an escape sequence. This dual behavior means `tab myname` always does the right thing regardless of context.

\newpage
