#!/usr/bin/env bash
# Night light control for the swaync control center (hyprsunset backend).
#   nightlight.sh toggle     on/off, driven by $SWAYNC_TOGGLE_STATE
#   nightlight.sh status     prints true/false for the toggle button
#   nightlight.sh set <K>    slider: set temperature (turns night light on)
#   nightlight.sh get        slider: current temperature
# The hyprsunset.conf schedule still applies at its profile times; these
# manual changes last until the next scheduled profile kicks in.

STATE="${XDG_STATE_HOME:-$HOME/.local/state}/nightlight"
DEFAULT_TEMP=4500
mkdir -p "$(dirname "$STATE")"

on=false temp=$DEFAULT_TEMP
[ -f "$STATE" ] && read -r on temp < "$STATE"
save() { echo "$on $temp" > "$STATE"; }

ensure_running() {
    command -v hyprsunset >/dev/null || { notify-send -u low "Night Light" "hyprsunset is not installed"; exit 1; }
    if ! pidof hyprsunset >/dev/null; then
        setsid -f hyprsunset >/dev/null 2>&1
        for _ in $(seq 20); do hyprctl hyprsunset temperature >/dev/null 2>&1 && break; sleep 0.1; done
    fi
}

apply() {
    ensure_running
    if [ "$on" = true ]; then
        hyprctl hyprsunset temperature "$temp" >/dev/null
    else
        hyprctl hyprsunset identity >/dev/null
    fi
}

case "$1" in
    toggle) on="${SWAYNC_TOGGLE_STATE:-false}"; save; apply ;;
    status) echo "$on" ;;
    set)    temp="${2%.*}"; on=true; save; apply ;;
    get)    echo "$temp" ;;
esac
