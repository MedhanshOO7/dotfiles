#!/usr/bin/env bash
# Volume/brightness keys with an on-screen display (swayosd).
# Falls back to plain wpctl/brightnessctl if swayosd isn't installed or running.
#   osd.sh vol-up | vol-down | vol-mute | mic-mute | bright-up | bright-down

if command -v swayosd-client >/dev/null && pidof swayosd-server >/dev/null; then
    case "$1" in
        vol-up)      swayosd-client --output-volume +2 ;;
        vol-down)    swayosd-client --output-volume -2 ;;
        vol-mute)    swayosd-client --output-volume mute-toggle ;;
        mic-mute)    swayosd-client --input-volume mute-toggle ;;
        bright-up)   swayosd-client --brightness +5 ;;
        bright-down) swayosd-client --brightness -5 ;;
    esac
else
    case "$1" in
        vol-up)      wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 2%+ ;;
        vol-down)    wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%- ;;
        vol-mute)    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
        mic-mute)    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle ;;
        bright-up)   brightnessctl s 5%+ ;;
        bright-down) brightnessctl s 5%- ;;
    esac
fi
