#!/usr/bin/env bash

# Secrets management helpers
# Default secrets file can be overridden with SECRETS_FILE
secrets_file() {
  if [ -n "${SECRETS_FILE:-}" ]; then
    printf '%s' "$SECRETS_FILE"
  else
    printf '%s' "$HOME/.secrets"
  fi
}

secrets_fix_perms() {
  local f; f="$(secrets_file)"
  chmod 600 "$f" 2>/dev/null || true
}

# Backup policy for installer:
# - If ~/.secrets exists and ~/.secrets.bak doesn't, create ~/.secrets.bak
# - Else create ~/.secrets.bak_<unix_ts>
# Prints the backup path when a backup is created
secrets_backup_rotate() {
  local f; f="$(secrets_file)"
  [ -f "$f" ] || return 0
  local bak_base="${f}.bak"
  local bak_path
  if [ -f "$bak_base" ]; then
    bak_path="${bak_base}_$(date +%s)"
  else
    bak_path="$bak_base"
  fi
  cp "$f" "$bak_path" 2>/dev/null || true
  echo "Backed up $(basename "$f") to $(basename "$bak_path")"
}

# Create ~/.secrets securely if missing
secrets_create_if_missing() {
  local f; f="$(secrets_file)"
  if [ ! -f "$f" ]; then
    umask 177
    printf '# User secrets (export KEY=value)\n' > "$f"
  fi
  secrets_fix_perms
}

# List secret keys (one per line)
secrets_list() {
  local f; f="$(secrets_file)"
  [ -f "$f" ] || { echo "No secrets file at $f"; return 0; }
  sed -n -E 's/^[[:space:]]*(export[[:space:]]+)?([A-Z_][A-Z0-9_]*)=.*/\2/p' "$f" | sort -u
}

# Remove a secret by key (atomic)
secrets_remove() {
  local name="$1"
  local f; f="$(secrets_file)"
  [ -n "$name" ] || { echo "Missing secret name" >&2; return 1; }
  if ! secrets_valid_name "$name"; then echo "Invalid secret name: $name" >&2; return 1; fi
  [ -f "$f" ] || { echo "No secrets file at $f"; return 0; }
  local tmp="${f}.tmp.$$"
  awk -v key="$name" '
    {
      if ($0 ~ /^[[:space:]]*#/) { print; next }
      if ($0 ~ "^[[:space:]]*(export[[:space:]]+)?" key "=") { next }
      print
    }
  ' "$f" > "$tmp" && mv "$tmp" "$f"
  secrets_fix_perms
}


# Validate variable name: ^[A-Z_][A-Z0-9_]*$
secrets_valid_name() {
  case "$1" in
    ([A-Z_][A-Z0-9_]*) return 0 ;;
    (*) return 1 ;;
  esac
}

# Set or update a secret (atomic write), always writes KEY=<quoted>
# Usage: secrets_set NAME VALUE
secrets_set() {
  local name="$1" value="$2"
  local f; f="$(secrets_file)"
  secrets_create_if_missing
  # shell-quote the value for safe storage
  local qval; qval=$(printf '%q' "$value")
  local tmp="${f}.tmp.$$"
  awk -v key="$name" -v val="$qval" '
    BEGIN { updated=0 }
    {
      # skip commented lines that start with # after optional whitespace
      if ($0 ~ /^[[:space:]]*#/) { print; next }
      # match exact KEY= or export KEY=
      if ($0 ~ "^[[:space:]]*(export[[:space:]]+)?" key "=") {
        print "export " key "=" val; updated=1; next
      }
      print
    }
    END {
      if (!updated) { print "export " key "=" val }
    }
  ' "$f" > "$tmp" && mv "$tmp" "$f"
  secrets_fix_perms
}

# Print export lines for secrets. Usage: secrets_env [NAME...]
secrets_env() {
  local f; f="$(secrets_file)"
  [ -f "$f" ] || return 0
  awk -v names="$*" '
    BEGIN {
      split(names, arr, /[[:space:]]+/)
      want_any = 0
      for (i in arr) {
        if (arr[i] != "") { want[arr[i]] = 1; want_any = 1 }
      }
    }
    /^[[:space:]]*#/ { next }
    /^[[:space:]]*$/ { next }
    {
      line = $0
      sub(/^[[:space:]]*/, "", line)
      sub(/^export[[:space:]]+/, "", line)
      if (match(line, /^([A-Z_][A-Z0-9_]*)=(.*)$/, m)) {
        key = m[1]
        val = m[2]
        if (!want_any || (key in want)) {
          print "export " key "=" val
        }
      }
    }
  ' "$f"
}
