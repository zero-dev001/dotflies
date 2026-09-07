#!/bin/bash
set -euo pipefail

if ! command -v herdr &>/dev/null; then
  echo "Installing Herdr..."
  curl -fsSL https://herdr.dev/install.sh | sh
  echo "Herdr installed."
else
  echo "Herdr is already installed."
fi
