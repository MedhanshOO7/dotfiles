#!/usr/bin/env bash
# DTS-style sound modes for EasyEffects. Device presets are picked automatically by
# EasyEffects autoload (Speakers / EDX Pro on the 3.5 mm jack / Chu II DSP over USB);
# this switches the *mode* for whatever device is active, keeping the device.
#
#   audio-mode.sh music | movie   switch mode for the current device
#   audio-mode.sh toggle          music <-> movie
#   audio-mode.sh flat            toggle EasyEffects bypass (A/B against the raw sound)
#   audio-mode.sh state <music|movie|flat>   prints true/false (control-center toggles)
#
# Presets live in ~/.local/share/easyeffects/output as "<Device> - Music|Movie".

current() { timeout 5 easyeffects -a output 2>/dev/null | head -1; }   # e.g. "EDX Pro - Music"
bypassed() { [[ $(timeout 5 easyeffects -b 3 2>/dev/null) == 1 ]]; }

notify() { notify-send -e -a "Sound" -i audio-speakers -t 2000 "Sound" "$1"; }

set_mode() {  # $1 = Music|Movie
    local cur dev
    cur=$(current); dev=${cur% - *}
    [[ -n $dev && $dev != "$cur" ]] || dev="Speakers"
    bypassed && timeout 5 easyeffects -b 2 >/dev/null
    timeout 5 easyeffects -l "$dev - $1" >/dev/null && notify "$dev · $1"
}

case "$1" in
    music) set_mode Music ;;
    movie) set_mode Movie ;;
    toggle) [[ $(current) == *" - Movie" ]] && set_mode Music || set_mode Movie ;;
    flat)
        if bypassed; then timeout 5 easyeffects -b 2 >/dev/null; notify "Effects on ($(current))"
        else timeout 5 easyeffects -b 1 >/dev/null; notify "Flat: effects bypassed"; fi
        ;;
    state)
        case "$2" in
            flat) bypassed && echo true || echo false ;;
            music) ! bypassed && [[ $(current) == *" - Music" ]] && echo true || echo false ;;
            movie) ! bypassed && [[ $(current) == *" - Movie" ]] && echo true || echo false ;;
        esac
        ;;
    *) sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac
