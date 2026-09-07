#!/bin/bash

# ~/.macos — macOS defaults for development
# Adapted from https://github.com/mathiasbynens/dotfiles
# Only includes settings compatible with macOS Sequoia / Apple Silicon

# run_once_ in chezmoi means "once per content hash": editing this file makes it
# run again on the next `chezmoi apply`. Every write below is idempotent, so a
# re-run is safe; it ends by restarting Dock, Finder and friends.
#
# Nothing here needs root, so there is deliberately no `sudo -v`. The login
# LaunchAgent runs `chezmoi update --no-tty`, where a sudo prompt cannot be
# answered and would only stall the run.

# Close System Settings to prevent overriding changes
osascript -e 'tell application "System Settings" to quit' 2>/dev/null

###############################################################################
# Keyboard (THE biggest win for developers)                                   #
###############################################################################

# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Blazingly fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# Enable full keyboard access for all controls
# (e.g. enable Tab in modal dialogs to tab to "Don't Save")
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Disable automatic capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart dashes (they break code)
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic period substitution
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart quotes (they break code)
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

###############################################################################
# Trackpad & Input                                                            #
###############################################################################

# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Tracking speed for trackpad and mouse. 3.0 is the right-hand end of the
# System Settings slider. Read at login, so a change here needs a logout/login
# (or a reboot) before it is felt.
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 3.0
defaults write NSGlobalDomain com.apple.mouse.scaling -float 3.0

# Use scroll gesture with the Ctrl (^) modifier key to zoom
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

###############################################################################
# Finder                                                                      #
###############################################################################

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Use list view in all Finder windows by default
# Four-letter codes for other views: `icnv`, `clmv`, `glyv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Disable Finder animations
defaults write com.apple.finder DisableAllAnimations -bool true

# Show the ~/Library folder
chflags nohidden ~/Library 2>/dev/null
xattr -d com.apple.FinderInfo ~/Library 2>/dev/null

# Expand "General", "Open with", and "Sharing & Permissions" in Get Info
defaults write com.apple.finder FXInfoPanesExpanded -dict \
	General -bool true \
	OpenWith -bool true \
	Privileges -bool true

###############################################################################
# Save / Print / Dialogs                                                      #
###############################################################################

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Save to disk (not iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Disable the "Are you sure you want to open this application?" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

###############################################################################
# Screenshots                                                                 #
###############################################################################

# Save screenshots to ~/Desktop/screenshots
mkdir -p "${HOME}/Desktop/screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Desktop/screenshots"

# Save screenshots in PNG format
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

###############################################################################
# Dock                                                                        #
###############################################################################

# Set icon size to 36 pixels
defaults write com.apple.dock tilesize -int 36

# Pin the Dock to the left edge
defaults write com.apple.dock orientation -string "left"

# Scale effect instead of Genie for minimize
defaults write com.apple.dock mineffect -string "scale"

# Minimize windows into their application's icon
defaults write com.apple.dock minimize-to-application -bool true

# Don't animate opening applications from the Dock
defaults write com.apple.dock launchanim -bool false

# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1

# Don't automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Auto-hide the Dock
defaults write com.apple.dock autohide -bool true

# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0

# Remove the animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0

# Make icons of hidden applications translucent
defaults write com.apple.dock showhidden -bool true

# Don't show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

# Magnify icons on hover
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -int 73

# Dock contents. macOS seeds a fresh account with a dozen Apple apps; replace
# that with the short list below. Only apps present on this machine are added,
# because a missing app shows up as a "?" tile. Add apps in the order they
# should appear.
dock_apps=(
  "/Applications/Brave Browser.app"
  "/Applications/Parallels Desktop.app"
)
defaults write com.apple.dock persistent-apps -array
for app in "${dock_apps[@]}"; do
  [ -d "$app" ] || continue
  url="file://${app// /%20}/"
  defaults write com.apple.dock persistent-apps -array-add "<dict>
    <key>tile-data</key><dict>
      <key>file-data</key><dict>
        <key>_CFURLString</key><string>${url}</string>
        <key>_CFURLStringType</key><integer>15</integer>
      </dict>
    </dict>
    <key>tile-type</key><string>file-tile</string>
  </dict>"
done

# Right side of the Dock: a Downloads stack, sorted by date added, fan view.
defaults write com.apple.dock persistent-others -array "<dict>
  <key>tile-data</key><dict>
    <key>file-data</key><dict>
      <key>_CFURLString</key><string>file://${HOME}/Downloads/</string>
      <key>_CFURLStringType</key><integer>15</integer>
    </dict>
    <key>arrangement</key><integer>2</integer>
    <key>displayas</key><integer>0</integer>
    <key>showas</key><integer>1</integer>
  </dict>
  <key>tile-type</key><string>directory-tile</string>
</dict>"

###############################################################################
# Window / UI Speed                                                           #
###############################################################################

# Increase window resize speed for Cocoa applications
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# Disable the over-the-top focus ring animation
defaults write NSGlobalDomain NSUseAnimatedFocusRing -bool false

# Set Help Viewer windows to non-floating mode
defaults write com.apple.helpviewer DevMode -bool true

# Disable Resume system-wide
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

###############################################################################
# Security                                                                    #
###############################################################################

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

###############################################################################
# Terminal / iTerm2                                                           #
###############################################################################

# Only use UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4

# Enable Secure Keyboard Entry in Terminal.app
defaults write com.apple.terminal SecureKeyboardEntry -bool true

# Disable the annoying line marks in Terminal.app
defaults write com.apple.Terminal ShowLineMarks -int 0

# Don't display the annoying prompt when quitting iTerm
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

###############################################################################
# Activity Monitor                                                            #
###############################################################################

# Show main window when launching
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# Visualize CPU usage in the Dock icon
defaults write com.apple.ActivityMonitor IconType -int 5

# Show all processes
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Sort by CPU usage
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

###############################################################################
# TextEdit                                                                    #
###############################################################################

# Use plain text mode for new documents
defaults write com.apple.TextEdit RichText -int 0

# Open and save files as UTF-8
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

###############################################################################
# Mac App Store                                                               #
###############################################################################

# Enable automatic update check
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# Check for software updates daily
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Download newly available updates in background
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# Install system data files & security updates
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

# Turn on app auto-update
defaults write com.apple.commerce AutoUpdate -bool true

###############################################################################
# Photos                                                                      #
###############################################################################

# Prevent Photos from opening automatically when devices are plugged in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

###############################################################################
# Messages                                                                    #
###############################################################################

# Disable automatic emoji substitution
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false

# Disable smart quotes in Messages (annoying for code snippets)
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

###############################################################################
# Mail                                                                        #
###############################################################################

# Copy email addresses as `foo@example.com` instead of `Foo Bar <foo@example.com>`
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

# Disable inline attachments (just show the icons)
defaults write com.apple.mail DisableInlineAttachmentViewing -bool true

###############################################################################
# Kill affected applications                                                  #
###############################################################################

for app in "Activity Monitor" \
	"cfprefsd" \
	"Dock" \
	"Finder" \
	"Mail" \
	"Messages" \
	"Photos" \
	"SystemUIServer" \
	"Terminal"; do
	killall "${app}" &>/dev/null
done

echo "macOS defaults applied. Some changes require a logout/restart to take effect."
