# GitHub CLI and gh-dash

> Manage pull requests, issues, and CI runs without leaving the terminal, plus a TUI dashboard that brings your GitHub world into a single view.

## Your Setup

The GitHub CLI is installed via Homebrew:

```bash
brew install gh
```

After installation, authentication is handled with:

```bash
gh auth login
```

This stores credentials in the system keychain. Once authenticated, every `gh` command operates against the GitHub API without requiring personal access tokens in environment variables.

The `gh-dash` extension is installed as a TUI dashboard:

```bash
gh extension install dlvhdr/gh-dash
```

Both tools work with the git identity configured in `~/.gitconfig`:

```ini
[user]
    name = zero-dev001
    email = 316405743+zero-dev001@users.noreply.github.com
```

## Core Concepts

### What gh Replaces

Before the GitHub CLI, interacting with GitHub required switching to a browser. Creating a pull request meant opening github.com, navigating to the repository, clicking "New pull request," filling out a form, and clicking "Create." Reviewing CI status meant refreshing a browser tab.

With `gh`, all of these operations happen in the terminal:

- Create, view, and merge pull requests.
- Create and manage issues.
- Monitor GitHub Actions runs.
- Browse repository pages.
- Clone repositories by name (no URL needed).

### The gh Extension System

GitHub CLI supports extensions -- community-built plugins that add new subcommands. Extensions are installed with `gh extension install` and invoked as `gh <extension-name>`. The `gh-dash` extension adds a `gh dash` command that launches a full TUI dashboard.

### gh-dash: The Dashboard

`gh dash` renders a terminal user interface with multiple sections:

- **Pull Requests** -- PRs you authored, PRs assigned to you, PRs requesting your review.
- **Issues** -- Issues you created, issues assigned to you.
- **Configurable sections** -- custom queries for any GitHub search filter.

The dashboard refreshes periodically, giving you a live view of your GitHub activity without opening a browser.

## Essential Commands

### Pull Request Workflow

| Command | Action |
|---------|--------|
| `gh pr create` | Create a PR from the current branch |
| `gh pr create --fill` | Create a PR, auto-filling title and body from commits |
| `gh pr create --draft` | Create a draft PR |
| `gh pr create --title "..." --body "..."` | Create with explicit title and body |
| `gh pr list` | List open PRs in the current repo |
| `gh pr list --author @me` | List your open PRs |
| `gh pr list --state merged` | List merged PRs |
| `gh pr view` | View the current branch's PR |
| `gh pr view 42` | View PR number 42 |
| `gh pr view --web` | Open the PR in the browser |
| `gh pr checkout 42` | Check out PR number 42 locally |
| `gh pr merge` | Merge the current branch's PR |
| `gh pr merge --squash` | Squash merge |
| `gh pr merge --rebase` | Rebase merge |
| `gh pr merge --delete-branch` | Merge and delete the branch |
| `gh pr review` | Start a review on the current PR |
| `gh pr review --approve` | Approve the PR |
| `gh pr review --request-changes -b "..."` | Request changes with a comment |
| `gh pr diff` | View the PR diff (rendered through delta) |
| `gh pr checks` | View CI check status for the PR |

### Issue Workflow

| Command | Action |
|---------|--------|
| `gh issue create` | Create an issue interactively |
| `gh issue create --title "..." --body "..."` | Create with explicit title and body |
| `gh issue create --label bug` | Create with a label |
| `gh issue list` | List open issues |
| `gh issue list --assignee @me` | List your assigned issues |
| `gh issue list --label "priority:high"` | Filter by label |
| `gh issue view 42` | View issue number 42 |
| `gh issue view 42 --web` | Open in browser |
| `gh issue close 42` | Close an issue |
| `gh issue reopen 42` | Reopen a closed issue |
| `gh issue comment 42 --body "..."` | Add a comment |

### Repository Operations

| Command | Action |
|---------|--------|
| `gh repo clone owner/repo` | Clone a repository by name |
| `gh repo clone repo` | Clone from your own account |
| `gh repo view` | View current repo info |
| `gh repo view --web` | Open repo in browser |
| `gh repo fork` | Fork the current repo |
| `gh browse` | Open the repo in the browser |
| `gh browse --settings` | Open repo settings |
| `gh browse path/to/file` | Open a specific file on GitHub |

### GitHub Actions

| Command | Action |
|---------|--------|
| `gh run list` | List recent workflow runs |
| `gh run view` | View the most recent run |
| `gh run view 12345` | View a specific run |
| `gh run view --log` | View full run logs |
| `gh run watch` | Watch a run in progress (live updates) |
| `gh run rerun 12345` | Re-run a failed workflow |
| `gh run rerun 12345 --failed` | Re-run only the failed jobs |

### gh-dash Keys

