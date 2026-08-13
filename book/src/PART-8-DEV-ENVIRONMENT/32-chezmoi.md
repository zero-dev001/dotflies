# Dotfiles Management: chezmoi

> One source directory, every machine in sync -- chezmoi turns dotfile chaos into declarative configuration.

---

## Overview

chezmoi is a dotfiles manager that keeps configuration files in a source directory and applies them to the home directory. Unlike symlink-based tools like GNU Stow, chezmoi copies files to their target locations after optionally processing them through a template engine. This approach is more robust: the target files are real files, not symlinks, so tools that do not follow symlinks work correctly.

The source directory for this environment is:

```
~/.local/share/chezmoi/
```

This directory is a Git repository. Changes to dotfiles are committed, pushed, and pulled like any other code. On a new machine, a single command bootstraps the entire environment from the remote repository.

---

## Core Concepts

### Source State vs. Target State

chezmoi maintains a distinction between two states:

- **Source state:** the files in `~/.local/share/chezmoi/`. These are the templates, scripts, and data that define what the configuration should look like.
- **Target state:** the files in `~/` and `~/.config/`. These are the actual files that tools read.

The `chezmoi apply` command computes the difference between the source state and target state, then modifies the target to match the source.

### Naming Conventions

chezmoi uses filename prefixes in the source directory to control how files are handled:

| Source prefix       | Target behavior                                     | Example                                    |
|---------------------|-----------------------------------------------------|--------------------------------------------|
| `dot_`              | Replaced with `.` in target                         | `dot_zshrc` becomes `~/.zshrc`             |
| `dot_config/`       | Maps to `~/.config/`                                | `dot_config/starship.toml`                 |
| `private_`          | File gets `0600` permissions                        | `private_Library/` for LaunchAgents        |
| `run_once_`         | Script runs once, never again                       | `run_once_macos-defaults.sh`               |
| `run_onchange_`     | Script re-runs when its content hash changes        | `run_onchange_install-zsh-plugins.sh`      |
| `run_onchange_before_` | Runs before other operations when content changes | `run_onchange_before_install-brew-packages.sh.tmpl` |
| `.tmpl`             | Processed through Go template engine                | `dot_zshrc.tmpl`                           |

These prefixes compose. A file named `run_onchange_before_install-brew-packages.sh.tmpl` is a script that runs before other targets, re-runs when its content changes, and is processed as a template before execution.

---

## Essential Commands

### Daily Usage

| Command              | Purpose                                              |
|----------------------|------------------------------------------------------|
| `chezmoi cd`         | Open a shell in the source directory                 |
| `chezmoi edit FILE`  | Edit a target file in its source form                |
| `chezmoi diff`       | Show what would change on the next apply             |
| `chezmoi apply`      | Apply source state to target state                   |
| `chezmoi apply -v`   | Apply with verbose output showing each action        |
| `chezmoi status`     | Show files that differ between source and target     |
| `chezmoi update`     | Pull latest from remote and apply                    |

### Managing Files

| Command                        | Purpose                                       |
|--------------------------------|-----------------------------------------------|
| `chezmoi add ~/.gitconfig`     | Add a file from target to source              |
| `chezmoi add --template FILE`  | Add a file as a template                      |
| `chezmoi managed`              | List all files chezmoi manages                |
| `chezmoi managed --include=files` | List only managed files (not directories)  |
| `chezmoi forget FILE`          | Stop managing a file (remove from source)     |
| `chezmoi re-add`               | Update source from modified target files      |

### Inspection

| Command                        | Purpose                                       |
|--------------------------------|-----------------------------------------------|
| `chezmoi cat FILE`             | Print the target-state content of a file      |
| `chezmoi source-path FILE`     | Show the source path for a target file        |
| `chezmoi data`                 | Print all template data as JSON               |
| `chezmoi doctor`               | Diagnose common configuration problems        |
| `chezmoi git status`           | Run git commands in the source directory       |

---

## Templates

Files ending in `.tmpl` are processed through Go's `text/template` engine before being written to the target. This allows machine-specific customization from a single source file.

### Example: dot_zshrc.tmpl

The main shell configuration uses a template for the optional project bin path:

```
{{ if dig "projectBinPath" "" . }}
export PATH="$HOME/{{ .projectBinPath }}:$PATH"
{{ end }}
```

The `dig` function checks whether `projectBinPath` is defined in chezmoi's template data. If it is, the PATH export is included in the rendered `.zshrc`. If not, that block is omitted entirely.

Template data is defined in `~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
projectBinPath = "work/bin"
```

### Template Functions

chezmoi provides template functions beyond the Go standard library:

