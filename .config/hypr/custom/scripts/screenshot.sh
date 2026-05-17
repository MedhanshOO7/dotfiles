#!/usr/bin/env bash
set -uo pipefail

SAVE_DIR="$HOME/Pictures/HyprlandSnips"
mkdir -p "$SAVE_DIR"

FILENAME="Screenshot_$(date '+%Y-%m-%d_%H-%M-%S').png"
FILEPATH="$SAVE_DIR/$FILENAME"

# Auto window snapping via hyprctl + slurp
AREA=$(hyprctl clients -j | jq -r '.[] | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | slurp 2>/dev/null) || exit 0
grim -t png -g "$AREA" "$FILEPATH" || exit 0

# Cleanup if user cancelled or screenshot failed (0-byte file)
if [ ! -s "$FILEPATH" ]; then
    rm -f "$FILEPATH"
    exit 0
fi

# Copy to clipboard in background while notification loads
wl-copy --type image/png < "$FILEPATH" &

ACTION=$(
    notify-send \
        "Screenshot Saved" \
        "$FILENAME" \
        -a "Screenshot" \
        -i "$FILEPATH" \
        -u critical \
        -t 5000 \
        --action="open=Open" \
        --action="edit=Edit" \
        --wait 2>/dev/null
) || ACTION=""

case "$ACTION" in
    open)
        imv "$FILEPATH" >/dev/null 2>&1 & disown
        ;;
    edit)
        EDITED_FILE="$(mktemp --suffix=.png /tmp/swappy-output-XXXXXX)"
        if swappy -f "$FILEPATH" -o "$EDITED_FILE"; then
            mv "$EDITED_FILE" "$FILEPATH"
            wl-copy --type image/png < "$FILEPATH"
            notify-send "Screenshot Updated" "$FILENAME" \
                -a "Screenshot" -i "$FILEPATH" -u low -t 2000 >/dev/null 2>&1 || true
        else
            rm -f "$EDITED_FILE"
        fi
        ;;
esac