| Key | Action |
|-----|--------|
| `j` / `k` | Move down / up |
| `Enter` | View the selected PR or issue |
| `o` | Open in browser |
| `d` | View diff |
| `c` | Checkout the PR |
| `m` | Merge the PR |
| `/` | Search / filter |
| `s` | Switch section (PRs, Issues, custom) |
| `r` | Refresh the dashboard |
| `?` | Show help |
| `q` | Quit |

## Practical Recipes

### Create a PR from a feature branch

```bash
gco main && gl                    # Update main
gcb feat/add-search               # Create feature branch
# ... make changes, commit ...
gp -u origin feat/add-search      # Push with upstream tracking
gh pr create --fill                # Create PR with auto-filled title/body
```

The `--fill` flag uses the commit messages from the branch to populate the PR title and body. For a single-commit branch, this is usually perfect. For multi-commit branches, you may want to write a custom body:

```bash
gh pr create --title "Add search functionality" --body "Implements full-text search.

## Changes
- Added search endpoint
- Added search component
- Added tests

## Testing
Run \`npm test\` to verify."
```

### Review and merge a teammate's PR

```bash
gh pr list                         # See open PRs
gh pr checkout 42                  # Check out PR 42 locally
gh pr diff 42                      # View the diff (via delta)
# ... test locally ...
gh pr review --approve             # Approve the PR
gh pr merge --squash --delete-branch  # Squash merge and clean up
```

### Monitor a CI run

```bash
gh pr checks                       # Quick status of checks
gh run watch                       # Live output of the running workflow
```

The `watch` command refreshes every few seconds, showing job progress in real time. When the run completes, it exits with the appropriate exit code (0 for success, 1 for failure).

### Create an issue from the terminal

```bash
gh issue create --title "Login timeout too short" \
  --body "Users with slow connections hit the 5s timeout." \
  --label bug --label "priority:high" \
  --assignee zero-dev001
```

### Quick open in browser

When you need the browser for something gh cannot do (like configuring branch protection rules):

```bash
gh browse                          # Opens repo
gh browse --settings               # Opens settings
gh pr view --web                   # Opens current PR
gh issue view 42 --web             # Opens issue 42
```

### Clone a repo by name

```bash
gh repo clone zero-dev001/my-project   # Full path
gh repo clone my-project              # From your own account
```

No need to construct a full git URL. gh resolves the repository and clones it.

### Search for a PR

```bash
gh pr list --search "fix auth"     # Search by text
gh pr list --state all             # Include closed/merged
gh pr list --head feat/my-branch   # Find PR for a specific branch
```

### View another repo's PRs

```bash
gh pr list --repo owner/repo
gh pr view 42 --repo owner/repo
```

You do not need to be inside the repo directory.

## Advanced Usage

### gh API for Custom Queries

The `gh api` command provides direct access to the GitHub REST and GraphQL APIs:

```bash
# Get PR comments
gh api repos/owner/repo/pulls/42/comments

# Get your notifications
gh api notifications

# GraphQL query
gh api graphql -f query='
  query {
    viewer {
      pullRequests(first: 10, states: OPEN) {
        nodes {
          title
          url
        }
      }
    }
  }
'
```

This is useful for automation and for accessing data that the higher-level commands do not expose.

### gh-dash Configuration

gh-dash reads its configuration from `~/.config/gh-dash/config.yml`. You can customize:

- Which sections appear (PRs authored, PRs reviewing, custom searches).
- Refresh interval.
- Keybindings.
- Theme colors.

A typical configuration might add a section for PRs in repositories you maintain:

```yaml
prSections:
  - title: "My PRs"
    filters: "is:open author:@me"
  - title: "Review Requested"
    filters: "is:open review-requested:@me"
  - title: "Team PRs"
    filters: "is:open org:my-org"
issuesSections:
  - title: "My Issues"
    filters: "is:open author:@me"
  - title: "Assigned"
    filters: "is:open assignee:@me"
```

### Aliases for Common gh Commands

gh supports custom aliases stored in its config:

```bash
gh alias set prc 'pr create --fill'
gh alias set prm 'pr merge --squash --delete-branch'
gh alias set prv 'pr view --web'
```

After defining these:

```bash
gh prc     # Create PR with auto-fill
gh prm     # Squash merge and delete branch
gh prv     # Open PR in browser
```

### Using gh in Scripts

gh commands work well in CI/CD scripts and automation:

```bash
# Wait for checks to pass, then merge
gh pr checks --watch && gh pr merge --squash --delete-branch

# Create a release
gh release create v1.0.0 --generate-notes

# Download an artifact from a workflow run
gh run download 12345 --name my-artifact
```

### gh with Multiple GitHub Accounts

If you work with multiple GitHub accounts (personal and work), gh supports switching:

```bash
gh auth login --hostname github.com           # Default
gh auth login --hostname github.enterprise.com # Enterprise
gh auth switch                                  # Switch between accounts
```

\newpage
