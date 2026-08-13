# Neovim Fundamentals

> The language of vim is a grammar: verbs act on nouns, and fluency comes from combining a small set of each.

---

## Your Setup

zero.dev001 uses Neovim (aliased as `vim` and `v`) with the LazyVim distribution. But the power of Neovim does not come from plugins -- it comes from the modal editing model that has existed since the 1970s. Every plugin, every custom mapping, and every workflow in the following chapters builds on the fundamentals covered here. Learn these, and every vim-based tool (lazygit, Yazi, man pages, even your shell with vi mode) becomes immediately more productive.

Neovim is launched from the shell:

```
$ nvim .              # Open Neovim in current directory
$ nvim file.ts        # Open a specific file
$ v file.ts           # Same thing, via alias
```

Multiple Neovim configurations are available through `NVIM_APPNAME`:

```
$ vtest               # nvim-test config
$ vkick               # nvim-kickstart config
$ vlazy               # nvim-lazyvim config
$ vmin                # nvim-minimal config
```

---

## Core Concepts

### Modal Editing

Vim is a modal editor. The same key does different things depending on which mode you are in. This is the single most important concept to internalize.

| Mode      | Purpose                        | How to Enter            | How to Leave       |
|-----------|--------------------------------|-------------------------|--------------------|
| Normal    | Navigate and manipulate text   | `Esc` or `Ctrl+[`      | Enter another mode |
| Insert    | Type text                      | `i`, `a`, `o`, `I`, `A`, `O` | `Esc`        |
| Visual    | Select text                    | `v`, `V`, `Ctrl+V`     | `Esc`              |
| Command   | Execute commands               | `:`                     | `Enter` or `Esc`   |
| Replace   | Overwrite text character by character | `R`              | `Esc`              |

Normal mode is the home mode. You should spend most of your time there. If you are ever lost, press `Esc` until you are back in Normal mode.

### The Insert Mode Entry Points

Each key that enters Insert mode places your cursor in a different position:

| Key | Cursor Position                           |
|-----|-------------------------------------------|
| `i` | Before the character under the cursor     |
| `a` | After the character under the cursor      |
| `I` | At the first non-blank character of the line |
| `A` | At the end of the line                    |
| `o` | New line below, in insert mode            |
| `O` | New line above, in insert mode            |
| `s` | Delete character under cursor, enter insert |
| `S` | Delete entire line, enter insert          |

---

## Essential Commands

### Movement -- Characters and Lines

| Key       | Motion                                       |
|-----------|----------------------------------------------|
| `h`       | One character left                           |
| `j`       | One line down                                |
| `k`       | One line up                                  |
| `l`       | One character right                          |
| `0`       | Beginning of line (column 0)                 |
| `^`       | First non-blank character of line            |
| `$`       | End of line                                  |
| `g_`      | Last non-blank character of line             |

### Movement -- Words

| Key       | Motion                                       |
|-----------|----------------------------------------------|
| `w`       | Start of next word                           |
| `b`       | Start of previous word                       |
| `e`       | End of current/next word                     |
| `ge`      | End of previous word                         |
| `W`       | Start of next WORD (whitespace-delimited)    |
| `B`       | Start of previous WORD                       |
| `E`       | End of current/next WORD                     |

A "word" is a sequence of letters, digits, and underscores. A "WORD" is any sequence of non-blank characters. In `my-variable`, `w` stops at `-` and `v`, while `W` jumps over the whole thing.

### Movement -- Vertical

| Key       | Motion                                       |
|-----------|----------------------------------------------|
| `gg`      | First line of file                           |
| `G`       | Last line of file                            |
| `{count}G`| Go to line number                           |
| `Ctrl+D`  | Half-page down                               |
| `Ctrl+U`  | Half-page up                                 |
| `Ctrl+F`  | Full page forward                            |
| `Ctrl+B`  | Full page backward                           |
| `{`       | Previous blank line (paragraph boundary)     |
| `}`       | Next blank line                              |
| `%`       | Matching bracket/paren/brace                 |

### Movement -- Find on Line

| Key       | Motion                                       |
|-----------|----------------------------------------------|
| `f{char}` | Jump forward to {char} on current line       |
| `F{char}` | Jump backward to {char} on current line      |
| `t{char}` | Jump forward to one before {char}            |
| `T{char}` | Jump backward to one after {char}            |
| `;`       | Repeat last f/F/t/T forward                  |
| `,`       | Repeat last f/F/t/T backward                 |

The `f` and `t` commands are among the fastest ways to move within a line. To delete everything up to a comma: `dt,`. To change a function argument: `ct)`.

### Operators

Operators are the verbs of the vim grammar. They act on a motion or text object.

| Operator  | Action                                       |
|-----------|----------------------------------------------|
| `d`       | Delete (cut into register)                   |
| `c`       | Change (delete and enter Insert mode)        |
| `y`       | Yank (copy into register)                    |
| `>`       | Indent right                                 |
| `<`       | Indent left (dedent)                         |
| `=`       | Auto-format/indent                           |
| `gu`      | Convert to lowercase                         |
| `gU`      | Convert to uppercase                         |
| `g~`      | Toggle case                                  |
| `!`       | Filter through external program              |

