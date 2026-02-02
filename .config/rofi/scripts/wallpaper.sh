#!/usr/bin/env bash

# --- CONFIGURATION ---
# Change this to the actual path where your folders (abstract, aerial, etc.) are located
WALL_BASE_DIR="/home/medhansh/Pictures/walpapers/walls/" 
TYPES="jpg|jpeg|png|webp"

# --- STEP 1: SELECT CATEGORY ---
# Get clean folder names
category=$(find "$WALL_BASE_DIR" -maxdepth 1 -type d -not -path "$WALL_BASE_DIR" | sed "s|$WALL_BASE_DIR/||" | rofi -dmenu -i -p "󱂬 Category")

[[ -z "$category" ]] && exit 1
SELECTED_DIR="$WALL_BASE_DIR/$category"

# --- STEP 2: SELECT WALLPAPER ---
# This loop generates a string for Rofi: "Display Name\x00icon\x1f/Full/Path/To/Icon\x1finfo\x1f/Full/Path/To/Return"
selection_data=$(find "$SELECTED_DIR" -maxdepth 1 -type f | grep -E "\.($TYPES)$" | while read -r path; do
    filename=$(basename "$path")
    echo -e "${filename}\x00icon\x1f${path}\x1finfo\x1f${path}"
done | rofi -dmenu -i -show-icons -p "󰸉 Select Wallpaper" -format "f")

# --- EXPLANATION of -format "f" ---
# By using -format "f", Rofi returns the 'filter' string (the filename).
# But since we want the full path for the command, we grab the "info" field we hid earlier.

# Re-run the logic to get the full path based on the selected display name
[[ -z "$selection_data" ]] && exit 1
FULL_PATH="$SELECTED_DIR/$selection_data"

# --- STEP 3: APPLY TO KDE PLASMA 6 ---
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
    var allDesktops = desktops();
    for (var i = 0; i < allDesktops.length; i++) {
        var d = allDesktops[i];
        d.currentConfigGroup = Array('Wallpaper', 'org.kde.image', 'General');
        d.writeConfig('Image', 'file://${FULL_PATH}');
    }
"