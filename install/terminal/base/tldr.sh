#!/bin/bash

# Install tldr for simplified man pages. See https://tldr.sh/
if command -v tldr >/dev/null 2>&1; then
  if command -v pipx >/dev/null 2>&1 && pipx list 2>/dev/null | grep -E '^\s*package tldr[[:space:]]' >/dev/null; then
    pipx upgrade tldr || true
  else
    tldr --update >/dev/null 2>&1 || true
  fi
  return 0 2>/dev/null || true
fi

pipx install tldr
