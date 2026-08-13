# LazyVim Distribution

> A batteries-included Neovim configuration that provides IDE features out of the box while staying fast and extensible.

---

## Your Setup

zero.dev001's Neovim runs the LazyVim distribution -- a pre-configured Neovim setup built on the lazy.nvim plugin manager. LazyVim provides sensible defaults for dozens of plugins, a consistent keymap system organized around the Space leader key, and an "extras" system for opting into language-specific tooling.

The configuration lives at:

```
Source:   ~/.local/share/chezmoi/dot_config/nvim/
Deployed: ~/.config/nvim/
```

The directory structure follows LazyVim conventions:

```
~/.config/nvim/
  init.lua                    -- Entry point, loads lazy.nvim
  lua/
    config/
      autocmds.lua            -- Custom autocommands
      keymaps.lua             -- Custom key mappings
      lazy.lua                -- lazy.nvim bootstrap and setup
      options.lua             -- Neovim options
    plugins/
      99.lua                  -- AI plugin (99.nvim)
      auto-save.lua           -- Auto-save on buffer changes
      conform.lua             -- Formatter configuration
      dadbod.lua              -- Database UI
      hardtime.lua            -- Vim habit trainer
      img-clip.lua            -- Image paste from clipboard
      stay-centered.lua       -- Keep cursor centered
      vim-visual-multi.lua    -- Multiple cursors
      example.lua             -- LazyVim example (disabled)
```

The bootstrap in `lazy.lua` loads LazyVim first, then imports custom plugins:

```lua
require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "plugins" },
  },
})
```

Plugin updates are checked automatically but silently -- the `checker` runs periodically with `notify = false`.

---

## Core Concepts

### The Leader Key

The leader key is **Space**. Nearly every LazyVim command starts with it. When you press Space and pause, **which-key** pops up a floating window showing every available mapping and its description. This means you never need to memorize keybindings from scratch -- press Space, read the menu, and pick the action you want.

The which-key groups are organized mnemonically:

| Prefix         | Group                          |
|----------------|--------------------------------|
| `<leader>f`    | **Find/File** (telescope)      |
| `<leader>s`    | **Search** (grep, symbols)     |
| `<leader>b`    | **Buffer**                     |
| `<leader>c`    | **Code** (LSP actions)         |
| `<leader>g`    | **Git**                        |
| `<leader>u`    | **UI** (toggles)               |
| `<leader>x`    | **Diagnostics** (trouble)      |
| `<leader>w`    | **Window**                     |
| `<leader>l`    | **Lazy** (plugin manager)      |
| `<leader>q`    | **Quit/Session**               |

### lazy.nvim Package Manager

lazy.nvim is the plugin manager underneath LazyVim. It handles downloading, updating, lazy-loading, and profiling plugins.

Key features:
- **Lazy-loading**: Plugins load on demand -- on specific events, commands, keymaps, or filetypes. This keeps startup fast.
- **Lockfile**: `lazy-lock.json` pins every plugin to a specific commit, ensuring reproducible installs.
- **Profiling**: The Lazy UI shows exactly how long each plugin takes to load.

### The Extras System

LazyVim provides "extras" -- optional plugin bundles for languages, tools, and UI features. Extras are imported in the plugin spec:

```lua
{ import = "lazyvim.plugins.extras.lang.typescript" }
{ import = "lazyvim.plugins.extras.lang.json" }
{ import = "lazyvim.plugins.extras.ui.mini-starter" }
```

You can browse and toggle extras from the Lazy UI with `<leader>l` then navigating to the Extras tab.

---

## Essential Commands

### File Finding (Telescope)

| Key              | Action                                    |
|------------------|-------------------------------------------|
| `<leader>ff`     | Find files in project                     |
| `<leader>fr`     | Find recent files                         |
| `<leader>fg`     | Live grep across project                  |
| `<leader>fb`     | Find open buffers                         |
| `<leader>fc`     | Find Neovim config files                  |
| `<leader>fp`     | Find plugin files                         |
| `<leader>f/`     | Search in current buffer                  |
| `<leader><space>`| Find files (alias for `<leader>ff`)       |

Inside a Telescope picker:

