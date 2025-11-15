#!/bin/bash

# Install Nerd Fonts (user-scoped by default)
# - Skippable via HAWKUP_SKIP_NERDFONTS=1
# - Configure fonts with NERDFONTS_FONTS (space-separated names)
# - Pin or override release with NERDFONTS_VERSION
# - Force re-install with NERDFONTS_FORCE=1
# - Change install dir with NERDFONTS_DIR

if [ "${HAWKUP_SKIP_NERDFONTS:-0}" = "1" ]; then
  echo "Skipping Nerd Fonts install (HAWKUP_SKIP_NERDFONTS=1)"
  return 0 2>/dev/null || exit 0
fi

# Respect explicit empty selection to skip
if [ "${NERDFONTS_FONTS+x}" = "x" ] && [ -z "${NERDFONTS_FONTS//[[:space:]]/}" ]; then
  echo "No Nerd Fonts selected; skipping install."
  return 0 2>/dev/null || exit 0
fi

# Default fonts if none were specified
FONTS_STR="${NERDFONTS_FONTS:-JetBrainsMono FiraCode Hack}"

# Source shared helpers
source "$HAWKUP_DIR/install/lib/nerdfonts.sh" 2>/dev/null || true

# Compute tag and install
TAG="${NERDFONTS_VERSION:-$(nf_latest_tag)}"
# shellcheck disable=SC2206
FONTS_ARR=($FONTS_STR)

mkdir -p "${NERDFONTS_DIR:-$HOME/.local/share/fonts/NerdFonts}" || true
nf_install_fonts "$TAG" "${FONTS_ARR[@]}"

echo "Nerd Fonts install step completed."
