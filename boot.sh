#!/bin/bash

set -e

ascii_art='.__                   __
|  |__ _____   __  _ _|  | __ __ ______
|  |  \\__  \  \ \/ \/ |  |/ /|  |  \____ \
|   Y  \/ __ \_ \     /|    < |  |  /  |_> >
|___|  (____  /  \/\_/ |__|_ \|____/|   __/
     \/     \/              \/       |__|
'

echo -e "$ascii_art"
echo "=> Hawkup is for fresh Ubuntu 24.04+ installations only!"
echo -e "\nBegin installation (or abort with ctrl+c)..."

# Pull in the shared apt helper from the repo, since the repo is not cloned yet.
# If the fetch fails (rare), use a minimal local fallback.
if command -v curl >/dev/null 2>&1; then
  # shellcheck disable=SC1090
  source <(curl -fsSL https://raw.githubusercontent.com/abhishekbhardwaj/hawkup/main/install/lib/apt.sh) || true
fi

if ! command -v wait_for_apt >/dev/null 2>&1; then
  wait_for_apt() {
    sudo -v >/dev/null 2>&1 || true
    if command -v systemctl >/dev/null 2>&1; then
      while systemctl is-active --quiet apt-daily.service || \
            systemctl is-active --quiet apt-daily-upgrade.service; do
        echo "Waiting for background apt services to finish..."
        sleep 5
      done
    fi
    while pgrep -x apt >/dev/null 2>&1 || \
          pgrep -x apt-get >/dev/null 2>&1 || \
          pgrep -x dpkg >/dev/null 2>&1; do
      echo "Waiting for other apt/dpkg processes to finish..."
      sleep 5
    done
    while ! sudo flock -n /var/lib/dpkg/lock-frontend -c true || \
          ! sudo flock -n /var/lib/dpkg/lock -c true; do
      echo "Waiting for APT locks to be released..."
      sleep 5
    done
    sudo dpkg --configure -a >/dev/null 2>&1 || true
  }
fi

wait_for_apt

echo "Updating apt cache..."
sudo apt-get update >/dev/null

echo "Ensuring git is installed..."
sudo apt-get install -y git >/dev/null

echo "Cloning Hawkup..."
rm -rf ~/.local/share/hawkup
git clone https://github.com/abhishekbhardwaj/hawkup.git ~/.local/share/hawkup >/dev/null
echo "Installation starting..."
source ~/.local/share/hawkup/install.sh
