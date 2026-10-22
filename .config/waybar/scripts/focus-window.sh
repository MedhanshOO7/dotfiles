#!/usr/bin/env bash
# Focuses a window by its Hyprland address (switching to its workspace).
# Used by the workspace-taskbar icons, whose clicks otherwise do nothing.
# Hyprland's Lua config rejects old-style "dispatch focuswindow", so this
# goes through hl.dsp.focus. Waybar may pass the address with or without 0x.
addr="${1#0x}"
[ -n "$addr" ] || exit 0
hyprctl dispatch "hl.dsp.focus({ window = \"address:0x${addr}\" })" >/dev/null
