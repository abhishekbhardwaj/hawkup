#!/bin/bash

sudo apt install -y vim

# Copy vim configuration file if it doesn't exist
[ ! -f "$HOME/.vimrc" ] && cp "$HAWKUP_DIR/configs/.vimrc" "$HOME/.vimrc"
