# Workflow: Debugging with AI

> Three panes, two AI tools, one problem -- using Claude Code and 99.nvim to diagnose and fix bugs.

---

## Overview

The IDE layout in this environment places two AI tools within reach of the editor at all times. Claude Code runs in a dedicated terminal pane on the left side of the screen, providing conversational AI with full context awareness. The 99.nvim plugin inside Neovim provides visual-mode AI assistance for targeted code analysis. The combination is powerful: use 99.nvim for quick, focused questions about specific code blocks, and use Claude Code for broader context, multi-file reasoning, and complex debugging.

This chapter walks through a typical debugging session that leverages both tools alongside the standard terminal workflow.

---

## The IDE Layout

The debugging workflow assumes the three-pane IDE layout created by the `ide()` function:

```
+--------------------+-----------------------------------+
|                    |                                   |
|   Claude Code      |          Neovim                   |
|   (left pane)     |          (right top pane)         |
|                    |                                   |
|                    |                                   |
|                    |                                   |
|                    +-----------------------------------+
|                    |    Terminal (right bottom pane)    |
+--------------------+-----------------------------------+
```

Each pane serves a specific role in debugging:

- **Claude Code (left):** Long-form reasoning, multi-file analysis, suggesting fixes, explaining unfamiliar code
- **Neovim (right top):** Reading and editing code, navigating to definitions, viewing diagnostics
- **Terminal (right bottom):** Reproducing the bug, running tests, checking logs, verifying fixes

Navigation between panes uses vim-tmux-navigator:

| Key       | Action                         |
|-----------|--------------------------------|
| `Ctrl+h`  | Move to the left pane          |
| `Ctrl+j`  | Move to the pane below         |
| `Ctrl+k`  | Move to the pane above         |
| `Ctrl+l`  | Move to the right pane         |

---

## Step 1: Reproduce the Bug

Start in the terminal pane (`Ctrl+j` from Neovim to move down). Run the failing command, test, or request:

```bash
bun test src/auth.test.ts
```

Or reproduce a runtime error:

```bash
bun dev
# Navigate to the failing route in the browser
# Observe the error in the terminal output
```

Read the error message carefully. Note the file names, line numbers, and stack trace. This information guides every subsequent step.

---

## Step 2: Navigate to the Problem in Neovim

Move to the Neovim pane (`Ctrl+k` to move up). Navigate to the file mentioned in the error:

```
Space+ff  -> type the filename -> Enter
```

Or jump directly:

```vim
:e src/services/auth.ts
```

Once in the file, navigate to the relevant line:

```vim
42G       " Go to line 42
```

Use LSP diagnostics to see if the editor already flags the issue:

| Key         | Action                                    |
|-------------|-------------------------------------------|
| `Space+cd`  | Show diagnostics for the current line     |
| `]d`        | Jump to the next diagnostic               |
| `[d`        | Jump to the previous diagnostic           |
| `K`         | Show hover info for the symbol under cursor |
| `gd`        | Go to the definition of a function/type   |
| `gr`        | Find all references to a symbol           |

Often, the LSP catches type errors, undefined variables, or import issues that explain the bug directly.

---

## Step 3: Ask 99.nvim About Specific Code

When you have identified a suspicious code block but do not understand why it fails, use 99.nvim's visual mode integration.

1. Enter visual mode (`v` or `V` for line-wise)
2. Select the relevant code block
3. Press `leader+9v` (Space, then 9, then v)

This sends the selected code to the 99.nvim AI provider (Claude Code) with the visual context. A prompt window opens where you can type your question:

```
Why would this function return undefined when the user object exists?
```

The AI response appears in a Neovim buffer, formatted with syntax highlighting. This is ideal for targeted questions about a specific function, block, or expression.

### 99.nvim Keybindings

| Key           | Mode   | Action                              |
|---------------|--------|-------------------------------------|
| `Space+9v`    | Visual | Send selection to AI with a prompt  |
| `Space+mm`    | Normal | Select the AI model                 |
| `Space+9s`    | Normal | Stop all running AI requests        |

---

## Step 4: Ask Claude Code for Broader Context