Double an operator to act on the entire current line: `dd` deletes a line, `yy` yanks a line, `cc` changes a line, `>>` indents a line, `==` auto-indents a line.

### Text Objects

Text objects are the nouns of the vim grammar. They define a region of text. Every text object comes in two flavors: **inner** (`i`) excludes delimiters, **a/around** (`a`) includes them.

| Text Object | Inner (`i`)                    | Around (`a`)                   |
|-------------|--------------------------------|--------------------------------|
| `w`         | Inner word                     | Word plus trailing space       |
| `W`         | Inner WORD                     | WORD plus trailing space       |
| `s`         | Inner sentence                 | Sentence plus trailing space   |
| `p`         | Inner paragraph                | Paragraph plus surrounding blanks |
| `"`         | Inside double quotes           | Quotes included                |
| `'`         | Inside single quotes           | Quotes included                |
| `` ` ``     | Inside backticks               | Backticks included             |
| `(`/`)`/`b` | Inside parentheses            | Parentheses included           |
| `[`/`]`    | Inside square brackets         | Brackets included              |
| `{`/`}`/`B` | Inside curly braces           | Braces included                |
| `<`/`>`    | Inside angle brackets          | Brackets included              |
| `t`         | Inside HTML/XML tags           | Tags included                  |

---

## Practical Recipes

### The Vim Grammar in Action

Every editing command is a sentence: **operator + motion** or **operator + text object**. Once you learn the grammar, you can construct commands you have never seen before.

| Command   | Reads As                              | Effect                                |
|-----------|---------------------------------------|---------------------------------------|
| `dw`      | Delete word (from cursor)             | Deletes to start of next word         |
| `diw`     | Delete inner word                     | Deletes the word under cursor         |
| `daw`     | Delete a word                         | Deletes word plus surrounding space   |
| `ci"`     | Change inside quotes                  | Clears quoted string, enters Insert   |
| `ca(`     | Change around parens                  | Clears parens and contents            |
| `yap`     | Yank around paragraph                 | Copies paragraph to register          |
| `dit`     | Delete inside tag                     | Clears HTML tag contents              |
| `>ip`     | Indent inner paragraph                | Indents the current paragraph         |
| `guiw`    | Lowercase inner word                  | Converts word to lowercase            |
| `gUaw`    | Uppercase a word                      | Converts word to uppercase            |
| `=aB`     | Format around block                   | Auto-indents the current `{}` block   |
| `da[`     | Delete around brackets                | Removes `[...]` entirely              |
| `yi(`     | Yank inside parens                    | Copies contents of parentheses        |

### Counts as Multipliers

Prefix any motion or command with a number to repeat it:

| Command   | Effect                                       |
|-----------|----------------------------------------------|
| `3w`      | Move forward 3 words                         |
| `5j`      | Move down 5 lines                            |
| `2dd`     | Delete 2 lines                               |
| `3yy`     | Yank 3 lines                                 |
| `4>>`     | Indent 4 lines                               |
| `50G`     | Go to line 50                                |

### Registers

Every delete and yank goes into a register. Registers are vim's clipboard system.

| Register  | Contents                                     |
|-----------|----------------------------------------------|
| `"`       | Default register (last delete/yank)          |
| `0`       | Last yank (not affected by deletes)          |
| `1`-`9`   | Delete history (1 is most recent)           |
| `a`-`z`   | Named registers (you choose)                |
| `A`-`Z`   | Append to named register (lowercase letter) |
| `+`       | System clipboard                             |
| `*`       | Primary selection (X11) / same as + on macOS|
| `_`       | Black hole register (delete without saving)  |
| `/`       | Last search pattern                          |
| `.`       | Last inserted text                           |
| `:`       | Last command-line command                    |

Using registers:

| Command    | Effect                                      |
|------------|---------------------------------------------|
| `"ayy`     | Yank current line into register `a`         |
| `"ap`      | Paste from register `a`                     |
| `"+y`      | Yank to system clipboard                    |
| `"+p`      | Paste from system clipboard                 |
| `"_dd`     | Delete line without saving to any register  |
| `:reg`     | Show all register contents                  |
| `:reg a`   | Show contents of register `a`               |

### Marks

Marks let you bookmark positions in a file and jump back to them.

