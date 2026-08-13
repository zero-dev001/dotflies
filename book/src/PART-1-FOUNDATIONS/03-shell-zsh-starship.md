# Shell: Zsh + Starship

> The shell is where intent becomes action -- its prompt should inform, and its configuration should never get in the way.

---

## Your Setup

The shell layer consists of two components: Zsh as the shell (with Oh My Zsh for plugin management) and Starship as the prompt. Configuration lives at:

- **Zsh config:** `~/.zshrc`
- **Chezmoi source:** `~/.local/share/chezmoi/dot_zshrc.tmpl` (templated for machine-specific paths)
- **Starship config:** `~/.config/starship.toml`
- **Chezmoi source:** `~/.local/share/chezmoi/dot_config/starship.toml`
- **Aliases:** `~/.aliases.zsh` (sourced from `.zshrc`)
- **Oh My Zsh path:** `~/.oh-my-zsh`

### The .zshrc in Full

```zsh
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Oh My Zsh (no theme - Starship handles the prompt)
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
ENABLE_CORRECTION="true"
DISABLE_UPDATE_PROMPT=true
DISABLE_AUTO_TITLE="true"
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

# Editor
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Man pages in Neovim with syntax highlighting
export MANPAGER='nvim +Man!'

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# PATH additions
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
[ -d "$(brew --prefix)/opt/mysql-client/bin" ] && \
  export PATH="$(brew --prefix)/opt/mysql-client/bin:$PATH"
[ -d "$(brew --prefix)/opt/llvm/bin" ] && \
  export PATH="$(brew --prefix)/opt/llvm/bin:$PATH"

# Tool init
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(zoxide init zsh --cmd cd)"
eval "$(atuin init zsh)"
eval "$(mise activate zsh)"

# Aliases and shell functions
[ -f ~/.aliases.zsh ] && source ~/.aliases.zsh

# Starship prompt (must be last)
eval "$(starship init zsh)"
```

### The starship.toml in Full

```toml
format = """
$username\
$hostname\
$time\
$all\
$directory
$character
"""

[character]
success_symbol = '[>>>>](#a6e3a1 bold)'
error_symbol = '[XXXX](#f38ba8 bold)'
vicmd_symbol = '[<<<<](#cba6f7 bold)'

[battery]
disabled = true

[gcloud]
disabled = true

[time]
style = '#cba6f7 bold'
disabled = false
format = '[\[$time\]]($style) '
time_format = '%y/%m/%d'

[username]
style_user = '#cba6f7 bold'
style_root = 'white bold'
format = '[$user]($style).@.'
show_always = true

[hostname]
ssh_only = true
format = '(white bold)[$hostname](#a6e3a1 bold)'

[directory]
style = '#89dceb bold'
truncation_length = 0
truncate_to_repo = false

[git_branch]
style = '#f5c2e7 bold'

[git_status]
style = '#fab387 bold'

[nodejs]
style = '#a6e3a1 bold'

[python]
style = '#f9e2af bold'

[rust]
style = '#fab387 bold'

[golang]
style = '#89dceb bold'

[docker_context]
style = '#89b4fa bold'

[cmd_duration]
style = '#f9e2af bold'
min_time = 2_000

[ruby]
detect_variables = []
detect_files = ['Gemfile', '.ruby-version']
```

## Core Concepts

### Why Zsh + Oh My Zsh with No Theme?

Oh My Zsh provides two things: a plugin system and themes. This setup uses it only for the plugin system. The `ZSH_THEME=""` setting disables Oh My Zsh's prompt entirely, leaving prompt rendering to Starship.

This separation gives the best of both worlds:

- **Oh My Zsh plugins** provide git aliases, syntax highlighting, and autosuggestions without needing to install and configure each one manually.
- **Starship** provides a fast, highly configurable prompt that renders in Rust and works across shells (Zsh, Bash, Fish, PowerShell).

### Plugin Stack

