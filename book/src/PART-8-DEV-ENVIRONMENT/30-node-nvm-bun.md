# Node.js: NVM and Bun

> Two runtimes, one language -- NVM for compatibility, Bun for speed.

---

## Overview

This environment runs two JavaScript runtimes side by side. NVM (Node Version Manager) provides traditional Node.js with per-project version switching. Bun provides a faster alternative runtime, bundler, test runner, and package manager in a single binary. Both are configured in the shell and managed through chezmoi.

The division of labor is straightforward: use Node.js via NVM when a project requires it (most production apps, CI pipelines, legacy codebases), and use Bun when starting fresh or when speed matters (scripting, local tooling, rapid prototyping).

---

## NVM Configuration

NVM is initialized in `~/.zshrc` with three lines that chezmoi manages via `dot_zshrc.tmpl`:

```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
```

The first line sets the directory where NVM stores its Node versions and configuration. The second sources NVM itself, making the `nvm` command available. The third enables tab completion for NVM commands.

### Automatic Installation

Chezmoi handles NVM and Node.js installation through a run-on-change script:

```
run_onchange_install-nvm-and-node.sh.tmpl
```

This script is a chezmoi template that reads from `.node-version` in the chezmoi source directory. When the content of `.node-version` changes, chezmoi re-runs the script, which installs the specified Node version and sets it as the default. The current pinned version is Node 22.

The script performs three steps:

1. Install NVM itself if the `$NVM_DIR` directory does not exist
2. Source NVM into the current shell
3. Run `nvm install` and `nvm alias default` for the version specified in `.node-version`

### Essential NVM Commands

| Command                     | Purpose                                        |
|-----------------------------|-------------------------------------------------|
| `nvm ls`                    | List all locally installed Node versions        |
| `nvm ls-remote --lts`       | List available LTS versions for download        |
| `nvm use 22`                | Switch to Node 22 in the current shell          |
| `nvm install 22`            | Download and install Node 22                    |
| `nvm alias default 22`      | Set Node 22 as the default for new shells       |
| `nvm current`               | Print the currently active Node version         |
| `nvm which 22`              | Print the path to the Node 22 binary            |
| `nvm uninstall 20`          | Remove Node 20 from disk                        |

### Per-Project Version Pinning

When you enter a directory containing a `.node-version` or `.nvmrc` file, you can run `nvm use` to switch to the version specified in that file. The `.node-version` file in the chezmoi source directory serves double duty: it pins the global default version and triggers the chezmoi run-on-change script when updated.

To update the global Node version:

```bash
chezmoi cd
echo "22" > .node-version
chezmoi apply
```

This changes the file, triggers the install script, and ensures every machine managed by chezmoi converges on the same Node version.

---

## Bun Configuration

Bun is configured in `~/.zshrc` with three lines:

```bash
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
```

The first line sets the Bun installation directory. The second adds the Bun binary to `PATH`. The third sources Bun's shell completion script for tab completion of Bun commands and subcommands.

### Essential Bun Commands

| Command                        | Purpose                                        |
|--------------------------------|-------------------------------------------------|
| `bun run dev`                  | Run the `dev` script from package.json         |
| `bun run build`                | Run the `build` script from package.json       |
| `bun install`                  | Install all dependencies from package.json     |
| `bun add react`                | Add a dependency                               |
| `bun add -d vitest`            | Add a dev dependency                           |
| `bun dev`                      | Shorthand for `bun run dev`                    |
| `bun build ./src/index.ts`     | Bundle a TypeScript entry point                |
| `bun test`                     | Run tests using Bun's built-in test runner     |
| `bunx create-next-app`         | Execute a package binary without installing    |
| `bun upgrade`                  | Upgrade Bun itself to the latest version       |

### Why Bun Alongside Node

Bun is not a full replacement for Node.js. Some libraries assume Node-specific APIs. CI environments typically run Node. Production deployments on most platforms target Node. But Bun offers compelling advantages for local development:

- **Speed.** `bun install` is significantly faster than `npm install` or `yarn install`. For large monorepos, this saves minutes per install.
- **Built-in bundler.** `bun build` replaces webpack, esbuild, or Rollup for many use cases.
- **Built-in test runner.** `bun test` is Jest-compatible but faster.
- **TypeScript out of the box.** Bun runs `.ts` files directly without a compilation step.
- **Single binary.** No dependency on a separate package manager installation.

The practical rule: start with Bun for new projects, fall back to Node when something does not work.

---

## How They Interact

NVM and Bun do not conflict. NVM manages Node.js versions in `~/.nvm/versions/node/`. Bun lives in `~/.bun/`. Both are on `PATH`, but they serve different `node` binaries. When you run `node`, you get the NVM-managed version. When you run `bun`, you get Bun's runtime.

For projects that need Node.js specifically:

```bash
nvm use        # reads .node-version or .nvmrc
npm install    # uses Node's npm
npm run dev    # runs via Node
```

For projects that use Bun:

```bash
bun install    # uses Bun's package manager
bun dev        # runs via Bun's runtime
```

For projects that mix both (common in transitional codebases):

```bash
nvm use        # ensure correct Node version
bun install    # use Bun for faster installs (compatible lockfile)
bun run dev    # use Bun to execute the dev script
```

---

## Chezmoi Integration

The `.node-version` file in the chezmoi source directory is the single source of truth for the default Node.js version across all machines. The install script template includes the file content in a comment line:

```bash
# Node version: {{ include ".node-version" | trim }}
```

This chezmoi template directive means the script's content hash changes whenever `.node-version` changes. Since the script uses `run_onchange_` prefix, chezmoi detects the content change and re-runs the script automatically during `chezmoi apply`.

This pattern -- using chezmoi template includes to trigger re-runs -- is a powerful way to tie installation scripts to data files without manual intervention.

---

## Troubleshooting

| Problem                              | Solution                                          |
|--------------------------------------|---------------------------------------------------|
| `nvm: command not found`             | Source NVM: `. "$NVM_DIR/nvm.sh"`                |
| Wrong Node version in a project      | Add `.node-version` to the project root           |
| `bun: command not found`             | Check that `$BUN_INSTALL/bin` is on `PATH`       |
| Bun install fails on native module   | Fall back to `npm install` for that project       |
| NVM is slow to load                  | Normal on first shell load; subsequent shells cache |

---

## Quick Reference

```bash
# Check versions
node --version      # Node.js version (via NVM)
bun --version       # Bun version
nvm current         # Which Node NVM is using

# Switch Node versions
nvm use 22          # Use Node 22
nvm install --lts   # Install latest LTS

# Bun workflow
bun init            # Scaffold a new project
bun install         # Install dependencies
bun dev             # Start dev server
bun test            # Run tests
bunx degit user/repo my-project  # Clone a template
```

\newpage