| Key              | Action                                    |
|------------------|-------------------------------------------|
| `Ctrl+J / Ctrl+K`| Move up/down in results                  |
| `Enter`          | Open selected file                        |
| `Ctrl+X`         | Open in horizontal split                  |
| `Ctrl+V`         | Open in vertical split                    |
| `Ctrl+T`         | Open in new tab                           |
| `Esc`            | Close picker (in Normal mode)             |

### File Explorer (neo-tree)

| Key              | Action                                    |
|------------------|-------------------------------------------|
| `<leader>e`      | Toggle file explorer (focus)              |
| `<leader>E`      | Toggle file explorer (root dir)           |

Inside neo-tree:

| Key       | Action                                       |
|-----------|----------------------------------------------|
| `Enter`   | Open file/expand directory                   |
| `a`       | Add file (end with `/` for directory)        |
| `d`       | Delete                                       |
| `r`       | Rename                                       |
| `c`       | Copy                                         |
| `m`       | Move                                         |
| `y`       | Copy file name                               |
| `Y`       | Copy relative path                           |
| `H`       | Toggle hidden files                          |
| `/`       | Filter/search                                |
| `q`       | Close                                        |

### Buffer Management

| Key              | Action                                    |
|------------------|-------------------------------------------|
| `<leader>bb`     | Switch buffer (picker)                    |
| `<leader>bd`     | Delete current buffer                     |
| `<leader>bo`     | Delete other buffers                      |
| `H`              | Previous buffer                           |
| `L`              | Next buffer                               |
| `<leader>,`      | Switch buffer (alternative)               |

### Search and Replace

| Key              | Action                                    |
|------------------|-------------------------------------------|
| `<leader>sg`     | Grep across project (Telescope)           |
| `<leader>sw`     | Search word under cursor                  |
| `<leader>ss`     | Search document symbols                   |
| `<leader>sS`     | Search workspace symbols                  |
| `<leader>sr`     | Search and replace (grug-far)             |
| `<leader>sd`     | Search diagnostics                        |
| `<leader>sh`     | Search help tags                          |
| `<leader>sk`     | Search keymaps                            |
| `<leader>sm`     | Search marks                              |

### Navigation

| Key              | Action                                    |
|------------------|-------------------------------------------|
| `s`              | Flash jump (type 2 chars to jump)         |
| `S`              | Flash treesitter selection                |
| `Ctrl+H`         | Navigate to left split/tmux pane          |
| `Ctrl+J`         | Navigate to split/tmux pane below         |
| `Ctrl+K`         | Navigate to split/tmux pane above         |
| `Ctrl+L`         | Navigate to right split/tmux pane         |

The `Ctrl+H/J/K/L` bindings work seamlessly between Neovim splits and tmux panes via **vim-tmux-navigator**. You never need to think about whether you are crossing a Neovim split boundary or a tmux pane boundary -- the same keys handle both.

### Git Integration

| Key              | Action                                    |
|------------------|-------------------------------------------|
| `<leader>gg`     | Open lazygit                              |
| `<leader>gf`     | Lazygit current file history              |
| `<leader>gb`     | Git blame line                            |
| `<leader>gB`     | Git browse (open in browser)              |
| `]h`             | Next git hunk                             |
| `[h`             | Previous git hunk                         |
| `<leader>ghp`    | Preview hunk                              |
| `<leader>ghs`    | Stage hunk                                |
| `<leader>ghr`    | Reset hunk                                |

### UI Toggles

| Key              | Action                                    |
|------------------|-------------------------------------------|
| `<leader>uf`     | Toggle auto-format                        |
| `<leader>uw`     | Toggle word wrap                          |
| `<leader>ul`     | Toggle line numbers                       |
| `<leader>uL`     | Toggle relative line numbers              |
| `<leader>us`     | Toggle spell check                        |
| `<leader>ud`     | Toggle diagnostics                        |
| `<leader>uc`     | Toggle conceal                            |
| `<leader>uh`     | Toggle inlay hints                        |

---

## Practical Recipes

### Quick File Navigation Workflow

The fastest way to open files depends on context:

