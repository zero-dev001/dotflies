# Appendix A: All Keybindings

> Every keybinding in every tool, organized by context.

---

## Tmux: Prefix Commands

The tmux prefix is `Ctrl+b`.

### Session Management

| Action                     | Keys               |
|----------------------------|---------------------|
| Sesh session picker        | `prefix + T`       |
| SessionX picker            | `prefix + o`       |
| Detach from session        | `prefix + d`       |
| Rename session             | `prefix + $`       |
| List sessions              | `prefix + s`       |

### Window Management

| Action                     | Keys               |
|----------------------------|---------------------|
| Create window              | `prefix + c`       |
| Next window                | `prefix + n`       |
| Previous window            | `prefix + p`       |
| Rename window              | `prefix + ,`       |
| Close window               | `prefix + &`       |
| Select window 1-9          | `prefix + 1-9`     |
| Move pane to new window    | `prefix + !`       |

### Pane Management

| Action                     | Keys               |
|----------------------------|---------------------|
| Split horizontal           | `prefix + "`       |
| Split vertical             | `prefix + %`       |
| Select pane (vim-style)    | `prefix + h/j/k/l` |
| Zoom pane (toggle)         | `prefix + z`       |
| Close pane                 | `prefix + x`       |
| Floating terminal (floax)  | `prefix + p`       |

### Copy Mode (vi-style)

Enter copy mode with `prefix + [`.

| Action                     | Keys               |
|----------------------------|---------------------|
| Begin selection            | `v`                |
| Rectangle selection toggle | `Ctrl+v`           |
| Copy selection and exit    | `y`                |
| Search forward             | `/`                |
| Search backward            | `?`                |
| Half page down             | `Ctrl+d`           |
| Half page up               | `Ctrl+u`           |
| Go to top                  | `gg`               |
| Go to bottom               | `G`                |

### Plugin Commands

| Action                     | Keys               |
|----------------------------|---------------------|
| Install plugins (TPM)      | `prefix + I`       |
| Save session (resurrect)   | `prefix + Ctrl+s`  |
| Restore session (resurrect)| `prefix + Ctrl+r`  |
| Open URL (fzf-url)         | `prefix + u`       |

### Sesh Picker Sub-Commands

When the sesh fzf popup is open (`prefix + T`):

| Key          | Action                          |
|--------------|---------------------------------|
| `Ctrl+a`     | Show all sessions               |
| `Ctrl+t`     | Show tmux sessions only         |
| `Ctrl+g`     | Show config sessions only       |
| `Ctrl+x`     | Show zoxide directories         |
| `Ctrl+f`     | Find directories (fd search)    |
| `Ctrl+d`     | Kill the selected session       |
| `Tab`        | Move down in the list           |
| `Shift+Tab`  | Move up in the list             |

---

## Tmux: No-Prefix Commands

These keybindings work without pressing the prefix key first.

### Pane Navigation (Alt + Arrow)

| Action                     | Keys              |
|----------------------------|-------------------|
| Pane left                  | `Alt+Left`        |
| Pane right                 | `Alt+Right`       |
| Pane up                    | `Alt+Up`          |
| Pane down                  | `Alt+Down`        |

### Window Navigation

| Action                     | Keys              |
|----------------------------|-------------------|
| Previous window            | `Shift+Left`      |
| Next window                | `Shift+Right`     |
| Previous window (vim)      | `Alt+H`           |
| Next window (vim)          | `Alt+L`           |

### Vim-Tmux-Navigator (Seamless Pane/Split Navigation)

These work identically in both tmux panes and Neovim splits:

| Action                     | Keys              |
|----------------------------|-------------------|
| Navigate left              | `Ctrl+h`          |
| Navigate down              | `Ctrl+j`          |
| Navigate up                | `Ctrl+k`          |
| Navigate right             | `Ctrl+l`          |

---

## Neovim: Leader Commands

The leader key is `Space`.

### Files and Buffers

| Action                     | Keys              |
|----------------------------|--------------------|
| Find files                 | `Space+ff`        |
| Live grep                  | `Space+fg`        |
| Recent files               | `Space+fr`        |
| Open buffers               | `Space+fb`        |
| File explorer (neo-tree)   | `Space+e`         |
| Switch buffer              | `Space+bb`        |
| Delete buffer              | `Space+bd`        |
| Previous buffer            | `H`               |
| Next buffer                | `L`               |

### Search

