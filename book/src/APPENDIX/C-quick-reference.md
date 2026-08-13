# Appendix C: Quick Reference Card

> One-page task-oriented reference -- find what you need by what you want to do.

---

## Finding Things

| Task                              | Command / Keys                                 |
|-----------------------------------|------------------------------------------------|
| Find a file by name               | `Space+ff` (Neovim) or `Ctrl+T` (shell fzf)   |
| Find text in files                | `Space+fg` (Neovim) or `rg "pattern"` (shell)  |
| Find text live (as you type)      | `Space+sg` (Neovim)                            |
| Find word under cursor            | `Space+sw` (Neovim)                            |
| Find a directory                  | `fcd` (fuzzy) or `fd --type d name`            |
| Find a file, copy path            | `f` (fuzzy file to clipboard)                  |
| Find a file, open in editor       | `fv` (fuzzy file to Neovim)                    |
| Find in command history            | `Ctrl+R` (atuin search)                        |
| Find open buffers                 | `Space+fb` (Neovim)                            |
| Find recent files                 | `Space+fr` (Neovim)                            |
| Find hidden files too             | `fd --hidden` or `l` (eza -a)                  |
| Find by file content (structural) | `ast-grep -p 'pattern'`                        |
| Search and replace in project     | `Space+sr` (Neovim, grug-far)                  |
| Quick man page summary            | `tldr command`                                 |

---

## Editing

| Task                              | Command / Keys                                 |
|-----------------------------------|------------------------------------------------|
| Open Neovim                       | `v` or `vim` or `nvim`                         |
| Open specific file                | `v filename` or `Space+ff` inside Neovim       |
| File explorer                     | `Space+e` (neo-tree toggle)                    |
| Create new file in explorer       | `a` (in neo-tree)                              |
| Go to definition                  | `gd`                                           |
| Go to declaration                 | `gD`                                           |
| Find all references               | `gr`                                           |
| Rename symbol                     | `Space+cr`                                     |
| Code action / quick fix           | `Space+ca`                                     |
| Format file                       | `Space+cf`                                     |
| View line diagnostics             | `Space+cd`                                     |
| Next / previous diagnostic        | `]d` / `[d`                                    |
| Hover documentation               | `K`                                            |
| Select and ask AI                 | Visual select, then `Space+9v`                 |
| Select AI model                   | `Space+mm`                                     |
| Stop AI requests                  | `Space+9s`                                     |
| Open minimal Neovim               | `vmin`                                         |
| Open LazyVim config               | `vlazy`                                        |
| Flash jump                        | `s` then type 2 characters                     |
| Switch buffers                    | `H` / `L` or `Space+bb`                       |
| Delete buffer                     | `Space+bd`                                     |

---

## Navigating

| Task                              | Command / Keys                                 |
|-----------------------------------|------------------------------------------------|
| Jump to a directory               | `cd partial-name` (zoxide)                     |
| Go up one directory               | `..`                                           |
| Go up two directories             | `...`                                          |
| Go up three directories           | `....`                                         |
| Toggle previous directory         | `-` or `cd -`                                  |
| cd and list contents              | `cx dirname`                                   |
| Fuzzy pick a directory            | `fcd`                                          |
| Change dir via fzf                | `Alt+C` (shell binding)                        |
| Browse files visually             | `y` (yazi, syncs CWD on quit)                  |
| Switch tmux session               | `prefix+T` (sesh) or `prefix+o` (sessionx)    |
| Switch tmux window                | `Shift+Left/Right` or `Alt+H/L`               |
| Switch tmux pane                  | `Ctrl+h/j/k/l` (vim-tmux-navigator)           |
| Switch workspace                  | `Alt+1/2/3/4` (Aerospace)                      |
| Move window to workspace          | `Alt+Shift+1/2/3/4` (Aerospace)               |
| Focus window in workspace         | `Cmd+Shift+H/J/K/L` (Aerospace)               |
| Move window in workspace          | `Ctrl+Shift+H/J/K/L` (Aerospace)              |
| Toggle focus back-and-forth       | `Alt+O` (Aerospace)                            |

---

## Git