For questions that span multiple files or require understanding the architecture, switch to the Claude Code pane (`Ctrl+h` to move left).

Claude Code runs in the terminal and has access to the full project context. You can ask questions like:

```
The auth middleware is returning 401 for valid tokens.
I see the token validation in src/services/auth.ts calls verifyToken()
on line 42, but the function seems correct.

Can you look at how the token is being passed from the request headers
in src/middleware/auth.ts and trace the flow to find where it breaks?
```

Claude Code can read files, search the codebase, and reason across multiple modules. It excels at:

- **Tracing data flow** across files and functions
- **Finding missing pieces** like unset environment variables or missing middleware
- **Suggesting fixes** with full awareness of the codebase structure
- **Explaining unfamiliar code** that was written by someone else

---

## Step 5: Navigate Between Panes Seamlessly

The debugging loop involves rapid switching between panes:

1. **Terminal:** See the error, run a test
2. **Neovim:** Read the code, check diagnostics
3. **Claude Code:** Ask about the broader context
4. **Neovim:** Read the file Claude Code suggested
5. **Terminal:** Test a hypothesis

Each switch is a single `Ctrl+h/j/k/l` keypress. There is no window switching, no Alt+Tab, no clicking. The three panes are always visible simultaneously, so you maintain visual context even while typing in a different pane.

---

## Step 6: Apply the Fix

Once the bug is understood, make the fix in Neovim. The typical sequence:

1. Navigate to the file and line (`Space+ff`, then `42G`)
2. Enter insert mode (`i`) and make the change
3. Save (`:w` or the auto-save plugin handles it)
4. Move to the terminal pane (`Ctrl+j`)
5. Run the test again:

```bash
bun test src/auth.test.ts
```

If the test passes, the fix is confirmed.

---

## Step 7: Verify and Commit

With the fix verified, commit the change:

```bash
lazygit
```

In lazygit:

1. Stage the changed files (`Space` on each file)
2. Commit (`c`, type the message, `Enter`)
3. Push (`P`)

Or from the command line:

```bash
git add src/services/auth.ts
git commit -m "Fix token validation: handle expired tokens in verifyToken"
git push
```

---

## AI Debugging Patterns

Over time, certain patterns emerge for effective AI-assisted debugging.

### Pattern: Rubber Duck with Claude Code

Describe the problem in natural language in the Claude Code pane. Often, the act of articulating the problem reveals the solution before the AI even responds. When it does respond, it confirms or corrects your reasoning.

### Pattern: Targeted Selection with 99.nvim

Select a function in Neovim visual mode and ask: "What edge cases could cause this to fail?" The AI examines the specific code and identifies potential issues you missed.

### Pattern: Stack Trace Analysis

Paste the full error stack trace into Claude Code and ask: "Trace this error back to the root cause in this project." Claude Code can follow the chain of calls across files.

### Pattern: Comparison

When a function works in one context but fails in another, select both call sites in Neovim and ask 99.nvim: "What is different about these two invocations that could explain why the second one fails?"

---

## When to Use Which AI Tool

| Situation                                  | Tool           | Reason                                |
|--------------------------------------------|----------------|---------------------------------------|
| Quick question about a code block          | 99.nvim        | Fastest, stays in the editor          |
| Multi-file investigation                   | Claude Code    | Has project-wide context              |
| Need to read/search files first            | Claude Code    | Can browse the filesystem             |
| Understanding a type error                 | 99.nvim        | Select the type and ask               |
| Generating a fix or refactor               | Claude Code    | Better at multi-line code generation  |
| Explaining someone else's code             | Either         | 99.nvim for a function, Claude Code for a module |

---

## Troubleshooting

| Problem                                | Solution                                    |
|----------------------------------------|---------------------------------------------|
| 99.nvim not responding                 | Check `Space+9s` to stop stale requests     |
| Claude Code lost context               | Start a new conversation in the pane        |
| Pane navigation not working            | Ensure vim-tmux-navigator is installed      |
| IDE layout panes wrong size            | Run `ide .` again to recreate the layout    |
| AI suggests wrong fix                  | Provide more context: paste the error, show the types |

\newpage
