#!/bin/bash
set -euo pipefail

if ! command -v mise &>/dev/null; then
  echo "Installing mise..."
  curl https://mise.run | sh
  echo "mise installed."
else
  echo "mise is already installed."
fi