| Function                       | Purpose                                       |
|--------------------------------|-----------------------------------------------|
| `{{ .chezmoi.os }}`           | Operating system (`darwin`, `linux`)           |
| `{{ .chezmoi.arch }}`         | Architecture (`amd64`, `arm64`)               |
| `{{ .chezmoi.hostname }}`     | Machine hostname                              |
| `{{ .chezmoi.sourceDir }}`    | Path to chezmoi source directory              |
| `{{ include "file" }}`        | Include contents of another source file       |
| `{{ include "file" \| trim }}` | Include and trim whitespace                   |
| `{{ output "cmd" "arg" }}`    | Capture command output                        |

---

## Run Scripts

Run scripts are executable files in the source directory that chezmoi runs during `chezmoi apply`. They handle tasks that cannot be expressed as file copies: installing packages, compiling tools, setting system defaults.

### Scripts in This Environment

| Script                                            | Type        | Purpose                                  |
|---------------------------------------------------|-------------|------------------------------------------|
| `run_once_macos-defaults.sh`                      | Run once    | Set macOS system preferences             |
| `run_once_install-gh-extensions.sh`               | Run once    | Install GitHub CLI extensions            |
| `run_onchange_before_install-brew-packages.sh.tmpl` | On change | Install Homebrew and run `brew bundle`   |
| `run_onchange_install-nvm-and-node.sh.tmpl`       | On change   | Install NVM and pin Node version         |
| `run_onchange_install-zsh-plugins.sh`             | On change   | Install Oh My Zsh plugins               |
| `run_onchange_install-tmux-plugins.sh`            | On change   | Install TPM and tmux plugins             |
| `run_onchange_install-mise.sh`                    | On change   | Install mise runtime manager             |

**Run-once scripts** execute the first time `chezmoi apply` runs on a machine, then never again. chezmoi records their completion in its state database. This is ideal for one-time setup like macOS defaults.

**Run-on-change scripts** execute whenever their content changes. For template scripts (`.tmpl` suffix), this means the rendered content is hashed. When a Brewfile changes, the hash of the rendered install script changes, triggering a re-run. This is the mechanism that keeps packages in sync across machines.

**Before scripts** (`run_onchange_before_`) run before chezmoi writes any files. This ensures that package managers are up to date before configuration files that depend on installed packages are written.

---

## Auto-Sync with LaunchAgent

A macOS LaunchAgent ensures dotfiles stay synchronized automatically:

```
~/Library/LaunchAgents/com.chezmoi.update.plist
```

This LaunchAgent runs `chezmoi update --no-tty` at login. The `--no-tty` flag prevents chezmoi from prompting for confirmation, which would fail in a non-interactive context. Output is logged to `/tmp/chezmoi-update.log`.

The plist file itself is managed by chezmoi under `private_Library/LaunchAgents/`, using the `private_` prefix to ensure correct permissions on the `Library` directory.

---

## Workflow: Making a Configuration Change

The typical workflow for modifying a dotfile:

```bash
# 1. Navigate to the source directory
chezmoi cd

# 2. Edit the file (or use chezmoi edit)
nvim dot_tmux.conf

# 3. Preview what will change
chezmoi diff

# 4. Apply changes
chezmoi apply

# 5. Commit and push
git add dot_tmux.conf
git commit -m "Update tmux configuration"
git push
```

Alternatively, for quick edits:

```bash
# Edit the source file for a target
chezmoi edit ~/.tmux.conf

# This opens the source file (dot_tmux.conf) in your editor.
# After saving, apply:
chezmoi apply
```

---

## Bootstrapping a New Machine

To set up a fresh macOS machine from the dotfiles repository:

```bash
# 1. Install chezmoi and initialize from the repo
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply YOUR_GITHUB_USERNAME

# 2. chezmoi runs all scripts in order:
#    - before scripts: install Homebrew and packages
#    - on-change scripts: install NVM, Node, plugins
#    - once scripts: set macOS defaults
#    - file copies: deploy all dotfiles

# 3. Restart the shell
exec zsh
```

After that single command, the machine has every tool installed, every configuration file deployed, and every macOS default set.

---

## Troubleshooting

| Problem                                | Solution                                     |
|----------------------------------------|----------------------------------------------|
| `chezmoi diff` shows unexpected changes | Run `chezmoi data` to check template values |
| Script fails during apply              | Check the script output, fix, re-run apply   |
| Template renders incorrectly           | Use `chezmoi cat FILE` to see rendered output |
| File permissions wrong                 | Use `private_` or `executable_` prefix       |
| Want to stop managing a file           | `chezmoi forget ~/path/to/file`              |

\newpage
