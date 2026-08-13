#!/bin/bash
# Install TPM and tmux plugins
set -euo pipefail

TPM_DIR="$HOME/.tmux/plugins/tpm"

# Install TPM if not present
if [ ! -d "$TPM_DIR" ]; then
  echo "Installing Tmux Plugin Manager..."
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
  echo "Updating TPM..."
  git -C "$TPM_DIR" pull --ff-only 2>/dev/null || true
fi

# Install tmux plugins (non-interactive)
if [ -f "$TPM_DIR/bin/install_plugins" ]; then
  echo "Installing tmux plugins..."
  "$TPM_DIR/bin/install_plugins" || true
fi

echo "Tmux plugins installed."
