# Beautiful Diffs: delta

> A syntax-highlighting pager that replaces git's default diff output with side-by-side, line-numbered, Catppuccin-colored diffs you can navigate like a document.

## Your Setup

Delta is configured in `~/.gitconfig` as both the core pager and the interactive diff filter:

```ini
[core]
    pager = delta
[interactive]
    diffFilter = delta --color-only
[delta]
    navigate = true
    dark = true
    side-by-side = true
    line-numbers = true
    syntax-theme = Catppuccin Mocha
```

This configuration means:

- **Every git command that produces paged output** -- `git diff`, `git log -p`, `git show`, `git blame`, `git stash show -p` -- renders through delta automatically.
- **Interactive staging** (`git add -p`) uses delta's color-only mode for syntax highlighting without the side-by-side layout (which would break the interactive interface).
- **Navigation mode** is enabled, allowing you to jump between file diffs with `n` and `N` keys.
- **Side-by-side** layout shows old and new versions of each file in parallel columns.
- **Line numbers** appear in the gutter of both sides.
- **Catppuccin Mocha** theme ensures diffs match the color palette used in iTerm2, Neovim, lazygit, and every other tool in the environment.

Delta is installed via Homebrew:

```bash
brew install git-delta
```

The companion tool `diffnav` is also installed, providing an alternative navigation interface for delta output.

## Core Concepts

### What Delta Replaces

Without delta, git diff output looks like this:

```
diff --git a/src/app.ts b/src/app.ts
index abc1234..def5678 100644
--- a/src/app.ts
+++ b/src/app.ts
@@ -10,7 +10,7 @@ function main() {
-  const timeout = 5000;
+  const timeout = 10000;
```

Plain text, no syntax highlighting, no line numbers, unified format only. For small changes this is adequate. For large diffs across multiple files, it becomes difficult to read.

With delta, the same diff renders as:

- Two columns side by side: the left column shows the old version, the right column shows the new version.
- Full syntax highlighting using Treesitter-quality parsing for the file's language.
- Line numbers in the gutter of both columns.
- Additions highlighted in green, deletions in red, using the Catppuccin Mocha palette.
- Moved lines highlighted differently from changed lines (because `diff.colorMoved = default` is set).
- File headers clearly delineated with the filename and change summary.

### Side-by-Side Mode

Side-by-side diffs show the before and after states in parallel columns. This layout has several advantages:

- **Context is visible on both sides.** You do not need to mentally reconstruct what the old code looked like while reading the new code -- both are right there.
- **Line alignment.** Corresponding lines are vertically aligned, making it easy to see exactly what changed on each line.
- **Large diffs are scannable.** You can quickly scroll through a multi-file diff and spot the important changes because the layout is denser than unified format.

The trade-off is horizontal space. On a typical terminal (120+ columns), side-by-side works well. On very narrow terminals, lines may wrap. You can temporarily disable it:

```bash
git diff --no-ext-diff
```

Or pass delta flags directly:

```bash
git diff | delta --side-by-side=false
```

### Navigation with n/N

When `navigate = true`, delta inserts special markers at file boundaries. Inside the pager (less), you can press:

| Key | Action |
|-----|--------|
| `n` | Jump to the next file in the diff |
| `N` | Jump to the previous file in the diff |

This transforms large diffs from a wall of text into a navigable document. Instead of scrolling through hundreds of lines, you jump directly to the file you care about.

### Syntax Themes

Delta supports any syntax theme that `bat` supports, because both tools use the same syntect highlighting engine. The `Catppuccin Mocha` theme is specified to match the rest of the environment:

- Additions use Catppuccin green (`#a6e3a1`)
- Deletions use Catppuccin red (`#f38ba8`)
- Syntax colors (keywords, strings, functions) match what you see in Neovim and bat
- The dark background matches the terminal's base color (`#1e1e2e`)

## Essential Commands

### Commands That Automatically Use Delta

| Command | What Delta Renders |
|---------|--------------------|
| `git diff` (alias: `gd`) | Unstaged changes, side-by-side |
| `git diff --staged` (alias: `gds`) | Staged changes, side-by-side |
| `git log -p` | Commit history with full diffs |
| `git show <commit>` | Single commit with diff |
| `git blame <file>` | Annotated file with syntax highlighting |
| `git stash show -p` | Stash contents with diff |
| `git diff branch1..branch2` | Differences between two branches |
| `git diff HEAD~3..HEAD` | Last three commits as a diff |

### Delta-Specific Navigation (Inside the Pager)

| Key | Action |
|-----|--------|
| `n` | Next file in diff |
| `N` | Previous file in diff |
| `q` | Quit the pager |
| `/pattern` | Search forward for text |
| `?pattern` | Search backward for text |
| `g` | Go to top of output |
| `G` | Go to bottom of output |
| `Space` | Page down |
| `b` | Page up |
| `j` / `k` | Scroll down / up one line |

### Overriding Delta Temporarily

| Command | Effect |
|---------|--------|
| `git diff --no-ext-diff` | Bypass delta entirely, use default git diff |
| `git diff \| delta --side-by-side=false` | Pipe through delta without side-by-side |
| `git diff \| delta --line-numbers=false` | Pipe through delta without line numbers |
| `GIT_PAGER=cat git diff` | Use cat as pager (plain text, no delta) |

