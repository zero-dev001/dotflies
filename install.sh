#!/bin/bash
set -euo pipefail

# Bootstrap script for fresh machines
# Usage: curl -fsSL <raw-url>/install.sh | bash
#   or:  git clone <repo> && cd dotfiles && ./install.sh

# 1. Install Homebrew
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 2. Install chezmoi
if ! command -v chezmoi &>/dev/null; then
  echo "Installing chezmoi..."
  brew install chezmoi
fi

# 3. Initialize and apply chezmoi from this repo
echo "Initializing chezmoi..."
chezmoi init --apply zero-dev001/dotfiles

echo "Done! Open a new terminal to see the changes."
