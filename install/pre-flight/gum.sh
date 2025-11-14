#!/bin/bash

# Gum is used to drive interactive choices
cd /tmp

# Ensure downloader exists on minimal images
if ! command -v wget >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y wget
fi

GUM_VERSION="0.17.0"
wget -qO gum.deb "https://github.com/charmbracelet/gum/releases/download/v${GUM_VERSION}/gum_${GUM_VERSION}_amd64.deb"
sudo apt-get install -y --allow-downgrades ./gum.deb
rm gum.deb
cd -
