#!/bin/bash

# Install gh extensions (requires gh CLI to be installed)
if command -v gh &>/dev/null; then
  gh extension install dlvhdr/gh-dash || true
fi
