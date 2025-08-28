#!/usr/bin/env bash
set -euo pipefail

# Sync from Documents to my backups folder in external disk drive.
# The destination has the suffix "--mirror" a la BEM naming convention.
#
# Pattern:
# Source: /home/$USER/Documents/
# Destination: /media/$USER/<uuid>/backups/Documents--mirror/
#
# Example command:
# rsync -avh --delete "/home/djalil/Documents/" "/media/djalil/MyExternalDrive/backups/Documents--mirror/"

src_dir="/home/$USER/Documents"
dst_dirs=$(find "/media/$USER/" -maxdepth 3 -type d -regex ".*/backups/Documents--mirror$" -print)
dst_dirs_count=$(echo "$dst_dirs" | grep -c . || true)

if [ "$dst_dirs_count" -eq 0 ]; then
    echo "❌ No destination folder found!"
    exit 1
elif [ "$dst_dirs_count" -gt 1 ]; then
    echo "❌ Multiple destination folders found:"
    echo "$dst_dirs"
    exit 1
fi

dst_dir="$dst_dirs"

echo "⚠️ About to sync from '$src_dir/' to '$dst_dir/' (this may delete files)."
read -rp "Press ENTER to continue, or Ctrl+C to abort."
rsync -avh --delete --progress "$src_dir/" "$dst_dir/"