| Task                              | Command / Keys                                 |
|-----------------------------------|------------------------------------------------|
| Open git TUI                      | `lazygit`                                      |
| Status                            | `git status` or `gst`                          |
| Stage file                        | `git add file` or `Space` in lazygit           |
| Stage all                         | `gaa` (git add --all)                          |
| Commit                            | `gc -m "message"` or `c` in lazygit            |
| Push                              | `gp` or `P` in lazygit                         |
| Pull                              | `gl` or `p` in lazygit                         |
| View diff (unstaged)              | `gd` (git diff, rendered by delta)             |
| View diff (staged)                | `gds` (git diff --staged)                      |
| View PR diff                      | `git diff main...HEAD`                         |
| Diff with file stats              | `git diff main...HEAD --stat`                  |
| Interactive diff navigation       | `git diff main...HEAD \| diffnav`              |
| Create branch                     | `gcb branch-name` (git checkout -b)            |
| Switch branch                     | `gco branch-name` (git checkout)               |
| Stash / pop                       | `gsta` / `gstp`                                |
| Log (one line per commit)         | `glo` (git log --oneline)                      |
| Log (graph view)                  | `glg` (git log --graph)                        |
| List open PRs                     | `gh pr list`                                   |
| Checkout a PR                     | `gh pr checkout NUMBER`                        |
| View a PR                         | `gh pr view NUMBER`                            |
| Create a PR                       | `gh pr create --fill`                          |
| Review a PR (approve)             | `gh pr review NUMBER --approve`                |
| Review a PR (request changes)     | `gh pr review NUMBER --request-changes`        |
| Merge a PR                        | `gh pr merge NUMBER --squash --delete-branch`  |
| Create repo from local dir        | `gh repo create name --private --source=. --push` |
| PR dashboard                      | `gh dash`                                      |

---

## Terminal Management (tmux)

| Task                              | Command / Keys                                 |
|-----------------------------------|------------------------------------------------|
| Launch IDE layout                 | `ide .` or `ide ~/project`                     |
| New window                        | `prefix+c`                                     |
| Split horizontal                  | `prefix+"`                                     |
| Split vertical                    | `prefix+%`                                     |
| Navigate panes                    | `Ctrl+h/j/k/l`                                |
| Zoom current pane                 | `prefix+z`                                     |
| Close pane                        | `prefix+x`                                     |
| Floating terminal                 | `prefix+p` (floax)                             |
| Rename window                     | `tab name` or `prefix+,`                       |
| Detach from tmux                  | `prefix+d`                                     |
| Session picker (sesh)             | `prefix+T`                                     |
| Session picker (sessionx)         | `prefix+o`                                     |
| List sessions                     | `prefix+s`                                     |
| Next window                       | `Shift+Right` or `Alt+L`                       |
| Previous window                   | `Shift+Left` or `Alt+H`                        |
| Enter copy mode                   | `prefix+[`                                     |
| Select in copy mode               | `v` (then `y` to copy)                         |
| Save session (resurrect)          | `prefix+Ctrl+s`                                |
| Restore session (resurrect)       | `prefix+Ctrl+r`                                |
| Install plugins (TPM)             | `prefix+I`                                     |

---

## System

| Task                              | Command / Keys                                 |
|-----------------------------------|------------------------------------------------|
| Public IP address                 | `ip`                                           |
| Local IP address                  | `localip`                                      |
| Flush DNS cache                   | `flush`                                        |
| Update everything                 | `update` (macOS + Homebrew)                    |
| System info                       | `fastfetch`                                    |
| System monitor                    | `btop`                                         |
| Mute volume                       | `stfu`                                         |
| Max volume                        | `pumpitup`                                     |
| Lock screen                       | `afk`                                          |
| Show hidden files (Finder)        | `show`                                         |
| Hide hidden files (Finder)        | `hide`                                         |
| Hide desktop icons                | `hidedesktop`                                  |
| Show desktop icons                | `showdesktop`                                  |
| Delete .DS_Store files            | `cleanup`                                      |
| Empty all trashes                 | `emptytrash`                                   |
| View man page (in Neovim)         | `man command` (uses nvim as MANPAGER)          |
| View user manual                  | `manual`                                       |

