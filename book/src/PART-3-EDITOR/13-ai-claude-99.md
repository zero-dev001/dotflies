# AI Integration: Claude and 99.nvim

> AI as a resident collaborator -- embedded in the editor, running beside it in the terminal, and woven into every coding session.

---

## Your Setup

zero.dev001's AI workflow has two layers: **99.nvim** inside Neovim for inline AI assistance, and **Claude Code** running as a CLI tool in a dedicated tmux pane. Together they create an environment where AI is always one keystroke or one pane switch away.

The 99.nvim plugin:

```
Source: ~/Developer/zero/workspace/99
Provider: ClaudeCodeProvider
Model: opus-4.6
```

The IDE tmux layout:

```
+--------+----------------------------+
| 20%    |        Neovim (80%)        |
|        |                            |
| Claude +----------------------------+
|        |      Terminal (20%)        |
+--------+----------------------------+
```

This layout is created by the `ide()` shell function, which uses tmuxinator to launch three panes with precise sizing.

---

## Core Concepts

### 99.nvim Architecture

99.nvim is a custom Neovim plugin developed locally. It is not published to a package registry -- it lives in zero.dev001's development workspace at `~/Developer/zero/workspace/99` and is loaded by lazy.nvim via the `dir` field.

The plugin follows a provider pattern:

- **Providers** abstract the AI backend. The `ClaudeCodeProvider` connects to the Claude API.
- **Models** are selectable at runtime. The default is `opus-4.6`, but any model the provider supports can be chosen via the picker.
- **Visual mode integration** is the primary interaction: select code, invoke AI, receive a response.

The plugin configuration in `lua/plugins/99.lua`:

```lua
return {
  {
    dir = vim.fn.expand("~/Developer/zero/workspace/99"),
    config = function()
      require("99").setup({
        provider = require("99.providers").ClaudeCodeProvider,
        model = "opus-4.6",
      })
    end,
    keys = {
      { "<leader>mm", function() require("99").select_model() end,
        desc = "Select AI model" },
      { "<leader>9v", function() require("99").visual() end,
        mode = "v", desc = "99 AI visual" },
      { "<leader>9s", function() require("99").stop_all_requests() end,
        desc = "99 Stop all requests" },
    },
  },
}
```

The `keys` field serves double duty: it defines the keybindings and tells lazy.nvim to lazy-load the plugin only when one of these keys is pressed.

### Claude Code in the Terminal

Claude Code is a CLI tool that provides a conversational AI interface directly in the terminal. It runs as an interactive process in its own tmux pane -- not as a Neovim plugin, but as a separate application sharing the same project context.

Key characteristics:
- Runs in the left 20% pane of the IDE layout
- Has full access to the project filesystem
- Can read files, suggest changes, run commands
- Maintains conversation history within a session
- Understands project context from the working directory

### The IDE Layout

The `ide()` function creates the complete development environment:

```bash
ide() {
  local dir="${1:-.}"
  local name=$(basename "$(cd "$dir" 2>/dev/null && pwd)")
  tmuxinator start ide "$dir" --no-attach
  tmux resize-pane -t "$name:1.0" -x '20%'
  tmux resize-pane -t "$name:1.2" -y '20%'
  tmux select-pane -t "$name:1.1"
  tmux rename-window -t "$name:1" "$name"
  tmux attach-session -t "$name"
}
```

The tmuxinator template (`~/.config/tmuxinator/ide.yml`) defines:

| Pane      | Content     | Position         | Size |
|-----------|-------------|------------------|------|
| Pane 0    | `claude`    | Left             | 20%  |
| Pane 1    | `nvim .`    | Right top        | 80%  |
| Pane 2    | Terminal    | Right bottom     | 20%  |

After tmuxinator creates the layout, the `ide()` function resizes panes to exact proportions, selects the Neovim pane as active, and renames the tmux window to the project name.

---

## Essential Commands

### 99.nvim Key Mappings

| Key            | Mode     | Action                              |
|----------------|----------|-------------------------------------|
| `<leader>mm`   | Normal   | Open model selection picker         |
| `<leader>9v`   | Visual   | Send visual selection to AI         |
| `<leader>9s`   | Normal   | Stop all active AI requests         |

### IDE Layout Commands

| Command            | Action                                  |
|--------------------|-----------------------------------------|
| `ide`              | Start IDE layout in current directory   |
| `ide ~/Projects/x` | Start IDE layout in specified directory |
| `Ctrl+H`          | Move to left pane (Claude Code)         |
| `Ctrl+L`          | Move to right pane (Neovim)             |
| `Ctrl+J`          | Move to pane below (Terminal)           |
| `Ctrl+K`          | Move to pane above                      |

The `Ctrl+H/J/K/L` navigation works seamlessly between Neovim splits and tmux panes thanks to vim-tmux-navigator. Pressing `Ctrl+H` from Neovim will cross the tmux pane boundary into the Claude Code pane on the left.

### Claude Code Terminal Commands

These are run directly in the Claude Code pane or any terminal:

| Command                | Action                              |
|------------------------|-------------------------------------|
| `claude`               | Start a new Claude Code session     |
| `claude "question"`    | Ask a one-off question              |
| `/help`                | Show available commands             |
| `/clear`               | Clear conversation history          |
| `Ctrl+C`               | Cancel current response             |

---

## Practical Recipes

### Using 99.nvim for Code Transformation

The primary workflow for in-editor AI:

