# Navigation: zoxide

> A smarter cd that learns your habits -- replacing the built-in entirely so every directory change gets smarter over time.

## Your Setup

Zoxide is initialized in `~/.zshrc` with a critical flag that most guides overlook:

```bash
eval "$(zoxide init zsh --cmd cd)"
```

The `--cmd cd` argument replaces the shell built-in `cd` command with zoxide. This means you do not use a separate `z` command. Every time you type `cd`, you are invoking zoxide's frecency-based directory jumper. The `z` command does not exist in this setup -- `cd` is zoxide.

Additionally, `cdi` is automatically created as the interactive variant, launching fzf for directory selection.

Navigation aliases are defined in `~/.aliases.zsh`:

```bash
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias -- -="cd -"
```

Custom navigation functions build on top of zoxide:

```bash
cx() { cd "$@" && l; }           # cd + list directory contents
fcd() { cd "$(fd --type d --hidden --follow --exclude .git | fzf)" && l; }
```

## Core Concepts

### Frecency Algorithm

Zoxide ranks directories by "frecency" -- a combination of frequency and recency. Directories you visit often and recently score higher. The database updates every time you `cd` into a directory.

- **Frequency**: How many times you have visited a directory.
- **Recency**: How recently you visited. Recent visits are weighted more heavily.
- **Aging**: Scores decay over time. Directories you stop visiting gradually lose rank.

### How Matching Works

When you type `cd foo`, zoxide does not simply look for a directory named `foo` in the current directory. It searches its database of all directories you have ever visited and picks the highest-scoring match:

- `cd proj` -- jumps to the highest-ranked directory containing "proj"
- `cd proj api` -- matches directories containing both "proj" and "api" as substrings, in order
- `cd /exact/path` -- absolute paths bypass zoxide and work as traditional cd

If zoxide has no match, it falls back to standard `cd` behavior in the current directory.

### The Database

Zoxide stores its database at `~/.local/share/zoxide/db.zo`. The database is updated automatically on every successful `cd`. You can query and manage it with `zoxide query`.

## Essential Commands

| Command | Action | Notes |
|---------|--------|-------|
| `cd foo` | Jump to best "foo" match | Uses frecency ranking |
| `cd foo bar` | Jump to match for both terms | Terms matched in order |
| `cd ..` | Parent directory | Alias: `..` |
| `cd ../..` | Two levels up | Alias: `...` |
| `cd ../../..` | Three levels up | Alias: `....` |
| `cd -` | Previous directory | Alias: `-` |
| `cdi` | Interactive directory picker | fzf-powered selection |
| `cx foo` | cd + list contents | Custom function |
| `fcd` | fd + fzf + cd + list | Custom function |

### Database Management

| Command | Action |
|---------|--------|
| `zoxide query` | List all tracked directories with scores |
| `zoxide query foo` | Show best match for "foo" |
| `zoxide query foo --list` | List all matches for "foo" with scores |
| `zoxide query --all` | Show all directories sorted by score |
| `zoxide add /path` | Manually add a directory to the database |
| `zoxide remove /path` | Remove a directory from the database |
| `zoxide edit` | Open the database in your editor |

## Practical Recipes

### Jump to a project by partial name

```bash
cd dotfiles          # Jumps to ~/.local/share/chezmoi if that is your top match
cd myapp api         # Jumps to ~/projects/myapp/packages/api
```

### Navigate up then list

The `cx` function combines `cd` with the `l` alias (which runs `eza -l --icons --git -a`), giving you an immediate view of what is in the target directory:

```bash
cx ..                # Go up one level and list
cx ~/projects        # Jump to projects and list
```

### Fuzzy directory navigation with fcd

The `fcd` function uses `fd` to find all directories (including hidden ones, excluding `.git`), pipes them through fzf for interactive selection, then `cd`s into the chosen directory and lists its contents:

```bash
fcd                  # Opens fzf with all directories under current path
```

