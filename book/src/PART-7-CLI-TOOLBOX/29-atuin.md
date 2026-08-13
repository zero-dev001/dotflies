# Shell History: atuin

> A replacement for Ctrl+R that provides full-text search, cross-machine sync, and statistics for your entire shell history.

## Your Setup

atuin is installed via Homebrew and initialized in `~/.zshrc`:

```ruby
# Brewfile
brew "atuin"
```

```bash
# ~/.zshrc
eval "$(atuin init zsh)"
```

The configuration lives at `~/.config/atuin/config.toml`:

```toml
style = "compact"
inline_height = 30
enter_accept = true
```

These three settings define your atuin experience:

- **style = "compact"** -- Uses a single-line-per-entry display instead of the default multi-line style, fitting more history entries on screen.
- **inline_height = 30** -- The search UI appears inline in the terminal (not fullscreen) and shows up to 30 entries at a time.
- **enter_accept = true** -- Pressing Enter immediately executes the selected command rather than pasting it into the command line for editing.

atuin is initialized after fzf in your zshrc, which means atuin's Ctrl+R binding takes precedence over fzf's default history search. This is intentional -- atuin provides a richer history search experience, while fzf continues to serve as a general-purpose fuzzy finder for files, directories, and other uses.

## Core Concepts

### What atuin Replaces

By default, zsh's Ctrl+R performs a simple reverse incremental search through the history file (`~/.zsh_history`). This search is limited: it only matches from the beginning of the command, it does not understand context, and history is lost when it exceeds `HISTSIZE`.

atuin replaces this with a SQLite-backed history database that stores every command along with metadata: the working directory where it was run, the exit code, the session ID, the hostname, and the timestamp. This enables searches like "show me all git commands I ran in this project that failed."

### How It Works

When you press Ctrl+R, atuin opens an inline search interface in your terminal. As you type, it performs full-text search across your entire history. Results are ranked by recency and frequency by default. You navigate with arrow keys and select with Enter.

atuin hooks into the shell's `preexec` and `precmd` functions to record every command as it is executed, including the exit code after it completes.

### Sync Across Machines

atuin can optionally sync your shell history across multiple machines using an encrypted sync server. Each command is end-to-end encrypted before leaving your machine. You can use the public atuin sync server or self-host one.

## Essential Commands

| Command / Key | Purpose |
|---|---|
| `Ctrl+R` | Open interactive history search |
| Type while in search | Filter results by full-text match |
| `Up/Down` | Navigate through search results |
| `Enter` | Execute the selected command (with `enter_accept = true`) |
| `Tab` | Paste selected command into prompt for editing |
| `Esc` | Close the search UI |
| `Ctrl+R` (again, while open) | Cycle through search modes |

### atuin CLI Commands

| Command | Purpose |
|---|---|
| `atuin search "pattern"` | Search history from the command line |
| `atuin search --exit 0 "pattern"` | Search only successful commands |
| `atuin search --exit 1 "pattern"` | Search only failed commands |
| `atuin search --cwd /path "pattern"` | Search commands run in a specific directory |
| `atuin search --after "2025-01-01" "pattern"` | Search after a date |
| `atuin search --before "2025-06-01" "pattern"` | Search before a date |
| `atuin stats` | Show shell usage statistics |
| `atuin stats --count 20` | Show top 20 most-used commands |
| `atuin history list` | List recent history entries |
| `atuin history list --cmd-only` | List commands only (no metadata) |
| `atuin import auto` | Import history from zsh/bash history files |
| `atuin import zsh` | Import specifically from zsh history |
| `atuin register` | Create an account for sync |
| `atuin login` | Log in to an existing sync account |
| `atuin sync` | Manually trigger a sync |
| `atuin key` | Show your encryption key (save this) |
| `atuin default-config` | Print the full default configuration |

## Configuration Reference

The full configuration file lives at `~/.config/atuin/config.toml`. Your setup uses minimal configuration, relying on sensible defaults for most settings. Here are the key options:

| Setting | Your Value | Default | Purpose |
|---|---|---|---|
| `style` | `compact` | `auto` | UI layout: compact, full, or auto |
| `inline_height` | `30` | `0` (fullscreen) | Number of lines for inline display |
| `enter_accept` | `true` | `false` | Enter executes vs pastes to prompt |

### Additional Configuration Options

