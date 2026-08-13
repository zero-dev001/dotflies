# System Monitoring: btop, fastfetch, and Friends

> Keep an eye on your machine -- CPU, memory, disk, network, and processes -- with modern monitoring tools and handy shell functions.

## Your Setup

System monitoring tools installed via Homebrew in the master Brewfile:

```ruby
brew "btop"
brew "fastfetch"
cask "stats"
```

In addition, several shell aliases and functions in `~/.aliases.zsh` provide quick access to system information:

```bash
# File and directory sizes
fs() { du -sh -- "$@" | sort -h; }

# Compare original vs gzipped file size
gz() {
  local orig=$(wc -c < "$1")
  local gzipped=$(gzip -c "$1" | wc -c)
  echo "orig: $(echo "$orig" | numfmt --to=iec) / gzip: $(echo "$gzipped" | numfmt --to=iec) / ratio: $(echo "scale=2; $gzipped * 100 / $orig" | bc)%"
}

# Quick HTTP server
server() { open "http://localhost:${1:-8000}" && python3 -m http.server "${1:-8000}"; }

# Networking
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias flush="dscacheutil -flushcache && killall -HUP mDNSResponder"
```

## Core Concepts

### btop -- Interactive Resource Monitor

btop is a modern replacement for htop and top. It provides a rich terminal UI showing CPU usage per core, memory and swap usage, disk I/O, network throughput, and a filterable process list. It supports mouse interaction, vim-style keyboard navigation, and process management (send signals, renice).

### fastfetch -- System Information Display

fastfetch is a fast system information tool (a rewrite of neofetch in C). It displays a quick summary of your system: OS, kernel version, uptime, installed packages, shell, terminal, CPU, GPU, and memory. It is primarily used for quick reference and for showing off your terminal setup.

### Stats -- Menu Bar Monitor

Stats is a macOS application (installed as a cask) that places live system metrics in the menu bar. It shows CPU load, memory pressure, disk usage, network activity, and battery status at a glance without opening a terminal.

## Essential Commands -- btop

| Command / Key | Purpose |
|---|---|
| `btop` | Launch the interactive monitor |
| `f` | Filter processes by name |
| `/` | Search for a process |
| `t` | Toggle tree view for processes |
| `k` | Send a signal to the selected process |
| `s` | Select signal type to send |
| `n` | Nice/renice the selected process |
| `e` | Toggle per-core CPU graph |
| `m` | Toggle memory graph style |
| `d` | Toggle disk I/O display |
| `Up/Down` | Navigate the process list |
| `Left/Right` | Change sorting column |
| `Enter` | Show detailed info for selected process |
| `Tab` | Cycle through display sections |
| `Esc` | Close menus and dialogs |
| `q` | Quit btop |
| `h` | Show help |

### btop Configuration

btop stores its configuration in `~/.config/btop/btop.conf`. Key settings include:

| Setting | Purpose |
|---|---|
| `color_theme` | Theme name (e.g., catppuccin_mocha) |
| `theme_background` | Whether to use the theme's background colour |
| `vim_keys` | Enable h/j/k/l navigation |
| `update_ms` | Refresh interval in milliseconds |
| `proc_sorting` | Default sort column (cpu, mem, pid, etc.) |
| `proc_tree` | Start in tree view |

## Essential Commands -- fastfetch

| Command | Purpose |
|---|---|
| `fastfetch` | Display full system info summary |
| `fastfetch --logo none` | Display info without the logo |
| `fastfetch --structure OS:Kernel:Uptime:Shell` | Show only selected modules |
| `fastfetch --list-modules` | List all available info modules |
| `fastfetch --gen-config` | Generate a default config file |
| `fastfetch -c paleofetch` | Use a preset configuration |

fastfetch output includes:

- **OS**: macOS version and build
- **Kernel**: Darwin kernel version
- **Uptime**: How long since last restart
- **Packages**: Count from Homebrew, npm, pip, etc.
- **Shell**: zsh version
- **Terminal**: iTerm2
- **CPU**: Model and speed
- **GPU**: Integrated and discrete graphics
- **Memory**: Used / Total

## Shell Functions and Aliases

### fs -- File and Directory Sizes

```bash
fs() { du -sh -- "$@" | sort -h; }
```

Usage:

| Command | Purpose |
|---|---|
| `fs *` | Show sizes of everything in the current directory, sorted |
| `fs ~/Projects/*` | Compare project directory sizes |
| `fs .git node_modules src` | Check specific directories |
| `fs *.log` | Check sizes of all log files |

