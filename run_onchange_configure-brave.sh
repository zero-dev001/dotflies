#!/bin/bash
set -euo pipefail

# Brave configuration via Chromium enterprise policies.
#
# Brave reads policy from its macOS preference domain, so `defaults write
# com.brave.Browser <PolicyName>` applies without MDM or sudo. These land as
# user-level (not forced) policies -- visible at brave://policy.
#
# Scope note: this file covers only settings that are safe and meaningful to
# version control. Bookmarks, history, passwords and per-extension state live
# in the browser profile, which is machine-bound (Chromium encrypts cookies and
# logins with a macOS Keychain key unique to each machine) and must never go in
# a public repo. Use Brave Sync for that data instead.

DOMAIN="com.brave.Browser"

# Extensions to install automatically on a new machine.
# "normal_installed" auto-installs but still lets you disable/remove them by
# hand; use "force_installed" instead to make one permanent.
#
# Wallet extensions are listed for convenience only -- the extension installs,
# but its keys do not transfer. Restore each wallet from its seed phrase.
EXTENSIONS=(
  "aeblfdkhhhdcdjpifhhbdiojplfjncoa" # 1Password - Password Manager
  "amibeingpndbmhcmnjdekhljpjcbjnpl" # Am I Being Pwned
  "bhghoamapcdpbohphigoooaddinpkbai" # Authenticator
  "epcnnfbjfcgphgdmggkamkmgojdagdnn" # uBlock
  "fcoeoabgfenejglbffodgkkbkcdhcgfn" # Claude
  "fhbohimaelbohpjbbldcngcnapndodjp" # BEW lite
  "khncfooichmfjbepaaaebmommgaepoid" # Unhook - Remove YouTube Recommended & Shorts
  "laookkfknpbbblfpciffpaejjkokdgca" # Momentum
  "ldpochfccmkkmhdbclfhpagapcfdljkj" # Decentraleyes
  "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # Privacy Badger
  # -- wallets (extension only; keys need manual seed restore) --
  "bfnaelmomeimhlpmgjnjophhpkkoljpa" # Phantom
  "cfbfdhimifdmdehjmkdobpcjfefblkjm" # Plug
  "fldfpgipfncgndfolcbkdeeknbbbnhcc" # My Wallet - Crypto & Web3
  "idnnbdplmphpflfnlkomgpfbpcgelopg" # Xverse: Bitcoin Crypto Wallet
  "mkpegjkblkkefacfnmkajcjmabijhclg" # Magic Eden Wallet
  "pmbjpcmaaladnfpacpmhmnfmpklgbdjb" # OP_WALLET
)

CRX_UPDATE_URL="https://clients2.google.com/service/update2/crx"

echo "Configuring Brave policies..."

# Rebuild ExtensionSettings from scratch so removing an entry above actually
# drops it, rather than leaving a stale key behind.
defaults delete "$DOMAIN" ExtensionSettings 2>/dev/null || true
defaults write "$DOMAIN" ExtensionSettings -dict

for ext in "${EXTENSIONS[@]}"; do
  defaults write "$DOMAIN" ExtensionSettings -dict-add "$ext" \
    "{\"installation_mode\"=\"normal_installed\";\"update_url\"=\"$CRX_UPDATE_URL\";}"
done

# 1Password is the password manager, so keep Brave's built-in one out of the way.
defaults write "$DOMAIN" PasswordManagerEnabled -bool false

# Drop the promos that otherwise need dismissing on every fresh machine.
defaults write "$DOMAIN" BraveRewardsDisabled -bool true
defaults write "$DOMAIN" BraveVPNDisabled -bool true

# Privacy defaults, consistent with the rest of this setup.
defaults write "$DOMAIN" MetricsReportingEnabled -bool false
defaults write "$DOMAIN" BackgroundModeEnabled -bool false

echo "Brave policies applied (${#EXTENSIONS[@]} extensions). Restart Brave, then verify at brave://policy"
