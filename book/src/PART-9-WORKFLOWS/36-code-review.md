# Workflow: Code Review

> Pull request review from the terminal -- checkout, read, understand, and respond without leaving the keyboard.

---

## Overview

Code review in this environment happens entirely in the terminal. The GitHub CLI checks out pull requests, delta provides syntax-highlighted diffs with Catppuccin colors, Neovim enables deep code exploration, and lazygit offers a visual interface for navigating commits. The review is submitted back through the GitHub CLI without ever opening a browser.

This workflow is faster than browser-based review for most cases. The terminal tools provide better navigation (vim motions, fuzzy finding), better diffs (delta's side-by-side view with word-level highlighting), and better context (jump-to-definition, grep across the codebase).

---

## Step 1: Checkout the Pull Request

Start by listing open pull requests:

```bash
gh pr list
```

This shows all open PRs with their numbers, titles, branches, and authors. To check out a specific PR:

```bash
gh pr checkout 42
```

This command does several things:

1. Fetches the PR branch from the remote
2. Creates a local branch tracking the remote PR branch
3. Switches to that branch

You are now on the PR branch with all its changes available locally.

To see a summary of the PR before diving into code:

```bash
gh pr view 42
```

This prints the PR title, body, labels, reviewers, and status checks.

---

## Step 2: View the Overall Diff

Get a high-level view of what changed:

```bash
git diff main...HEAD
```

The three-dot syntax (`main...HEAD`) shows only the changes introduced by the PR branch, excluding any changes on main that happened after the branch point. This is the correct diff for reviewing a PR.

Because git-delta is configured as the default pager, this diff renders with:

- Syntax highlighting in the Catppuccin Mocha palette
- Line numbers on both sides
- Word-level diff highlighting (changed words within a line are emphasized)
- File headers with clear separation

For a summary of which files changed:

```bash
git diff main...HEAD --stat
```

This shows each changed file with insertion/deletion counts, giving you a map of the PR's scope before reading any code.

---

## Step 3: Read the Diff with Delta

Delta is the syntax-highlighting pager configured for all git diff output. It transforms raw diffs into something readable.

Key delta features active in this configuration:

| Feature                  | Effect                                         |
|--------------------------|-------------------------------------------------|
| Catppuccin Mocha theme   | Colors match the rest of the environment        |
| Side-by-side mode        | Old and new versions shown in parallel columns  |
| Line numbers             | Both old and new line numbers visible           |
| Word-level highlighting  | Changed words within a line are underlined      |
| Navigate mode            | Press `n`/`N` in the pager to jump between files|

When viewing a large diff, use delta's navigation in the pager (less):

| Key       | Action                                           |
|-----------|--------------------------------------------------|
| `n`       | Jump to the next file in the diff                |
| `N`       | Jump to the previous file in the diff            |
| `/pattern`| Search for a pattern in the diff                 |
| `q`       | Quit the pager                                   |
| `g`       | Go to the top of the diff                        |
| `G`       | Go to the bottom of the diff                     |

For an interactive, navigable diff experience, use diffnav:

```bash
git diff main...HEAD | diffnav
```

diffnav provides a file list on the left and the diff on the right, with keyboard navigation between files.

---

## Step 4: Explore the Code in Neovim

For deeper understanding, open Neovim in the project:

```bash
nvim .
```

Or if the IDE layout is already running, switch to the Neovim pane with `Ctrl+l` or `Ctrl+k` (vim-tmux-navigator).

### Finding Changed Code

| Key           | Action                                          |
|---------------|-------------------------------------------------|
| `Space+ff`    | Find files by name                              |
| `Space+fg`    | Grep for text across the project                |
| `Space+sg`    | Search with live grep (results update as you type) |
| `Space+sw`    | Search for the word under cursor                |

### Understanding Code

| Key           | Action                                          |
|---------------|-------------------------------------------------|
| `gd`          | Go to definition of symbol under cursor         |
| `gr`          | Find all references to symbol under cursor      |
| `K`           | Show hover documentation                        |
| `Space+ca`    | Code actions (quick fixes, refactors)           |
| `Space+cd`    | Line diagnostics (errors, warnings)             |
| `[d` / `]d`   | Jump to previous/next diagnostic                |

### Reviewing Specific Changes

To see the git diff for the current file inside Neovim, the Gitsigns plugin shows added, modified, and deleted lines in the gutter. Use:

| Key           | Action                                          |
|---------------|-------------------------------------------------|
| `]c`          | Jump to next changed hunk                       |
| `[c`          | Jump to previous changed hunk                   |

---

## Step 5: Explore Commits in Lazygit

For PRs with many commits, lazygit provides a visual commit history:

```bash
lazygit
```

In lazygit, navigate to the commits panel to see each commit in the PR. Key navigation:

| Key       | Action                                            |
|-----------|---------------------------------------------------|
| `j`/`k`   | Move down/up in the commit list                  |
| `Enter`   | View the diff for the selected commit            |
| `w`       | Toggle diff options (whitespace, context lines)  |
| `h`/`l`   | Switch between panels (files, commits, branches) |
| `q`       | Quit lazygit                                     |

This is especially useful for understanding the evolution of a PR. You can step through commits one at a time to see how the author built the feature.

---

## Step 6: Submit the Review

Once you have formed an opinion, submit the review through the GitHub CLI.

### Approve

```bash
gh pr review 42 --approve --body "Looks good. Clean implementation."
```

### Request Changes

```bash
gh pr review 42 --request-changes --body "The error handling in auth.ts needs a try-catch around the API call. See inline comments."
```

### Comment Only

```bash
gh pr review 42 --comment --body "A few questions about the approach."
```

### Adding Inline Comments

For file-specific comments, use the GitHub CLI API directly:

```bash
gh api repos/OWNER/REPO/pulls/42/comments \
  --method POST \
  -f body="This function could be simplified with a reduce." \
  -f path="src/utils/transform.ts" \
  -F line=25 \
  -f side="RIGHT" \
  -f commit_id="$(git rev-parse HEAD)"
```

For most reviews, the overall comment is sufficient. Inline comments are reserved for specific line-level feedback.

---

## Step 7: Merge When Approved

If you are the one merging after approval:

```bash
gh pr merge 42
```

This presents an interactive prompt asking which merge strategy to use:

- **Create a merge commit** -- preserves all commits
- **Rebase and merge** -- linear history, replays commits
- **Squash and merge** -- condenses to a single commit

Or specify directly:

```bash
gh pr merge 42 --squash --delete-branch
```

The `--delete-branch` flag cleans up the remote branch after merging.

---

## Reviewing Multiple PRs

For teams with many open PRs, the `gh dash` extension (installed via chezmoi's run-once script) provides a dashboard view:

```bash
gh dash
```

This shows a TUI with sections for PRs you authored, PRs assigned to you, and PRs requesting your review. You can select a PR and jump directly to checkout or review.

---

## The Full Sequence

A complete code review flow:

```bash
# 1. See what needs review
gh pr list

# 2. Read the PR description
gh pr view 42

# 3. Check out the code
gh pr checkout 42

# 4. View the full diff
git diff main...HEAD

# 5. Check file-by-file with stats
git diff main...HEAD --stat

# 6. Open Neovim for deep exploration
nvim .
# Use Space+fg to grep, gd to jump to definitions

# 7. Use lazygit for commit-by-commit review
lazygit

# 8. Submit the review
gh pr review 42 --approve --body "Ship it."

# 9. Merge if ready
gh pr merge 42 --squash --delete-branch

# 10. Return to main
git checkout main && git pull
```

---

## Troubleshooting

| Problem                              | Solution                                      |
|--------------------------------------|-----------------------------------------------|
| `gh pr checkout` fails               | Run `gh auth login` to authenticate           |
| Delta not showing colors             | Check `~/.gitconfig` for `[core] pager = delta` |
| Neovim LSP not working on PR branch  | Run `npm install` or `bun install` first      |
| `git diff main...HEAD` shows nothing | Check branch name: might be `master` not `main` |
| PR has merge conflicts               | Resolve in Neovim, then `git add` and commit  |

\newpage
