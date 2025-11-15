#!/bin/bash

AVAILABLE_LANGUAGES=("Bun" "Deno" "Elixir" "Go" "Java" "Node.js" "PHP" "Python" "Ruby" "Rust" "Zig")
DEFAULT_LANGUAGES="Bun,Node.js"

# If preset, honor it; otherwise prompt with gum
if [ -z "${HAWKUP_FIRST_RUN_LANGUAGES//[[:space:]]/}" ]; then
  export HAWKUP_FIRST_RUN_LANGUAGES=$(gum choose "${AVAILABLE_LANGUAGES[@]}" --no-limit --selected "$DEFAULT_LANGUAGES" --height 10 --header "Select programming languages")
else
  echo "Using preset languages: $HAWKUP_FIRST_RUN_LANGUAGES"
fi

AVAILABLE_DBS=("MySQL" "PostgreSQL" "Redis")
DEFAULT_DBS=""
if [ -z "${HAWKUP_FIRST_RUN_DBS//[[:space:]]/}" ]; then
  export HAWKUP_FIRST_RUN_DBS=$(gum choose "${AVAILABLE_DBS[@]}" --no-limit --selected "$DEFAULT_DBS" --height 3 --header "Select databases (runs in Docker)")
else
  echo "Using preset databases: $HAWKUP_FIRST_RUN_DBS"
fi

# Nerd Fonts selection (using shared helpers)
source "$HAWKUP_DIR/install/lib/nerdfonts.sh" 2>/dev/null || true

NFV="${NERDFONTS_VERSION:-$(nf_latest_tag)}"
mapfile -t AVAILABLE_NF < <(nf_list_fonts "$NFV")
if [ ${#AVAILABLE_NF[@]} -eq 0 ]; then
  AVAILABLE_NF=(CascadiaMono CascadiaCode FiraMono FiraCode Hack JetBrainsMono Meslo Mononoki Iosevka VictorMono NerdFontsSymbolsOnly)
fi

DEFAULT_NF="CascadiaMono,FiraMono,JetBrainsMono,Meslo"

if [ -z "${NERDFONTS_FONTS//[[:space:]]/}" ]; then
  SEL=$(gum choose "${AVAILABLE_NF[@]}" --no-limit --selected "$DEFAULT_NF" --height 20 --header "Select Nerd Fonts to install (space to toggle)")
  export NERDFONTS_VERSION="$NFV"
  export NERDFONTS_FONTS="$(printf "%s" "$SEL" | tr '\n' ' ' | sed 's/  */ /g;s/^ //;s/ $//')"
else
  echo "Using preset Nerd Fonts: $NERDFONTS_FONTS"
fi
