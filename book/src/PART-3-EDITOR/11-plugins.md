# Custom Plugins

> Beyond LazyVim defaults: eight handpicked plugins that fill specific gaps in the editing workflow.

---

## Your Setup

LazyVim ships with a curated set of plugins -- Telescope, neo-tree, Flash, which-key, and many more. zero.dev001 adds eight additional plugins on top of the LazyVim base to handle AI assistance, auto-saving, formatting, database work, habit training, image pasting, scroll behavior, and multiple cursors.

Each plugin is defined in its own file under `lua/plugins/`. This keeps the configuration modular -- you can disable any plugin by deleting its file or adding `enabled = false`.

Plugin source files:

```
~/.config/nvim/lua/plugins/
  99.lua                -- AI integration
  auto-save.lua         -- Automatic saving
  conform.lua           -- Code formatting
  dadbod.lua            -- Database UI
  hardtime.lua          -- Vim habit trainer
  img-clip.lua          -- Image clipboard paste
  stay-centered.lua     -- Cursor centering
  vim-visual-multi.lua  -- Multiple cursors
```

---

## Core Concepts

### Plugin Loading Strategies

Each plugin uses a different lazy-loading strategy suited to when it is needed:

| Plugin            | Loading Strategy                         | Rationale                          |
|-------------------|------------------------------------------|------------------------------------|
| 99.nvim           | On keymap (`keys`)                       | Only load when AI is invoked       |
| auto-save.nvim    | On event (`InsertLeave`, `TextChanged`)  | Active whenever editing            |
| conform.nvim      | LazyVim default + custom autocmd         | Formatting on buffer leave         |
| dadbod            | On command (`DBUI`, `DBUIToggle`)        | Only when database work begins     |
| hardtime.nvim     | Immediate (no lazy config)               | Must be active from start          |
| img-clip.nvim     | On `VeryLazy` event                      | Available after startup            |
| stay-centered.nvim| Immediate                                | Must be active from start          |
| vim-visual-multi  | On `VeryLazy` event                      | Available after startup            |

### Local Plugins

The 99.nvim plugin is loaded from a local directory rather than a Git repository. Instead of specifying a `"user/repo"` string, it uses the `dir` field:

```lua
{
  dir = vim.fn.expand("~/Developer/zero/workspace/99"),
}
```

This means the plugin code lives alongside other development projects and can be edited and tested in real time without publishing to GitHub.

---

## Essential Commands

### 99.nvim -- AI Integration

| Key            | Mode     | Action                              |
|----------------|----------|-------------------------------------|
| `<leader>mm`   | Normal   | Open model selection picker         |
| `<leader>9v`   | Visual   | Send selection to AI for processing |
| `<leader>9s`   | Normal   | Stop all active AI requests         |

Configuration details:

| Setting    | Value                                       |
|------------|---------------------------------------------|
| Provider   | `ClaudeCodeProvider`                        |
| Model      | `opus-4.6`                                  |
| Source     | `~/Developer/zero/workspace/99`             |

The plugin uses the `ClaudeCodeProvider` from the `99.providers` module, connecting to the Claude API. The model can be changed at runtime with `<leader>mm`, which presents a picker of available models.

Workflow:
1. Select code in Visual mode (`v` or `V`)
2. Press `<leader>9v` to invoke AI on the selection
3. The AI processes the selection and returns a result
4. If a request is taking too long, press `<leader>9s` to cancel

### auto-save.nvim -- Automatic Saving

| Trigger         | Behavior                                  |
|-----------------|-------------------------------------------|
| `InsertLeave`   | Save when exiting Insert mode             |
| `TextChanged`   | Save when text changes in Normal mode     |

This plugin requires zero configuration -- it is a single spec with empty `opts`:

```lua
{
  "okuuuu/auto-save.nvim",
  event = { "InsertLeave", "TextChanged" },
  opts = {},
}
```

The effect is that you never need to manually `:w`. The moment you stop typing or leave Insert mode, the buffer is saved. This pairs naturally with the `conform.nvim` formatting-on-BufLeave strategy: you edit, auto-save fires, you switch buffers, conform formats the buffer you just left.

### conform.nvim -- Code Formatting

| Trigger         | Behavior                                  |
|-----------------|-------------------------------------------|
| `BufLeave`      | Format when switching away from a buffer  |

