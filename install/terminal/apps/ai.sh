#!/bin/bash

if command -v npm >/dev/null 2>&1; then
  echo "[hawkup:ai] Installing opencode-ai via npm..."
  npm install -g opencode-ai
else
  echo "[hawkup:ai] Warning: Node.js (npm) is required. Skipping AI tools installation." >&2
  echo "[hawkup:ai] Install Node.js LTS (e.g., via 'mise') and rerun: hawkup ai install opencode" >&2
fi