---

## File Operations

| Task                              | Command / Keys                                 |
|-----------------------------------|------------------------------------------------|
| List files (simple)               | `ls` (aliased to eza)                          |
| List files (detailed + icons)     | `l`                                            |
| Tree view (2 levels, detailed)    | `lt`                                           |
| Tree view (2 levels, compact)     | `ltree`                                        |
| View file with syntax highlight   | `cat file` (aliased to bat)                    |
| File / directory sizes (sorted)   | `fs *` or `fs dir1 dir2`                       |
| Gzip compression ratio            | `gz filename`                                  |
| Create dir and cd into it         | `mkd path/to/dir`                              |
| Quick HTTP server                 | `server` (port 8000) or `server 3000`          |
| Browse files in TUI               | `y` (yazi with CWD sync)                       |
| Copy file path to clipboard       | `f` (fuzzy picker)                             |
| Open file in Neovim               | `fv` (fuzzy picker)                            |
| Download file                     | `wget URL` or `aria2c URL` (multi-connection)  |
| Download video                    | `yt-dlp URL`                                   |
| Convert document format           | `pandoc input.md -o output.pdf`                |
| Process image                     | `magick input.png -resize 50% output.png`      |

---

## Package Management

| Task                              | Command                                        |
|-----------------------------------|------------------------------------------------|
| Install all Homebrew packages     | `brew bundle`                                  |
| Install base tier only            | `brew bundle --file=brewfiles/00-base.Brewfile` |
| Check missing packages            | `brew bundle check`                            |
| Clean unused packages             | `brew bundle cleanup --force`                  |
| Search for a formula              | `brew search name`                             |
| Install a formula                 | `brew install name`                            |
| Install a cask                    | `brew install --cask name`                     |
| Update Homebrew                   | `brew update && brew upgrade`                  |

---

## Runtime Versions

| Task                              | Command                                        |
|-----------------------------------|------------------------------------------------|
| Switch Node version               | `nvm use 22`                                   |
| Install Node version              | `nvm install 22`                               |
| List installed Node versions      | `nvm ls`                                       |
| Current Node version              | `nvm current`                                  |
| Install Bun packages              | `bun install`                                  |
| Add Bun dependency                | `bun add package`                              |
| Run Bun script                    | `bun run dev` or `bun dev`                     |
| Execute without install           | `bunx package-name`                            |
| Pin runtime with mise             | `mise use python@3.12`                         |
| See active mise versions          | `mise current`                                 |
| List all mise versions            | `mise ls`                                      |

---

## Dotfiles (chezmoi)

| Task                              | Command                                        |
|-----------------------------------|------------------------------------------------|
| Go to source directory            | `chezmoi cd`                                   |
| Edit a managed file               | `chezmoi edit ~/.zshrc`                        |
| Preview pending changes           | `chezmoi diff`                                 |
| Apply source to target            | `chezmoi apply`                                |
| Pull and apply from remote        | `chezmoi update`                               |
| List managed files                | `chezmoi managed`                              |
| Add a file to chezmoi             | `chezmoi add ~/.gitconfig`                     |
| Check for problems                | `chezmoi doctor`                               |
| View template data                | `chezmoi data`                                 |
| See source path of target         | `chezmoi source-path ~/.zshrc`                 |

---

## Workspace Layout (Aerospace)

| Workspace | Switch   | Contents                              |
|-----------|----------|---------------------------------------|
| 1         | `Alt+1`  | Browsers (Firefox Developer Edition)  |
| 2         | `Alt+2`  | Terminals (iTerm2)                    |
| 3         | `Alt+3`  | Communication (Slack, Discord, Telegram) |
| 4         | `Alt+4`  | Media and other (Spotify)             |

---

## IDE Pane Layout

```
+--------------------+-----------------------------------+
|   Claude Code      |          Neovim                   |
|   (Ctrl+h)        |          (Ctrl+l)                 |
|                    +-----------------------------------+
|                    |       Terminal (Ctrl+j)            |
+--------------------+-----------------------------------+
```

Launch: `ide .` or `ide ~/Projects/my-app`

\newpage
