# Version Management: mise

> One tool to manage every runtime version -- faster than asdf, simpler than juggling version managers.

---

## Overview

mise (pronounced "meez") is a polyglot runtime version manager that replaces the need for separate version managers per language. Instead of installing nvm for Node, pyenv for Python, rbenv for Ruby, and so on, mise handles all of them through a single CLI with a unified configuration format.

mise is the spiritual successor to asdf. It is compatible with asdf's `.tool-versions` file format but is written in Rust, which gives it significantly faster startup and execution times. Where asdf adds noticeable latency to shell initialization through shims, mise uses a different activation strategy that keeps the shell responsive.

---

## Installation and Activation

mise is installed through two mechanisms in this environment.

First, it is listed in the essential Brewfile:

```
brew "mise"
```

Second, a dedicated chezmoi run-on-change script ensures mise is available even if Homebrew has not been run yet:

```bash
#!/bin/bash
set -euo pipefail

if ! command -v mise &>/dev/null; then
  echo "Installing mise..."
  curl https://mise.run | sh
  echo "mise installed."
else
  echo "mise is already installed."
fi
```

Activation happens in `~/.zshrc` with a single line:

```bash
eval "$(mise activate zsh)"
```

This line is critical. Unlike asdf, which uses shims (wrapper scripts in a directory on `PATH`), mise modifies `PATH` directly each time you change directories. This means the correct version of a tool is always the real binary, not a shim that adds overhead to every invocation.

The activation line must come after other PATH modifications but before the Starship prompt initialization, which is the order maintained in `dot_zshrc.tmpl`.

---

## Configuration Files

mise supports two configuration file formats. You can use either or both in a project.

### `.tool-versions` (asdf-compatible)

```
python 3.12.0
ruby 3.3.0
golang 1.22.0
```

This format is one tool per line, with the tool name and version separated by a space. It is compatible with asdf, so teams that have not migrated to mise can still use the same file.

### `mise.toml` (mise-native)

```toml
[tools]
python = "3.12.0"
ruby = "3.3.0"
golang = "1.22.0"

[env]
VIRTUAL_ENV = "{{env.HOME}}/.virtualenvs/myproject"
```

The TOML format is more expressive. It supports environment variable configuration, tool-specific settings, and conditional logic. For new projects, `mise.toml` is the preferred format.

### Global Configuration

mise also reads a global configuration file at `~/.config/mise/config.toml`. This sets default versions for tools when no project-level configuration is present.

---

## Essential Commands

### Installing and Using Tools

| Command                          | Purpose                                           |
|----------------------------------|---------------------------------------------------|
| `mise install python@3.12`       | Install Python 3.12                               |
| `mise install python`            | Install the version specified in config            |
| `mise install`                   | Install all tools specified in the current config  |
| `mise use python@3.12`           | Install and pin Python 3.12 in current directory   |
| `mise use -g python@3.12`        | Set Python 3.12 as the global default              |
| `mise uninstall python@3.11`     | Remove a specific installed version                |

### Querying State

| Command                          | Purpose                                           |
|----------------------------------|---------------------------------------------------|
| `mise ls`                        | List all installed tool versions                   |
| `mise ls python`                 | List installed Python versions                     |
| `mise current`                   | Show currently active versions for all tools       |
| `mise current python`            | Show the active Python version                     |
| `mise where python@3.12`         | Print the installation path for a version          |
| `mise ls-remote python`          | List all available Python versions for install     |

### Managing Configuration

| Command                          | Purpose                                           |
|----------------------------------|---------------------------------------------------|
| `mise use python@3.12`           | Write version to `.mise.toml` in current dir       |
| `mise use -g node@22`            | Write version to global config                     |
| `mise env`                       | Print the environment variables mise would set     |
| `mise doctor`                    | Diagnose common configuration problems             |
| `mise settings`                  | Show all mise settings                             |

---

## How mise Resolves Versions

When you run a command like `python`, mise determines which version to use by checking these locations in order:

1. **Command-line override:** `mise exec python@3.11 -- python script.py`
2. **Current directory:** `.mise.toml` or `.tool-versions` in the working directory
3. **Parent directories:** mise walks up the directory tree looking for config files
4. **Global config:** `~/.config/mise/config.toml`
5. **System default:** the version installed by the OS or Homebrew

This hierarchical resolution means you can set a global default and override it per-project without any manual switching. When you `cd` into a project directory, mise automatically adjusts `PATH` to point to the correct versions.

---

## mise vs. NVM

This environment uses both mise and NVM. This is not redundant -- they serve different roles.

NVM is the established standard for Node.js version management. It is deeply integrated with the Node ecosystem. The `.node-version` and `.nvmrc` files are recognized by CI platforms, deployment services, and IDE plugins. The chezmoi run-on-change script that installs Node relies on NVM.

mise handles everything else. If a project needs Python, Ruby, Go, Terraform, or any other tool that has a mise plugin, mise manages it. For Node specifically, NVM remains the primary manager because of its ecosystem integration, but mise can serve as a backup or alternative.

The practical guideline:

| Tool      | Managed by | Reason                                    |
|-----------|------------|-------------------------------------------|
| Node.js   | NVM        | Ecosystem standard, chezmoi integration   |
| Python    | mise       | Replaces pyenv                            |
| Ruby      | mise       | Replaces rbenv                            |
| Go        | mise       | Replaces manual downloads                 |
| Rust      | rustup     | Rust has its own excellent toolchain       |
| All others| mise       | Single tool, consistent interface          |

---

## Practical Workflows

### Setting Up a Python Project

```bash
mkdir ~/Projects/my-python-app && cd $_
mise use python@3.12
python --version   # Python 3.12.x
python -m venv .venv
source .venv/bin/activate
```

### Setting Up a Multi-Language Project

```bash
mkdir ~/Projects/fullstack-app && cd $_
mise use python@3.12 golang@1.22
cat .mise.toml
# [tools]
# python = "3.12"
# golang = "1.22"
```

### Checking What Is Active

```bash
$ mise current
python  3.12.0  ~/Projects/my-app/.mise.toml
golang  1.22.0  ~/Projects/my-app/.mise.toml
```

### Updating a Tool

```bash
mise ls-remote python | tail -5   # see latest versions
mise use python@3.13              # update the config
mise install                      # install the new version
```

---

## Plugins

mise uses a plugin system to support different tools. Most common tools have built-in support (called "core plugins"), which means they work without installing anything extra. For less common tools, mise can use asdf plugins.

To see available plugins:

```bash
mise plugins ls-remote
```

Core plugins (no installation needed) include: Python, Node, Ruby, Go, Java, Erlang, Elixir, and many others.

---

## Troubleshooting

| Problem                              | Solution                                          |
|--------------------------------------|---------------------------------------------------|
| `mise: command not found`            | Run the install script or `brew install mise`     |
| Wrong version active                 | Check `mise current` and `mise doctor`            |
| Version not installing               | Try `mise install --verbose` for detailed output  |
| Slow shell startup                   | Ensure `eval "$(mise activate zsh)"` is used, not shims |
| Config file not detected             | Verify filename: `.mise.toml` or `.tool-versions` |

---

## Quick Reference

```bash
# Install a runtime
mise install python@3.12

# Pin version to current project
mise use python@3.12

# See what is active
mise current

# See all installed versions
mise ls

# Diagnose issues
mise doctor
```

\newpage
