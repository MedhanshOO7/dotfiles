#!/usr/bin/env bash
CONFIG_FILE="$HOME/.config/illogical-impulse/config.json"
JSON_PATH=".screenRecord.savePath"
CUSTOM_PATH=$(jq -r "$JSON_PATH" "$CONFIG_FILE" 2>/dev/null)
RECORDING_DIR=""
if [[ -n "$CUSTOM_PATH" ]]; then
    RECORDING_DIR="$CUSTOM_PATH"
else
    RECORDING_DIR="$HOME/Videos"
fi

getdate() {
    date '+%Y-%m-%d_%H.%M.%S'
}

getaudiooutput() {
    echo "default_output"
}

getactivemonitor() {
    hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name'
}

mkdir -p "$RECORDING_DIR"
cd "$RECORDING_DIR" || exit

MANUAL_REGION=""
SOUND_FLAG=0
FULLSCREEN_FLAG=0
ARGS=("$@")

for ((i=0;i<${#ARGS[@]};i++)); do
    if [[ "${ARGS[i]}" == "--region" ]]; then
        if (( i+1 < ${#ARGS[@]} )); then
            MANUAL_REGION="${ARGS[i+1]}"
        else
            notify-send "Recording cancelled" "No region specified for --region" -a 'Recorder' & disown
            exit 1
        fi
    elif [[ "${ARGS[i]}" == "--sound" ]]; then
        SOUND_FLAG=1
    elif [[ "${ARGS[i]}" == "--fullscreen" ]]; then
        FULLSCREEN_FLAG=1
    fi
done

if pgrep -f gpu-screen-recorder > /dev/null; then
    pkill -f gpu-screen-recorder
    sleep 0.5
    LAST_FILE=$(ls -t "$RECORDING_DIR"/*.mp4 2>/dev/null | head -1)
    action=$(notify-send "Recording Stopped" "$LAST_FILE" -a 'Recorder' --action="open=Open in VLC" --wait)
    if [[ "$action" == "open" ]]; then
        vlc "$LAST_FILE" & disown
    fi
else
    OUTFILE='./recording_'"$(getdate)"'.mp4'
    if [[ $FULLSCREEN_FLAG -eq 1 ]]; then
        notify-send "Starting recording" "$OUTFILE" -a 'Recorder' & disown
        if [[ $SOUND_FLAG -eq 1 ]]; then
            gpu-screen-recorder -w "$(getactivemonitor)" -f 60 -a "$(getaudiooutput)" -o "$OUTFILE"
        else
            gpu-screen-recorder -w "$(getactivemonitor)" -f 60 -o "$OUTFILE"
        fi
    else
        if [[ -n "$MANUAL_REGION" ]]; then
            region="$MANUAL_REGION"
        else
            if ! region="$(slurp 2>&1)"; then
                notify-send "Recording cancelled" "Selection was cancelled" -a 'Recorder' & disown
                exit 1
            fi
        fi
        read -r x y w h <<< "$(echo "$region" | sed 's/,/ /;s/x/ /;s/+/ /')"
        GSR_REGION="${w}x${h}+${x}+${y}"
        notify-send "Starting recording" "$OUTFILE" -a 'Recorder' & disown
        if [[ $SOUND_FLAG -eq 1 ]]; then
            gpu-screen-recorder -w region -region "$GSR_REGION" -f 60 -a "$(getaudiooutput)" -o "$OUTFILE"
        else
            gpu-screen-recorder -w region -region "$GSR_REGION" -f 60 -o "$OUTFILE"
        fi
    fi
fi
