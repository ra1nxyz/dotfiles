#!/bin/bash
set -euo pipefail

# Folder for temp screenshots
TMPDIR="$HOME/.local/share/screenshot_tmp"
mkdir -p "$TMPDIR"
FILE="$TMPDIR/screenshot_$(date +%s).png"

cleanup() {
    pkill -x wayfreeze 2>/dev/null || true
}
trap cleanup EXIT

# Start wayfreeze
wayfreeze &

sleep 0.1

if grim -g "$(slurp)" "$FILE"; then
    # Screenshot succeeded
    RESPONSE=$(curl -s -X POST "https://i.buggirls.xyz/api/upload" \
      -H "x-api-key: EmRVfA9kWtL5112VSBHmdDaoUVx4oLjBIkE1KUvQtGhKOBuEOCwb49msKUe385tb" \ 
      -F "file[]=@$FILE")
      # no this api key is not valid anymore :3

    URL=$(echo "$RESPONSE" | jq -r '.url')

    echo -n "$URL" | wl-copy

    notify-send "Screenshot uploaded" "$URL"

    rm -f "$FILE"
else
    # cancelled
    notify-send "Screenshot cancelled"
fi

pkill -x wayfreeze 2>/dev/null || true
