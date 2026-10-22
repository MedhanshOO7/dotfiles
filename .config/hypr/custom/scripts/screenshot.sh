#!/usr/bin/env bash
# Screenshots for Hyprland, native wlroots tools (grim + slurp), cursor-aware.
#
#   screenshot.sh [area]   click a window to take exactly that window, or drag a region;
#                          works on every monitor at once (no monitor picker).
#                          Copied to the clipboard right away, then opened in swappy to
#                          annotate (Ctrl+S save, Ctrl+C copy again, Esc close)
#   screenshot.sh --full   the monitor under the cursor -> file + clipboard
#   screenshot.sh --window the window under the cursor -> file + clipboard
#   screenshot.sh --pin    Flameshot pin-to-screen
#
# Why not Flameshot for capture: on this setup (fractional 1.33 scale on eDP-1 plus a
# second monitor) it can't see Wayland windows, asks which monitor to use, and upscales
# laptop captures to 3840x2400 with region coordinates that don't line up.

set -u

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/Screenshot_$(date '+%Y-%m-%d_%H-%M-%S').png"
COLORS="$HOME/.config/hud/colors.css"

for cmd in grim slurp jq wl-copy notify-send; do
    command -v "$cmd" >/dev/null || { notify-send -u critical "Screenshot" "Missing: $cmd"; exit 1; }
done

# HUD palette for the slurp overlay (falls back to neutral colours)
hud() { sed -n "s/^@define-color $1[[:space:]]*#\([0-9a-fA-F]\{6\}\);.*/\1/p" "$COLORS" 2>/dev/null | head -1; }
PRIMARY=$(hud primary); PRIMARY=${PRIMARY:-bdc7d4}

# "x,y wxh" (logical, global) of the monitor under the cursor
monitor_under_cursor() {
    local cx cy
    read -r cx cy < <(hyprctl cursorpos -j | jq -r '"\(.x|floor) \(.y|floor)"')
    hyprctl monitors -j | jq -r --argjson cx "$cx" --argjson cy "$cy" '
        .[] | . as $m
        | ($m.width / $m.scale | floor) as $w | ($m.height / $m.scale | floor) as $h
        | if ($m.transform % 2) == 1 then {w: $h, h: $w} else {w: $w, h: $h} end
        | select($cx >= $m.x and $cx < $m.x + .w and $cy >= $m.y and $cy < $m.y + .h)
        | $m.name' | head -1
}

# Boxes of every window on a visible workspace, topmost first (floating, then most recently
# focused), in slurp's "x,y wxh" format. A plain click in slurp picks the box under the cursor.
window_boxes() {
    local visible
    visible=$(hyprctl monitors -j | jq -c '[.[] | .activeWorkspace.id, .specialWorkspace.id] | map(select(. != 0))')
    hyprctl clients -j | jq -r --argjson vis "$visible" '
        map(select(.mapped and (.hidden | not) and (.workspace.id as $w | $vis | index($w))))
        | sort_by([(if .floating then 0 else 1 end), .focusHistoryID])
        | .[] | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"'
}

window_under_cursor() {
    local cx cy
    read -r cx cy < <(hyprctl cursorpos -j | jq -r '"\(.x|floor) \(.y|floor)"')
    window_boxes | while read -r pos size; do
        local x=${pos%,*} y=${pos#*,} w=${size%x*} h=${size#*x}
        if (( cx >= x && cx < x + w && cy >= y && cy < y + h )); then echo "$pos $size"; break; fi
    done
}

saved() {  # $1 = what was captured
    wl-copy --type image/png < "$FILE"
    notify-send -e -a "Screenshot" -i "$FILE" -t 3000 "Screenshot" "$1 saved and copied"
}

case "${1:-area}" in
    area|gui|--gui|--area)
        geom=$(window_boxes | slurp -d -w 2 \
            -c "${PRIMARY}ff" -b "00000066" -s "${PRIMARY}22" -B "${PRIMARY}33" \
            -F "GeistMono Nerd Font Propo") || exit 0   # Esc / right-click cancels
        grim -g "$geom" "$FILE" || { notify-send -u critical "Screenshot" "grim failed"; exit 1; }
        wl-copy --type image/png < "$FILE"
        if command -v swappy >/dev/null; then
            swappy -f "$FILE" -o "$FILE" &>/dev/null &   # annotate; saving overwrites the same file
            disown
        else
            saved "Selection"
        fi
        ;;
    full|--full)
        mon=$(monitor_under_cursor)
        grim ${mon:+-o "$mon"} "$FILE" && saved "${mon:-Screen}"
        ;;
    window|--window)
        geom=$(window_under_cursor)
        [[ -n $geom ]] || { notify-send -e -a "Screenshot" "Screenshot" "No window under the cursor"; exit 1; }
        grim -g "$geom" "$FILE" && saved "Window"
        ;;
    pin|--pin)
        flameshot gui --pin
        ;;
    *)
        sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'
        exit 1
        ;;
esac
