# Search: fd and ripgrep

> Two Rust-powered search tools that replace find and grep -- fd locates files by name, ripgrep searches file contents, and both are fast enough to pipe through fzf interactively.

## Your Setup

Both tools are installed via Homebrew and used extensively throughout the environment:

- **fd** feeds file lists to fzf (Ctrl+T binding, custom functions), Neovim Telescope, and Yazi search-by-name.
- **ripgrep (rg)** powers content search in Neovim Telescope live grep and Yazi search-by-content.

Custom functions from `~/.aliases.zsh` that depend on fd:

```bash
f()   { echo "$(fd --type f --hidden --follow --exclude .git | fzf)" | pbcopy; }
fv()  { nvim "$(fd --type f --hidden --follow --exclude .git | fzf)"; }
fcd() { cd "$(fd --type d --hidden --follow --exclude .git | fzf)" && l; }
```

Both tools respect `.gitignore` by default, which makes them fast and noise-free in project directories.

## Core Concepts

### fd: File Finding

fd is a fast, user-friendly alternative to `find`. Key design principles:

- **Smart defaults**: Ignores hidden files and `.gitignore` patterns by default.
- **Regex by default**: The pattern argument is a regular expression, not a glob.
- **Colorized output**: Results are syntax-highlighted by file type.
- **Parallel execution**: The `--exec` flag runs commands in parallel.

### ripgrep: Content Searching

ripgrep (invoked as `rg`) is a fast alternative to `grep` for searching file contents. Key design principles:

- **Recursive by default**: Searches the current directory tree without flags.
- **Respects .gitignore**: Skips ignored files automatically.
- **Smart case**: With `-S`, lowercase patterns are case-insensitive; patterns with uppercase are case-sensitive.
- **Line-oriented**: Outputs file path, line number, and matching line.

### Comparison Tables

#### fd vs find

| Task | fd | find |
|------|-----|------|
| Find files named "config" | `fd config` | `find . -name '*config*'` |
| Find only directories | `fd -t d` | `find . -type d` |
| Find by extension | `fd -e json` | `find . -name '*.json'` |
| Include hidden files | `fd -H` | Default behavior |
| Exclude a directory | `fd --exclude node_modules` | `find . -not -path '*/node_modules/*'` |
| Execute command | `fd -e js --exec wc -l` | `find . -name '*.js' -exec wc -l {} \;` |
| Max depth | `fd -d 2` | `find . -maxdepth 2` |
| Case insensitive | `fd -i pattern` | `find . -iname '*pattern*'` |
| Respects .gitignore | Yes (default) | No |

#### rg vs grep

| Task | rg | grep |
|------|-----|------|
| Search for "TODO" recursively | `rg TODO` | `grep -r TODO .` |
| Case insensitive | `rg -i todo` | `grep -ri todo .` |
| Show only filenames | `rg -l TODO` | `grep -rl TODO .` |
| Context lines | `rg -C 3 TODO` | `grep -C 3 -r TODO .` |
| Word boundary match | `rg -w error` | `grep -rw error .` |
| Search specific file type | `rg -t py import` | `grep -r --include='*.py' import .` |
| Invert match | `rg -v pattern` | `grep -rv pattern .` |
| Count matches | `rg -c pattern` | `grep -rc pattern .` |
| Respects .gitignore | Yes (default) | No |
| Regex by default | Yes | Basic (use -E for extended) |

## Essential Commands: fd

| Command | Action |
|---------|--------|
| `fd pattern` | Find files/dirs matching regex pattern |
| `fd -e ext` | Find by extension (e.g., `fd -e rs`) |
| `fd -t f` | Files only |
| `fd -t d` | Directories only |
| `fd -t l` | Symlinks only |
| `fd -H` | Include hidden files |
| `fd -I` | Do not respect .gitignore |
| `fd --no-ignore` | Skip all ignore files |
| `fd -d N` | Limit search depth to N |
| `fd --exclude dir` | Exclude a directory |
| `fd -E '*.min.js'` | Exclude by glob pattern |
| `fd -x cmd` | Execute command for each result (parallel) |
| `fd -X cmd` | Execute command with all results as arguments |
| `fd -0` | Null-separated output (for xargs -0) |
| `fd pattern /path` | Search in a specific directory |
| `fd -a` | Show absolute paths |
| `fd --changed-within 1d` | Modified within last day |
| `fd --changed-before 1w` | Modified before last week |
| `fd -S +1m` | Files larger than 1 megabyte |

## Essential Commands: ripgrep

| Command | Action |
|---------|--------|
| `rg pattern` | Search current directory tree for pattern |
| `rg -i pattern` | Case insensitive search |
| `rg -S pattern` | Smart case (lowercase = insensitive) |
| `rg -w pattern` | Match whole words only |
| `rg -l pattern` | List only filenames with matches |
| `rg -c pattern` | Count matches per file |
| `rg -C N pattern` | Show N context lines around matches |
| `rg -A N pattern` | Show N lines after each match |
| `rg -B N pattern` | Show N lines before each match |
| `rg -t type pattern` | Restrict to file type (e.g., `rg -t py`) |
| `rg -T type pattern` | Exclude a file type |
| `rg -g 'glob' pattern` | Filter files by glob |
| `rg -g '!test*' pattern` | Exclude files matching glob |
| `rg --hidden pattern` | Include hidden files |
| `rg --no-ignore pattern` | Skip gitignore rules |
| `rg -e pat1 -e pat2` | Multiple patterns (OR logic) |
| `rg -v pattern` | Invert match (non-matching lines) |
| `rg -F 'literal'` | Fixed string (no regex) |
| `rg -m N pattern` | Limit to N matches per file |
| `rg --json pattern` | Output in JSON format |
| `rg -o pattern` | Print only the matching portion |
| `rg --sort path pattern` | Sort results by file path |
| `rg -U 'multi\nline'` | Multiline matching |

