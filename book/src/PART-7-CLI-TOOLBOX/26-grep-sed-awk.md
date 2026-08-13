# Text Processing: grep, sed, and awk

> The classic Unix text processing trinity -- pattern matching, stream editing, and field-oriented data transformation.

## Your Setup

GNU grep is installed via Homebrew to replace the BSD version shipped with macOS:

```ruby
brew "grep"
```

The Homebrew GNU grep provides `-P` (Perl-compatible regex) and other features missing from the macOS default. After installation, it is available as `ggrep` or, if Homebrew's gnubin directory is in your PATH, as `grep`.

sed and awk on macOS are the BSD variants. Their behaviour differs from the GNU versions in small but important ways, particularly sed's `-i` flag (macOS requires `sed -i ''`, while GNU uses `sed -i`).

**Note:** For most interactive code searching, **ripgrep** (`rg`) is the preferred tool in this environment. It is faster, respects `.gitignore`, and has a more intuitive interface. However, grep, sed, and awk remain essential for pipelines, scripts, and text transformations where ripgrep does not apply.

## Core Concepts

### grep -- Global Regular Expression Print

grep searches files or stdin for lines matching a pattern and prints them. It is the most fundamental text search tool in Unix. Think of grep as a filter: input goes in, only matching lines come out.

### sed -- Stream Editor

sed processes text line by line, applying transformation rules. It does not load the entire file into memory, making it efficient for large files. The most common use is find-and-replace, but sed can also insert, delete, and rearrange lines.

### awk -- Pattern-Action Language

awk is a small programming language designed for processing columnar text data. It automatically splits each line into fields ($1, $2, ...) and lets you write pattern-action rules. awk bridges the gap between simple one-liners and full scripting languages.

## Essential Commands -- grep

| Command | Purpose |
|---|---|
| `grep pattern file` | Search for pattern in a file |
| `grep -r pattern dir` | Recursive search through a directory |
| `grep -i pattern file` | Case-insensitive search |
| `grep -n pattern file` | Show line numbers with matches |
| `grep -l pattern dir/*` | Show only filenames containing matches |
| `grep -c pattern file` | Count matching lines |
| `grep -v pattern file` | Invert match (show non-matching lines) |
| `grep -w pattern file` | Match whole words only |
| `grep -E 'pat1\|pat2' file` | Extended regex (egrep) -- alternation |
| `grep -P '\d{3}-\d{4}' file` | Perl regex (GNU grep only) |
| `grep -A 3 pattern file` | Show 3 lines after each match |
| `grep -B 2 pattern file` | Show 2 lines before each match |
| `grep -C 2 pattern file` | Show 2 lines of context (before and after) |
| `grep -o pattern file` | Print only the matched text, not the full line |
| `grep -q pattern file` | Quiet mode -- exit code only, no output |
| `grep --include='*.py' -r pattern dir` | Recursive, limited to specific file types |

## Essential Commands -- sed

| Command | Purpose |
|---|---|
| `sed 's/old/new/' file` | Replace first occurrence per line |
| `sed 's/old/new/g' file` | Replace all occurrences per line |
| `sed -i '' 's/old/new/g' file` | In-place edit (macOS BSD sed) |
| `sed -n '5p' file` | Print only line 5 |
| `sed -n '2,5p' file` | Print lines 2 through 5 |
| `sed -n '/pattern/p' file` | Print lines matching pattern |
| `sed '/pattern/d' file` | Delete lines matching pattern |
| `sed '5d' file` | Delete line 5 |
| `sed '2,5d' file` | Delete lines 2 through 5 |
| `sed '3i\new line' file` | Insert text before line 3 |
| `sed '3a\new line' file` | Append text after line 3 |
| `sed -e 's/a/b/' -e 's/c/d/' file` | Multiple substitutions |
| `sed 's/pattern/&-suffix/' file` | Append to matched text (`&` = match) |
| `sed 's/\(group\)/\1-extra/' file` | Backreference to captured group |
| `sed '/start/,/end/d' file` | Delete a range between two patterns |
| `sed '1,3s/old/new/' file` | Replace only on lines 1 through 3 |

## Essential Commands -- awk