The three plugins loaded by Oh My Zsh:

**git** -- Provides approximately 150 git aliases. The most frequently used:

| Alias  | Expansion                        | Purpose                    |
|--------|----------------------------------|----------------------------|
| `gst`  | `git status`                     | Check working tree         |
| `ga`   | `git add`                        | Stage files                |
| `gc`   | `git commit`                     | Commit                     |
| `gco`  | `git checkout`                   | Switch branches            |
| `gp`   | `git push`                       | Push to remote             |
| `gl`   | `git pull`                       | Pull from remote           |
| `gd`   | `git diff`                       | View diff                  |
| `glog` | `git log --oneline --decorate --graph` | Visual log           |
| `gb`   | `git branch`                     | List branches              |
| `grb`  | `git rebase`                     | Rebase                     |
| `gsta` | `git stash push`                 | Stash changes              |
| `gstp` | `git stash pop`                  | Pop stash                  |

**zsh-syntax-highlighting** -- Highlights commands as you type them. Valid commands appear green, invalid commands appear red, strings appear in quotes highlighting, and paths that exist are underlined. This provides instant feedback about typos before you press Enter.

**zsh-autosuggestions** -- Shows a ghosted suggestion of the most recent matching command from history as you type. Press the right arrow key (or End) to accept the full suggestion, or press Ctrl+Right to accept one word at a time.

### Oh My Zsh Settings

| Setting                    | Value    | Purpose                                    |
|----------------------------|----------|--------------------------------------------|
| `ZSH_THEME`               | `""`     | Disable Oh My Zsh theme (Starship instead) |
| `ENABLE_CORRECTION`       | `true`   | Suggest corrections for mistyped commands   |
| `DISABLE_UPDATE_PROMPT`   | `true`   | Auto-update without asking                  |
| `DISABLE_AUTO_TITLE`      | `true`   | Do not set terminal title (tmux handles it) |

The `DISABLE_AUTO_TITLE` setting is important when using tmux. Without it, Oh My Zsh would set the terminal title on every command, which conflicts with tmux's own title management and can cause flickering in the tmux status bar.

### Editor Configuration

```zsh
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi
```

When working locally, the default editor is Neovim. When connected via SSH, it falls back to Vim, which is more likely to be available on remote servers without a full Neovim installation.

The `EDITOR` variable is used by many tools: git (for commit messages, interactive rebase), tmux (for copy mode editing), `fc` (for editing the last command), and any CLI that opens an editor.

### Man Pages in Neovim

```zsh
export MANPAGER='nvim +Man!'
```

This replaces the default `less` man page viewer with Neovim. The `+Man!` argument tells Neovim to activate its built-in Man plugin, which provides:

- Syntax highlighting for man pages
- Clickable cross-references (press `K` on a referenced command to jump to its man page)
- Full Neovim navigation (search with `/`, jump with `gg`/`G`, etc.)
- Catppuccin Mocha colors applied to man page content

### Tool Initialization Order

The order of `eval` statements in `.zshrc` matters. Each tool that hooks into the shell must be initialized in the correct sequence:

```
1. Oh My Zsh        -- loads first, provides base shell config and plugins
2. fzf              -- fuzzy finder shell integration (Ctrl+R, Ctrl+T, Alt+C)
3. zoxide           -- replaces cd with frecency-based jumping
4. atuin            -- replaces shell history with a searchable database
5. mise             -- activates language runtime version management
6. aliases          -- loaded after all tools so aliases can reference them
7. Starship         -- MUST be last; it wraps the prompt function
```

Starship must be initialized last because it replaces the `precmd` and `preexec` hook functions. If another tool initializes after Starship, it might overwrite these hooks and break the prompt.

### PATH Construction

The PATH is built up in layers:

