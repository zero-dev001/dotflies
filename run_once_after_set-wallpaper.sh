#!/bin/bash
set -euo pipefail

WALLPAPER="$HOME/Pictures/Wallpapers/omarchy-quattro-official-5k.webp"

if [ -f "$WALLPAPER" ]; then
  osascript -e "tell application \"System Events\" to tell every desktop to set picture to POSIX file \"$WALLPAPER\""
  echo "Wallpaper set to $WALLPAPER"
else
  echo "Wallpaper file not found at $WALLPAPER, skipping" >&2
fi
