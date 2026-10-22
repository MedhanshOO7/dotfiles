#!/usr/bin/env bash
# Reports whether any process currently has a /dev/video* device open.
shopt -s nullglob
for dev in /dev/video*; do
    if fuser "$dev" &>/dev/null; then
        echo '{"text":"󰄀","tooltip":"Camera active","class":"active","alt":"active"}'
        exit 0
    fi
done
echo '{"text":"","tooltip":"Camera inactive","class":"","alt":"inactive"}'