## Practical Recipes

### Review a feature branch diff

```bash
git diff main..feat/my-branch
```

Delta renders the entire diff between main and the feature branch in side-by-side format. Press `n` to jump between files, focusing on the ones you care about.

### Review a single commit

```bash
git show abc1234
```

Shows the commit message followed by the full diff, syntax-highlighted and side-by-side.

### Compare two commits

```bash
git diff abc1234..def5678
```

Delta renders the difference between any two commits with full highlighting.

### Review what you are about to commit

```bash
gds          # git diff --staged
```

Before running `gc` (git commit), always review staged changes. Delta's side-by-side view makes it easy to catch mistakes, debug output, or unintended changes.

### View a file's history with diffs

```bash
git log -p --follow -- src/utils.ts
```

Every commit that touched the file is shown with its full diff. Press `n` to jump between commits (each commit's diff is treated as a separate file section by delta's navigator).

### Blame with syntax highlighting

```bash
git blame src/app.ts
```

Delta syntax-highlights the blame output, making it much easier to read than the default monochrome output. Each line shows the commit hash, author, date, and the code itself in full color.

### View stash contents before applying

```bash
git stash show -p stash@{0}
```

See exactly what a stash contains before deciding to apply it. The side-by-side view shows what would change.

### Diff only specific file types

```bash
git diff -- '*.ts' '*.tsx'
```

Limit the diff to TypeScript files. Delta still renders everything in side-by-side mode with correct syntax highlighting for the file type.

## Advanced Usage

### How Delta Integrates with the Pager

Delta produces output with ANSI color codes and passes it to `less` (the default pager for `less -R`). The `navigate = true` option inserts special section markers that `less` can jump between. This is why `n`/`N` navigation works -- delta is using less's built-in section-jump feature.

### The Interactive Diff Filter

The `interactive.diffFilter = delta --color-only` setting is specifically for `git add -p` (interactive staging). In this mode, git shows you hunks one at a time and asks whether to stage each one. The `--color-only` flag tells delta to add syntax highlighting but not reformat the output into side-by-side mode, which would break the interactive interface.

This means when you run:

```bash
git add -p src/app.ts
```

Each hunk is syntax-highlighted with Catppuccin colors, but displayed in the standard unified format that the interactive staging interface expects.

### Delta and colorMoved

The `diff.colorMoved = default` setting in gitconfig works in concert with delta. When git detects that lines were moved rather than changed (for example, moving a function from the top of a file to the bottom), it marks those lines with a special attribute. Delta then renders moved lines in a distinct color, separate from additions and deletions.

This is especially useful during refactoring. A diff that appears to delete 50 lines and add 50 identical lines elsewhere is actually just a move -- and delta makes that visually obvious.

### The diffnav Tool

The `diffnav` tool provides an alternative way to navigate delta output. Instead of using `n`/`N` within less, diffnav presents a file picker at the top of the screen, letting you select which file's diff to view. It is installed alongside delta and can be used as:

```bash
git diff | diffnav
```

This is particularly useful for large diffs spanning many files, where the file picker gives you a better overview than sequential navigation.

### Performance Considerations

Delta adds overhead to every git diff operation because it performs syntax highlighting on the fly. For most diffs, this is imperceptible. For extremely large diffs (thousands of lines across dozens of files), you may notice a slight delay. In those cases:

```bash
git diff --stat                  # See which files changed (fast, minimal delta work)
git diff -- path/to/specific.ts # Narrow the diff to one file
```

### Using Delta Outside of Git

Delta can highlight any unified diff, not just git diffs:

```bash
diff -u old_file.ts new_file.ts | delta
```

This is useful for comparing files that are not in a git repository, or for reviewing diff output from other tools.

### Delta Configuration Options Not in This Setup

Delta supports many options beyond what is configured here. Some worth knowing:

| Option | What It Does |
|--------|-------------|
| `hyperlinks = true` | Make file paths clickable in terminals that support OSC 8 |
| `file-modified-label = "modified:"` | Customize the label shown for modified files |
| `hunk-header-style = file line-number syntax` | Show file name and line number in hunk headers |
| `line-numbers-left-format = "{nm:>4} "` | Customize left-side line number format |
| `line-numbers-right-format = "{np:>4} "` | Customize right-side line number format |
| `max-line-length = 512` | Truncate very long lines (default: 512) |
| `wrap-max-lines = 2` | Maximum lines to use when wrapping long lines |

### Catppuccin Consistency

The `syntax-theme = Catppuccin Mocha` setting is not arbitrary. It is the same theme used across the entire environment:

| Tool | Catppuccin Integration |
|------|----------------------|
| iTerm2 | Catppuccin Mocha color profile |
| Neovim | Catppuccin Mocha colorscheme |
| bat | `--theme="Catppuccin Mocha"` |
| lazygit | Inherits terminal colors |
| Starship | Catppuccin Mocha palette in prompt |
| Delta | `syntax-theme = Catppuccin Mocha` |

When you see a string literal highlighted in peach in Neovim, it is the same peach in a delta diff. When a keyword is mauve in your editor, it is mauve in your diffs. This consistency eliminates the cognitive cost of switching contexts between editing and reviewing code.

\newpage
