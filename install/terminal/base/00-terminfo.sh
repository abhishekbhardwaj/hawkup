#!/bin/bash

# Best-effort terminfo setup so modern terminals Just Work.
# Do not abort the whole install if anything here fails.

# Install broader terminfo set and tic compiler
if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get install -y ncurses-term ncurses-bin >/dev/null 2>&1 || true
fi

# Create ~/.terminfo if missing
mkdir -p "$HOME/.terminfo" >/dev/null 2>&1 || true

# Helper: compile the alias source to the desired destination
compile_src() {
  local src="$1"
  # Try system-wide first (if permitted), then fallback to user dir
  if command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
    sudo tic -x -o /usr/share/terminfo "$src" >/dev/null 2>&1 || true
    sudo tic -x -o /usr/local/share/terminfo "$src" >/dev/null 2>&1 || true
  fi
  tic -x -o "$HOME/.terminfo" "$src" >/dev/null 2>&1 || true
}

# Compile fallback aliases for common modern terminals if their entries are missing.
# These alias entries simply "use=xterm-256color" so tmux and apps have 256-color capabilities.
need_compile=false
for name in xterm-ghostty xterm-kitty alacritty alacritty-direct wezterm; do
  if ! infocmp "$name" >/dev/null 2>&1; then
    need_compile=true
    break
  fi
done

if [ "$need_compile" = true ]; then
  # Source file lives in the repo
  if [ -f "$HAWKUP_DIR/configs/terminfo/aliases.src" ]; then
    compile_src "$HAWKUP_DIR/configs/terminfo/aliases.src"
  fi
fi

# Ensure current TERM has an entry (if not, alias it to xterm-256color pragmatically)
if ! infocmp "${TERM:-xterm-256color}" >/dev/null 2>&1; then
  current_term="${TERM:-xterm-256color}"
  tmp_src="$(mktemp)"
  cat >"$tmp_src" <<EOF
${current_term}|Auto-alias to xterm-256color,
  use=xterm-256color,
EOF
  compile_src "$tmp_src"
  rm -f "$tmp_src" >/dev/null 2>&1 || true
fi

# Ensure tmux-256color exists; fall back to aliasing screen-256color if absent.
if ! infocmp tmux-256color >/dev/null 2>&1; then
  tmp_tmux_src="$(mktemp)"
  cat >"$tmp_tmux_src" <<'EOF'
tmux-256color|tmux with 256 colors (fallback),
  use=screen-256color,
EOF
  compile_src "$tmp_tmux_src"
  rm -f "$tmp_tmux_src" >/dev/null 2>&1 || true
fi

true