| Action                     | Keys              |
|----------------------------|--------------------|
| Grep across project        | `Space+sg`        |
| Search word under cursor   | `Space+sw`        |
| Document symbols           | `Space+ss`        |
| Workspace symbols          | `Space+sS`        |
| Search and replace         | `Space+sr`        |
| Search in current buffer   | `Space+/`         |
| Search command history      | `Space+sc`        |
| Search keymaps             | `Space+sk`        |
| Search help tags           | `Space+sH`        |
| Search marks               | `Space+sm`        |
| Search registers           | `Space+s"`        |
| Resume last picker         | `Space+sR`        |

### Code Actions and Diagnostics

| Action                     | Keys              |
|----------------------------|--------------------|
| Code action                | `Space+ca`        |
| Line diagnostics           | `Space+cd`        |
| Rename symbol              | `Space+cr`        |
| Format file                | `Space+cf`        |
| Open Mason (LSP installer) | `Space+cm`       |

### Git (from Neovim)

| Action                     | Keys              |
|----------------------------|--------------------|
| Git commits (Telescope)    | `Space+gc`        |
| Git status (Telescope)     | `Space+gs`        |
| Next git hunk              | `]h`              |
| Previous git hunk          | `[h`              |

### AI (99.nvim)

| Action                     | Keys              | Mode   |
|----------------------------|-------------------|--------|
| Visual AI prompt           | `Space+9v`        | Visual |
| Select AI model            | `Space+mm`        | Normal |
| Stop all AI requests       | `Space+9s`        | Normal |

### Plugins

| Action                     | Keys              |
|----------------------------|--------------------|
| Toggle database UI (dadbod)| `Space+D`         |
| Paste image (img-clip)     | `Space+p`         |
| Open Lazy plugin manager   | `Space+l`         |

---

## Neovim: LSP Commands

These work in any buffer with an active language server.

| Action                     | Keys              |
|----------------------------|--------------------|
| Go to definition           | `gd`              |
| Go to declaration          | `gD`              |
| Go to implementation       | `gi`              |
| Go to type definition      | `gy`              |
| Find all references        | `gr`              |
| Hover documentation        | `K`               |
| Signature help             | `Ctrl+k`          |
| Next diagnostic            | `]d`              |
| Previous diagnostic        | `[d`              |
| Next changed hunk          | `]c`              |
| Previous changed hunk      | `[c`              |

---

## Neovim: General Navigation

| Action                     | Keys              |
|----------------------------|--------------------|
| Top of file                | `gg`              |
| Bottom of file             | `G`               |
| Go to line N               | `NG` (e.g., `42G`)|
| Half page down             | `Ctrl+d`          |
| Half page up               | `Ctrl+u`          |
| Search forward             | `/pattern`        |
| Search backward            | `?pattern`        |
| Next search result         | `n`               |
| Previous search result     | `N`               |
| Jump to matching bracket   | `%`               |
| Flash jump (2-char)        | `s` then 2 chars  |
| Navigate splits            | `Ctrl+h/j/k/l`   |

---

## Aerospace: Main Mode

| Action                     | Keys                |
|----------------------------|---------------------|
| Toggle tile layout         | `Alt+/`             |
| Accordion layout           | `Alt+,`             |
| Focus left                 | `Cmd+Shift+H`       |
| Focus down                 | `Cmd+Shift+J`       |
| Focus up                   | `Cmd+Shift+K`       |
| Focus right                | `Cmd+Shift+L`       |
| Move window left           | `Ctrl+Shift+H`      |
| Move window down           | `Ctrl+Shift+J`      |
| Move window up             | `Ctrl+Shift+K`      |
| Move window right          | `Ctrl+Shift+L`      |
| Fullscreen                 | `Cmd+Shift+F`       |
| Focus back-and-forth       | `Alt+O`             |
| Resize shrink              | `Alt+Shift+-`       |
| Resize grow                | `Alt+Shift+=`       |
| Workspace 1                | `Alt+1`             |
| Workspace 2                | `Alt+2`             |
| Workspace 3                | `Alt+3`             |
| Workspace 4                | `Alt+4`             |
| Move to workspace 1        | `Alt+Shift+1`       |
| Move to workspace 2        | `Alt+Shift+2`       |
| Move to workspace 3        | `Alt+Shift+3`       |
| Move to workspace 4        | `Alt+Shift+4`       |
| Move workspace to monitor  | `Alt+Shift+Tab`     |
| Enter service mode         | `Alt+Shift+;`       |

---

## Aerospace: Service Mode

