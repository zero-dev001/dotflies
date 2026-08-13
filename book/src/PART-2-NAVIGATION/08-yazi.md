# File Manager: Yazi

> A terminal file manager with Vim motions, image previews, and deep integration with fd, rg, fzf, and zoxide -- launched with a shell wrapper that syncs your working directory on exit.

## Your Setup

Yazi is launched via a shell wrapper function defined in `~/.aliases.zsh`:

```bash
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}
```

This wrapper writes the last working directory to a temp file on exit. When you quit Yazi with `q`, your shell `cd`s to wherever you navigated. Quitting with `Q` exits without syncing the directory.

Configuration lives in `~/.config/yazi/`:

- `yazi.toml` -- General settings (layout ratio 2:4:3, hidden files shown, alphabetical sort, directories first)
- `keymap.toml` -- All keybindings (Vim-style, heavily customized)
- `theme.toml` -- Color theme
- `package.toml` -- Plugin packages

The layout uses a three-pane view: parent directory (left, 2 parts), current directory (center, 4 parts), preview (right, 3 parts). Hidden files are shown by default. Sort is alphabetical, case-insensitive, with directories listed first.

## Core Concepts

### The Three-Pane Layout

Yazi displays three columns: the parent directory on the left, the current directory in the center, and a preview of the hovered file on the right. You navigate by moving the cursor in the center pane. Moving into a child directory shifts all panes left; moving to the parent shifts them right.

### Vim-Style Modes

Yazi uses modal navigation like Vim:

- **Normal mode**: Default state. Navigate, select, and operate on files.
- **Visual mode**: Enter with `v`. Move the cursor to extend a selection range.
- **Input mode**: Activated by commands like `a` (create), `r` (rename), `;` (shell). Has its own Vim-like normal/insert sub-modes.

### The Two Quit Commands

| Key | Action | Shell CWD |
|-----|--------|-----------|
| `q` | Quit Yazi | Shell changes to Yazi's last directory |
| `Q` | Quit without syncing | Shell stays in the directory it was before |

This distinction is critical. Use `q` when you navigated to a directory and want your shell to follow. Use `Q` when you were just browsing.

## Essential Commands

### Movement

| Key | Action |
|-----|--------|
| `j` | Next file (down) |
| `k` | Previous file (up) |
| `h` | Parent directory (left) |
| `l` | Enter directory / open file (right) |
| `Ctrl+U` | Half page up |
| `Ctrl+D` | Half page down |
| `Ctrl+B` | Full page up |
| `Ctrl+F` | Full page down |
| `gg` | Go to first file |
| `G` | Go to last file |
| `H` | Go back (directory history) |
| `L` | Go forward (directory history) |
| `K` | Seek preview up 5 lines |
| `J` | Seek preview down 5 lines |

### Selection

| Key | Action |
|-----|--------|
| `Space` | Toggle selection on current file, move down |
| `Ctrl+A` | Select all files |
| `Ctrl+R` | Invert selection |
| `v` | Enter visual mode (extend selection by moving) |
| `V` | Enter visual mode (unset mode) |
| `Esc` | Clear selection / exit visual mode |

### File Operations

| Key | Action |
|-----|--------|
| `o` | Open selected files |
| `O` | Open selected files (choose program interactively) |
| `Enter` | Open selected files |
| `y` | Yank (copy) selected files |
| `x` | Cut selected files |
| `p` | Paste yanked/cut files |
| `P` | Paste (overwrite if exists) |
| `Y` | Cancel yank |
| `X` | Cancel yank |
| `d` | Move to trash |
| `D` | Permanently delete |
| `a` | Create file or directory (append `/` for directory) |
| `r` | Rename (cursor before extension) |
| `-` | Create symlink (absolute path) |
| `_` | Create symlink (relative path) |

### Search and Find

| Key | Action |
|-----|--------|
| `s` | Search by filename via fd |
| `S` | Search by content via ripgrep |
| `Ctrl+S` | Cancel ongoing search |
| `z` | Jump to file/directory via fzf |
| `Z` | Jump to directory via zoxide |
| `f` | Filter current directory (live, narrows visible files) |
| `/` | Find next (highlight matches in current directory) |
| `?` | Find previous |
| `n` | Go to next match |
| `N` | Go to previous match |

