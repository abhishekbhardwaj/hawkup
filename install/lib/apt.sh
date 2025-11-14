# shellcheck shell=bash

# Wait for apt/dpkg background tasks to avoid lock contention on fresh systems
wait_for_apt() {
  # Refresh sudo timestamp to avoid repeated prompts
  sudo -v >/dev/null 2>&1 || true

  # Wait for systemd apt timers/services if present
  if command -v systemctl >/dev/null 2>&1; then
    while systemctl is-active --quiet apt-daily.service || \
          systemctl is-active --quiet apt-daily-upgrade.service; do
      echo "Waiting for background apt services to finish..."
      sleep 5
    done
  fi

  # Wait for any apt/dpkg processes to exit
  while pgrep -x apt >/dev/null 2>&1 || \
        pgrep -x apt-get >/dev/null 2>&1 || \
        pgrep -x dpkg >/dev/null 2>&1; do
    echo "Waiting for other apt/dpkg processes to finish..."
    sleep 5
  done

  # Try to acquire dpkg locks non-blocking; loop until both are free
  while ! sudo flock -n /var/lib/dpkg/lock-frontend -c true || \
        ! sudo flock -n /var/lib/dpkg/lock -c true; do
    echo "Waiting for APT locks to be released..."
    sleep 5
  done

  # Repair any half-configured packages
  sudo dpkg --configure -a >/dev/null 2>&1 || true
}

