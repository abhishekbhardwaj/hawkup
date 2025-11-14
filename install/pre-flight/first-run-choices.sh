#!/bin/bash

AVAILABLE_LANGUAGES=("Bun" "Deno" "Elixir" "Go" "Java" "Node.js" "PHP" "Python" "Ruby" "Rust" "Zig")
DEFAULT_LANGUAGES="Ruby,Bun,Go,Deno,Node.js"

# If preset, honor it; otherwise prompt with gum
if [ -z "${HAWKUP_FIRST_RUN_LANGUAGES//[[:space:]]/}" ]; then
  export HAWKUP_FIRST_RUN_LANGUAGES=$(gum choose "${AVAILABLE_LANGUAGES[@]}" --no-limit --selected "$DEFAULT_LANGUAGES" --height 10 --header "Select programming languages")
else
  echo "Using preset languages: $HAWKUP_FIRST_RUN_LANGUAGES"
fi

AVAILABLE_DBS=("MySQL" "PostgreSQL" "Redis")
DEFAULT_DBS="MySQL,PostgreSQL,Redis"
if [ -z "${HAWKUP_FIRST_RUN_DBS//[[:space:]]/}" ]; then
  export HAWKUP_FIRST_RUN_DBS=$(gum choose "${AVAILABLE_DBS[@]}" --no-limit --selected "$DEFAULT_DBS" --height 3 --header "Select databases (runs in Docker)")
else
  echo "Using preset databases: $HAWKUP_FIRST_RUN_DBS"
fi