```
$HOME/bin                              -- personal scripts
$HOME/.local/bin                       -- locally installed binaries
/usr/local/bin                         -- Homebrew (Intel) / system
$BUN_INSTALL/bin                       -- Bun runtime
$(brew --prefix)/opt/mysql-client/bin  -- MySQL client (if installed)
$(brew --prefix)/opt/llvm/bin          -- LLVM toolchain (if installed)
```

The chezmoi template (`dot_zshrc.tmpl`) allows machine-specific PATH entries:

```zsh
{{ if dig "projectBinPath" "" . }}
export PATH="$HOME/{{ .projectBinPath }}:$PATH"
{{ end }}
```

This conditionally adds a project-specific bin directory only on machines where `projectBinPath` is defined in the chezmoi config.

## Essential Commands

### Shell Navigation

| Action                          | Keybinding / Command        | Notes                           |
|---------------------------------|-----------------------------|---------------------------------|
| Accept autosuggestion           | `Right Arrow` or `End`      | Completes ghosted suggestion    |
| Accept one word                 | `Ctrl+Right`                | Partial autosuggestion accept   |
| Search history (atuin)          | `Ctrl+R`                    | Opens atuin TUI                 |
| Fuzzy find file                 | `Ctrl+T`                    | fzf file finder                 |
| Fuzzy cd into directory         | `Alt+C`                     | fzf directory finder            |
| Clear screen                    | `Ctrl+L`                    | Keeps scrollback                |
| Cancel current line             | `Ctrl+C`                    | Aborts current input            |
| Move to beginning of line       | `Ctrl+A`                    | Home                            |
| Move to end of line             | `Ctrl+E`                    | End                             |
| Delete word backward            | `Ctrl+W`                    | Kills word before cursor        |
| Delete to beginning of line     | `Ctrl+U`                    | Kills to start                  |
| Delete to end of line           | `Ctrl+K`                    | Kills to end                    |
| Undo                            | `Ctrl+/`                    | Undo last edit                  |
| Spell correction                | Automatic                   | Suggests `Did you mean...?`     |

### Environment Variables

| Variable       | Value                    | Used By                       |
|----------------|--------------------------|-------------------------------|
| `EDITOR`       | `nvim` (local) / `vim` (SSH) | git, tmux, fc, etc.       |
| `MANPAGER`     | `nvim +Man!`             | `man` command                 |
| `ZSH`          | `$HOME/.oh-my-zsh`      | Oh My Zsh framework           |
| `NVM_DIR`      | `$HOME/.nvm`            | Node Version Manager          |
| `BUN_INSTALL`  | `$HOME/.bun`            | Bun JavaScript runtime        |

## Practical Recipes

### Recipe: Understanding the Prompt

The Starship prompt renders on two lines. Here is what a typical prompt looks like and what each part means:

```
zero.@. [26/03/11]  main *!? v20.11.0 via  v3.12.0  47s
~/projects/my-app
>>>>
```

Breaking this down piece by piece:

| Segment               | Config Section    | Color (Catppuccin) | Meaning                        |
|-----------------------|-------------------|--------------------|---------------------------------|
| `zero`               | `[username]`      | Mauve (`#cba6f7`)  | Current user                   |
| `.@.`                 | `[username]`      | Mauve              | Separator (hostname omitted locally) |
| `[26/03/11]`          | `[time]`          | Mauve (`#cba6f7`)  | Date: year/month/day           |
| ` main`              | `[git_branch]`    | Pink (`#f5c2e7`)   | Git branch name                |
| `*!?`                 | `[git_status]`    | Peach (`#fab387`)  | Modified, staged, untracked    |
| `v20.11.0`            | `[nodejs]`        | Green (`#a6e3a1`)  | Node.js version (if detected)  |
| `via  v3.12.0`       | `[python]`        | Yellow (`#f9e2af`) | Python version (if detected)   |
| `47s`                 | `[cmd_duration]`  | Yellow (`#f9e2af`) | Last command took 47 seconds   |
| `~/projects/my-app`   | `[directory]`     | Sky (`#89dceb`)    | Full path, no truncation       |
| `>>>>`                | `[character]`     | Green (`#a6e3a1`)  | Success (last exit code was 0) |