Entered with `Alt+Shift+;`. All commands return to main mode after execution.

| Action                     | Keys              |
|----------------------------|--------------------|
| Reload config, exit        | `Esc`             |
| Flatten workspace tree     | `r`               |
| Toggle floating/tiling     | `f`               |
| Close all but current      | `Backspace`       |
| Join with left             | `Alt+Shift+H`     |
| Join with down             | `Alt+Shift+J`     |
| Join with up               | `Alt+Shift+K`     |
| Join with right            | `Alt+Shift+L`     |

---

## Yazi Navigation

### Movement

| Action                     | Keys              |
|----------------------------|--------------------|
| Move down                  | `j`               |
| Move up                    | `k`               |
| Enter directory / open     | `l` or `Enter`    |
| Go to parent directory     | `h`               |
| Go to top                  | `gg`              |
| Go to bottom               | `G`               |
| Half page up               | `Ctrl+u`          |
| Half page down             | `Ctrl+d`          |
| History back               | `H`               |
| History forward            | `L`               |

### File Operations

| Action                     | Keys              |
|----------------------------|--------------------|
| Toggle selection           | `Space`           |
| Select all                 | `Ctrl+a`          |
| Visual mode                | `v`               |
| Copy (yank)                | `y`               |
| Cut                        | `x`               |
| Paste                      | `p`               |
| Delete (trash)             | `d`               |
| Permanent delete           | `D`               |
| Create file/directory      | `a`               |
| Rename                     | `r`               |
| Open in editor             | `e`               |
| Open shell                 | `s`               |

### Search and Find

| Action                     | Keys              |
|----------------------------|--------------------|
| Search by name (fd)        | `s`               |
| Search by content (rg)     | `S`               |
| Filter                     | `f`               |
| Find next                  | `/`               |
| Find previous              | `?`               |
| Next match                 | `n`               |
| Previous match             | `N`               |
| Jump via fzf               | `z`               |
| Jump via zoxide            | `Z`               |

### Goto Shortcuts

| Action                     | Keys              |
|----------------------------|--------------------|
| Go to home                 | `gh`              |
| Go to ~/.config            | `gc`              |
| Go to ~/Downloads          | `gd`              |

### Other

| Action                     | Keys              |
|----------------------------|--------------------|
| Toggle hidden files        | `.`               |
| Shell command              | `;`               |
| Shell command (blocking)   | `:`               |
| New tab                    | `t`               |
| Switch to tab 1-9          | `1-9`             |
| Previous / next tab        | `[` / `]`         |
| Task manager               | `w`               |
| Help                       | `~` or `F1`       |
| Quit (sync CWD)            | `q`               |
| Quit (no CWD sync)         | `Q`               |

---

## fzf Shell Bindings

| Action                     | Keys              |
|----------------------------|-------------------|
| Search files               | `Ctrl+T`          |
| Search command history      | `Ctrl+R`          |
| Search directories (cd)    | `Alt+C`           |

### Inside an fzf Picker

| Action                     | Keys              |
|----------------------------|--------------------|
| Move down                  | `Ctrl+j` or Down  |
| Move up                    | `Ctrl+k` or Up    |
| Select                     | `Enter`           |
| Cancel                     | `Esc` or `Ctrl+c` |
| Toggle selection           | `Tab`             |
| Select all                 | `Ctrl+a`          |
| Preview scroll down        | `Shift+Down`      |
| Preview scroll up          | `Shift+Up`        |

---

## Lazygit

| Action                     | Keys              |
|----------------------------|--------------------|
| Switch panels              | `h`/`l` or `Tab`  |
| Move up/down               | `k`/`j`           |
| Stage file/hunk            | `Space`           |
| Commit                     | `c`               |
| Push                       | `P`               |
| Pull                       | `p`               |
| Amend last commit          | `A`               |
| New branch                 | `n`               |
| Checkout branch            | `Space`           |
| Force push                 | `Shift+P`         |
| Interactive rebase          | `i`               |
| Search                     | `/`               |
| Open file in editor        | `e`               |
| View diff                  | `Enter`           |
| Toggle whitespace in diff  | `w`               |
| Quit                       | `q`               |

---

## Atuin (Shell History)

| Action                     | Keys              |
|----------------------------|--------------------|
| Search history             | `Ctrl+R`          |
| Move down in results       | `Ctrl+n` or Down  |
| Move up in results         | `Ctrl+p` or Up    |
| Select entry               | `Enter`           |
| Cancel search              | `Esc`             |

\newpage
