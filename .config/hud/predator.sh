#!/usr/bin/env bash
# Predator (nekro-sense) bridge for the HUD: waybar pill, swaync toggles, matugen hook.
# Reads go straight to sysfs (cheap, never wakes the dGPU); writes go through nekroctl,
# which validates values. Needs the nekro_sense module and membership in the
# nekro-sense group (no root).
#
#   predator.sh status                     waybar JSON (CPU temp, fans, profile, limiter)
#   predator.sh gui                        open (or focus) the nekro-sense GUI
#   predator.sh fan-toggle | fan-state     fans max <-> auto
#   predator.sh limit-toggle | limit-state 80% battery charge limit
#   predator.sh kbd-sync on|off|state      keyboard RGB follows the HUD primary colour
#   predator.sh kbd-apply                  re-apply the colour if kbd-sync is on (matugen hook)
#   predator.sh login                      session start: keyboard light stays on (no 30s timeout)

NEKRO=/sys/devices/platform/nekro-acer-wmi
PS=$NEKRO/predator_sense
NEKROCTL="$HOME/.local/bin/nekroctl"
GUI="$HOME/builds/nekro-sense/tools/nekroctl-gui-rs/target/release/nekroctl-gui-rs"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/hud"
SYNC_FLAG="$STATE_DIR/kbd-sync"          # present = keyboard follows the theme
SAVED_EFFECT="$STATE_DIR/kbd-effect"     # effect to restore when sync is turned off
SAVED_ZONES="$STATE_DIR/kbd-zones"       # per-zone colours, for when that effect is static
COLORS="$HOME/.config/hud/colors.css"

hwmon_by_name() {
    local h
    for h in /sys/class/hwmon/hwmon*; do
        [[ $(<"$h/name") == "$1" && -e "$h/device" && $(readlink -f "$h/device") == *"$2"* ]] && { echo "$h"; return; }
    done
}

notify() { notify-send -e -a "Predator" -i "${2:-computer}" -t 2500 "Predator" "$1"; }

