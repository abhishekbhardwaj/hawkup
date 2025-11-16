#!/bin/bash

# Allow skipping tmux setup entirely (e.g., in headless CI)
if [ "${HAWKUP_SKIP_TMUX:-0}" = "1" ]; then
  echo "Skipping tmux setup (HAWKUP_SKIP_TMUX=1)"
  return 0 2>/dev/null || exit 0
fi

safe_term() {
  local t="${TERM:-xterm-256color}"
  if infocmp "$t" >/dev/null 2>&1; then
    printf "%s" "$t"
  else
    printf "%s" "xterm-256color"
  fi
}

normalize_tpm_perms() {
  local tpm="$HOME/.tmux/plugins/tpm"
  [ -d "$tpm" ] || return 0
  chmod -R u+rwX "$tpm" 2>/dev/null || true
  [ -d "$tpm/bin" ] && chmod u+x "$tpm"/bin/* 2>/dev/null || true
  [ -d "$tpm/scripts" ] && chmod u+x "$tpm"/scripts/* 2>/dev/null || true
  [ -f "$tpm/tpm" ] && chmod u+x "$tpm/tpm" 2>/dev/null || true
}

# Function to setup tmux and its plugins
setup_tmux() {
    echo "Setting up tmux and its plugins..."
    mkdir -p "$HOME/.tmux/plugins" || true
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" >/dev/null 2>&1 || true
    fi

    # Normalize permissions in case a restrictive umask was active earlier
    normalize_tpm_perms

    # Load config if possible; be resilient
    if command -v tmux >/dev/null 2>&1; then
      local ST
      ST="$(safe_term)"
      TERM="$ST" tmux -L hawkup -f /dev/null start-server >/dev/null 2>&1 || true
      TERM="$ST" tmux -L hawkup source-file "$HOME/.tmux.conf" >/dev/null 2>&1 || true
    fi
}

# Function to install tmux plugins
install_tmux_plugins() {
    echo "Installing tmux plugins..."

    if ! command -v tmux >/dev/null 2>&1; then
      echo "tmux not found; skipping plugin install." >&2
      return 0
    fi

    # Auto-fix TPM permissions and validate installer presence
    normalize_tpm_perms

    if [ ! -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
      echo "TPM not found or not executable; skipping plugin install." >&2
      return 0
    fi

    local ST
    ST="$(safe_term)"

    # Start a temporary tmux session on a dedicated socket to avoid conflicts
    if ! TERM="$ST" tmux -L hawkup -f /dev/null new-session -d -s __temp >/dev/null 2>&1; then
      echo "Could not start tmux server with TERM=$ST; skipping plugin install." >&2
      return 0
    fi

    # Install plugins (best-effort)
    TERM="$ST" TMUX_PLUGIN_MANAGER_PATH="$HOME/.tmux/plugins" \
      "$HOME/.tmux/plugins/tpm/bin/install_plugins" >/dev/null 2>&1 || true

    # Kill the temporary tmux session
    TERM="$ST" tmux -L hawkup kill-session -t __temp >/dev/null 2>&1 || true

    echo "Tmux plugins installation step completed (best effort)."
}

# Ensure tmux is installed (best-effort)
if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get install -y tmux >/dev/null 2>&1 || true
fi

# Copy tmux configuration file if it doesn't exist
[ ! -f "$HOME/.tmux.conf" ] && cp "$HAWKUP_DIR/configs/.tmux.conf" "$HOME/.tmux.conf" >/dev/null 2>&1 || true

setup_tmux
install_tmux_plugins
