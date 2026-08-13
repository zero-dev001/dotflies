#!/bin/bash
# Install Catppuccin Mocha themes for bat and btop
set -euo pipefail

# Bat - download Catppuccin Mocha .tmTheme
BAT_THEMES="$(bat --config-dir)/themes"
mkdir -p "$BAT_THEMES"
if [ ! -f "$BAT_THEMES/Catppuccin Mocha.tmTheme" ]; then
  echo "Installing Catppuccin Mocha theme for bat..."
  curl -fsSL -o "$BAT_THEMES/Catppuccin Mocha.tmTheme" \
    "https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Mocha.tmTheme"
  bat cache --build
else
  echo "Bat Catppuccin theme already installed."
fi

# Btop - download Catppuccin Mocha theme
BTOP_THEMES="$HOME/.config/btop/themes"
mkdir -p "$BTOP_THEMES"
if [ ! -f "$BTOP_THEMES/catppuccin_mocha.theme" ]; then
  echo "Installing Catppuccin Mocha theme for btop..."
  curl -fsSL -o "$BTOP_THEMES/catppuccin_mocha.theme" \
    "https://raw.githubusercontent.com/catppuccin/btop/main/themes/catppuccin_mocha.theme"
else
  echo "Btop Catppuccin theme already installed."
fi

echo "Catppuccin themes installed."
