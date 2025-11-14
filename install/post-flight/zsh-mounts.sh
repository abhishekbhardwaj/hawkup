#!/bin/bash

# Ubuntu if installed on a ZFS formatted drive, mounts bpool and rpool and shows them as mounted drives on the dock
# To disable: https://askubuntu.com/a/1553027
# This forces only user-accessible devices to show up on dock.

RULE='ENV{ID_FS_TYPE}=="zfs_member", ENV{UDISKS_IGNORE}="1"'
RULE_FILE='/etc/udev/rules.d/99-hide-zfs-pools.rules'

# Check if ZFS is installed and ZFS pools exist
if command -v zfs >/dev/null 2>&1 && zpool list >/dev/null 2>&1; then
    # Idempotently create the udev rule without interactive sudo
    if [ ! -f "$RULE_FILE" ] || ! grep -qF "$RULE" "$RULE_FILE"; then
        echo "$RULE" | sudo tee "$RULE_FILE" >/dev/null
        sudo udevadm control --reload-rules
        sudo udevadm trigger
        echo "Applied udev rule to hide ZFS pools from Dock."
    else
        echo "ZFS udev rule already present."
    fi
else
    echo "ZFS not detected or no ZFS pools found. Skipping ZFS pool hiding."
fi
