# Git Workflow

> A rebase-centric workflow backed by delta diffs, Oh My Zsh aliases, and an automatic rsync backup on every commit.

## Your Setup

Git is configured in `~/.gitconfig` (chezmoi source: `dot_gitconfig`):

```ini
[user]
    name = zero-dev001
    email = 316405743+zero-dev001@users.noreply.github.com
[core]
    editor = vi
    hooksPath = ~/.githooks
    excludesfile = ~/.gitignore
    pager = delta
[init]
    defaultBranch = main
[interactive]
    diffFilter = delta --color-only
[delta]
    navigate = true
    dark = true
    side-by-side = true
    line-numbers = true
    syntax-theme = Catppuccin Mocha
[merge]
    conflictstyle = diff3
[diff]
    colorMoved = default
```

Key decisions encoded in this configuration:

- **vi as editor** -- commit messages open in vi, not Neovim, keeping git operations lightweight and fast.
- **Custom hooks path** -- all git hooks live in `~/.githooks/`, managed by chezmoi, so every repository on the machine shares the same post-commit backup behavior.
- **Global excludes** -- `~/.gitignore` contains patterns for macOS (`.DS_Store`), editors (`.swp`, `.swo`), and environment files (`.env`) so they never appear in any repository's untracked files.
- **Delta as pager** -- every git command that pages output (diff, log, show, blame) renders through delta with side-by-side Catppuccin-colored syntax highlighting.
- **diff3 conflict style** -- merge conflicts show three sections (ours, base, theirs) instead of two, making it clear what the original code looked like before either branch changed it.
- **colorMoved** -- when lines are moved rather than changed, git highlights them differently so you can distinguish a genuine edit from a reorganization.

Oh My Zsh's `git` plugin is loaded in `~/.zshrc`, providing a comprehensive set of aliases that form the muscle memory for daily git operations.

## Core Concepts

### The Commit Cycle

Every change follows the same four-step loop: check status, stage changes, commit, push. The Oh My Zsh aliases compress this into single commands.

### Branching Model

This setup uses a simple branching model:

- `main` is the default branch and the source of truth.
- Feature branches are created from `main`, named descriptively (e.g., `feat/add-search`, `fix/login-timeout`).
- Branches are rebased onto `main` before merging to keep a linear history.
- Branches are deleted after merge.

### The diff3 Conflict Style

Standard git conflicts show two sections:

```
<<<<<<< HEAD
our changes
=======
their changes
>>>>>>> feature-branch
```

With `conflictstyle = diff3`, you see three:

```
<<<<<<< HEAD
our changes
||||||| parent of abc1234
the original code before either branch touched it
=======
their changes
>>>>>>> feature-branch
```

The middle section is the common ancestor. This tells you what each side intended to change, making conflict resolution dramatically easier. Without it, you are guessing what the original looked like.

### The Post-Commit Backup Hook

Every repository on the machine triggers a post-commit hook defined in `~/.githooks/post-commit`. This hook runs an rsync backup of the project source directory to a configurable destination:

```bash
RSYNC_FLAGS=(-a -h --exclude=.git/ '--filter=:- .gitignore'
             "--exclude-from=$HOME/.gitignore" --delete)
```

The hook respects both the repository's `.gitignore` and the global `~/.gitignore`, so only tracked and meaningful files are backed up. It can run synchronously (default) or asynchronously (`ASYNC=1`). The backup log is written to `~/.githook_backup.log`.

This means every commit creates a point-in-time snapshot of your project in a separate location, independent of git. If the git repository is corrupted or deleted, you have a clean rsync copy.

## Essential Commands

### Daily Workflow (Oh My Zsh Aliases)

| Alias | Expands To | Action |
|-------|------------|--------|
| `gst` | `git status` | Show working tree status |
| `ga` | `git add` | Stage specific files |
| `gaa` | `git add --all` | Stage all changes |
| `gc` | `git commit --verbose` | Commit with diff shown in editor |
| `gcam` | `git commit -a -m` | Stage all and commit with message |
| `gp` | `git push` | Push to remote |
| `gl` | `git pull` | Pull from remote |
| `gf` | `git fetch` | Fetch from remote |

### Branching

| Alias | Expands To | Action |
|-------|------------|--------|
| `gco` | `git checkout` | Switch branches |
| `gcb` | `git checkout -b` | Create and switch to new branch |
| `gb` | `git branch` | List branches |
| `gbd` | `git branch -d` | Delete a branch (safe) |
| `gm` | `git merge` | Merge a branch |

### Viewing History

| Alias | Expands To | Action |
|-------|------------|--------|
| `glo` | `git log --oneline --decorate` | Compact log |
| `glg` | `git log --stat` | Log with file change stats |
| `gd` | `git diff` | Diff unstaged changes |
| `gds` | `git diff --staged` | Diff staged changes |

### Stashing

