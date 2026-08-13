# Git TUI: lazygit

> A full terminal interface for git that makes staging hunks, interactive rebasing, and conflict resolution visual and fast.

## Your Setup

Lazygit is installed from the jesseduffield/lazygit Homebrew tap:

```bash
brew install jesseduffield/lazygit/lazygit
```

Launch it from any git repository:

```bash
lazygit
```

Lazygit renders a multi-panel terminal interface that replaces the need to memorize dozens of git commands. It integrates with delta for diff rendering, inheriting the Catppuccin Mocha color palette from the terminal.

There is no separate lazygit configuration file in this setup -- it uses sensible defaults and picks up delta as the diff pager from gitconfig. The diff3 merge conflict style configured in gitconfig carries through to lazygit's conflict resolution view.

## Core Concepts

### The Five Panels

Lazygit divides the terminal into five panels, each accessible by number key or by tabbing between them:

| Panel | Key | Contents |
|-------|-----|----------|
| Status | `1` | Current branch, repo name, recent commit |
| Files | `2` | Working tree changes (staged and unstaged) |
| Branches | `3` | Local and remote branches |
| Commits | `4` | Commit history for the current branch |
| Stash | `5` | Stashed changes |

The active panel is highlighted. The right side of the screen shows a context-sensitive detail view -- if you are in the Files panel, it shows the diff for the selected file. If you are in the Commits panel, it shows the diff for the selected commit.

### Staging Model

Lazygit distinguishes between three states for changes:

- **Unstaged** -- the file appears in red in the Files panel.
- **Staged** -- the file appears in green.
- **Partially staged** -- some hunks are staged, others are not. The file appears with a mixed indicator.

You can stage entire files, individual hunks, or even individual lines within a hunk. This granular control is one of lazygit's greatest strengths -- it replaces the cumbersome `git add -p` workflow with a visual interface.

### Navigation Philosophy

Lazygit follows vim-inspired navigation:

- `j` and `k` move up and down within a panel.
- `h` and `l` (or panel numbers) switch between panels.
- `Enter` opens a detail view or expands the current item.
- `q` quits or goes back one level.
- `?` shows context-sensitive help for the current panel.

## Essential Commands

### Global Keys

| Key | Action |
|-----|--------|
| `1`-`5` | Switch to panel by number |
| `q` | Quit lazygit (or go back one level) |
| `?` | Show help for current panel |
| `/` | Filter the current panel's list |
| `Enter` | View detail / expand |
| `[` / `]` | Switch tabs within a panel |
| `@` | Open command log (see every git command lazygit runs) |
| `+` | Toggle view (expand/collapse detail pane) |
| `R` | Refresh |

### Files Panel

| Key | Action |
|-----|--------|
| `Space` | Stage or unstage the selected file |
| `a` | Stage all files / unstage all files (toggle) |
| `c` | Commit staged changes |
| `A` | Amend the last commit |
| `d` | Discard changes in the selected file |
| `D` | Open discard options (unstaged, all, etc.) |
| `e` | Open file in editor |
| `o` | Open file in default application |
| `i` | Add to .gitignore |
| `S` | Stash all changes |
| `Enter` | View individual hunks for staging |

### Inside a File (Hunk View)

| Key | Action |
|-----|--------|
| `Space` | Stage or unstage the selected hunk |
| `v` | Toggle line-by-line selection mode |
| `a` | Stage or unstage all hunks in the file |
| `j` / `k` | Move between hunks |
| `Esc` | Return to the files list |

### Branches Panel

| Key | Action |
|-----|--------|
| `n` | Create a new branch |
| `Space` | Checkout the selected branch |
| `d` | Delete the selected branch |
| `r` | Rebase current branch onto selected |
| `M` | Merge selected branch into current |
| `f` | Fetch |
| `Enter` | View commits on the selected branch |

### Commits Panel

| Key | Action |
|-----|--------|
| `s` | Squash the selected commit into the one above it |
| `r` | Reword the selected commit message |
| `d` | Drop the selected commit |
| `e` | Edit the selected commit (interactive rebase) |
| `p` | Pick (keep) during rebase |
| `f` | Fixup (squash without changing message) |
| `Enter` | View the full diff of the selected commit |
| `y` | Copy commit hash to clipboard |
| `g` | Reset options (soft, mixed, hard) |
| `t` | Create a tag on the selected commit |

### Push and Pull

| Key | Action |
|-----|--------|
| `p` | Push to remote |
| `P` | Pull from remote |
| `shift+p` | Push with options (force push shows a confirmation) |

### Stash Panel

