#!/usr/bin/env bash

# Paths - Adjusted to your scripts directory
DIR="$HOME/.config/rofi/scripts"
HIST="$DIR/emoji_history.txt"
META="$DIR/emoji_metadata.txt"

# Ensure files exist
touch "$HIST"

# 1. Combine History + Meta
# History items appear first. awk removes duplicates while preserving that order.
list=$(cat "$HIST" "$META" | awk '!x[$0]++')

# 2. Launch Rofi
# We use a theme string to force the 5-column grid and clean look
selected=$(echo -e "$list" | \
    rofi -dmenu \
         -i \
         -p "Emoji" \
         -theme-str 'window { width: 450px; }' \
         -theme-str 'listview { columns: 5; lines: 9; spacing: 10px; }' \
         -theme-str 'element { orientation: vertical; padding: 20px; }' \
         -theme-str 'element-text { horizontal-align: 0.5; vertical-align: 0.5; font: "serif 30"; }')

# Exit if Escaped
[[ -z "$selected" ]] && exit

# 3. THE CLEANER: Strip hidden metadata
# This cuts the string at the null byte (\0) and takes the first part (the emoji)
emoji=$(echo -n "$selected" | cut -d$'\0' -f1)

# 4. Copy to Clipboard
# Detects Wayland vs X11 automatically
if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
    echo -n "$emoji" | wl-copy
else
    echo -n "$emoji" | xclip -selection clipboard
fi

# 5. Update History
# We save the FULL line (Emoji\0Tags) so your favorites remain searchable
{ echo "$selected"; grep -vF "$selected" "$HIST"; } > "$HIST.tmp"
head -n 50 "$HIST.tmp" > "$HIST"
rm "$HIST.tmp"

# 6. Notify
notify-send "Copied $emoji" "Ready to paste!" -i face-smile -t 2000