1. **You know the filename**: `<leader>ff`, type part of the name, Enter.
2. **You were just editing it**: `<leader>fr` for recent files.
3. **You need to find text**: `<leader>sg` to grep, then open the result.
4. **You want to browse the tree**: `<leader>e` to open neo-tree.
5. **You are switching between two files**: `H` and `L` to bounce between buffers.

### Project-Wide Search and Replace

Using grug-far (`<leader>sr`):

1. Press `<leader>sr` to open the search and replace panel.
2. Type the search pattern in the first field.
3. Type the replacement in the second field.
4. Preview results in the buffer below.
5. Apply replacements selectively or globally.

This is significantly more ergonomic than `:s` commands for multi-file replacements.

### Flash Jump

Flash replaces the traditional `f`/`t` motions with a two-character search:

1. Press `s` in Normal mode.
2. Type the first character of your target -- labels appear on all matches.
3. Type the label character to jump directly there.

Flash also works as an operator motion: `ds{char}{label}` deletes from cursor to the labeled position. `ys{char}{label}` yanks from cursor to the label.

### Managing the Plugin System

| Command          | Effect                                    |
|------------------|-------------------------------------------|
| `<leader>l`      | Open Lazy plugin manager UI               |
| `:Lazy sync`     | Update all plugins                        |
| `:Lazy profile`  | Show startup profiling                    |
| `:Lazy health`   | Check plugin health                       |

Inside the Lazy UI:
- **S** to sync (install/update/clean)
- **U** to update all
- **X** to clean removed plugins
- **p** to show profiling
- **i** to install missing plugins

### Overriding LazyVim Defaults

To override a LazyVim plugin, create a file in `lua/plugins/` that returns a spec for the same plugin. The `opts` tables are deep-merged:

```lua
-- lua/plugins/my-override.lua
return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      layout_strategy = "horizontal",
    },
  },
}
```

To disable a LazyVim plugin entirely:

```lua
return {
  { "some/plugin.nvim", enabled = false },
}
```

---

## Advanced Usage

### The Plugin Spec Format

Every plugin in lazy.nvim is defined by a spec table. The most common fields:

| Field           | Purpose                                    |
|-----------------|--------------------------------------------|
| `[1]` (string)  | Plugin repository (`"user/repo"`)         |
| `dir`           | Local directory path (for local plugins)  |
| `opts`          | Options table passed to `plugin.setup()`  |
| `config`        | Function called when plugin loads          |
| `keys`          | Keymaps (also triggers lazy-loading)       |
| `cmd`           | Commands (triggers lazy-loading)           |
| `event`         | Events (triggers lazy-loading)             |
| `ft`            | Filetypes (triggers lazy-loading)          |
| `dependencies`  | Plugins loaded before this one             |
| `lazy`          | Boolean to force lazy-load behavior        |
| `enabled`       | Boolean or function to enable/disable      |
| `branch`        | Git branch to use                          |

### Performance Notes

LazyVim with all of zero.dev001's custom plugins starts in under 100ms on modern hardware. The key performance strategies:

- Most custom plugins are lazy-loaded via `event`, `cmd`, or `keys`
- The `checker` runs in the background with notifications disabled
- Disabled runtime plugins: `gzip`, `tarPlugin`, `tohtml`, `tutor`, `zipPlugin`
- lazy.nvim caches module resolution for faster subsequent loads

### Session Management

| Key              | Action                                    |
|------------------|-------------------------------------------|
| `<leader>qs`     | Restore session for current directory     |
| `<leader>ql`     | Restore last session                      |
| `<leader>qd`     | Quit and delete session                   |
| `<leader>qq`     | Quit all                                  |

LazyVim auto-saves sessions so you can close Neovim and reopen exactly where you left off.

### Startup Sequence

When Neovim launches, the following happens in order:

1. `init.lua` runs, loading `config/lazy.lua`
2. lazy.nvim bootstraps itself if not installed
3. LazyVim core plugins load (which-key, telescope, neo-tree, etc.)
4. Custom plugins from `lua/plugins/` are merged and loaded
5. `config/options.lua`, `config/keymaps.lua`, and `config/autocmds.lua` execute on `VeryLazy` event
6. Lazy-loaded plugins wait for their trigger conditions

Understanding this sequence matters when debugging load order issues or when a keymap needs to override a plugin's default.

\newpage
