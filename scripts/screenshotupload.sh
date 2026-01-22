#!/bin/bash
set -euo pipefail

# Folder for temp screenshots
TMPDIR="$HOME/.local/share/screenshot_tmp"
mkdir -p "$TMPDIR"
FILE="$TMPDIR/screenshot_$(date +%s).png"

# Ensure wayfreeze is killed on exit, even if script crashes or user cancels
cleanup() {
    pkill -x wayfreeze 2>/dev/null || true
}
trap cleanup EXIT

# Start wayfreeze
wayfreeze &

# Tiny delay to ensure wayfreeze starts
sleep 0.1

# Take screenshot with selection
if grim -g "$(slurp)" "$FILE"; then
    # Screenshot succeeded
    # Upload
    RESPONSE=$(curl -s -X POST "https://i.buggirls.xyz/api/upload" \
      -H "x-api-key: EmRVfA9kWtL5112VSBHmdDaoUVx4oLjBIkE1KUvQtGhKOBuEOCwb49msKUe385tb" \
      -F "file[]=@$FILE")

    # Extract URL
    URL=$(echo "$RESPONSE" | jq -r '.url')

    # Copy to clipboard
    echo -n "$URL" | wl-copy

    # Notify user
    notify-send "Screenshot uploaded" "$URL"

    # Optional: delete temp screenshot
    rm -f "$FILE"
else
    # User cancelled
    notify-send "Screenshot cancelled"
fi

# Kill any lingering wayfreeze processes (failsafe)
pkill -x wayfreeze 2>/dev/null || true
