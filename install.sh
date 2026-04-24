#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Root directory for Hawkup (allows running from any extracted path)
HAWKUP_DIR="${HAWKUP_DIR:-$HOME/.local/share/hawkup}"

# Ensure hawkup helper is executable even if repo mode is wrong
chmod +x "$HAWKUP_DIR/bin/hawkup" || true

# Source apt helper and be defensive once at the start; subsequent apt runs are sequential
source "$HAWKUP_DIR/install/lib/apt.sh"
wait_for_apt

# Give people a chance to retry running the installation
trap 'echo "Hawkup installation failed! You can retry by running: HAWKUP_DIR=\"$HAWKUP_DIR\" bash \"$HAWKUP_DIR/install.sh\""' ERR

# Check the distribution name and version and abort if incompatible
source "$HAWKUP_DIR/install/pre-flight/check-version.sh"

# Ask for app choices
echo "Get ready to make a few choices..."
source "$HAWKUP_DIR/install/pre-flight/gum.sh" >/dev/null
source "$HAWKUP_DIR/install/pre-flight/first-run-choices.sh"
source "$HAWKUP_DIR/install/pre-flight/identification.sh"

source "$HAWKUP_DIR/install/terminal.sh"
source "$HAWKUP_DIR/install/post-flight/zsh-mounts.sh"

# Logout to pickup changes
if [ "${HAWKUP_SKIP_REBOOT:-0}" = "1" ]; then
  echo "Skipping reboot (HAWKUP_SKIP_REBOOT=1)"
else
  gum confirm "Ready to reboot for all settings to take effect?" && sudo reboot || true
fi
