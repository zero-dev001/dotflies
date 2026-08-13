# macOS Defaults

> A stock macOS installation is designed for casual users -- these defaults transform it into a development operating system.

---

## Your Setup

macOS stores application and system preferences in a property list (plist) database. The `defaults` command reads and writes entries in this database. zero.dev001's macOS defaults script runs once via chezmoi and configures approximately 60 settings across 15 categories.

- **Script:** `run_once_macos-defaults.sh`
- **Chezmoi source:** `~/.local/share/chezmoi/run_once_macos-defaults.sh`
- **Execution:** Runs automatically on first `chezmoi apply`, never again (prefix `run_once_`)
- **Requires:** Administrator password (uses `sudo`)
- **Post-run:** Kills affected applications to apply changes immediately
- **Based on:** Mathias Bynens' `.macos` dotfile, adapted for macOS Sequoia and Apple Silicon

The script begins by closing System Settings (to prevent it from overwriting changes) and establishing a sudo keep-alive:

```bash
osascript -e 'tell application "System Settings" to quit' 2>/dev/null
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
```

## Core Concepts

### How macOS Defaults Work

Every macOS application stores its preferences in plist files under `~/Library/Preferences/`. The `defaults` command provides a CLI to read and write these files without opening System Settings.

```bash
# Read a value
defaults read com.apple.dock tilesize

# Write a value
defaults write com.apple.dock tilesize -int 36

# Delete a value (reset to system default)
defaults delete com.apple.dock tilesize

# Read all values for an app
defaults read com.apple.dock
```

Changes to most settings require restarting the affected application. The script handles this by killing all affected apps at the end.

**Important:** Some `defaults write` commands modify `NSGlobalDomain`, which applies to all applications. Others target specific app domains like `com.apple.dock` or `com.apple.finder`.

### The run_once_ Prefix

The `run_once_` prefix in the filename tells chezmoi to run this script exactly once. Chezmoi tracks whether it has been executed by storing a hash of the file. If you modify the script, chezmoi will re-run it on the next `chezmoi apply`.

To force a re-run:

```bash
# Re-run by changing the script content (even a comment change works)
chezmoi edit run_once_macos-defaults.sh
chezmoi apply

# Or run it directly
bash ~/.local/share/chezmoi/run_once_macos-defaults.sh
```

## Essential Commands

### Keyboard Settings

These are the most impactful settings for a developer. They eliminate the delay that macOS adds to key input and disable text transformations that break code.

