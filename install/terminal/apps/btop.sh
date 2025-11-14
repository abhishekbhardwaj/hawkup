#!/bin/bash

# This script installs btop, a resource monitor that shows usage and stats for processor, memory, disks, network and processes.
sudo apt install -y btop

# Use Hawkup btop config
mkdir -p "$HOME/.config/btop/themes"
cp "$HAWKUP_DIR/configs/btop/btop.conf" "$HOME/.config/btop/btop.conf"
cp "$HAWKUP_DIR/configs/btop/themes/catppuccin.theme" "$HOME/.config/btop/themes/catppuccin.theme"
