#!/bin/bash

# Needed for all installers
sudo apt update -y
sudo apt upgrade -y

sudo apt install -y curl git unzip build-essential pkg-config autoconf bison clang rustc pipx \
  libssl-dev libreadline-dev zlib1g-dev libyaml-dev libreadline-dev libncurses5-dev libffi-dev libgdbm-dev libjemalloc2 \
  libvips imagemagick libmagickwand-dev mupdf mupdf-tools \
  fzf ripgrep bat eza zoxide plocate apache2-utils fd-find software-properties-common unzip

# Sync shell configs
if [ -f "$HOME/.bashrc" ] && ! cmp -s "$HOME/.bashrc" "$HAWKUP_DIR/configs/.bashrc"; then
  cp "$HOME/.bashrc" "$HOME/.bashrc.bak" || true
fi
cp "$HAWKUP_DIR/configs/.bashrc" "$HOME/.bashrc"

if [ -f "$HOME/.inputrc" ] && ! cmp -s "$HOME/.inputrc" "$HAWKUP_DIR/configs/.inputrc"; then
  cp "$HOME/.inputrc" "$HOME/.inputrc.bak" || true
fi
cp "$HAWKUP_DIR/configs/.inputrc" "$HOME/.inputrc"

mkdir -p "$HOME/.config"
if [ -d "$HOME/.config/bash" ]; then
  cp -r "$HOME/.config/bash" "$HOME/.config/bash.bak" || true
fi
cp -r "$HAWKUP_DIR/configs/bash" "$HOME/.config/bash"

# Load PATH and env for this session
[ -f "$HOME/.config/bash/shell" ] && source "$HOME/.config/bash/shell"

# Run BASE Terminal Installers in a safe order
# 1) Docker first (required for database containers)
[ -f "$HAWKUP_DIR/install/terminal/base/docker.sh" ] && source "$HAWKUP_DIR/install/terminal/base/docker.sh"

# 2) Other base installers except database
# Make sure terminfo bootstrap runs first explicitly, then skip it in the loop.
[ -f "$HAWKUP_DIR/install/terminal/base/00-terminfo.sh" ] && source "$HAWKUP_DIR/install/terminal/base/00-terminfo.sh"
for installer in "$HAWKUP_DIR"/install/terminal/base/*.sh; do
  case "$installer" in
    *docker.sh|*database.sh|*/00-terminfo.sh) continue ;;
  esac
  source "$installer"
done

# 3) Databases (after Docker is installed and configured)
[ -f "$HAWKUP_DIR/install/terminal/base/database.sh" ] && source "$HAWKUP_DIR/install/terminal/base/database.sh"

# Install Terminal Apps
for installer in "$HAWKUP_DIR"/install/terminal/apps/*.sh; do source "$installer"; done