The `-h` flag on both `du` and `sort` ensures human-readable sizes (K, M, G) are sorted numerically, so 2M comes before 1G.

### gz -- Gzip Compression Ratio

```bash
gz() {
  local orig=$(wc -c < "$1")
  local gzipped=$(gzip -c "$1" | wc -c)
  echo "orig: $(echo "$orig" | numfmt --to=iec) / gzip: $(echo "$gzipped" | numfmt --to=iec) / ratio: $(echo "scale=2; $gzipped * 100 / $orig" | bc)%"
}
```

Usage:

```bash
gz bundle.js
# orig: 450K / gzip: 112K / ratio: 24.89%
```

This is invaluable for web development -- quickly check how well your JavaScript, CSS, or JSON compresses before deploying.

### server -- Quick HTTP Server

```bash
server() { open "http://localhost:${1:-8000}" && python3 -m http.server "${1:-8000}"; }
```

Usage:

| Command | Purpose |
|---|---|
| `server` | Serve current directory on port 8000 |
| `server 3000` | Serve on port 3000 |

This opens the browser automatically and starts Python's built-in HTTP server. Useful for previewing static sites, testing HTML files, or sharing files on a local network.

### Networking Aliases

| Alias | Expands To | Purpose |
|---|---|---|
| `ip` | `dig +short myip.opendns.com @resolver1.opendns.com` | Show your public IP address |
| `localip` | `ipconfig getifaddr en0` | Show your local network IP |
| `flush` | `dscacheutil -flushcache && killall -HUP mDNSResponder` | Flush the DNS cache |

## Practical Recipes

### Diagnose high CPU usage

```bash
# Launch btop, press 'f' to filter, type the suspect process name
btop
```

Alternatively, for a quick non-interactive check:

```bash
ps aux | sort -rn -k 3 | head -10
```

### Check disk space across all volumes

```bash
df -h | grep -v tmpfs
```

Or for specific directories:

```bash
fs ~/Projects ~/Documents ~/Downloads
```

### Monitor network connections

```bash
# In btop, press 'd' to toggle the network panel
# For a quick snapshot outside btop:
lsof -i -P -n | grep LISTEN
```

### Quick system overview for troubleshooting

```bash
fastfetch
```

This gives you OS version, kernel, uptime, and hardware specs in one shot -- useful when filing bug reports or asking for help.

### Find what is eating disk space

```bash
# Top-level breakdown
fs /*

# Drill into a specific directory
fs ~/Library/*

# Find largest files recursively
find . -type f -exec du -h {} + | sort -rh | head -20
```

### Check if a port is in use

```bash
lsof -i :8080
```

### Kill a process by name

```bash
# Find it
pgrep -l node

# Kill it
pkill node

# Or use btop: navigate to the process, press 'k', select SIGTERM
```

## Advanced Usage

### btop Themes

btop supports themes stored in `~/.config/btop/themes/`. Community themes are available, including Catppuccin variants that match the rest of your terminal aesthetic:

```bash
# Download Catppuccin theme for btop
curl -o ~/.config/btop/themes/catppuccin_mocha.theme \
  https://raw.githubusercontent.com/catppuccin/btop/main/themes/catppuccin_mocha.theme
```

Then set `color_theme = "catppuccin_mocha"` in `~/.config/btop/btop.conf`.

### Scripting System Checks

Combine these tools in a morning startup script:

```bash
#!/bin/bash
echo "=== System Status ==="
fastfetch --structure OS:Uptime:CPU:Memory --logo none
echo ""
echo "=== Disk Usage ==="
df -h / | tail -1
echo ""
echo "=== Public IP ==="
dig +short myip.opendns.com @resolver1.opendns.com
```

### Stats Menu Bar Customization

Stats (the menu bar app) is configured through its GUI preferences. You can choose which monitors to display:

- CPU utilization (percentage or graph)
- Memory pressure
- Disk read/write rates
- Network upload/download speeds
- Battery percentage and time remaining
- Fan speed and temperature sensors

Each widget can be customized for colour, update interval, and display format. Since it runs as a menu bar app, it provides always-visible monitoring without consuming a terminal window.

### Maintenance Aliases

Your setup also includes maintenance shortcuts:

| Alias | Purpose |
|---|---|
| `cleanup` | Delete all `.DS_Store` files recursively |
| `emptytrash` | Force-empty Trash and system log files |
| `update` | Run macOS software update, Homebrew update/upgrade/cleanup |

The `update` alias is especially useful as a single command to keep everything current:

```bash
alias update="sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup"
```

\newpage