The distinction between search, find, and filter:

- **Search** (`s`/`S`): Recursively searches the entire subtree using fd or rg. Results replace the file list.
- **Filter** (`f`): Narrows the current directory view in real time as you type. Does not recurse.
- **Find** (`/`/`?`): Highlights matching files in the current directory and jumps between them with `n`/`N`. Does not hide non-matches.

### Goto Shortcuts

| Key Sequence | Destination |
|-------------|-------------|
| `gh` | Home directory (`~`) |
| `gc` | Config directory (`~/.config`) |
| `gd` | Downloads directory (`~/Downloads`) |
| `g Space` | Interactive directory jump (cd prompt) |
| `gf` | Follow hovered symlink to its target |

### Tabs

| Key | Action |
|-----|--------|
| `t` | Create new tab at current directory |
| `1`-`9` | Switch to tab by number |
| `[` | Switch to previous tab |
| `]` | Switch to next tab |
| `{` | Swap current tab with previous |
| `}` | Swap current tab with next |
| `Ctrl+C` | Close current tab (or quit if last) |

### Copy Paths

| Key Sequence | What Is Copied |
|-------------|----------------|
| `cc` | Full file path |
| `cd` | Directory path (dirname) |
| `cf` | Filename with extension |
| `cn` | Filename without extension |

### Sorting

| Key Sequence | Sort By | Reverse |
|-------------|---------|---------|
| `,m` | Modified time | `,M` |
| `,b` | Birth/creation time | `,B` |
| `,s` | File size | `,S` |
| `,a` | Alphabetical | `,A` |
| `,n` | Natural order | `,N` |
| `,e` | Extension | `,E` |
| `,r` | Random | -- |

Sorting by time or size also sets the linemode to display that metadata alongside filenames.

### Linemode (Metadata Display)

| Key Sequence | Shows |
|-------------|-------|
| `ms` | File size |
| `mp` | Permissions |
| `mb` | Birth/creation time |
| `mm` | Modified time |
| `mo` | Owner |
| `mn` | None (reset) |

### Other

| Key | Action |
|-----|--------|
| `.` | Toggle hidden files |
| `;` | Run shell command (interactive) |
| `:` | Run shell command (blocking, waits for exit) |
| `Tab` | Spot (preview) the hovered file |
| `w` | Show task manager |
| `~` or `F1` | Open help |
| `Ctrl+Z` | Suspend Yazi (return to shell, `fg` to resume) |

## Practical Recipes

### Browse and land in a directory

```bash
y                    # Launch Yazi
# Navigate with h/j/k/l to the target directory
# Press q to quit -- your shell is now in that directory
```

### Quick file preview without opening

Navigate to any file. The right pane shows a preview automatically. For a larger preview, press `Tab` to open the spotter view. Yazi previews text files with syntax highlighting, images inline (in supported terminals like iTerm2), PDFs, archives, and more.

### Bulk rename files

1. Select files with `Space` (one by one) or `v` (visual range) or `Ctrl+A` (all).
2. Press `r` to rename. For a single file, this opens an inline rename prompt with the cursor positioned before the extension.

### Move files between directories using tabs

1. Press `t` to open a new tab.
2. Navigate to the destination directory in the new tab.
3. Press `[` to go back to the source tab.
4. Select files with `Space`.
5. Press `x` to cut (or `y` to copy).
6. Press `]` to go to the destination tab.
7. Press `p` to paste.

### Search for a file deep in the tree

Press `s` to search by filename (uses fd). Type part of the filename. The results replace the file list. Navigate to the desired file and press `Enter` to open it or `Ctrl+S` to cancel and return to the normal view.

### Search file contents

Press `S` to search by content (uses rg). Type a search pattern. Yazi shows files containing that pattern. This is useful when you know what a file contains but not its name.

### Jump to a frequently visited directory

Press `Z` to invoke zoxide. Type part of the directory name. Zoxide uses its frecency database to find the best match and jumps there.

### Jump using fzf

Press `z` to invoke the fzf plugin. This presents a fuzzy finder over the directory tree, letting you type to narrow down and jump to any file or directory.

### Filter the current directory

