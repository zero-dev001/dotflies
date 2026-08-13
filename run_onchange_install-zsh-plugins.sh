#!/bin/bash
# Install Oh My Zsh, Powerlevel10k, zsh-syntax-highlighting, zsh-autosuggestions
set -euo pipefail

ZSH="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"

# Install Oh My Zsh if not present
if [ ! -d "$ZSH" ]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Powerlevel10k theme
P10K_DIR="$ZSH_CUSTOM/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  echo "Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
  echo "Updating Powerlevel10k..."
  git -C "$P10K_DIR" pull --ff-only 2>/dev/null || true
fi

# Install zsh-syntax-highlighting
ZSH_SH_DIR="$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
if [ ! -d "$ZSH_SH_DIR" ]; then
  echo "Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_SH_DIR"
else
  echo "Updating zsh-syntax-highlighting..."
  git -C "$ZSH_SH_DIR" pull --ff-only 2>/dev/null || true
fi

# Install zsh-autosuggestions
ZSH_AS_DIR="$ZSH_CUSTOM/plugins/zsh-autosuggestions"
if [ ! -d "$ZSH_AS_DIR" ]; then
  echo "Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_AS_DIR"
else
  echo "Updating zsh-autosuggestions..."
  git -C "$ZSH_AS_DIR" pull --ff-only 2>/dev/null || true
fi

# Install zsh-completions
ZSH_COMP_DIR="$ZSH_CUSTOM/plugins/zsh-completions"
if [ ! -d "$ZSH_COMP_DIR" ]; then
  echo "Installing zsh-completions..."
  git clone https://github.com/zsh-users/zsh-completions.git "$ZSH_COMP_DIR"
else
  echo "Updating zsh-completions..."
  git -C "$ZSH_COMP_DIR" pull --ff-only 2>/dev/null || true
fi

echo "Zsh plugins installed."