| Setting | Default | Purpose |
|---|---|---|
| `search_mode` | `fuzzy` | Search algorithm: prefix, fulltext, fuzzy, skim |
| `filter_mode` | `global` | Scope: global, host, session, directory |
| `filter_mode_shell_up_key_binding` | `global` | Scope for Up arrow history |
| `show_preview` | `false` | Show full command preview below results |
| `show_help` | `true` | Show keybinding help in search UI |
| `max_preview_height` | `4` | Lines for command preview |
| `history_filter` | `[]` | Regex patterns to exclude from history |
| `secrets_filter` | `true` | Auto-filter commands with secrets/tokens |
| `workspaces` | `false` | Enable per-workspace history filtering |
| `sync_frequency` | `"1h"` | How often to auto-sync |
| `sync_address` | `"https://api.atuin.sh"` | Sync server URL |

## Practical Recipes

### Find that docker command you ran last week

Press Ctrl+R and start typing `docker`. atuin searches across your entire history, not just the current session. Results show the most recent matches first.

### Search by directory

```bash
atuin search --cwd ~/Projects/my-app "npm"
```

This finds all npm commands you ran specifically in that project directory -- useful when you cannot remember the exact test or build command.

### Find commands that failed

```bash
atuin search --exit 1 "make"
```

Only shows `make` commands that exited with a non-zero status. Useful for revisiting build failures.

### View your most-used commands

```bash
atuin stats
```

This produces a ranked list of your most frequently used commands, giving you insight into your workflow patterns. Example output:

```
[##########] 542  git
[########  ] 431  nvim
[#######   ] 389  cd
[#####     ] 267  ls
[####      ] 198  cat
```

Remember that `ls` is aliased to `eza` and `cat` is aliased to `bat`, so these counts reflect the aliases you actually type.

### Import existing history

If you are setting up atuin on a new machine, import your existing zsh history:

```bash
atuin import auto
```

This detects your shell and imports from the appropriate history file. All imported commands will be searchable immediately.

### Exclude sensitive commands from history

Add patterns to `history_filter` in the config file:

```toml
history_filter = [
  "^export.*TOKEN",
  "^export.*SECRET",
  "^export.*PASSWORD",
]
```

Commands matching these patterns will not be recorded. The `secrets_filter = true` default also provides automatic detection of common secret patterns.

## Advanced Usage

### Search Modes

atuin supports multiple search algorithms, cycled with Ctrl+R during an active search:

| Mode | Behaviour |
|---|---|
| `fuzzy` | Characters can be non-contiguous (like fzf) |
| `fulltext` | Substring match anywhere in the command |
| `prefix` | Match from the start of the command |
| `skim` | Skim-based fuzzy matching |

Your default is `fuzzy`, which is the most forgiving. If you get too many results, switch to `prefix` for a narrower match.

### Filter Modes

The filter mode controls the scope of the search:

| Mode | Scope |
|---|---|
| `global` | All history from all machines (if synced) |
| `host` | Only commands from the current machine |
| `session` | Only commands from the current terminal session |
| `directory` | Only commands run in the current directory |

You can change the default filter mode in the config or cycle through modes during a search.

### Syncing Across Machines

To set up sync:

```bash
# On the first machine
atuin register -u your-username -e your@email.com -p your-password
atuin key  # Save this key -- you need it for other machines

# On additional machines
atuin login -u your-username -p your-password
atuin import auto
atuin sync
```

All data is end-to-end encrypted with your key. The sync server (whether self-hosted or the public server at api.atuin.sh) never sees your plaintext commands.

### atuin and the Shell Initialization Order

Your zshrc initializes tools in this order:

```bash
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh     # fzf bindings (sets Ctrl+R)
eval "$(zoxide init zsh --cmd cd)"           # zoxide (sets cd)
eval "$(atuin init zsh)"                     # atuin (overrides Ctrl+R)
eval "$(mise activate zsh)"                  # mise (tool versions)
```

atuin is loaded after fzf deliberately. fzf sets up a Ctrl+R binding for history search, and atuin overwrites it with its own, superior implementation. If you ever want fzf's simpler history search back, swap the order or comment out the atuin line.

### Up Arrow Integration

atuin can also replace the Up arrow key behaviour, turning it from "previous command" into a context-aware history search:

```toml
# In config.toml (not in your current config, but available)
filter_mode_shell_up_key_binding = "directory"
```

With this setting, pressing Up would cycle through commands previously run in the current directory rather than the global history. This is particularly useful in project directories where you repeatedly run the same build or test commands.

\newpage
