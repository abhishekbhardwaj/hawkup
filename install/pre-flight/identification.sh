#!/bin/bash

echo "Enter identification for git and autocomplete..."
SYSTEM_NAME=$(getent passwd "$USER" | cut -d ':' -f 5 | cut -d ',' -f 1)

# Only prompt when not preset via environment
if [ -z "${HAWKUP_USER_NAME//[[:space:]]/}" ]; then
  export HAWKUP_USER_NAME=$(gum input --placeholder "Enter full name" --value "$SYSTEM_NAME" --prompt "Name> ")
else
  echo "Using preset name: $HAWKUP_USER_NAME"
fi

if [ -z "${HAWKUP_USER_EMAIL//[[:space:]]/}" ]; then
  export HAWKUP_USER_EMAIL=$(gum input --placeholder "Enter email address" --prompt "Email> ")
else
  echo "Using preset email: $HAWKUP_USER_EMAIL"
fi