This is useful when you do not remember the exact directory name but want to browse visually.

### Interactive mode with cdi

When zoxide has multiple candidates and you want to choose manually:

```bash
cdi proj             # Shows all "proj" matches in fzf, lets you pick
cdi                  # Shows all tracked directories in fzf
```

### Check what zoxide would pick

```bash
zoxide query proj          # Prints the path zoxide would jump to
zoxide query proj --list   # Shows all candidates with scores
```

### Clean up stale entries

Over time, deleted directories accumulate in the database. Zoxide automatically removes entries when you try to `cd` into a directory that no longer exists, but you can also clean manually:

```bash
zoxide remove /old/path/that/no/longer/exists
```

### Seed the database for a new machine

After a fresh setup, the database is empty. Visit your important directories once to seed it:

```bash
cd ~/projects/app1 && cd ~/projects/app2 && cd ~/.config && cd ~
```

After that, `cd app1` will work from anywhere.

## Advanced Usage

### Integration with Other Tools

Zoxide is not just for the shell. It powers directory navigation across multiple tools in this environment:

| Tool | How Zoxide Is Used |
|------|--------------------|
| **Yazi** | Press `Z` to jump to any directory via zoxide |
| **sesh** | Session picker uses zoxide for project directory suggestions |
| **tmux sessionx** | Can browse zoxide directories when creating sessions |
| **cdi** | The zoxide-generated interactive variant with fzf |

### How --cmd cd Changes the Shell

The `--cmd cd` flag generates shell functions that replace `cd` with `__zoxide_z` and create `cdi` as `__zoxide_zi`. The actual shell integration looks roughly like:

```bash
function cd() {
  __zoxide_z "$@"
}
function cdi() {
  __zoxide_zi "$@"
}
```

This means `cd` gains smart matching, but standard `cd` behavior (absolute paths, `cd -`, `cd` with no arguments to go home) is preserved.

### Precedence Rules

Zoxide applies this matching logic in order:

1. If the argument is empty, go to `$HOME` (standard `cd` behavior).
2. If the argument is `-`, go to `$OLDPWD` (previous directory).
3. If the argument is an absolute path or a valid relative path, use it directly.
4. Otherwise, search the database for the best frecency match.

This means `cd ./foo` always goes to the literal `./foo` subdirectory, while `cd foo` searches the database.

### Excluding Directories

You can prevent zoxide from tracking certain directories by setting `_ZO_EXCLUDE_DIRS`:

```bash
export _ZO_EXCLUDE_DIRS="$HOME:$HOME/private/*:/tmp/*"
```

### Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `_ZO_DATA_DIR` | `~/.local/share/zoxide` | Database location |
| `_ZO_ECHO` | `0` | Print matched directory before jumping |
| `_ZO_EXCLUDE_DIRS` | `$HOME` | Directories to exclude from tracking |
| `_ZO_FZF_OPTS` | (none) | Extra options passed to fzf in interactive mode |
| `_ZO_MAXAGE` | `10000` | Maximum total score before aging kicks in |
| `_ZO_RESOLVE_SYMLINKS` | `0` | Resolve symlinks before adding to database |

### Debugging Unexpected Jumps

If `cd foo` takes you somewhere unexpected:

```bash
zoxide query foo --list    # See all candidates and their scores
zoxide remove /wrong/path  # Remove the unwanted entry
cd /correct/path           # Visit the correct one to boost its score
```

### The Dot Aliases and Zoxide

The dot aliases (`..`, `...`, `....`, `.....`) call `cd ..`, `cd ../..`, and so on. Because `cd` is zoxide, these relative paths are passed through. Since `..` resolves to a valid relative path, zoxide uses it directly without database lookup -- exactly as you would expect.

The `-` alias calls `cd -`, which triggers zoxide's built-in support for `$OLDPWD`, toggling between your two most recent directories.

\newpage