When the last command fails (non-zero exit code):

```
zero.@. [26/03/11]
~/projects/my-app
XXXX
```

The `>>>>` changes to `XXXX` in red (`#f38ba8`), making errors immediately visible.

When in Zsh vi command mode (if enabled):

```
zero.@. [26/03/11]
~/projects/my-app
<<<<
```

The `<<<<` in mauve (`#cba6f7`) indicates vi normal mode.

### Recipe: Using Zoxide as cd

Zoxide is initialized with `--cmd cd`, which means it replaces the built-in `cd` command:

```bash
# Traditional cd still works for explicit paths
cd /usr/local/bin
cd ..
cd ~

# But now cd also supports frecency jumping
cd projects      # Jumps to most frequently/recently visited "projects" dir
cd my-app        # Jumps to the best match for "my-app"
cd proj app      # Multiple arguments narrow the search: matches "projects/my-app"

# Interactive selection when multiple matches exist
cdi              # Opens fzf to select from matching directories
```

Zoxide tracks every directory you visit and ranks them by frequency and recency (frecency). Over time, short fragments like `cd app` reliably jump to the right directory without typing the full path.

### Recipe: Using Atuin for Shell History

Atuin replaces the default Zsh history with a SQLite database that supports:

```bash
# Search history interactively
Ctrl+R           # Opens the atuin TUI

# In the atuin TUI:
# - Type to filter commands
# - Up/Down to navigate results
# - Enter to select and execute
# - Esc to cancel

# History is synchronized across machines (if configured)
# History includes: command, exit code, duration, directory, hostname
```

### Recipe: NVM Auto-Switching

NVM (Node Version Manager) is loaded early in `.zshrc`. Combined with a `.nvmrc` file in a project directory:

```bash
# In your project directory, create .nvmrc:
echo "20" > .nvmrc

# NVM can be configured to auto-switch on cd:
# (add to .zshrc after NVM init)
autoload -U add-zsh-hook
load-nvmrc() {
  local nvmrc_path="$(nvm_find_nvmrc)"
  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")
    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
      nvm use
    fi
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc
```

### Recipe: Checking Tool Initialization

To verify all tools are properly initialized:

```bash
# Check each tool
which nvim          # Should point to Neovim
echo $EDITOR        # Should be 'nvim'
which zoxide        # Should be in PATH
which atuin         # Should be in PATH
which starship      # Should be in PATH
mise --version      # Should print version
bun --version       # Should print version
nvm --version       # Should print version
fzf --version       # Should print version
```

## Advanced Usage

### The Chezmoi Template System

The `.zshrc` is managed as a chezmoi template (`dot_zshrc.tmpl`). This allows machine-specific customization:

```zsh
{{ if dig "projectBinPath" "" . }}
export PATH="$HOME/{{ .projectBinPath }}:$PATH"
{{ end }}
```

The `dig` function safely accesses nested chezmoi data. If `projectBinPath` is defined in `~/.config/chezmoi/chezmoi.toml`, the PATH entry is included. If not, it is silently omitted.

To add machine-specific configuration:

```toml
# ~/.config/chezmoi/chezmoi.toml
[data]
  projectBinPath = "work/tools/bin"
```

### Starship Module Ordering

The `format` string controls what appears in the prompt and in what order:

```toml
format = """
$username\
$hostname\
$time\
$all\
$directory
$character
"""
```

The first line contains: username, hostname (SSH only), time, and then `$all` which expands to all auto-detected modules (git, languages, docker, cmd_duration, etc.). The second line contains the directory. The third line contains the prompt character.

This two-line layout ensures that the command you type always starts at a predictable position (after `>>>>`) regardless of how long the first line gets with git info, language versions, and other context.

### Disabled Modules

