#!/bin/bash

if command -v npm >/dev/null 2>&1; then
  echo "[hawkup:ai] Installing opencode-ai via npm..."
  npm install -g opencode-ai
  echo "[hawkup:ai] Installing Claude CLI..."
  curl -fsSL https://claude.ai/install.sh | bash
else
  echo "[hawkup:ai] Warning: Node.js (npm) is required. Skipping AI tools installation." >&2
  echo "[hawkup:ai] Install Node.js LTS (e.g., via 'mise') and rerun: hawkup install-ai" >&2
fi
