#!/bin/bash

# --------------------------------------------------
# Nekroctl Power Profile Menu
# --------------------------------------------------

choice=$(yad \
    --title="Power Profile" \
    --class="waybar-power-menu" \
    --width=380 \
    --height=300 \
    --center \
    --undecorated \
    --skip-taskbar \
    --list \
    --column="Profile" \
    --column="Description" \
    "performance" "󰓅 Maximum performance" \
    "balanced-performance" "󰾅 Performance + balance" \
    "balanced" "󰗑 Balanced" \
    "quiet" "󰒲 Quiet" \
    "low-power" "󰌪 Maximum battery life" \
    --button="Cancel:1" \
    --button="Apply:0" \
    --print-column=1)

if [ $? -ne 0 ]; then
    exit 0
fi

if [ -z "$choice" ]; then
    exit 0
fi

profile="${choice%%|*}"

/home/medhansh/.local/bin/nekroctl power set "$profile"

notify-send \
    "Power Profile" \
    "Switched to $profile"
