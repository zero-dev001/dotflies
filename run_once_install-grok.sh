#!/bin/bash
set -euo pipefail

if [ -x "$HOME/.grok/bin/grok" ]; then
  echo "Grok CLI is already installed."
  exit 0
fi

echo "Installing Grok CLI..."
# Two things the upstream installer does would fight chezmoi:
#   1. it appends a "grok installer" PATH block to the rc file of $SHELL --
#      ~/.zshrc is generated from dot_zshrc.tmpl, so the block is reverted on
#      the next apply. Blanking SHELL leaves it with no rc file to edit.
#   2. when ~/.grok/bin is not already on PATH it symlinks grok/agent into
#      ~/.local/bin. Pre-seeding PATH makes it skip that.
# dot_zshrc.tmpl puts ~/.grok/bin on PATH and loads the completions instead.
curl -fsSL https://x.ai/cli/install.sh | SHELL='' PATH="$HOME/.grok/bin:$PATH" bash

echo "Grok CLI installed. Run 'grok login' once on this machine to authenticate."