| Command | Purpose |
|---|---|
| `awk '{print $1}' file` | Print the first field of each line |
| `awk '{print $1, $3}' file` | Print fields 1 and 3 |
| `awk -F',' '{print $2}' file` | Use comma as field separator |
| `awk -F: '{print $1}' /etc/passwd` | Use colon as separator |
| `awk '/pattern/ {print}' file` | Print lines matching pattern |
| `awk '$3 > 100 {print $1, $3}' file` | Conditional field printing |
| `awk '{print NR, $0}' file` | Print line numbers |
| `awk 'NR==5' file` | Print only line 5 |
| `awk 'NR>=5 && NR<=10' file` | Print lines 5 through 10 |
| `awk '{print NF}' file` | Print number of fields per line |
| `awk '{print $NF}' file` | Print last field of each line |
| `awk '{printf "%-20s %s\n", $1, $2}' file` | Formatted output |
| `awk 'BEGIN{sum=0} {sum+=$1} END{print sum}' file` | Sum a column |
| `awk 'BEGIN{OFS=","} {print $1,$2}' file` | Set output field separator |
| `awk '!seen[$0]++' file` | Remove duplicate lines (preserving order) |
| `awk '{sum+=$1; count++} END{print sum/count}' file` | Calculate average |

## Practical Recipes

### Find TODOs across a codebase

```bash
grep -rn 'TODO\|FIXME\|HACK' --include='*.py' src/
```

For interactive use, prefer ripgrep: `rg 'TODO|FIXME|HACK' -t py src/`

### Replace a string across multiple files

```bash
# Preview what will change (use grep first)
grep -rl 'old_function' src/

# Apply the change
grep -rl 'old_function' src/ | xargs sed -i '' 's/old_function/new_function/g'
```

### Extract email addresses from a file

```bash
grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' file.txt
```

### Remove blank lines from a file

```bash
sed '/^$/d' file.txt
```

### Print a specific field from a CSV

```bash
awk -F',' '{print $2}' data.csv
```

For CSV files with quoted fields containing commas, awk's simple field splitting is insufficient. Use a dedicated CSV tool or `csvkit` instead.

### Sum a column of numbers

```bash
awk '{sum += $1} END {print sum}' numbers.txt
```

### Extract text between two markers

```bash
sed -n '/BEGIN_SECTION/,/END_SECTION/p' config.txt
```

### Add a header line to output

```bash
awk 'BEGIN {print "Name\tScore"} {print $1 "\t" $2}' results.txt
```

### Count word frequency

```bash
tr ' ' '\n' < file.txt | sort | uniq -c | sort -rn | head -20
```

This classic pipeline splits words, sorts, counts, and shows the top 20.

### Replace only on lines matching a condition

```bash
# Only replace "foo" with "bar" on lines containing "target"
sed '/target/s/foo/bar/g' file.txt
```

### Transpose rows and columns

```bash
awk '{for(i=1;i<=NF;i++) a[NR][i]=$i}
     END{for(j=1;j<=NF;j++){for(i=1;i<=NR;i++) printf "%s ", a[i][j]; print ""}}' file.txt
```

## Advanced Usage

### Combining grep, sed, and awk in Pipelines

The real power of these tools emerges when they are combined. Each tool handles what it does best:

```bash
# Find log errors, extract the timestamp and message, format as a table
grep 'ERROR' app.log | \
  sed 's/\[//;s/\]//' | \
  awk '{printf "%-20s %s\n", $1" "$2, substr($0, index($0,$4))}'
```

### awk as a Mini Programming Language

awk supports arrays, functions, and control flow:

```bash
# Count HTTP status codes from an access log
awk '{count[$9]++} END {for (code in count) print code, count[code]}' access.log | sort -rn -k2
```

### sed with Regular Expression Groups

```bash
# Swap first and last name
echo "Doe, John" | sed 's/\(.*\), \(.*\)/\2 \1/'
# Output: John Doe
```

### Multi-line Processing with sed

```bash
# Join every pair of lines
sed 'N;s/\n/ /' file.txt
```

### The -i Flag Portability Problem

The in-place edit flag differs between macOS (BSD) and Linux (GNU):

```bash
# macOS (BSD sed) -- requires empty string argument
sed -i '' 's/old/new/g' file.txt

# Linux (GNU sed) -- no argument needed
sed -i 's/old/new/g' file.txt

# Portable workaround
sed 's/old/new/g' file.txt > file.tmp && mv file.tmp file.txt
```

### When to Reach for Each Tool

| Task | Best Tool |
|---|---|
| Find lines matching a pattern | grep |
| Find and replace text | sed |
| Extract or rearrange columns | awk |
| Complex conditionals on fields | awk |
| Interactive code search | ripgrep (rg) |
| Structured data (JSON, CSV) | jq, csvkit |
| Delete or insert specific lines | sed |
| Aggregate or summarize data | awk |

\newpage