| Command    | Effect                                      |
|------------|---------------------------------------------|
| `m{a-z}`   | Set a mark at cursor position (file-local)  |
| `m{A-Z}`   | Set a global mark (across files)            |
| `'{letter}`| Jump to the line of a mark                  |
| `` `{letter} `` | Jump to the exact position of a mark   |
| `` `0 ``   | Position where you last exited Neovim       |
| `` `. ``   | Position of last change                     |
| `` `` ``   | Position before last jump                   |
| `:marks`   | List all marks                              |

### Macros

Macros record a sequence of keystrokes and replay them. They are the most powerful repetition tool in vim.

| Command    | Effect                                      |
|------------|---------------------------------------------|
| `q{a-z}`   | Start recording macro into register         |
| `q`        | Stop recording                              |
| `@{a-z}`   | Play macro from register                    |
| `@@`       | Repeat the last played macro                |
| `5@a`      | Play macro `a` five times                   |

A practical macro workflow:

1. Move to the first line you want to change
2. Press `qa` to start recording into register `a`
3. Make your edit on the current line
4. Press `j` to move to the next line (so the macro is repeatable)
5. Press `q` to stop recording
6. Press `@a` to replay once, then `@@` or `10@@` to repeat

---

## Advanced Usage

### Search and Substitution

| Command               | Effect                                    |
|-----------------------|-------------------------------------------|
| `/{pattern}`          | Search forward for pattern                |
| `?{pattern}`          | Search backward for pattern               |
| `n`                   | Next match (same direction)               |
| `N`                   | Next match (opposite direction)           |
| `*`                   | Search forward for word under cursor      |
| `#`                   | Search backward for word under cursor     |
| `:%s/old/new/g`       | Replace all occurrences in file           |
| `:%s/old/new/gc`      | Replace all with confirmation             |
| `:%s/old/new/gi`      | Replace all, case insensitive             |
| `:5,20s/old/new/g`    | Replace in lines 5-20                     |
| `:'<,'>s/old/new/g`   | Replace in visual selection               |
| `:s/old/new/g`        | Replace on current line                   |

Substitution flags:

| Flag | Meaning                                      |
|------|----------------------------------------------|
| `g`  | Global -- all occurrences on each line       |
| `c`  | Confirm each substitution                    |
| `i`  | Case insensitive                             |
| `I`  | Case sensitive (overrides ignorecase)        |
| `n`  | Count matches without substituting           |

### Visual Mode

Visual mode lets you select text and then act on the selection.

| Key        | Mode                                       |
|------------|--------------------------------------------|
| `v`        | Character-wise visual                      |
| `V`        | Line-wise visual                           |
| `Ctrl+V`   | Block-wise visual (column selection)      |
| `gv`       | Re-select the last visual selection        |
| `o`        | Jump to other end of selection             |

Once a visual selection is active, any operator acts on it: `d` deletes, `c` changes, `y` yanks, `>` indents, `u` lowercases, `U` uppercases.

Block visual mode (`Ctrl+V`) is uniquely powerful for columnar edits:

1. `Ctrl+V` to enter block visual mode
2. Select a column of text with `j`/`k` and `l`/`h`
3. `I` to insert at the start of each line, or `A` to append
4. Type your text, then press `Esc` -- the edit applies to every line

### The Dot Command

The `.` key repeats the last change. A "change" is anything from entering Insert mode to returning to Normal mode, or any Normal mode command that modifies text.

Effective use of `.`:

- `ciw` + type replacement + `Esc`, then `n.n.n.` to search and replace interactively
- `dd` to delete a line, then `.` to delete the next one
- `>>` to indent a line, then `j.j.j.` to indent several more
- `A;` + `Esc` to append a semicolon, then `j.j.` to do the same on following lines

The dot command is the reason vim users structure their edits as repeatable atomic operations. A single `ciw` followed by dots is faster than four separate manual edits.

### Undo and Redo

| Command    | Effect                                      |
|------------|---------------------------------------------|
| `u`        | Undo last change                            |
| `Ctrl+R`   | Redo (undo the undo)                       |
| `U`        | Undo all changes on the current line        |

Neovim supports undo branches -- if you undo several times and then make a new change, the undone changes are not lost. Use `:earlier 5m` to go back to the state 5 minutes ago, or `:later 5m` to go forward.

### Window Splits

| Command       | Effect                                   |
|---------------|------------------------------------------|
| `Ctrl+W s`    | Horizontal split                         |
| `Ctrl+W v`    | Vertical split                           |
| `Ctrl+W q`    | Close current split                      |
| `Ctrl+W o`    | Close all other splits                   |
| `Ctrl+W =`    | Equalize split sizes                     |
| `Ctrl+H/J/K/L`| Navigate between splits (LazyVim default)|

### Command-Line Mode Essentials

| Command       | Effect                                   |
|---------------|------------------------------------------|
| `:w`          | Save                                     |
| `:q`          | Quit (fails if unsaved changes)          |
| `:wq` / `:x` | Save and quit                            |
| `:q!`         | Quit without saving                      |
| `:e {file}`   | Open file                                |
| `:{number}`   | Go to line number                        |
| `:!{cmd}`     | Run shell command                        |
| `:r !{cmd}`   | Insert shell command output              |
| `:%!{cmd}`    | Filter entire file through command       |

---

This chapter covers the timeless vim fundamentals that apply regardless of your Neovim configuration. Master the grammar -- operators, motions, text objects -- and the rest of this book's editor chapters become intuitive extensions of what you already know.

\newpage