| Alias | Expands To | Action |
|-------|------------|--------|
| `gsta` | `git stash push` | Stash current changes |
| `gstp` | `git stash pop` | Apply and remove top stash |

## Practical Recipes

### Start a feature branch

```bash
gco main          # Switch to main
gl                 # Pull latest changes
gcb feat/new-thing # Create and switch to feature branch
```

### The full commit cycle

```bash
gst                # Check what changed
gd                 # Review unstaged diffs (renders in delta, side-by-side)
ga src/app.ts      # Stage specific files
gds                # Review staged diffs before committing
gc                 # Commit (opens vi for message)
gp                 # Push to remote
```

### Quick commit everything

```bash
gcam "fix: resolve timeout in auth flow"
gp
```

This stages all changes and commits with a message in one command. Use this for small, self-contained fixes. Avoid it for large changes where you want to review what you are staging.

### Stash work in progress

```bash
gsta               # Stash current changes
gco main           # Switch to main for a hotfix
# ... do the hotfix ...
gco feat/my-thing  # Return to feature branch
gstp               # Pop the stash
```

### Rebase onto main

```bash
gco main           # Switch to main
gl                 # Pull latest
gco feat/my-thing  # Back to feature branch
git rebase main    # Rebase onto latest main
```

If conflicts arise during rebase, the diff3 style shows three-way context. Fix each conflict, then:

```bash
ga .                      # Stage resolved files
git rebase --continue     # Continue the rebase
```

To abort a rebase that has gone wrong:

```bash
git rebase --abort
```

### Resolve a merge conflict with diff3

When you see a diff3 conflict block:

1. Read the middle section (`||||||| parent`) to understand the original code.
2. Read the top section (`<<<<<<< HEAD`) to understand your changes relative to the original.
3. Read the bottom section (`>>>>>>> branch`) to understand their changes relative to the original.
4. Write the correct resolution that incorporates both intents.
5. Remove all conflict markers.
6. Stage and continue.

This is categorically easier than two-way conflicts because you can see what each side was trying to do.

### Interactive rebase to clean up commits

Before merging a feature branch, clean up the commit history:

```bash
git rebase -i main
```

This opens vi with a list of commits. Common operations:

- `pick` -- keep the commit as-is
- `squash` -- combine with the previous commit
- `reword` -- change the commit message
- `drop` -- remove the commit entirely

### View a specific file's history

```bash
git log --follow -p -- src/utils.ts
```

This shows every commit that touched the file, with full diffs rendered through delta. The `--follow` flag tracks the file across renames.

### Blame with delta coloring

```bash
git blame src/app.ts
```

Because delta is the pager, blame output is syntax-highlighted and easier to read than default git blame.

## Advanced Usage

### The Post-Commit Hook in Detail

The post-commit hook at `~/.githooks/post-commit` is a chezmoi template (`executable_post-commit.tmpl`). It uses chezmoi template variables to set the source and destination paths:

```bash
SRC="${SRC:-$HOME/<projectSrcPath>}"
DEST="${DEST:-$HOME/<backupDestPath>}"
```

These paths are resolved from chezmoi's data file at apply time, so different machines can back up to different locations. The hook:

1. Creates the destination directory if it does not exist.
2. Runs rsync with archive mode, excluding `.git/`, respecting `.gitignore` filters, and deleting files from the destination that no longer exist in the source.
3. Logs all output to `~/.githook_backup.log`.

To run asynchronously (for large repos where you do not want to wait):

```bash
ASYNC=1 git commit -m "large change"
```

### Overriding the Hook Per-Repository

If a specific repository should not trigger the backup, override the hooks path:

```bash
git config --local core.hooksPath .githooks
```

This points that repository to its own hooks directory, bypassing the global one.

### colorMoved and Code Refactoring

The `diff.colorMoved = default` setting changes how git renders diffs when lines are moved rather than modified. Moved lines appear in a distinct color (dimmed text) rather than showing as a deletion and an addition. This is invaluable during refactoring -- when you move a function from one file to another, the diff clearly shows it was moved, not rewritten.

### Combining Aliases for Complex Workflows

Oh My Zsh aliases compose naturally with standard git arguments:

```bash
glo --all --graph       # Decorated graph log across all branches
gd --stat               # Diff summary showing files changed
gb -a                   # List all branches including remotes
gbd -D feature/old      # Force-delete a branch (uppercase D)
```

### Excluding Files Globally

The global `~/.gitignore` referenced by `core.excludesfile` contains patterns that should never be tracked in any repository:

```
.DS_Store
*.swp
*.swo
.env
.env.local
node_modules/
.idea/
.vscode/
```

This keeps repository-level `.gitignore` files focused on project-specific patterns.

### Safe Directory for Homebrew

The `safe.directory = /opt/homebrew` setting tells git to trust the Homebrew installation directory. Without this, git operations in `/opt/homebrew` fail with an ownership warning because the directory is often owned by a different user or group.

\newpage
