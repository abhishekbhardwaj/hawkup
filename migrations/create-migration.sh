#!/bin/bash
set -e

HAWKUP_DIR="${HAWKUP_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$HAWKUP_DIR"

desc="$*"

migrate_at=$(date +%s)
filename="migrations/${migrate_at}.sh"

if [ -e "$filename" ]; then
  echo "Migration already exists: $filename" >&2
  exit 1
fi

{
  echo '#!/bin/bash'
  echo
  echo "# Migration: $migrate_at"
  if [ -n "$desc" ]; then
    echo "# Description: $desc"
  fi
  echo
  echo '# Your migration code goes here'
  echo
} > "$filename"

chmod +x "$filename"

echo "Created migration: $filename"