Key configuration choices:

| Setting              | Value    | Rationale                         |
|----------------------|----------|-----------------------------------|
| `format_on_save`     | `false`  | No formatting on `:w`            |
| `format_after_save`  | `false`  | No formatting after `:w`         |
| `async`              | `true`   | Non-blocking formatting           |
| `lsp_fallback`       | `true`   | Use LSP if no formatter matches   |

The custom autocmd only triggers formatting when the buffer has been modified (`vim.bo[args.buf].modified`), avoiding unnecessary formatter invocations on clean buffers.

This approach means formatting never interrupts your typing flow. You type, auto-save preserves your changes, and when you move to another buffer or file, conform quietly formats what you left behind.

### dadbod -- Database UI

| Key            | Mode     | Action                              |
|----------------|----------|-------------------------------------|
| `<leader>D`    | Normal   | Toggle the database UI panel        |

Supporting commands:

| Command              | Action                               |
|----------------------|--------------------------------------|
| `:DBUI`              | Open the database UI                 |
| `:DBUIToggle`        | Toggle the database UI               |
| `:DBUIAddConnection` | Add a new database connection        |
| `:DBUIFindBuffer`    | Find the DBUI buffer                 |

The dadbod stack consists of three plugins working together:

| Plugin                      | Role                              |
|-----------------------------|-----------------------------------|
| `tpope/vim-dadbod`          | Core database interface           |
| `kristijanhusak/vim-dadbod-ui` | Visual UI for browsing/querying |
| `kristijanhusak/vim-dadbod-completion` | SQL autocompletion     |

Supported filetypes for completion: `sql`, `mysql`, `plsql`.

The UI uses Nerd Font icons (`vim.g.db_ui_use_nerd_fonts = 1`) for a clean visual presentation of database objects.

Workflow:
1. Press `<leader>D` to open the database UI
2. Add a connection string (e.g., `postgres://user:pass@localhost/dbname`)
3. Browse tables, views, and schemas in the left panel
4. Write and execute queries in the right panel
5. Results appear inline below your query

### hardtime.nvim -- Vim Habit Trainer

This plugin has no keybindings of its own. Instead, it monitors your editing behavior and discourages inefficient patterns.

What hardtime restricts:

| Bad Habit              | What Happens                          |
|------------------------|---------------------------------------|
| Holding `j` or `k`    | Key is blocked after repeated presses |
| Using arrow keys       | Keys are disabled                     |
| Repeated `h`/`l`      | Blocked -- use `w`, `b`, `f` instead |
| Using `x` repeatedly  | Suggests `dw` or `diw` instead       |

The plugin uses `nui.nvim` to display hints about better alternatives. The goal is to build muscle memory for efficient vim motions. Over time, the restrictions train you to reach for word motions (`w`, `b`, `e`), find motions (`f`, `t`), and text objects (`ciw`, `da(`) instead of character-by-character navigation.

### img-clip.nvim -- Image Clipboard Paste

| Key            | Mode     | Action                              |
|----------------|----------|-------------------------------------|
| `<leader>p`    | Normal   | Paste image from system clipboard   |

Configuration:

| Setting                    | Value    | Effect                        |
|----------------------------|----------|-------------------------------|
| `embed_image_as_base64`    | `false`  | Save as file, not inline data |
| `prompt_for_file_name`     | `false`  | Auto-generate filename        |
| `drag_and_drop.insert_mode`| `true`   | Support drag-and-drop in Insert |
| `use_absolute_path`        | `false`  | Use relative paths in links   |

Workflow:
1. Copy an image to the system clipboard (screenshot, browser image, etc.)
2. Position the cursor where you want the image reference
3. Press `<leader>p`
4. The image is saved to disk and a markdown/markup reference is inserted

This is particularly useful when writing documentation or markdown files -- screenshot something, switch to Neovim, and paste.

### stay-centered.nvim -- Cursor Centering

This plugin has no keybindings. It automatically keeps the cursor line vertically centered in the window as you scroll. This is equivalent to having `scrolloff` set to a very high value, but implemented more smoothly.

The effect: as you move through a file with `j`, `k`, `Ctrl+D`, `Ctrl+U`, or any other motion, the screen scrolls to keep your cursor in the middle of the viewport. You always see equal amounts of context above and below your current position.