Press `f` and start typing. The file list narrows in real time to show only matching entries. This is useful in large directories when you know roughly what you are looking for. Press `Esc` to clear the filter.

### Run a shell command on selected files

1. Select files with `Space`.
2. Press `;` for an interactive shell prompt.
3. Type your command. Use `$@` to refer to selected files.

Or press `:` for a blocking command that shows output and waits for you to press Enter.

### Copy a file path to clipboard

Navigate to the target file, then press `cc`. The full path is now in your system clipboard, ready to paste into a terminal, editor, or chat.

### Check file sizes in a directory

Press `,s` to sort by size (largest first shows at bottom; use `,S` for reverse). The linemode automatically switches to show sizes next to each filename.

## Advanced Usage

### The Shell Wrapper in Detail

The `y()` function is essential for Yazi integration with the shell. Without it, Yazi runs as a subprocess and any directory changes inside it are lost when it exits. The wrapper:

1. Creates a temporary file for CWD communication.
2. Launches Yazi with `--cwd-file` pointing to that temp file.
3. On exit, reads the temp file to get Yazi's last directory.
4. If the directory is valid and different from the current one, `cd`s to it.
5. Cleans up the temp file.

The `builtin cd` call (not the zoxide-enhanced `cd`) is used intentionally to avoid adding the intermediate navigation to zoxide's database.

### Yazi's Search Tools

Yazi delegates search to external tools rather than implementing its own:

| Yazi Key | External Tool | What It Searches |
|----------|--------------|-----------------|
| `s` | fd | Filenames, recursively |
| `S` | rg (ripgrep) | File contents, recursively |
| `z` | fzf | Filenames, interactively |
| `Z` | zoxide | Directory frecency database |
| `f` | Built-in | Current directory only (live filter) |
| `/` | Built-in | Current directory only (highlight matches) |

This means Yazi benefits from the same tools you use on the command line, with the same speed and .gitignore awareness.

### Task Manager

Press `w` to open the task manager. Yazi runs file operations (copy, move, delete, search) as background tasks. In the task manager:

| Key | Action |
|-----|--------|
| `j`/`k` | Navigate tasks |
| `Enter` | Inspect task details |
| `x` | Cancel a task |
| `w` | Close task manager |

### Opener Configuration

Yazi opens files based on MIME type rules defined in `yazi.toml`. The default opener for text files uses `$EDITOR` (Neovim in this setup). Images open with the system default (`open` on macOS), media files play with the default player, and archives can be extracted.

You can press `O` (capital) to choose from available openers interactively rather than using the default.

### Spot Mode

Press `Tab` to enter spot mode for the hovered file. This opens an expanded preview where you can scroll through the file content. In spot mode:

| Key | Action |
|-----|--------|
| `j`/`k` | Scroll content up/down |
| `h`/`l` | Swipe to previous/next file |
| `Tab` | Close spot mode |
| `cc` | Copy selected cell content |

### Input Mode (Rename, Create, Shell)

When you press `a` (create), `r` (rename), or `;`/`:` (shell), Yazi enters input mode with Vim keybindings:

| Key | Action |
|-----|--------|
| `i` | Enter insert mode |
| `a` | Enter append mode |
| `Esc` | Back to normal mode or cancel |
| `Enter` | Submit input |
| `Ctrl+C` | Cancel |
| `h`/`l` | Move cursor left/right |
| `w`/`b` | Move by word forward/backward |
| `0`/`$` | Move to beginning/end of line |
| `d` | Cut selection |
| `y` | Copy selection |
| `p`/`P` | Paste after/before cursor |
| `u` | Undo |
| `Ctrl+R` | Redo |

### Configuration Highlights

From `yazi.toml`, notable settings in this setup:

| Setting | Value | Meaning |
|---------|-------|---------|
| `ratio` | `[2, 4, 3]` | Column widths: parent 2, current 4, preview 3 |
| `show_hidden` | `true` | Hidden files visible by default |
| `sort_by` | `alphabetical` | Default sort order |
| `sort_dir_first` | `true` | Directories appear before files |
| `scrolloff` | `5` | Keep 5 lines visible above/below cursor |
| `title_format` | `Yazi: {cwd}` | Window title shows current directory |

\newpage
