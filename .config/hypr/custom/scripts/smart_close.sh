#!/usr/bin/env bash

# Fetch active window information in JSON format
WIN_JSON=$(hyprctl activewindow -j 2>/dev/null)
if [ -z "$WIN_JSON" ] || [ "$WIN_JSON" = "{}" ] || [ "$WIN_JSON" = "null" ]; then
    exit 0
fi

CLASS=$(echo "$WIN_JSON" | jq -r '.class // .initialClass // ""' | tr '[:upper:]' '[:lower:]')
ADDR=$(echo "$WIN_JSON" | jq -r '.address // ""')

# Applications that should minimize to background/tray instead of terminating
TRAY_APPS="signal|signal beta|betterbird|thunderbird|spotify|spotify-launcher|discord|vesktop|webcord|telegramdesktop|telegram|steam|qbittorrent|localsend|easyeffects|com.github.wwmm.easyeffects|windscribe|obsidian|strawberry|persepolis"

if echo "$CLASS" | grep -q -E "($TRAY_APPS)"; then
    # Move to hidden minimized workspace so it stays alive in background
    hyprctl dispatch movetoworkspacesilent "special:minimized,address:$ADDR"
else
    # Regular window close
    hyprctl dispatch killactive
fi