## Practical Recipes

### Find all TypeScript files in a project

```bash
fd -e ts -e tsx
```

### Find large files

```bash
fd -S +10m                    # Files over 10 MB
fd -S +100k -e log            # Log files over 100 KB
```

### Find recently modified files

```bash
fd --changed-within 2h        # Modified in the last 2 hours
fd --changed-within 1d -e rs  # Rust files modified today
```

### Delete all .DS_Store files

```bash
fd -H .DS_Store -x rm         # The -H flag includes hidden files
```

### Search for a function definition

```bash
rg "fn main" -t rust                # In Rust files
rg "function.*export" -t js         # Exported functions in JavaScript
rg "def (test_|it_)" -t py         # Test functions in Python
```

### Search and replace across files

```bash
rg -l "old_name" | xargs sed -i '' 's/old_name/new_name/g'
```

### Find TODOs with context

```bash
rg "TODO|FIXME|HACK" -C 2 --heading
```

The `--heading` flag groups results by file for readability.

### Search only in specific directories

```bash
rg pattern src/                     # Only search in src/
rg pattern -g 'src/**/*.ts'        # Only TypeScript files under src/
```

### Exclude test files from search

```bash
rg pattern -g '!*test*' -g '!*spec*'
```

### Count occurrences by file

```bash
rg -c "import" -t ts --sort path
```

### Pipe fd to fzf to act (the standard pattern)

```bash
# Find a file and open it
fd -e md | fzf --preview 'bat --color=always {}' | xargs nvim

# Find a directory and cd into it
cd "$(fd -t d | fzf)"

# Find a file and copy its path
fd -t f | fzf | pbcopy
```

### Pipe rg to fzf for interactive grep

```bash
rg --line-number --color=always pattern | fzf --ansi --delimiter : \
  --preview 'bat --color=always --highlight-line {2} {1}' \
  --preview-window '+{2}/2'
```

### Search for files containing two different patterns

```bash
rg -l "pattern1" | xargs rg -l "pattern2"
```

### List all file types ripgrep knows

```bash
rg --type-list                      # Shows all supported types
rg --type-list | rg python          # Find python-related types
```

## Advanced Usage

### Integration Map

Both tools are embedded throughout the dev environment:

| Tool | fd Usage | rg Usage |
|------|----------|----------|
| **fzf Ctrl+T** | File list generation | -- |
| **fzf Alt+C** | Directory list generation | -- |
| **Custom f/fv/fcd** | File and directory lists | -- |
| **Neovim Telescope** | File finder backend | Live grep backend |
| **Yazi** | `s` key: search by name | `S` key: search by content |

### fd Exec Patterns

fd's `-x` (each) and `-X` (batch) flags are powerful alternatives to `xargs`:

```bash
# Run a command for each file (parallel by default)
fd -e jpg -x convert {} {.}.png     # Convert all JPGs to PNG
fd -e rs -x wc -l                   # Count lines in each Rust file

# Run a command with all files as arguments (single invocation)
fd -e ts -X prettier --write        # Format all TypeScript files at once

# Placeholder syntax in -x:
#   {}   full path
#   {.}  path without extension
#   {/}  filename only
#   {//} parent directory
#   {/.} filename without extension
```

### ripgrep Configuration File

ripgrep supports a configuration file at `$RIPGREP_CONFIG_PATH`:

```bash
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"
```

Example config file:

```
--smart-case
--hidden
--glob=!.git
--glob=!node_modules
```

### Performance Tips

Both tools are fast by default, but you can squeeze more speed:

- **Limit depth**: `fd -d 3` and `rg --max-depth 3` avoid deeply nested directories.
- **Target directories**: `rg pattern src/` is faster than `rg pattern` when you know where to look.
- **Use type filters**: `rg -t py` avoids checking files that cannot match.
- **Use fixed strings**: `rg -F "exact.string"` avoids regex overhead.
- **Parallel output**: fd defaults to parallel execution with `-x`; rg defaults to parallel search across files.

### Combining fd and rg

Sometimes you want fd's file-finding ability with rg's content searching. Use fd to generate the file list and pass it to rg:

```bash
# Search only in recently modified files
fd --changed-within 1d -e ts -X rg "TODO"

# Search in files matching a complex name pattern
fd "controller" -e rb -X rg "before_action"

# Search excluding certain directories that rg's globs cannot express
fd -t f --exclude legacy --exclude vendor -X rg "deprecated"
```

### Using with git

```bash
# Find untracked files matching a pattern
git ls-files --others --exclude-standard | rg "test"

# Search only in files tracked by git
rg pattern $(git ls-files)

# Find all files that differ from main
git diff --name-only main | xargs rg "TODO"
```

\newpage
