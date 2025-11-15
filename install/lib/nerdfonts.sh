#!/bin/bash
# Nerd Fonts shared helpers (sourced by installers and CLI)

# Return 0 if a command exists
nf_have() { command -v "$1" >/dev/null 2>&1; }

# HTTP GET to stdout using curl or wget
nf_http() {
  local url="$1"
  if nf_have curl; then
    curl -fsSL -H "User-Agent: hawkup" "$url"
  elif nf_have wget; then
    wget -qO- "$url"
  else
    return 1
  fi
}

# Determine latest tag, honoring NERDFONTS_VERSION if set
nf_latest_tag() {
  if [ -n "${NERDFONTS_VERSION:-}" ]; then
    printf "%s" "$NERDFONTS_VERSION"
    return 0
  fi
  local tag
  tag=$(nf_http "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" 2>/dev/null \
    | sed 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
  printf "%s" "${tag:-v3.4.0}"
}

# Fetch assets JSON for a given tag
nf_release_json() {
  local tag="$1"
  nf_http "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/tags/${tag}" || true
}

# Parse asset names from release JSON based on browser_download_url; prints base names without .zip
nf_parse_asset_names() {
  grep -oE '"browser_download_url"[[:space:]]*:[[:space:]]*"[^"]*download/[^"]*/[^"]+\.zip"' \
  | sed -E 's/.*download\/[^\"]*\/([^\"]+)\.zip".*/\1/' \
  | grep -vi 'FontPatcher' \
  | sort -u
}

# List available font asset names for a tag
nf_list_fonts() {
  local tag="$1"
  local json
  json=$(nf_release_json "$tag")
  if [ -n "$json" ]; then
    printf "%s" "$json" | nf_parse_asset_names
  else
    printf "%s\n" CascadiaMono CascadiaCode FiraMono FiraCode Hack JetBrainsMono Meslo Mononoki Iosevka VictorMono NerdFontsSymbolsOnly
  fi
}

# Normalize common aliases/typos to release asset names
nf_normalize_name() {
  local n="$1"
  case "$n" in
    CaskaydiaMono|CaskaydiaCoveMono) echo "CascadiaMono" ;;
    CaskaydiaCode|Caskaydia|CaskaydiaCove) echo "CascadiaCode" ;;
    JetBainsMono) echo "JetBrainsMono" ;;
    MesloLGS|MesloLGSNF|MesloLGSNerdFont|MesloLGSNerdFonts) echo "Meslo" ;;
    Symbols|SymbolsOnly|NerdFontsSymbolsOnly|SymbolsNF) echo "NerdFontsSymbolsOnly" ;;
    *) echo "$n" ;;
  esac
}

# Install one font asset by name and tag
nf_install_one() {
  local tag="$1"; shift
  local name_raw="$1"; shift || true
  local target_dir="$1"; shift || true
  local force="$1"; shift || true

  local name url zip_dir zip_path out_dir
  name="$(nf_normalize_name "$name_raw")"
  url="https://github.com/ryanoasis/nerd-fonts/releases/download/${tag}/${name}.zip"
  zip_dir="$(mktemp -d 2>/dev/null || mktemp -d -t nf)"
  zip_path="${zip_dir}/${name}.zip"
  out_dir="${target_dir%/}/$name"

  mkdir -p "$out_dir" || true

  if [ -d "$out_dir" ] && [ -n "$(ls -A "$out_dir" 2>/dev/null)" ] && [ "$force" != "1" ]; then
    echo "Nerd Font '$name' already present; skipping (use force=1 to reinstall)."
    rm -rf "$zip_dir" 2>/dev/null || true
    return 0
  fi

  echo "Installing Nerd Font: $name ($tag)"
  if ! nf_http "$url" >"$zip_path"; then
    echo "Failed to download: $url" >&2
    rm -rf "$zip_dir" 2>/dev/null || true
    return 0
  fi

  if ! unzip -qq -o "$zip_path" -d "$zip_dir/$name" >/dev/null 2>&1; then
    echo "Failed to unzip $zip_path" >&2
    rm -rf "$zip_dir" 2>/dev/null || true
    return 0
  fi

  shopt -s nullglob
  for f in "$zip_dir/$name"/*.ttf "$zip_dir/$name"/*.otf; do
    cp -f "$f" "$out_dir/" 2>/dev/null || true
  done
  shopt -u nullglob

  rm -rf "$zip_dir" 2>/dev/null || true
}

# Install multiple fonts; honors NERDFONTS_DIR and NERDFONTS_FORCE
nf_install_fonts() {
  local tag="$1"; shift
  local target_dir="${NERDFONTS_DIR:-$HOME/.local/share/fonts/NerdFonts}"
  local force="${NERDFONTS_FORCE:-0}"

  [ -z "$tag" ] && tag="$(nf_latest_tag)"
  mkdir -p "$target_dir" || true

  for name in "$@"; do
    nf_install_one "$tag" "$name" "$target_dir" "$force"
  done

  if nf_have fc-cache; then
    fc-cache -f "$target_dir" >/dev/null 2>&1 || true
  fi
}
