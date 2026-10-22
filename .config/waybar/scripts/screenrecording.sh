#!/usr/bin/env bash
# Reports whether a known screen-recording process is running.
# Complements the pipewire-based "privacy" screenshare module by catching
# recorders that don't go through the xdg-desktop-portal screencast.
RECORDERS="wf-recorder|obs|wl-screenrec|simplescreenrec|kooha|gpu-screen-reco"  # comm names are cut to 15 chars

if pgrep -x "$RECORDERS" >/dev/null || pgrep -f "^(/usr/bin/)?ffmpeg .*(x11grab|kmsgrab)" >/dev/null; then
    echo '{"text":"󰑊","tooltip":"Screen recording active","class":"active","alt":"active"}'
else
    echo '{"text":"","tooltip":"Not recording","class":"","alt":"inactive"}'
fi