1. Navigate to the code you want to transform
2. Enter Visual mode with `v` (character), `V` (line), or use text objects
3. Select the relevant code block
4. Press `<leader>9v` to send the selection to the AI
5. The AI processes the selection and returns a result
6. Review the output

Example scenarios:
- Select a function and ask for a refactored version
- Select a block of code and request an explanation
- Select a data structure and request a type definition
- Select a test and request additional test cases

### Switching AI Models

Different tasks may benefit from different models:

1. Press `<leader>mm` in Normal mode
2. A picker appears showing available models
3. Select the model best suited for your current task
4. The model change takes effect immediately for subsequent requests

The default `opus-4.6` is the most capable model, but switching to a faster model can be useful for simple transformations where speed matters more than depth.

### Stopping a Runaway Request

If an AI request is taking too long or you realize you sent the wrong selection:

1. Press `<leader>9s` in Normal mode
2. All active requests are cancelled immediately
3. You can make a new selection and try again

### The Complete IDE Workflow

A full development session with AI integration:

1. **Start the environment**: `ide ~/Projects/myapp`
2. **Three panes appear**: Claude on the left, Neovim in the center-right, terminal below
3. **Code in Neovim**: Edit files, navigate with LSP, use all the tools from previous chapters
4. **Consult Claude Code**: Press `Ctrl+H` to switch to the Claude pane, ask a question about architecture or debugging, read the response
5. **Return to Neovim**: Press `Ctrl+L` to switch back, apply what you learned
6. **Use 99.nvim for inline tasks**: Select code, press `<leader>9v`, get an AI-assisted transformation without leaving the editor
7. **Run commands**: Press `Ctrl+J` to drop to the terminal pane, run tests or build commands, press `Ctrl+K` to return

This three-pane setup means AI is always visible in your peripheral vision. You can glance left to reference a previous Claude response while editing, or switch to the terminal to verify a suggestion.

### AI-Assisted Debugging

When you encounter a bug:

1. In Neovim, select the problematic code with Visual mode
2. Press `<leader>9v` for a quick inline analysis
3. For deeper investigation, switch to the Claude pane with `Ctrl+H`
4. Paste error messages, stack traces, or describe the behavior
5. Claude Code can read the project files to understand context
6. Switch back to Neovim with `Ctrl+L` and apply the fix
7. Drop to the terminal with `Ctrl+J` to run tests

### AI-Assisted Code Review

When reviewing code changes:

1. Open lazygit with `<leader>gg` in Neovim
2. Review diffs in the lazygit interface
3. For complex changes, switch to the Claude pane
4. Ask Claude to analyze the diff or explain the implications
5. Return to lazygit to approve, comment, or request changes

---

## Advanced Usage

### Developing 99.nvim

Since 99.nvim is a local plugin, development happens in real time:

1. Open the plugin source: `nvim ~/Developer/zero/workspace/99`
2. Make changes to the plugin code
3. In your project Neovim instance, reload with `:Lazy reload 99.nvim` or restart Neovim
4. Test the changes immediately

The lazy.nvim `dir` field means there is no install or build step -- Neovim reads the plugin source directly from disk. Changes to the plugin take effect on the next load.

### Provider System

The `99.providers` module abstracts AI backends. The `ClaudeCodeProvider` is the active provider, but the architecture supports swapping in different providers:

```lua
require("99").setup({
  provider = require("99.providers").ClaudeCodeProvider,
  model = "opus-4.6",
})
```

To switch providers, you would change the `provider` field to a different provider module. The `select_model()` function presents models available from the currently configured provider.

### Optimizing the IDE Layout

The default layout gives Claude 20% width, which is roughly 40 columns on a standard screen. This is enough for reading responses and short queries. Adjustments:

- For a wider Claude pane: modify the `tmux resize-pane` percentage in the `ide()` function
- For a taller terminal: change the `-y '20%'` value for pane 2
- For no terminal pane: modify the tmuxinator template to only create two panes

The tmuxinator template at `~/.config/tmuxinator/ide.yml`:

```yaml
name: <%= File.basename(File.expand_path(@args[0] || ".")) %>
root: <%= @args[0] || "." %>

windows:
  - code:
      layout: main-vertical
      panes:
        - claude
        - nvim .
        - # terminal
```

The template accepts a directory argument, names the session after the directory, and sets the root for all panes to that directory. This means Claude Code, Neovim, and the terminal all start in the same project root.

### Contextual AI Usage Patterns

Different situations call for different AI interaction patterns:

| Situation                  | Best Tool         | Approach                       |
|----------------------------|-------------------|--------------------------------|
| Refactor a single function | 99.nvim           | Select + `<leader>9v`          |
| Understand a codebase      | Claude Code       | Conversational exploration     |
| Debug an error             | Claude Code       | Paste error, discuss context   |
| Generate boilerplate       | Either            | Describe what you need         |
| Review a diff              | Claude Code       | Paste or describe the changes  |
| Quick type annotation      | 99.nvim           | Select code, request types     |
| Architecture decisions     | Claude Code       | Extended conversation          |

The rule of thumb: use 99.nvim for targeted, code-level transformations where you can select exactly what you want processed. Use Claude Code for exploratory conversations, debugging sessions, and architectural discussions where context builds over multiple exchanges.

### Security Considerations

Both AI tools interact with your code:

- **99.nvim** sends selected code to the Claude API via the ClaudeCodeProvider
- **Claude Code** can read files in the project directory

Be aware of what you send to AI services. Avoid selecting and sending sensitive credentials, API keys, or proprietary algorithms that should not leave your machine. The AI tools are powerful collaborators, but they communicate over the network.

\newpage