| Setting                                    | Domain            | Value      | Effect                          |
|--------------------------------------------|-------------------|------------|---------------------------------|
| `ApplePressAndHoldEnabled`                 | `NSGlobalDomain`  | `false`    | Disable accent popup on key hold|
| `KeyRepeat`                                | `NSGlobalDomain`  | `1`        | Fastest key repeat rate         |
| `InitialKeyRepeat`                         | `NSGlobalDomain`  | `10`       | Shortest delay before repeat    |
| `AppleKeyboardUIMode`                      | `NSGlobalDomain`  | `3`        | Tab through all UI controls     |
| `NSAutomaticCapitalizationEnabled`         | `NSGlobalDomain`  | `false`    | No auto-capitalize              |
| `NSAutomaticDashSubstitutionEnabled`       | `NSGlobalDomain`  | `false`    | No smart dashes (-- to em-dash) |
| `NSAutomaticPeriodSubstitutionEnabled`     | `NSGlobalDomain`  | `false`    | No double-space period          |
| `NSAutomaticQuoteSubstitutionEnabled`      | `NSGlobalDomain`  | `false`    | No smart quotes (" to curly)    |
| `NSAutomaticSpellingCorrectionEnabled`     | `NSGlobalDomain`  | `false`    | No autocorrect                  |

**Why these matter:**

- **Press-and-hold disabled:** On a stock Mac, holding a key shows an accent picker (e, e, e, etc.). This is useless for development and prevents key repeat. Disabling it restores key repeat behavior, which is essential for holding `j` in Vim to scroll down.
- **KeyRepeat=1, InitialKeyRepeat=10:** These are the lowest possible values. The key starts repeating almost instantly (10/60th of a second delay) and repeats at the maximum rate (1/60th of a second between repeats). This makes keyboard-driven navigation extremely responsive.
- **Full keyboard access (mode 3):** Allows Tab to cycle through all controls in dialogs, not just text fields. This means you can Tab to "Don't Save" in a save dialog instead of reaching for the mouse.
- **All auto-substitutions disabled:** Smart quotes turn `"hello"` into curly quotes that break code. Smart dashes turn `--` into em-dashes. Auto-period turns double-space into a period. Auto-capitalize changes the first letter after a period. All of these are destructive for programming.

### Trackpad and Input

| Setting                              | Domain                           | Value   | Effect                     |
|--------------------------------------|----------------------------------|---------|----------------------------|
| `Clicking` (Bluetooth trackpad)      | `com.apple.driver.AppleBluetoothMultitouch.trackpad` | `true` | Tap to click |
| `com.apple.mouse.tapBehavior`        | `NSGlobalDomain`                 | `1`     | Tap to click system-wide   |
| `closeViewScrollWheelToggle`         | `com.apple.universalaccess`      | `true`  | Ctrl+scroll to zoom        |
| `HIDScrollZoomModifierMask`          | `com.apple.universalaccess`      | `262144`| Use Ctrl key for zoom      |
| `closeViewZoomFollowsFocus`          | `com.apple.universalaccess`      | `true`  | Zoom follows keyboard focus|

**Tap to click** avoids the need to physically press the trackpad. A light tap registers as a click.

**Ctrl+scroll zoom** is invaluable for presentations, reading small text, or inspecting UI details.

### Finder

| Setting                          | Domain                      | Value    | Effect                          |
|----------------------------------|-----------------------------|----------|---------------------------------|
| `AppleShowAllExtensions`         | `NSGlobalDomain`            | `true`   | Show file extensions always     |
| `ShowStatusBar`                  | `com.apple.finder`          | `true`   | Show item count and disk space  |
| `ShowPathbar`                    | `com.apple.finder`          | `true`   | Show path breadcrumb at bottom  |
| `_FXShowPosixPathInTitle`        | `com.apple.finder`          | `true`   | Full POSIX path in title bar    |
| `_FXSortFoldersFirst`           | `com.apple.finder`          | `true`   | Folders above files when sorting|
| `FXDefaultSearchScope`          | `com.apple.finder`          | `SCcf`   | Search current folder, not Mac  |
| `FXEnableExtensionChangeWarning`| `com.apple.finder`          | `false`  | No warning on extension change  |
| `DSDontWriteNetworkStores`      | `com.apple.desktopservices` | `true`   | No .DS_Store on network volumes |
| `DSDontWriteUSBStores`          | `com.apple.desktopservices` | `true`   | No .DS_Store on USB volumes     |
| `FXPreferredViewStyle`          | `com.apple.finder`          | `Nlsv`   | Default to list view            |
| `DisableAllAnimations`          | `com.apple.finder`          | `true`   | No animations                   |
| Show ~/Library                   | `chflags nohidden`          | --       | Unhide the Library folder       |
| Expanded Info panes              | `FXInfoPanesExpanded`       | dict     | General, Open With, Privileges  |

**Key choices explained:**

- **POSIX path in title bar** shows `/Users/zero/projects/app` instead of "app" in the Finder title. This makes it easy to copy the path and use it in the terminal.
- **Search current folder** prevents the maddening default of searching the entire Mac when you press Cmd+F in a Finder window.
- **No .DS_Store on network/USB** prevents littering shared drives and external media with macOS metadata files that are meaningless on other operating systems.
- **List view** is the most information-dense Finder view and the closest to a terminal listing.

### Save, Print, and Dialogs

| Setting                                  | Domain            | Value   | Effect                           |
|------------------------------------------|-------------------|---------|----------------------------------|
| `NSNavPanelExpandedStateForSaveMode`     | `NSGlobalDomain`  | `true`  | Expanded save dialog             |
| `NSNavPanelExpandedStateForSaveMode2`    | `NSGlobalDomain`  | `true`  | Expanded save dialog (variant)   |
| `PMPrintingExpandedStateForPrint`        | `NSGlobalDomain`  | `true`  | Expanded print dialog            |
| `PMPrintingExpandedStateForPrint2`       | `NSGlobalDomain`  | `true`  | Expanded print dialog (variant)  |
| `NSDocumentSaveNewDocumentsToCloud`      | `NSGlobalDomain`  | `false` | Save to local disk, not iCloud   |
| `Quit When Finished`                     | `com.apple.print.PrintingPrefs` | `true` | Auto-quit printer app    |
| `LSQuarantine`                           | `com.apple.LaunchServices` | `false` | No quarantine dialog        |

**Expanded save/print panels** show the full file browser instead of the minimized dropdown. The minimized version hides the directory tree and forces you to navigate through a tiny interface.

**Save to disk** prevents the infuriating default of saving new documents to iCloud instead of the local filesystem.

**No quarantine dialog** suppresses the "Are you sure you want to open this application downloaded from the internet?" dialog. Since all applications are installed through Homebrew or the App Store, this dialog adds friction without adding security.

### Screenshots

| Setting              | Domain                      | Value                          | Effect                  |
|----------------------|-----------------------------|--------------------------------|-------------------------|
| `location`           | `com.apple.screencapture`   | `~/Desktop/screenshots`        | Custom save location    |
| `type`               | `com.apple.screencapture`   | `png`                          | PNG format (lossless)   |
| `disable-shadow`     | `com.apple.screencapture`   | `true`                         | No window shadow        |

Screenshots go to a dedicated `~/Desktop/screenshots` directory instead of cluttering the Desktop. PNG format preserves quality for documentation and bug reports. Disabling the shadow removes the macOS drop shadow from window screenshots, producing cleaner images.

### Dock

| Setting                    | Domain            | Value    | Effect                          |
|----------------------------|-------------------|----------|---------------------------------|
| `tilesize`                 | `com.apple.dock`  | `36`     | Small 36px icons                |
| `mineffect`                | `com.apple.dock`  | `scale`  | Scale effect (faster than Genie)|
| `minimize-to-application`  | `com.apple.dock`  | `true`   | Minimize into app icon          |
| `launchanim`               | `com.apple.dock`  | `false`  | No bounce animation on launch   |
| `expose-animation-duration`| `com.apple.dock`  | `0.1`    | Fast Mission Control (100ms)    |
| `mru-spaces`               | `com.apple.dock`  | `false`  | No auto-rearrange Spaces        |
| `autohide`                 | `com.apple.dock`  | `true`   | Auto-hide the Dock              |
| `autohide-delay`           | `com.apple.dock`  | `0`      | No delay before hiding          |
| `autohide-time-modifier`   | `com.apple.dock`  | `0`      | No hide/show animation          |
| `showhidden`               | `com.apple.dock`  | `true`   | Translucent icons for hidden apps|
| `show-recents`             | `com.apple.dock`  | `false`  | No recent apps section          |

**The Dock philosophy:** The Dock is an obstacle in a keyboard-driven workflow. These settings minimize its footprint:

- **Auto-hide with zero delay and zero animation** means the Dock vanishes instantly when not needed and reappears instantly on hover. There is no animation lag.
- **36px icons** make the Dock as small as practical when it does appear.
- **No MRU Spaces** prevents macOS from reordering your Spaces based on usage. With Aerospace managing window positions, unpredictable Space reordering would break spatial muscle memory.
- **No recent apps** removes the "suggested" section from the Dock that wastes space.
- **No launch animation** eliminates the bouncing icon that plays when starting an app.
- **Scale effect** is the fastest minimize animation. Genie is visually dramatic but slower.

### Window and UI Speed

| Setting                                 | Domain            | Value    | Effect                      |
|-----------------------------------------|-------------------|----------|-----------------------------|
| `NSWindowResizeTime`                    | `NSGlobalDomain`  | `0.001`  | Near-instant window resize  |
| `NSUseAnimatedFocusRing`               | `NSGlobalDomain`  | `false`  | No focus ring animation     |
| `DevMode` (Help Viewer)                | `com.apple.helpviewer` | `true` | Non-floating Help Viewer  |
| `NSQuitAlwaysKeepsWindows`             | System Preferences| `false`  | Disable Resume system-wide  |

**Near-instant resize** (`0.001` seconds) makes Cocoa applications resize without visible animation. The default includes a smooth resize animation that feels sluggish in a tiling window manager where windows resize frequently.

**Non-floating Help Viewer** allows the Help window to go behind other windows. By default, Help windows float above everything, which is annoying when you want to read help and type commands simultaneously.

**Disable Resume** prevents applications from reopening their previous windows when launched. This avoids the situation where opening TextEdit launches with six old documents from months ago.

### Security

| Setting                | Domain                    | Value | Effect                           |
|------------------------|---------------------------|-------|----------------------------------|
| `askForPassword`       | `com.apple.screensaver`   | `1`   | Require password after screensaver|
| `askForPasswordDelay`  | `com.apple.screensaver`   | `0`   | No grace period                  |

Password is required immediately after sleep or the screen saver begins. There is no delay -- the instant the screen locks, a password is needed to unlock it. This is a basic security measure for any machine used in shared spaces.

### Terminal and iTerm2

| Setting                | Domain                    | Value    | Effect                     |
|------------------------|---------------------------|----------|----------------------------|
| `StringEncodings`      | `com.apple.terminal`      | `4`      | UTF-8 only                 |
| `SecureKeyboardEntry`  | `com.apple.terminal`      | `true`   | Prevents keylogging        |
| `ShowLineMarks`        | `com.apple.Terminal`      | `0`      | No line marks              |
| `PromptOnQuit`         | `com.googlecode.iterm2`   | `false`  | No quit confirmation       |

Terminal.app is configured as a fallback. UTF-8 encoding prevents character display issues. Secure keyboard entry prevents other applications from intercepting keystrokes sent to the terminal -- an important security measure when typing passwords or tokens.

The iTerm2 quit prompt is disabled because iTerm2 is the primary terminal and the confirmation dialog adds unnecessary friction when quitting.

### Activity Monitor

| Setting            | Domain                        | Value        | Effect                    |
|--------------------|-------------------------------|--------------|---------------------------|
| `OpenMainWindow`   | `com.apple.ActivityMonitor`   | `true`       | Show window on launch     |
| `IconType`         | `com.apple.ActivityMonitor`   | `5`          | CPU graph in Dock icon    |
| `ShowCategory`     | `com.apple.ActivityMonitor`   | `0`          | Show all processes        |
| `SortColumn`       | `com.apple.ActivityMonitor`   | `CPUUsage`   | Sort by CPU               |
| `SortDirection`    | `com.apple.ActivityMonitor`   | `0`          | Descending (highest first)|

Activity Monitor shows a live CPU usage graph in its Dock icon (IconType 5), providing a glanceable indicator of system load. Processes are sorted by CPU usage in descending order so the heaviest processes are always visible at the top.

### TextEdit

| Setting                     | Domain              | Value | Effect                     |
|-----------------------------|---------------------|-------|----------------------------|
| `RichText`                  | `com.apple.TextEdit`| `0`   | Plain text by default      |
| `PlainTextEncoding`         | `com.apple.TextEdit`| `4`   | Open files as UTF-8        |
| `PlainTextEncodingForWrite` | `com.apple.TextEdit`| `4`   | Save files as UTF-8        |

TextEdit defaults to rich text (RTF), which is almost never what a developer wants. These settings make it open and save plain text with UTF-8 encoding, turning it into a simple, fast notepad for quick edits.

### Mac App Store

| Setting                      | Domain                   | Value  | Effect                       |
|------------------------------|--------------------------|--------|------------------------------|
| `AutomaticCheckEnabled`      | `com.apple.SoftwareUpdate`| `true` | Enable update checks         |
| `ScheduleFrequency`          | `com.apple.SoftwareUpdate`| `1`    | Check daily                  |
| `AutomaticDownload`          | `com.apple.SoftwareUpdate`| `1`    | Download in background       |
| `CriticalUpdateInstall`      | `com.apple.SoftwareUpdate`| `1`    | Auto-install security updates|
| `AutoUpdate`                 | `com.apple.commerce`     | `true` | Auto-update App Store apps   |

Updates are checked daily, downloaded in the background, and security updates are installed automatically. This keeps the system patched without manual intervention.

### Photos

| Setting          | Domain                    | Value  | Effect                           |
|------------------|---------------------------|--------|----------------------------------|
| `disableHotPlug` | `com.apple.ImageCapture`  | `true` | No auto-open on device connect   |

Prevents Photos from opening automatically when an iPhone, camera, or SD card is connected. This is a frequent annoyance when plugging in a phone to charge.

### Messages

| Setting                                        | Domain                  | Value  | Effect                    |
|------------------------------------------------|-------------------------|--------|---------------------------|
| `automaticEmojiSubstitutionEnablediMessage`    | Messages controller     | `false`| No auto-emoji             |
| `automaticQuoteSubstitutionEnabled`            | Messages controller     | `false`| No smart quotes           |

Prevents Messages from converting text like `:)` into emoji and straight quotes into curly quotes. Both of these transformations are destructive when sharing code snippets in messages.

### Mail

| Setting                          | Domain            | Value  | Effect                           |
|----------------------------------|-------------------|--------|----------------------------------|
| `AddressesIncludeNameOnPasteboard`| `com.apple.mail` | `false`| Copy as `foo@bar.com` not `Name <foo@bar.com>` |
| `DisableInlineAttachmentViewing` | `com.apple.mail`  | `true` | Show attachment icons, not inline|

**Plain email addresses** means copying an address from Mail gives you `user@example.com` instead of `User Name <user@example.com>`. The plain format is what you actually need when pasting into forms, scripts, or configuration files.

**Disable inline attachments** shows attached files as icons instead of rendering them inline in the email body. This makes emails with attachments cleaner and prevents large images from taking over the view.

## Practical Recipes

### Recipe: Applying Defaults to a New Machine

```bash
# Option 1: Through chezmoi (runs automatically on first apply)
chezmoi init --apply your-github-username

# Option 2: Run the script directly
bash ~/.local/share/chezmoi/run_once_macos-defaults.sh

# Option 3: Apply a single setting manually
defaults write com.apple.dock autohide -bool true
killall Dock
```

After running the full script, a logout or restart is recommended to ensure all settings take effect. Most settings apply immediately after the affected app is restarted, but some (like keyboard repeat rate) may require a logout.

### Recipe: Checking Current Values

Before making changes, you can read the current value of any setting:

```bash
# Check keyboard repeat rate
defaults read NSGlobalDomain KeyRepeat
defaults read NSGlobalDomain InitialKeyRepeat

# Check Dock settings
defaults read com.apple.dock tilesize
defaults read com.apple.dock autohide

# Check if autocorrect is off
defaults read NSGlobalDomain NSAutomaticSpellingCorrectionEnabled

# Dump all settings for an app
defaults read com.apple.finder

# Find a setting by name across all domains
defaults find "KeyRepeat"
```

### Recipe: Resetting a Single Setting

If a setting causes problems, delete it to restore the macOS default:

```bash
# Reset Dock icon size to system default
defaults delete com.apple.dock tilesize
killall Dock

# Reset keyboard repeat to system default
defaults delete NSGlobalDomain KeyRepeat
defaults delete NSGlobalDomain InitialKeyRepeat
# Logout required
```

### Recipe: Verifying Key Repeat Settings

After applying the keyboard defaults, test that key repeat works correctly:

```bash
# Open any text editor and hold down a key
# With KeyRepeat=1 and InitialKeyRepeat=10:
# - The key should start repeating almost immediately (~167ms)
# - Characters should appear very rapidly once repeating starts

# If the accent popup appears instead of key repeat:
defaults read NSGlobalDomain ApplePressAndHoldEnabled
# Should return 0 (false). If not:
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
# Then restart the application where you are testing
```

## Advanced Usage

### Understanding the Sudo Keep-Alive

The script uses a background loop to maintain sudo privileges:

```bash
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
```

This works as follows:

1. `sudo -v` prompts for the password and caches the credentials.
2. The `while` loop runs in the background, refreshing the sudo timestamp every 60 seconds.
3. `kill -0 "$$"` checks if the parent script is still running. If the script finishes, the loop exits.
4. The `2>/dev/null` suppresses error output from the loop.

This prevents the script from stalling mid-execution to ask for the password again.

### Settings That Require Logout or Restart

Most settings take effect immediately after restarting the affected application. However, some require a full logout or restart:

| Setting                   | Requires                      |
|---------------------------|-------------------------------|
| Keyboard repeat rate      | Logout (sometimes app restart)|
| Full keyboard access      | Logout                        |
| Tap to click              | Logout                        |
| Trackpad zoom             | Logout                        |
| Screenshot location       | App restart (screencapture)   |
| Dock changes              | `killall Dock`                |
| Finder changes            | `killall Finder`              |

The script kills affected applications at the end:

```bash
for app in "Activity Monitor" "cfprefsd" "Dock" "Finder" \
  "Mail" "Messages" "Photos" "SystemUIServer" "Terminal"; do
  killall "${app}" &>/dev/null
done
```

Note that `cfprefsd` is the preferences daemon. Killing it forces macOS to re-read all preference files from disk.

### Compatibility Notes

This script is adapted for macOS Sequoia on Apple Silicon. Some settings from older `.macos` scripts are intentionally excluded:

- **SIP-protected settings** that cannot be changed without disabling System Integrity Protection.
- **Deprecated domains** that no longer exist in modern macOS versions.
- **Settings that break on Apple Silicon** due to the different architecture.

If a setting does not take effect, check whether it has been superseded by a newer macOS version. Apple occasionally moves settings to new domains or removes them entirely.

### Monitoring Default Changes

To discover what settings an application uses, you can watch for changes:

```bash
# Before changing a setting in System Settings, dump the current state:
defaults read > /tmp/before.plist

# Make the change in System Settings GUI

# Dump the new state:
defaults read > /tmp/after.plist

# Diff to see what changed:
diff /tmp/before.plist /tmp/after.plist
```

This technique is useful for discovering undocumented `defaults write` commands that correspond to GUI toggles in System Settings.

\newpage