status() {
    if [[ ! -d $PS ]]; then
        echo '{"text":"󰈐 --","tooltip":"nekro_sense module not loaded","class":"offline"}'
        return
    fi
    local core nek cpu fans fan_cpu fan_gpu rpm1 rpm2 profile limit class mode
    core=$(hwmon_by_name coretemp "")
    nek=$(hwmon_by_name acer nekro-acer-wmi)
    cpu=$(( $(<"$core/temp1_input") / 1000 ))
    fans=$(<"$PS/fan_speed")                      # "CPU,GPU" percent, 0 = auto
    fan_cpu=${fans%,*} fan_gpu=${fans#*,}
    rpm1=$(<"$nek/fan1_input") rpm2=$(<"$nek/fan2_input")
    profile=$(</sys/firmware/acpi/platform_profile)
    limit=$(<"$PS/battery_limiter")

    if [[ $fans == "0,0" ]]; then mode="auto"; else mode="CPU ${fan_cpu}% · GPU ${fan_gpu}%"; fi
    class="normal"
    (( cpu >= 75 )) && class="warm"
    (( cpu >= 88 )) && class="hot"
    [[ $fans != "0,0" ]] && class="$class boost"

    printf '{"text":"󰈐 %s°","class":"%s","tooltip":"PREDATOR\\nCPU %s°C\\nFans %s / %s rpm (%s)\\nProfile %s\\nCharge limit %s\\n\\nclick: open · right-click: fan boost"}\n' \
        "$cpu" "$class" "$cpu" "$rpm1" "$rpm2" "$mode" "$profile" "$([[ $limit == 1 ]] && echo 80% || echo off)"
}

gui() {
    if pgrep -x nekroctl-gui-rs >/dev/null; then   # comm name (15 chars, exact)
        local addr
        addr=$(hyprctl clients -j | jq -r '.[] | select(.title | test("^Nekro Sense")) | .address' | head -1)
        [[ -n $addr ]] && hyprctl dispatch "hl.dsp.focus({ window = \"address:$addr\" })" >/dev/null
    else
        hyprctl dispatch "hl.dsp.exec_cmd(\"$GUI\")" >/dev/null   # via Hyprland: survives the caller's terminal
    fi
}

fan_state() { [[ $(<"$PS/fan_speed") != "0,0" ]] && echo true || echo false; }

fan_toggle() {
    if [[ $(fan_state) == true ]]; then
        "$NEKROCTL" fan auto >/dev/null && notify "Fans back to auto" fan
    else
        "$NEKROCTL" fan set 100 100 >/dev/null && notify "Fan boost: CPU and GPU fans at 100%" fan
    fi
}

limit_state() { [[ $(<"$PS/battery_limiter") == 1 ]] && echo true || echo false; }

limit_toggle() {
    if [[ $(limit_state) == true ]]; then
        "$NEKROCTL" battery off >/dev/null && notify "Charge limit off: charging to 100%" battery-full
    else
        "$NEKROCTL" battery on >/dev/null && notify "Charge limit on: stops at 80%" battery-good
    fi
}

primary_hex() { sed -n 's/^@define-color primary[[:space:]]*#\([0-9a-fA-F]\{6\}\);.*/\1/p' "$COLORS" | head -1; }

kbd_apply() {
    [[ -e $SYNC_FLAG ]] || return 0
    local hex; hex=$(primary_hex)
    [[ -n $hex ]] && "$NEKROCTL" rgb static "$hex" >/dev/null
}

kbd_sync() {
    mkdir -p "$STATE_DIR"
    case "$1" in
        on)
            if [[ ! -e $SYNC_FLAG ]]; then
                "$NEKROCTL" rgb effect-get > "$SAVED_EFFECT" 2>/dev/null
                "$NEKROCTL" rgb per-zone-get > "$SAVED_ZONES" 2>/dev/null
            fi
            touch "$SYNC_FLAG"
            kbd_apply && notify "Keyboard follows the theme colour" input-keyboard
            ;;
        off)
            rm -f "$SYNC_FLAG"
            # restore the effect that was running before (mode,speed,brightness,direction,r,g,b)
            if [[ -s $SAVED_EFFECT ]]; then
                IFS=, read -r m s b d r g bl < "$SAVED_EFFECT"
                # zone colours first (c1,c2,c3,c4,brightness): writing them selects static mode
                if [[ -s $SAVED_ZONES ]]; then
                    IFS=, read -r z1 z2 z3 z4 zb < "$SAVED_ZONES"
                    "$NEKROCTL" rgb per-zone -b "$zb" "$z1" "$z2" "$z3" "$z4" >/dev/null
                fi
                # then the animated effect, if one was running
                if [[ $m != 0 ]]; then
                    "$NEKROCTL" rgb effect "$m" -s "$s" -b "$b" -d "$d" -c "$(printf '%02x%02x%02x' "$r" "$g" "$bl")" >/dev/null
                fi
            fi
            notify "Keyboard lighting restored" input-keyboard
            ;;
        state) [[ -e $SYNC_FLAG ]] && echo true || echo false ;;
        *) echo "usage: $0 kbd-sync on|off|state" >&2; return 1 ;;
    esac
}

login() {
    # 0 = keyboard backlight never times out (1 = firmware 30s timeout). Replaces the
    # old root predator-backlight.service, which wrote to the gone linuwu_sense path.
    [[ -w $PS/backlight_timeout ]] && echo 0 > "$PS/backlight_timeout"
    kbd_apply
}

case "$1" in
    status) status ;;
    login) login ;;
    gui) gui ;;
    fan-toggle) fan_toggle ;;
    fan-state) fan_state ;;
    limit-toggle) limit_toggle ;;
    limit-state) limit_state ;;
    kbd-sync) kbd_sync "$2" ;;
    kbd-apply) kbd_apply ;;
    *) sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac
