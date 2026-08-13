# LSP and Treesitter

> Two technologies that transform Neovim from a text editor into a language-aware development environment.

---

## Your Setup

LazyVim pre-configures both LSP (Language Server Protocol) and Treesitter with sensible defaults. zero.dev001's setup uses the LazyVim defaults for both -- no custom overrides in `options.lua`, `keymaps.lua`, or `autocmds.lua` for these features. The LSP and Treesitter configuration comes entirely from LazyVim's built-in specs and any language extras that are imported.

The relevant LazyVim plugins:

| Plugin                          | Role                                    |
|---------------------------------|-----------------------------------------|
| `neovim/nvim-lspconfig`         | LSP client configuration                |
| `williamboman/mason.nvim`       | Package manager for LSP servers, formatters, linters |
| `williamboman/mason-lspconfig.nvim` | Bridge between Mason and lspconfig  |
| `nvim-treesitter/nvim-treesitter`  | Treesitter integration              |
| `folke/trouble.nvim`            | Pretty diagnostics list                 |
| `stevearc/conform.nvim`         | Formatting (configured in plugins/conform.lua) |

---

## Core Concepts

### What Is LSP?

The Language Server Protocol is a standard that lets editors communicate with language-specific servers. Instead of every editor implementing its own Go analyzer, TypeScript checker, or Python linter, a single language server provides:

- **Completions** -- context-aware suggestions as you type
- **Diagnostics** -- errors and warnings in real time
- **Go to definition** -- jump to where a symbol is defined
- **Find references** -- list everywhere a symbol is used
- **Hover documentation** -- show type signatures and docs
- **Code actions** -- automated refactors, quick fixes, import organization
- **Rename** -- rename a symbol across the entire project
- **Formatting** -- language-standard code formatting

The editor sends requests to the server; the server responds with structured data. Neovim's built-in LSP client handles the protocol. LazyVim and Mason handle the configuration and installation.

### What Is Treesitter?

Treesitter is a parser generator that builds concrete syntax trees for source code. Traditional syntax highlighting in vim uses regular expressions -- patterns like "a word after `function` is a function name." These patterns are fragile, slow, and frequently wrong.

Treesitter parses the actual grammar of each language and produces an AST (Abstract Syntax Tree). This gives Neovim:

- **Accurate highlighting** -- every token is highlighted based on its grammatical role, not a regex guess
- **Structural navigation** -- move between functions, classes, parameters, and other language constructs
- **Incremental selection** -- expand or shrink selections along AST boundaries
- **Text objects** -- `function`, `class`, `parameter`, `block`, and other language-aware selections
- **Folding** -- fold code based on syntax structure, not indentation
- **Indentation** -- auto-indent based on the syntax tree

### How They Work Together

LSP and Treesitter complement each other:

| Capability           | LSP                      | Treesitter               |
|----------------------|--------------------------|--------------------------|
| Syntax highlighting  | No                       | Yes (AST-based)          |
| Completions          | Yes (semantic)           | No                       |
| Diagnostics          | Yes (type errors, lint)  | No                       |
| Go to definition     | Yes (cross-file)         | No                       |
| Text objects          | No                      | Yes (function, class)    |
| Incremental selection| No                       | Yes                      |
| Code actions         | Yes (refactoring)        | No                       |
| Folding              | No                       | Yes (syntax-based)       |
| Indentation          | No                       | Yes (syntax-based)       |
| Rename symbol        | Yes (project-wide)       | No                       |

You want both. Treesitter handles the visual and structural aspects; LSP handles the semantic and project-wide intelligence.

---

## Essential Commands

### LSP Navigation

| Key            | Action                                       |
|----------------|----------------------------------------------|
| `gd`           | Go to definition                             |
| `gD`           | Go to declaration                            |
| `gr`           | Go to references (list all usages)           |
| `gI`           | Go to implementation                         |
| `gy`           | Go to type definition                        |
| `K`            | Hover documentation (show type/docs popup)   |
| `gK`           | Signature help                               |

### LSP Code Actions

| Key               | Action                                    |
|-------------------|-------------------------------------------|
| `<leader>ca`      | Code action (quick fixes, refactors)      |
| `<leader>cA`      | Source action (organize imports, etc.)     |
| `<leader>cr`      | Rename symbol (project-wide)              |
| `<leader>cf`      | Format document                           |
| `<leader>cl`      | LSP info (show active servers)            |

### Diagnostics

| Key               | Action                                    |
|-------------------|-------------------------------------------|
| `<leader>cd`      | Line diagnostics (show error popup)       |
| `]d`              | Next diagnostic                           |
| `[d`              | Previous diagnostic                       |
| `]e`              | Next error                                |
| `[e`              | Previous error                            |
| `]w`              | Next warning                              |
| `[w`              | Previous warning                          |
| `<leader>xx`      | Toggle Trouble (diagnostics panel)        |
| `<leader>xX`      | Buffer diagnostics (Trouble)              |
| `<leader>xL`      | Location list (Trouble)                   |
| `<leader>xQ`      | Quickfix list (Trouble)                   |

### Mason Package Manager

| Key / Command     | Action                                    |
|-------------------|-------------------------------------------|
| `<leader>cm`      | Open Mason UI                             |
| `:Mason`          | Open Mason UI (same)                      |
| `:MasonInstall {name}` | Install a specific package            |
| `:MasonUninstall {name}` | Uninstall a package                 |
| `:MasonUpdate`    | Update all packages                       |

Inside the Mason UI:

| Key    | Action                                         |
|--------|-------------------------------------------------|
| `i`    | Install package under cursor                    |
| `u`    | Update package                                  |
| `X`    | Uninstall package                               |
| `Ctrl+F` | Filter by category                           |
| `1-5`  | Filter by category number                       |

### Treesitter

| Key / Command          | Action                              |
|------------------------|-------------------------------------|
| `Enter`                | Initialize incremental selection    |
| `Enter` (again)        | Expand selection to next AST node   |
| `Backspace`            | Shrink selection to previous node   |
| `:TSInstall {lang}`    | Install a language parser           |
| `:TSUpdate`            | Update all installed parsers        |
| `:TSInstallInfo`       | Show installed/available parsers    |
| `:InspectTree`         | Show the syntax tree for current buffer |

---

## Practical Recipes

### Navigating a Codebase with LSP

A typical code exploration workflow:

1. Open a file and place cursor on a function call
2. Press `gd` to jump to its definition (may open another file)
3. Read the implementation, press `K` to see type info
4. Press `gr` to see everywhere this function is called
5. Select a reference from the list and jump to it
6. Press `Ctrl+O` to jump back through the navigation stack
7. Press `Ctrl+I` to jump forward again

The jump list (`Ctrl+O` / `Ctrl+I`) is your history of positions. Every `gd`, `gr`, or search creates a jump entry, so you can always retrace your steps.

### Rename a Symbol Safely

1. Place cursor on the variable, function, or type name
2. Press `<leader>cr` to trigger rename
3. Type the new name in the popup
4. Press `Enter` to confirm
5. The LSP renames every occurrence across every file in the project

This is semantically aware -- it renames the symbol, not the string. A variable named `count` inside a function will not rename the word "count" in a comment or in an unrelated scope.

### Understanding Diagnostics

When the LSP reports an error, you will see:

- A red (or yellow for warnings) marker in the sign column on the left
- Underlined text at the error location
- A virtual text hint at the end of the line (if enabled)

To read the full diagnostic message:

1. Move cursor to the error line
2. Press `<leader>cd` to open the diagnostic float
3. Read the full error message and any suggested fixes
4. Press `<leader>ca` to see available code actions (auto-fixes)

To cycle through all diagnostics: `]d` moves to the next, `[d` moves to the previous. To jump only between errors (skipping warnings): `]e` and `[e`.

### Incremental Selection with Treesitter

Treesitter incremental selection lets you expand a selection along AST boundaries:

1. Place cursor inside a string: `"hello world"`
2. Press `Enter` to start selection -- selects `hello world`
3. Press `Enter` again -- selects `"hello world"` (including quotes)
4. Press `Enter` again -- selects the entire function argument list
5. Press `Enter` again -- selects the entire function call
6. Press `Backspace` to shrink back one level

This is far more precise than visual mode because it understands the syntax structure. You never accidentally select half a bracket pair or miss a closing tag.

### Inspecting the Syntax Tree

To understand how Treesitter sees your code:

1. Open any source file
2. Run `:InspectTree`
3. A split opens showing the full AST
4. Move your cursor in the source -- the corresponding AST node highlights
5. Move your cursor in the tree -- the corresponding source highlights

This is invaluable for debugging highlighting issues, writing custom queries, or understanding why a text object selects a certain range.

---

## Advanced Usage

### Common Language Servers

LazyVim auto-installs servers for languages you use. Here are the most common ones in zero.dev001's workflow:

| Language    | Server                      | Provides                          |
|-------------|-----------------------------|-----------------------------------|
| TypeScript  | `typescript-language-server` | Types, completions, diagnostics   |
| Lua         | `lua-language-server`        | Neovim API awareness              |
| JSON        | `json-lsp`                   | Schema validation, completions    |
| CSS         | `css-lsp`                    | Properties, values, diagnostics   |
| HTML        | `html-lsp`                   | Tags, attributes, completions     |
| ESLint      | `eslint`                     | Linting, auto-fix on save         |
| Tailwind    | `tailwindcss-language-server`| Class completions, hover preview  |
| Go          | `gopls`                      | Full Go intelligence              |
| Python      | `pyright`                    | Type checking, completions        |
| Bash        | `bash-language-server`       | Shell script intelligence         |
| YAML        | `yaml-language-server`       | Schema validation                 |

### Mason-Managed Tools

Mason manages more than just LSP servers. It also handles:

| Category    | Examples                                   |
|-------------|--------------------------------------------|
| LSP servers | All servers listed above                   |
| Formatters  | `stylua`, `prettier`, `shfmt`, `black`     |
| Linters     | `shellcheck`, `flake8`, `eslint_d`         |
| DAP servers | Debug adapters for various languages       |

The `ensure_installed` list in the LazyVim mason config guarantees these tools are available:

```
stylua, shellcheck, shfmt, flake8
```

### Treesitter Text Objects

With Treesitter-powered text objects (provided by `nvim-treesitter-textobjects`), you get language-aware selections:

| Text Object   | Selects                                   |
|---------------|-------------------------------------------|
| `af`          | Around function (including signature)     |
| `if`          | Inside function (body only)               |
| `ac`          | Around class                              |
| `ic`          | Inside class                              |
| `aa`          | Around parameter/argument                 |
| `ia`          | Inside parameter/argument                 |

These work with all operators: `daf` deletes an entire function, `yif` yanks a function body, `caa` changes a function argument.

### Treesitter Navigation

Jump between language constructs:

| Key    | Action                                        |
|--------|-----------------------------------------------|
| `]f`   | Next function start                           |
| `[f`   | Previous function start                       |
| `]c`   | Next class start                              |
| `[c`   | Previous class start                          |
| `]a`   | Next parameter                                |
| `[a`   | Previous parameter                            |

### Diagnostics Severity Configuration

LazyVim configures diagnostic display with virtual text hints. The severity levels and their visual indicators:

| Severity | Sign   | Meaning                                |
|----------|--------|----------------------------------------|
| Error    | Red    | Code will not compile or run           |
| Warning  | Yellow | Potential issue, code still works      |
| Info     | Blue   | Informational hint                     |
| Hint     | Teal   | Suggestion for improvement             |

### Troubleshooting LSP Issues

When an LSP server is not working as expected:

1. Check server status: `<leader>cl` shows attached servers and their status
2. Check health: `:checkhealth lsp` runs diagnostics
3. Check Mason: `<leader>cm` shows installed/available packages
4. View logs: `:LspLog` opens the LSP log file
5. Restart server: `:LspRestart` restarts all attached servers

Common issues:
- **No completions**: The server may still be indexing. Large projects take time.
- **Wrong server attached**: Check `:LspInfo` for which server is active.
- **Missing server**: Run `:MasonInstall {server-name}` to install it.
- **Stale diagnostics**: `:LspRestart` clears the slate.

### Performance Considerations

LSP servers run as separate processes. For large projects:

- TypeScript projects with many files may take several seconds to fully index
- Multiple LSP servers can attach to the same buffer (e.g., TypeScript + ESLint + Tailwind)
- Treesitter parsing is incremental -- it only re-parses what changed, keeping highlighting fast even in large files
- If Neovim feels slow, check `:Lazy profile` and `:LspLog` to identify the bottleneck

\newpage