Two modules are explicitly disabled:

```toml
[battery]
disabled = true

[gcloud]
disabled = true
```

Battery is disabled because this is a desktop-focused setup where battery status is visible in the macOS menu bar. Google Cloud is disabled to avoid slow API calls that would delay prompt rendering.

### Git Status Symbols

The `[git_status]` module shows compact symbols for the state of the working tree:

| Symbol | Meaning                  |
|--------|--------------------------|
| `*`    | Modified files           |
| `+`    | Staged files             |
| `!`    | Conflicted files         |
| `?`    | Untracked files          |
| `$`    | Stashed changes          |
| `>`    | Ahead of remote          |
| `<`    | Behind remote            |
| `=`    | Diverged from remote     |

These appear in peach (`#fab387`), making them stand out against the pink git branch name.

### Language Detection

Starship automatically detects the project language and shows version information:

| Language   | Detection Files                          | Color                |
|------------|------------------------------------------|----------------------|
| Node.js    | `package.json`, `.node-version`          | Green (`#a6e3a1`)    |
| Python     | `requirements.txt`, `pyproject.toml`, `.python-version` | Yellow (`#f9e2af`) |
| Rust       | `Cargo.toml`                             | Peach (`#fab387`)    |
| Go         | `go.mod`                                 | Sky (`#89dceb`)      |
| Docker     | `Dockerfile`, `docker-compose.yml`       | Blue (`#89b4fa`)     |
| Ruby       | `Gemfile`, `.ruby-version`               | Red (default)        |

Ruby detection is customized to avoid false positives:

```toml
[ruby]
detect_variables = []
detect_files = ['Gemfile', '.ruby-version']
```

The `detect_variables = []` prevents Ruby from being detected based on environment variables, which could trigger in directories that happen to have Ruby-related variables set but are not Ruby projects.

### Command Duration

```toml
[cmd_duration]
style = '#f9e2af bold'
min_time = 2_000
```

Commands that take longer than 2 seconds (2000ms) display their duration in yellow. This is useful for:

- Noticing when a build is slower than usual
- Timing long-running operations without needing to prefix them with `time`
- Quick feedback on whether an optimization made a difference

### Shell Startup Performance

The `.zshrc` uses conditional loading to avoid unnecessary work:

```zsh
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
[ -d "$(brew --prefix)/opt/mysql-client/bin" ] && ...
```

Each line checks whether a file or directory exists before sourcing or adding it to PATH. This means:

- On machines without NVM, the NVM init is skipped.
- On machines without fzf, the fzf shell integration is skipped.
- On machines without MySQL client, no broken PATH entries are added.

To profile shell startup time:

```bash
# Time shell startup
time zsh -i -c exit

# Detailed profiling (add to top of .zshrc temporarily)
zmodload zsh/zprof
# ... rest of .zshrc ...
# Add to bottom: zprof
```

A healthy startup time is under 200ms. If startup exceeds 500ms, the most common culprits are NVM initialization and `brew --prefix` calls (which spawn a subprocess).

### Interaction Between Tools

The initialization chain creates several interactions worth noting:

1. **zoxide replaces cd:** After `eval "$(zoxide init zsh --cmd cd)"`, the `cd` command is a Zsh function that calls zoxide. The original `cd` is still accessible as `builtin cd`.

2. **atuin replaces Ctrl+R:** After `eval "$(atuin init zsh)"`, pressing Ctrl+R opens atuin's search UI instead of Zsh's built-in reverse-i-search.

3. **fzf provides Ctrl+T and Alt+C:** The fzf shell integration adds file-finding (Ctrl+T) and directory-changing (Alt+C) keybindings.

4. **mise activates shims:** After `eval "$(mise activate zsh)"`, language runtimes managed by mise are available in PATH via shims.

5. **Starship wraps precmd:** Starship's init replaces the prompt-rendering function. All tool-specific prompt modifications must happen before Starship init.

\newpage
