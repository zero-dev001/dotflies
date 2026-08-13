# Modern Replacements: bat and eza

> Drop-in replacements for cat and ls that add syntax highlighting, icons, git awareness, and tree views to everyday file inspection.

## Your Setup

Both tools are installed via Homebrew and aliased in `~/.aliases.zsh` to transparently replace their traditional counterparts:

```bash
# ~/.aliases.zsh
alias cat="bat"
alias ls="eza"
alias l="eza -l --icons --git -a"
alias lt="eza --tree --level=2 --long --icons --git"
alias ltree="eza --tree --level=2 --icons --git"
```

Because of these aliases, every time you type `cat` or `ls` you are already using the modern versions. The original binaries remain available as `/bin/cat` and `/bin/ls` if you ever need them.

bat is also used as:

- The previewer in **fzf** fuzzy finder windows
- The `preview_command` in **sesh** session definitions (e.g., `bat --color=always ~/.local/share/chezmoi/dot_zshrc.tmpl`)
- An alternative **MANPAGER** (though your setup uses `nvim +Man!` instead)

eza icons require a Nerd Font. Your terminal is configured with JetBrainsMono Nerd Font, which provides the necessary glyphs. Ensure a Nerd Font is set in your terminal or the icon characters will render as boxes.

## Core Concepts

### bat: A cat Clone with Wings

bat is a drop-in replacement for `cat` that adds automatic syntax highlighting for over 200 languages, line numbers, git diff markers in the gutter, and pager integration. When piped to another command, bat detects the non-interactive context and behaves like plain `cat`, so it is safe to use in pipelines.

### eza: A Modern ls

eza replaces `ls` with a tool that understands git status, renders file-type icons via Nerd Font glyphs, and offers a built-in tree view. It uses colour by default and supports long-format output with human-readable sizes.

## Essential Commands -- bat

| Command | Purpose |
|---|---|
| `bat file.py` | Display file with syntax highlighting and line numbers |
| `bat -l json data.txt` | Force a specific language for highlighting |
| `bat --diff a.py b.py` | Show a side-by-side diff between two files |
| `bat -p file.py` | Plain mode -- no line numbers, no header, no grid |
| `bat -pp file.py` | Plain-plain mode -- also disables paging |
| `bat --list-themes` | Show all available colour themes with previews |
| `bat --list-languages` | Show all supported language syntaxes |
| `bat -A file.txt` | Show non-printable characters (tabs, newlines, etc.) |
| `bat --style=numbers file.py` | Show only line numbers, no header or grid |
| `bat --style=header,grid file.py` | Pick specific style components |
| `bat --paging=never file.py` | Disable the pager even in interactive mode |
| `bat --color=always file \| less -R` | Force colour when piping to a pager |
| `bat header.h src.c` | Concatenate and display multiple files |
| `bat --wrap=never file.log` | Disable line wrapping for wide content |

## Essential Commands -- eza

| Command | Purpose |
|---|---|
| `ls` | Basic file listing (aliased to `eza`) |
| `l` | Long listing with icons, git status, and hidden files |
| `lt` | Tree view, 2 levels deep, long format with icons and git |
| `ltree` | Tree view, 2 levels deep, icons and git (no long format) |
| `eza -l --sort=modified` | Long listing sorted by modification time |
| `eza -l --sort=size` | Long listing sorted by file size |
| `eza -l --sort=ext` | Long listing sorted by file extension |
| `eza --tree --level=3` | Tree view with deeper nesting |
| `eza -l --no-permissions` | Long listing without the permissions column |
| `eza -l --no-user` | Long listing without the user/group columns |
| `eza --git-ignore` | Respect `.gitignore` and hide ignored files |
| `eza -l --header` | Long listing with a column header row |
| `eza -1` | One file per line, no extra detail |
| `eza -l --time-style=relative` | Show times as "2 hours ago" instead of dates |
| `eza --group-directories-first` | List directories before files |

## Practical Recipes

### Preview files with fzf using bat

```bash
# fzf with bat as the preview window
fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'
```

### Quickly check git changes in a directory

```bash
# Long listing shows git status per file (M, N, -, etc.)
l
```

The git column in eza output shows single-letter codes: `M` for modified, `N` for new/untracked, `-` for unchanged. This gives you an instant overview without running `git status`.

### Use bat as a MANPAGER

```bash
# Export to use bat for man pages (alternative to your nvim approach)
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
```

Your current setup uses `nvim +Man!` as the MANPAGER, which provides its own syntax highlighting. If you prefer bat, the line above is the standard recipe.

### Coloured diff between two files

```bash
bat --diff config.old config.new
```

This highlights additions and deletions with colour, similar to `git diff` but for arbitrary files.

### Explore a project structure before diving in

```bash
# See the shape of a project, two levels deep
eza --tree --level=2 --icons --git ~/projects/my-app
```

This is exactly what the sesh `nvim config` session uses as its preview command to give a quick structural overview.

### Tail a log file with syntax highlighting

```bash
tail -f /var/log/system.log | bat --paging=never -l log
```

bat detects piped input and disables paging automatically, but `--paging=never` makes the intent explicit.

### Display all supported bat themes with a sample

```bash
bat --list-themes | head -20
# Preview a specific theme:
bat --theme="Catppuccin Mocha" file.py
```

## Advanced Usage

### bat Configuration File

bat reads defaults from `~/.config/bat/config`. You can set your preferred theme and style globally:

```
# ~/.config/bat/config
--theme="Catppuccin Mocha"
--style="numbers,changes,header"
--italic-text=always
```

With a config file in place, every `bat` (and therefore every `cat`) invocation inherits your preferences without extra flags.

### Building Custom bat Syntaxes

If you work with an uncommon file format, bat supports adding custom `.sublime-syntax` files:

```bash
mkdir -p "$(bat --config-dir)/syntaxes"
# Place .sublime-syntax files there, then rebuild the cache:
bat cache --build
```

### eza Colour and Icon Customization

eza reads the `EXA_COLORS` environment variable (legacy name) or `LS_COLORS` for file-type colouring. You can override specific extensions:

```bash
export EXA_COLORS="*.md=38;5;141:*.json=38;5;178"
```

### Combining bat and eza in Scripts

Because both tools detect non-interactive output and fall back to plain text, they are safe in shell scripts. To force colour output (for example, when piping through `less`), pass `--color=always`:

```bash
eza -l --color=always | less -R
bat --color=always file.py | head -50
```

### Using bat with git

bat integrates with git to show change markers in the gutter. Lines added since the last commit get a green `+`, modified lines get a yellow `~`, and deleted regions get a red marker. This works automatically in any git repository.

```bash
# See only the changes column in bat output
bat --diff --style=changes file.py
```

\newpage
