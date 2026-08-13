# Workflow: Starting a New Project

> From an empty directory to a running development session, using the full stack.

---

## Overview

Starting a new project exercises nearly every tool in this environment: shell aliases for directory creation, NVM or Bun for runtime setup, Git for version control, chezmoi for configuration consistency, sesh for session management, the IDE layout for development, and Neovim for editing. This chapter walks through the complete sequence.

---

## Step 1: Create the Project Directory

Use the `mkd` function, which combines `mkdir -p` and `cd`:

```bash
mkd ~/Projects/new-project
```

This creates the directory (including any missing parent directories) and immediately changes into it. You are now in an empty directory ready to scaffold.

Alternatively, if the directory already exists:

```bash
cd new-project
```

Because `cd` is aliased to zoxide, this jump works even if you are not in `~/Projects/`. Zoxide learns directory paths the first time you visit them.

---

## Step 2: Initialize the Project

The initialization step depends on the type of project.

### Node.js Project with Bun

```bash
bun init
```

This scaffolds a `package.json`, `tsconfig.json`, and `index.ts` entry point. Bun's init is fast and opinionated toward TypeScript.

For a framework-specific scaffold:

```bash
bunx create-next-app .          # Next.js
bunx create-svelte .            # SvelteKit
bunx create-vite . --template react-ts  # Vite + React
```

### Node.js Project with npm

If the project requires Node.js specifically:

```bash
nvm use           # reads .node-version if present
npm init -y       # scaffold package.json
```

Or for a framework:

```bash
npx create-next-app .
```

### Python Project

```bash
mise use python@3.12
python -m venv .venv
source .venv/bin/activate
```

### General Project (No Runtime)

For documentation, configuration, or non-runtime projects:

```bash
git init
```

---

## Step 3: Initialize Git

If the scaffold command did not already initialize Git:

```bash
git init
```

Create a `.gitignore` appropriate to the project type. For a Node.js project:

```bash
cat > .gitignore << 'EOF'
node_modules/
dist/
.env
.env.local
*.log
.DS_Store
EOF
```

Make the initial commit:

```bash
git add .
git commit -m "Initial scaffold"
```

To create a GitHub repository and push:

```bash
gh repo create new-project --private --source=. --push
```

This single command creates a private repository on GitHub, sets it as the remote, and pushes the initial commit.

---

## Step 4: Launch the IDE Layout

With the project initialized, launch the three-pane IDE layout:

```bash
ide .
```

This creates a tmux session named after the project directory with:

- Left pane (20% width): Claude Code for AI assistance
- Right top pane (80% width): Neovim
- Right bottom pane (20% height): Terminal for running commands

The cursor starts in the Neovim pane. From here, the standard development workflow begins.

---

## Step 5: Register with Sesh (Optional)

For projects you will return to frequently, add an entry to `~/.config/sesh/sesh.toml`:

```toml
[[session]]
name = "new-project"
path = "~/Projects/new-project"
startup_command = "nvim"
preview_command = "eza --tree --level=2 --icons ~/Projects/new-project"
```

After adding this, the project appears in the sesh picker (`prefix + T`) with a tree preview. The `startup_command` means selecting this session immediately opens Neovim.

For projects you do not want to permanently register, zoxide handles discovery automatically. After visiting the directory a few times, `cd new-project` will jump to it from anywhere, and the zoxide list in the sesh picker (`Ctrl+x`) will include it.

---

## Step 6: Start Coding in Neovim

With Neovim open in the project directory, the initial exploration usually follows this pattern:

### Finding Files

| Key            | Action                                    |
|----------------|-------------------------------------------|
| `Space+ff`     | Find files by name (Telescope)            |
| `Space+fg`     | Find files by content (live grep)         |
| `Space+fr`     | Find recently opened files                |
| `Space+fb`     | Find open buffers                         |

### File Explorer

| Key            | Action                                    |
|----------------|-------------------------------------------|
| `Space+e`      | Toggle the file explorer (neo-tree)       |

### Creating New Files

In the file explorer, press `a` to create a new file. Type the path including any subdirectories and they will be created automatically.

Alternatively, from the command line:

```vim
:e src/components/Header.tsx
```

This opens a new buffer for the file. The directory `src/components/` is created when you save.

---

## Step 7: Git Workflow

As the project develops, the git workflow integrates lazygit and the GitHub CLI.

### Local Development

Open lazygit from any pane:

```bash
lazygit
```

Or from Neovim (if configured with a lazygit plugin). Lazygit provides a visual interface for:

- Staging individual files or hunks
- Writing commit messages
- Viewing the commit graph
- Managing branches

### Creating a Pull Request

When a feature is ready:

```bash
# Create and switch to a feature branch
git checkout -b feature/add-header

# Make commits...
# Then push and create PR
git push -u origin feature/add-header
gh pr create --fill
```

The `--fill` flag auto-fills the PR title and body from the commit messages.

---

## Scaffold Cheat Sheet

| Project Type          | Command                                          |
|-----------------------|--------------------------------------------------|
| Bun + TypeScript      | `bun init`                                       |
| Next.js               | `bunx create-next-app .`                         |
| SvelteKit             | `bunx create-svelte .`                           |
| Vite + React          | `bunx create-vite . --template react-ts`         |
| Vite + Vue            | `bunx create-vite . --template vue-ts`           |
| Node.js (npm)         | `npm init -y`                                    |
| Python                | `mise use python@3.12 && python -m venv .venv`   |
| Go                    | `mise use golang@1.22 && go mod init module-name` |
| Static site           | `git init`                                       |

---

## The Full Sequence

Putting it all together, here is the complete flow for a new TypeScript project:

```bash
# 1. Create and enter directory
mkd ~/Projects/my-app

# 2. Scaffold with Bun
bun init

# 3. Initialize git and push to GitHub
git init
git add .
git commit -m "Initial scaffold"
gh repo create my-app --private --source=. --push

# 4. Launch IDE layout
ide .

# 5. In Neovim: Space+ff to find files, start editing
# 6. In terminal pane: bun dev to start dev server
# 7. In Claude pane: ask for help, generate boilerplate
```

Total time from the idea to a running dev server: under two minutes.

---

## Tips

- **Use `mkd` instead of `mkdir && cd`.** The function does both in one command and the `$_` variable ensures you end up in the right place.

- **Let Bun scaffold when possible.** `bun init` produces a minimal, TypeScript-ready project without the bloat of some framework CLIs.

- **Create the GitHub repo immediately.** `gh repo create` with `--source=.` turns any local directory into a pushed repository in one command. Do not wait until the project is "ready."

- **Register long-lived projects in sesh.toml.** If you will work on a project for more than a few days, the ten seconds spent adding a sesh entry saves minutes of navigation over the project's lifetime.

- **Use the IDE layout from the start.** Even for quick experiments, the three-pane layout (AI + editor + terminal) is more productive than switching between separate windows.

---

## Troubleshooting

| Problem                            | Solution                                         |
|------------------------------------|--------------------------------------------------|
| `nvm use` says no .node-version    | Create one: `echo "22" > .node-version`          |
| `bun init` not found               | Check PATH: `echo $BUN_INSTALL/bin`              |
| `gh repo create` fails auth        | Run `gh auth login`                              |
| IDE layout opens in wrong dir      | Pass the full path: `ide ~/Projects/my-app`      |
| Neovim LSP not starting            | Open a file of the right type; LSP auto-attaches |

\newpage