| Key | Action |
|-----|--------|
| `Space` | Apply the selected stash |
| `g` | Pop the selected stash (apply and delete) |
| `d` | Drop the selected stash |
| `n` | Create a new stash with a custom name |
| `Enter` | View stash contents |

## Practical Recipes

### Stage specific hunks from a file

1. Navigate to the Files panel (`2`).
2. Select the file with `j`/`k`.
3. Press `Enter` to view hunks.
4. Move between hunks with `j`/`k`.
5. Press `Space` to stage individual hunks.
6. Press `Esc` to return to the file list.
7. Press `c` to commit only the staged hunks.

This replaces `git add -p` with a visual interface that shows you exactly what you are staging.

### Stage specific lines within a hunk

1. Enter hunk view as above.
2. Press `v` to enter line-by-line selection mode.
3. Use `j`/`k` to select individual lines.
4. Press `Space` to stage the selected lines.

This level of granularity is nearly impossible to achieve with command-line git.

### Interactive rebase to clean history

1. Navigate to the Commits panel (`4`).
2. Move to the oldest commit you want to modify.
3. Press `e` to start an interactive rebase from that point.
4. For each commit, use the appropriate key:
   - `s` to squash into the commit above
   - `r` to reword the message
   - `d` to drop
   - `f` to fixup (squash without message)
   - `p` to pick (keep as-is)
5. Lazygit applies the rebase in real time.

This is dramatically easier than the text editor-based `git rebase -i` because you see the result of each operation immediately.

### Resolve merge conflicts

1. After a merge or rebase that produces conflicts, lazygit shows conflicted files in the Files panel.
2. Select a conflicted file and press `Enter`.
3. The conflict view shows the diff3 sections (ours, base, theirs) when `conflictstyle = diff3` is set.
4. Navigate between conflict markers with `j`/`k`.
5. Choose a resolution:
   - `b` to choose the "base" version
   - `j`/`k` to select specific sections
   - Press the displayed key to pick a side
6. After resolving all conflicts in a file, it is automatically staged.
7. Continue the rebase/merge from the Status panel.

### Cherry-pick a commit from another branch

1. Navigate to the Branches panel (`3`).
2. Select the source branch and press `Enter` to view its commits.
3. Select the commit you want and press `c` to copy it (cherry-pick).
4. Return to your branch.
5. Press `v` to paste (apply the cherry-picked commit).

### Compare two branches visually

1. Go to the Branches panel (`3`).
2. Select the branch you want to compare against.
3. Press `Enter` to see its commits.
4. The diff view on the right shows each commit's changes, rendered through delta.

### Undo a commit (soft reset)

1. Navigate to the Commits panel (`4`).
2. Select the commit before the one you want to undo.
3. Press `g` to open reset options.
4. Choose "soft" to undo the commit but keep changes staged.

### Force push safely

After an interactive rebase or amend, you need to force push:

1. Press `p` to push.
2. Lazygit detects the divergence and asks for confirmation.
3. Confirm to force push with lease (which prevents overwriting someone else's commits).

## Advanced Usage

### The Command Log

Press `@` to open the command log. This shows every git command that lazygit executed on your behalf. This is invaluable for:

- **Learning git** -- see the actual commands behind the UI actions.
- **Debugging** -- if something went wrong, check what commands ran.
- **Reproducibility** -- copy commands to use in scripts or documentation.

### Delta Integration

Lazygit automatically uses delta when it is configured as the git pager. This means all diffs shown in the detail pane on the right side of the screen render with:

- Syntax highlighting in Catppuccin Mocha colors.
- Line numbers.
- Side-by-side layout (when the terminal is wide enough).

The diff3 conflict style also carries through, showing three-way conflicts in the merge resolution view.

### Lazygit in Neovim

Many developers launch lazygit from within Neovim using a floating terminal plugin. In this setup, you can open a terminal pane in tmux (or use Neovim's built-in terminal) and run `lazygit` from there. The vim-style keybindings mean the muscle memory transfers seamlessly.

### Custom Keybindings

Lazygit's keybindings can be customized in `~/.config/lazygit/config.yml`. While this setup uses defaults, common customizations include:

```yaml
keybinding:
  universal:
    quit: 'q'
    return: '<esc>'
  files:
    commitChanges: 'c'
```

### Filtering and Searching

Press `/` in any panel to filter the list:

- In the Files panel, filter by filename.
- In the Branches panel, filter by branch name.
- In the Commits panel, filter by commit message.

This is essential in large repositories with many branches or long commit histories.

### Performance on Large Repositories

Lazygit loads git data incrementally, so it starts fast even in repositories with thousands of commits. However, the initial load of the commit graph can take a moment. The Files panel loads almost instantly because it only reads the working tree status.

\newpage
