#!/usr/bin/env bash
# Re-apply the HUD theme everywhere after hud/colors.css (or tokens.css) changes.
# Called by matugen (post_hook) and safe to run by hand.

pkill -SIGUSR2 -x waybar 2>/dev/null                 # waybar: reload style
swaync-client -rs &>/dev/null                         # swaync: reload css
if pidof swayosd-server >/dev/null; then              # swayosd only reads css at startup
    pkill -x swayosd-server
    # via Hyprland (session scope); GDK_WAYLAND_DISABLE: see hud/tokens.css GLASS
    hyprctl dispatch 'hl.dsp.exec_cmd("GDK_WAYLAND_DISABLE=ext_background_effect_manager_v1 swayosd-server")' >/dev/null
fi
# (the Quickshell dock watches the matugen palette itself; nothing to restart)
"$HOME/.config/hud/predator.sh" kbd-apply            # keyboard RGB follows primary (only if synced)
exit 0
