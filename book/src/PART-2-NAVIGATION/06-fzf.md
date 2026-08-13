# Fuzzy Finding: fzf

> A general-purpose fuzzy finder that turns any list into an interactive, filterable menu -- it finds nothing on its own but makes everything else searchable.

## Your Setup

fzf is sourced in `~/.zshrc`:

```bash
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
```

This loads fzf's key bindings and shell completion into the zsh session. fzf itself is a filter: it reads lines from stdin, presents an interactive fuzzy search interface, and outputs the selected line(s) to stdout.

Custom functions in `~/.aliases.zsh` build on fzf:

```bash
f()   { echo "$(fd --type f --hidden --follow --exclude .git | fzf)" | pbcopy; }
fv()  { nvim "$(fd --type f --hidden --follow --exclude .git | fzf)"; }
fcd() { cd "$(fd --type d --hidden --follow --exclude .git | fzf)" && l; }
```

## Core Concepts

### fzf Is a Filter, Not a Finder

This is the single most important thing to understand. fzf does not search your filesystem. It takes a list of strings as input, lets you narrow that list interactively, and outputs the selection. The pattern is always:

```
generate list  |  fzf  |  do something with selection
```

For example:

```bash
fd --type f | fzf | xargs nvim     # fd finds, fzf picks, nvim opens
git branch | fzf | xargs git checkout  # git lists, fzf picks, git acts
```

### The Find-Pick-Act Pattern

Nearly every fzf workflow follows three steps:

1. **Find** -- A fast tool generates a list (fd, rg, git, ls, etc.)
2. **Pick** -- fzf presents the list for fuzzy selection
3. **Act** -- The selection is passed to another tool (cd, nvim, pbcopy, etc.)

Your custom functions implement exactly this pattern:

| Function | Find | Pick | Act |
|----------|------|------|-----|
| `f` | `fd --type f` | `fzf` | `pbcopy` (copy path) |
| `fv` | `fd --type f` | `fzf` | `nvim` (edit file) |
| `fcd` | `fd --type d` | `fzf` | `cd` + `l` (navigate + list) |

### Fuzzy Matching Syntax

fzf supports several matching operators within the search query:

| Token | Match Type | Example |
|-------|-----------|---------|
| `foo` | Fuzzy match | Items containing f, o, o in order |
| `'foo` | Exact match | Items containing literal "foo" |
| `^foo` | Prefix exact match | Items starting with "foo" |
| `foo$` | Suffix exact match | Items ending with "foo" |
| `!foo` | Inverse exact match | Items NOT containing "foo" |
| `!^foo` | Inverse prefix | Items NOT starting with "foo" |
| `!foo$` | Inverse suffix | Items NOT ending with "foo" |

Combine tokens with spaces (AND logic): `^src .ts$ !test` matches files starting with "src", ending in ".ts", excluding "test".

## Essential Commands

### Shell Key Bindings

| Key | Action | Notes |
|-----|--------|-------|
| `Ctrl+T` | Find file, paste path | Inserts selected file path at cursor |
| `Alt+C` | Find directory, cd into it | Changes to selected directory |
| `Ctrl+R` | Search shell history | Overridden by Atuin in this setup |

Note: Since Atuin is initialized after fzf in `~/.zshrc`, Atuin's `Ctrl+R` takes precedence. fzf's history search is effectively replaced by Atuin's richer interface.

### Custom Functions

| Command | Action | What Happens |
|---------|--------|-------------|
| `f` | Find file, copy path to clipboard | fd files -> fzf -> pbcopy |
| `fv` | Find file, open in Neovim | fd files -> fzf -> nvim |
| `fcd` | Find directory, cd + list | fd dirs -> fzf -> cd + eza listing |

### fzf Options

| Flag | Purpose | Example |
|------|---------|---------|
| `-m` | Multi-select (Tab to toggle) | `fzf -m` |
| `-q` | Start with a pre-filled query | `fzf -q ".md"` |
| `--preview` | Show file preview | `fzf --preview 'bat {}'` |
| `--height` | Limit to percentage of terminal | `fzf --height 40%` |
| `--reverse` | Reverse layout (list at top) | `fzf --reverse` |
| `--border` | Draw border around finder | `fzf --border` |
| `--header` | Display a header line | `fzf --header "Pick a file"` |
| `--bind` | Custom key bindings | `fzf --bind 'ctrl-y:accept'` |
| `--delimiter` | Field delimiter | `fzf --delimiter :` |
| `--with-nth` | Display specific fields | `fzf --with-nth 1,3` |
| `--preview-window` | Preview pane position/size | `fzf --preview-window right:60%` |

## Practical Recipes

### Find and edit a file

```bash
fv                   # Uses the custom function
# Or manually:
fd --type f | fzf --preview 'bat --color=always {}' | xargs nvim
```

### Find and copy a file path

```bash
f                    # Uses the custom function -- path goes to clipboard
# Then paste with Cmd+V anywhere
```

### Find a directory and navigate to it

```bash
fcd                  # Uses the custom function
# Or use the shell binding:
# Press Alt+C and type to filter
```

### Multi-select files to open

```bash
fd --type f -e md | fzf -m --preview 'bat --color=always {}' | xargs nvim
```

Press `Tab` to toggle selection on individual items, then `Enter` to confirm.

### Search git branches and switch

```bash
git branch --all | fzf --height 40% | sed 's/^[* ]*//' | sed 's|remotes/origin/||' | xargs git checkout
```

### Preview files while searching

```bash
fd --type f | fzf --preview 'bat --color=always --line-range=:100 {}' --preview-window right:60%
```

### Filter process list and kill

```bash
ps aux | fzf --height 40% --header "Select process to kill" | awk '{print $2}' | xargs kill
```

### Browse and select from any command output

```bash
brew list | fzf                          # Pick an installed package
docker ps --format '{{.Names}}' | fzf   # Pick a container
npm run --json 2>/dev/null | jq -r 'keys[]' | fzf  # Pick an npm script
```

### Pipe ripgrep results through fzf

```bash
rg --line-number "TODO" | fzf --delimiter : --preview 'bat --color=always --highlight-line {2} {1}' --preview-window '+{2}/2'
```

This searches for "TODO" with rg, pipes the results through fzf with a bat preview that highlights the matching line.

## Advanced Usage

### fzf as a UI Component in Other Tools

fzf is embedded deeply across this dev environment. It acts as the interactive selection layer for many tools:

| Tool | How fzf Is Used |
|------|-----------------|
| **sesh** | `sesh connect` uses `fzf-tmux -p 55%,60%` for session picking |
| **tmux-fzf-url** | Extracts URLs from tmux pane, picks with fzf |
| **tmux-fzf** | Fuzzy control of tmux sessions, windows, panes |
| **Yazi** | Press `z` to jump via fzf plugin |
| **Neovim Telescope** | Uses fzf-native sorter for fast matching |
| **zoxide cdi** | Interactive mode powered by fzf |
| **Ctrl+T binding** | Shell-level file finding |
| **Alt+C binding** | Shell-level directory navigation |

### fzf-tmux

The `fzf-tmux` command runs fzf in a tmux popup or split instead of inline. This is how sesh presents its session picker:

```bash
sesh connect "$(sesh list | fzf-tmux -p 55%,60%)"
```

The `-p 55%,60%` flag creates a centered popup at 55% width and 60% height.

### Customizing fzf with Environment Variables

You can set defaults via environment variables in your shell configuration:

| Variable | Purpose | Example |
|----------|---------|---------|
| `FZF_DEFAULT_COMMAND` | Default input when no stdin | `fd --type f --hidden --follow` |
| `FZF_DEFAULT_OPTS` | Default fzf options | `--height 40% --reverse --border` |
| `FZF_CTRL_T_COMMAND` | Command for Ctrl+T binding | `fd --type f --hidden --follow` |
| `FZF_CTRL_T_OPTS` | Options for Ctrl+T | `--preview 'bat --color=always {}'` |
| `FZF_ALT_C_COMMAND` | Command for Alt+C binding | `fd --type d --hidden --follow` |
| `FZF_ALT_C_OPTS` | Options for Alt+C | `--preview 'eza --tree --level=1 {}'` |

### Composing Custom Pickers

The real power is building one-off pickers for any situation:

```bash
# Pick a Brewfile to install from
ls ~/.config/brew/Brewfile* | fzf | xargs brew bundle --file

# Pick a dotfile to edit
chezmoi managed | fzf --preview 'bat --color=always ~/{}' | xargs chezmoi edit

# Pick a git stash to apply
git stash list | fzf --height 30% | cut -d: -f1 | xargs git stash pop
```

### Key Bindings Inside fzf

While the fzf interface is active, these keys are available by default:

| Key | Action |
|-----|--------|
| `Enter` | Confirm selection |
| `Esc` / `Ctrl+C` | Cancel |
| `Ctrl+J` / `Ctrl+N` | Move down |
| `Ctrl+K` / `Ctrl+P` | Move up |
| `Tab` | Toggle selection (multi-select mode) |
| `Shift+Tab` | Deselect (multi-select mode) |
| `Ctrl+A` | Select all (multi-select mode) |
| `Ctrl+/` | Toggle preview wrap |
| `Shift+Up/Down` | Scroll preview |
| `Page Up/Down` | Scroll results |

### The Mental Model

Think of fzf as a universal adapter. Any tool that produces a list of lines can have an interactive fuzzy interface added in front of it, and any tool that accepts an argument can act on the result. If you find yourself scanning through long command output looking for one item, pipe it through fzf instead.

\newpage
