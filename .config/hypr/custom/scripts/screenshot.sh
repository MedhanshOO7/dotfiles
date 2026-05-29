#!/usr/bin/env bash
set -uo pipefail

SAVE_DIR="$HOME/Pictures/HyprlandSnips"
mkdir -p "$SAVE_DIR"

# Temporary file to store the name of the new screenshot
TMP_OUT=$(mktemp)

# Start inotifywait in the background to watch the directory
# Note: we redirect stdout to the temp file so we can read it after wait finishes.
inotifywait -q -t 60 -e create -e moved_to --format '%f' "$SAVE_DIR" > "$TMP_OUT" 2>/dev/null &
WATCH_PID=$!

# Give inotifywait a tiny moment to start up
sleep 0.1

# Trigger quickshell's pretty region selector
hyprctl dispatch 'hl.dsp.global("quickshell:regionScreenshot")'

# Monitor the selector layer and the inotifywait process
HAS_BEEN_OPEN=false
STARTUP_COUNT=0
MAX_STARTUP_LIMIT=30 # 3 seconds at 0.1s interval

while kill -0 $WATCH_PID 2>/dev/null; do
    if hyprctl layers | grep -q "quickshell:regionSelector"; then
        HAS_BEEN_OPEN=true
    else
        if [ "$HAS_BEEN_OPEN" = "true" ]; then
            # The selector was open but is now closed.
            # Give it a tiny moment to ensure the file event isn't just slightly delayed.
            sleep 0.15
            if ! kill -0 $WATCH_PID 2>/dev/null; then
                # inotifywait finished (file created)
                break
            fi
            # Otherwise, the user cancelled. Kill inotifywait and exit.
            kill $WATCH_PID 2>/dev/null || true
            break
        fi
        
        # If it hasn't opened yet, check if we hit the startup limit
        STARTUP_COUNT=$((STARTUP_COUNT + 1))
        if [ $STARTUP_COUNT -ge $MAX_STARTUP_LIMIT ]; then
            # Quickshell took too long to open the selector, or it closed instantly.
            # We stop active layer checking and just wait on inotifywait to exit or time out.
            wait $WATCH_PID 2>/dev/null || true
            break
        fi
    fi
    sleep 0.1
done

NEW_FILE=$(cat "$TMP_OUT")
rm -f "$TMP_OUT"

if [ -z "$NEW_FILE" ]; then
    exit 0
fi

FILEPATH="$SAVE_DIR/$NEW_FILE"

# Wait dynamically for the file to exist and be non-empty (up to 2 seconds)
for i in {1..20}; do
    if [ -s "$FILEPATH" ]; then
        break
    fi
    sleep 0.1
done

if [ ! -s "$FILEPATH" ]; then
    exit 0
fi

# Show the notification with Open / Edit actions
ACTION=$(
    notify-send \
        "Screenshot Saved" \
        "$NEW_FILE" \
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
        xdg-open "$FILEPATH" >/dev/null 2>&1 & disown
        ;;
    edit)
        EDITED_FILE="$(mktemp --suffix=.png /tmp/swappy-output-XXXXXX)"
        if swappy -f "$FILEPATH" -o "$EDITED_FILE"; then
            mv "$EDITED_FILE" "$FILEPATH"
            wl-copy --type image/png < "$FILEPATH"
            notify-send "Screenshot Updated" "$NEW_FILE" \
                -a "Screenshot" -i "$FILEPATH" -u low -t 2000 >/dev/null 2>&1 || true
        else
            rm -f "$EDITED_FILE"
        fi
        ;;
esac