```lua
{
  "arnamak/stay-centered.nvim",
  opts = {},
}
```

### vim-visual-multi -- Multiple Cursors

| Key        | Mode     | Action                                 |
|------------|----------|----------------------------------------|
| `Ctrl+N`   | Normal   | Add cursor on current word             |
| `n`        | Multi    | Add next occurrence                    |
| `N`        | Multi    | Add previous occurrence                |
| `q`        | Multi    | Skip current and move to next          |
| `[`/`]`    | Multi    | Navigate between cursors               |
| `Ctrl+Down`| Normal   | Add cursor below                       |
| `Ctrl+Up`  | Normal   | Add cursor above                       |
| `Tab`      | Multi    | Switch between cursor and extend mode  |

Workflow for renaming a variable:
1. Place cursor on the variable name
2. Press `Ctrl+N` to select the word and enter multi-cursor mode
3. Press `n` repeatedly to select additional occurrences
4. Press `q` to skip any occurrence you do not want to change
5. Press `c` to change all selected occurrences simultaneously
6. Type the new name
7. Press `Esc` to exit

This is faster than search-and-replace for targeted, visual renaming where you want to confirm each occurrence.

---

## Practical Recipes

### The Auto-Save and Format Pipeline

The interaction between auto-save and conform creates a seamless editing pipeline:

```
Type code -> Leave Insert mode -> auto-save fires -> buffer saved
Switch to another buffer -> BufLeave fires -> conform formats async
Return to original buffer -> see formatted code
```

This means you never think about saving or formatting. Both happen automatically as a side effect of normal editing behavior.

### Database Exploration with Dadbod

A typical database exploration session:

1. Open the UI: `<leader>D`
2. Add connection: type the connection string in the prompt
3. Expand the connection in the tree to see schemas and tables
4. Press Enter on a table to see its structure
5. Open a new query buffer and write SQL
6. Execute the query with the dadbod execute command
7. Results render in a split below

The completion plugin provides table names, column names, and SQL keywords as you type in query buffers.

### Multi-Cursor Editing Patterns

**Add the same text to multiple lines:**

1. Move to the first target line
2. `Ctrl+Down` repeatedly to add cursors on consecutive lines
3. `I` to enter Insert mode at line start (or `A` for line end)
4. Type your addition
5. `Esc` to apply to all lines

**Change a function signature across calls:**

1. Place cursor on the function name
2. `Ctrl+N` to start multi-cursor on the word
3. `n` to find each additional call site
4. `q` to skip any site you want to leave unchanged
5. Use any vim editing command -- all cursors execute it simultaneously

---

## Advanced Usage

### Disabling Plugins Temporarily

To disable hardtime for a session when you need to hold `j` to scan a long file:

```vim
:Hardtime disable
```

Re-enable with:

```vim
:Hardtime enable
```

### Conform Formatter Selection

Conform picks formatters based on filetype. If no specific formatter is configured for a filetype, the `lsp_fallback = true` setting means it will ask the active LSP server to format instead. You can check which formatter will be used:

```vim
:ConformInfo
```

This shows the active formatters for the current buffer, their availability, and whether they are installed.

### Plugin Update Workflow

All custom plugins (except the local 99.nvim) are managed by lazy.nvim:

1. Press `<leader>l` to open the Lazy UI
2. Press `C` to check for updates
3. Press `U` to update all plugins
4. Review changes in the UI -- each plugin shows its recent commits
5. If something breaks, the lockfile (`lazy-lock.json`) lets you revert

The 99.nvim plugin, being local, is updated by pulling changes in its source directory (`~/Developer/zero/workspace/99`) with git.

### Writing Your Own Plugin Spec

To add a new plugin to this configuration:

1. Create a new file in `lua/plugins/` (e.g., `lua/plugins/my-plugin.lua`)
2. Return a spec table:

```lua
return {
  "author/plugin-name",
  event = "VeryLazy",        -- or keys, cmd, ft
  opts = {
    -- plugin options here
  },
}
```

3. Restart Neovim or run `:Lazy sync`
4. The plugin installs and loads automatically

For a local plugin under development:

```lua
return {
  dir = vim.fn.expand("~/Developer/my-plugin"),
  config = function()
    require("my-plugin").setup({})
  end,
}
```

The `dir` field tells lazy.nvim to load from a local path instead of cloning a repository.

\newpage
