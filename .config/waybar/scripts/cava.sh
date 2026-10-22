#!/bin/bash
# Renders cava's raw ascii output as unicode bar characters for a waybar
# custom module. Adapted from ray-pH/waybar-cava (cava-playerinfo-side).

# waybar restarts don't kill cava, so a stray process from a previous
# session keeps running in the background (Alexays/Waybar#358) — clear it
# first so we don't end up with two writers racing on stdout.
pkill -x cava 2>/dev/null

bar="▁▂▃▄▅▆▇█"
dict="s/;//g;"

i=0
while [ $i -lt ${#bar} ]; do
    dict="${dict}s/$i/${bar:$i:1}/g;"
    i=$((i + 1))
done

config_file="/tmp/waybar_cava_config"
cat > "$config_file" <<CAVA_EOF
[general]
bars = 10

[input]
method = pulse
source = alsa_output.pci-0000_00_1f.3.analog-stereo.monitor

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
CAVA_EOF

cava -p "$config_file" | while read -r line; do
    echo "$line" | sed "$dict"
done
