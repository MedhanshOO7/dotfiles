#!/usr/bin/env bash

# --- Configuration ---
ACTIVE_CON=$(nmcli -t -f NAME,TYPE connection show --active | head -n1 | sed 's/:/ /')
if [[ -z "$ACTIVE_CON" ]]; then
    PROMPT="Network: Disconnected"
else
    PROMPT="Network: $ACTIVE_CON"
fi

# Basic Rofi Command
ROFI_CMD="rofi -dmenu -i -p"

# --- Icons & Menu Options ---
OPT_WIFI="🛜  Wi-Fi Menu"
OPT_ETH="🖧  Wired Settings"
OPT_VPN="📶  VPN Connections"
OPT_TEST="🚀  Run Speed Test"
OPT_INFO="ℹ️  Connection Info"
OPT_DISC="🚫  Disconnect Active"
OPT_RESTART="🔄  Restart NetworkManager"

# --- Functions ---

notify() {
    notify-send "Network Manager" "$1"
}

wifi_menu() {
    notify "Scanning..."
    LIST=$(nmcli -f SECURITY,BARS,SSID device wifi list | sed 1d | awk '!seen[$0]++')
    
    if [[ -z "$LIST" ]]; then
        notify "No Wi-Fi networks found."
        return
    fi

    SELECTION=$(echo "$LIST" | $ROFI_CMD "Wi-Fi Networks")
    SSID=$(echo "$SELECTION" | awk -F'  +' '{print $NF}')

    if [[ -n "$SSID" ]]; then
        PASS=$(rofi -dmenu -password -p "Password for $SSID")
        if [[ -n "$PASS" ]]; then
            nmcli device wifi connect "$SSID" password "$PASS" && notify "Connected to $SSID" || notify "Connection Failed"
        else
            nmcli device wifi connect "$SSID" && notify "Connected to $SSID" || notify "Connection Failed"
        fi
    fi
}

vpn_menu() {
    STATUS_OUT=$(protonvpn status)
    
    if echo "$STATUS_OUT" | grep -q "Status: Connected"; then
        SERVER=$(echo "$STATUS_OUT" | grep "Server:" | cut -d: -f2 | xargs)
        
        SEL=$(echo "Disconnect" | $ROFI_CMD "VPN Active: $SERVER")
        if [[ "$SEL" == "Disconnect" ]]; then
            run_vpn_cmd "protonvpn disconnect" "Disconnecting..."
        fi
    else
        OPTIONS="Fastest Connect\nSelect Country"
        SEL=$(echo -e "$OPTIONS" | $ROFI_CMD "VPN: Disconnected")
        case "$SEL" in
            "Fastest Connect") run_vpn_cmd "protonvpn connect" "Finding best server..." ;;
            "Select Country")
                CC=$(rofi -dmenu -p "Country Code (e.g. US, JP)")
                [[ -n "$CC" ]] && run_vpn_cmd "protonvpn connect $CC" "Connecting to $CC..."
                ;;
        esac
    fi
}

run_vpn_cmd() {
    CMD="$1"
    LOADING_MSG="$2"
    RESULT_FILE=$(mktemp)

    ( $CMD > "$RESULT_FILE" 2>&1; pkill -f "rofi .* -p $LOADING_MSG" ) &
    BG_PID=$!

    echo "Please wait..." | $ROFI_CMD "$LOADING_MSG" > /dev/null 2>&1

    if [[ -s "$RESULT_FILE" ]]; then
        RAW_OUTPUT=$(cat "$RESULT_FILE")
        
        if [[ "$RAW_OUTPUT" == *"Connected to"* ]]; then
            SERVER=$(echo "$RAW_OUTPUT" | sed -n 's/.*Connected to \([^ ]*\) .*/\1/p')
            COUNTRY=$(echo "$RAW_OUTPUT" | sed -n 's/.*in \(.*\)\. Your.*/\1/p')
            IP=$(echo "$RAW_OUTPUT" | sed -n 's/.*address is \([^ ]*\).*/\1/p' | sed 's/\.$//')

            # ALIGNMENT FIX: Used printf to align the colons
            # %-12s means "pad the label to 12 chars"
            MENU_ITEMS=$(printf "⛔  %-12s : %s\n  %-12s : %s\n﫮  %-12s : %s\n  %-12s : %s" \
                "Status" "Connected" \
                "Server" "$SERVER" \
                "Country" "$COUNTRY" \
                "IP Addr" "$IP")

            echo "$MENU_ITEMS" | $ROFI_CMD "VPN Success" > /dev/null

        elif [[ "$RAW_OUTPUT" == *"Disconnected"* ]]; then
            echo "睊  VPN Disconnected" | $ROFI_CMD "Status" > /dev/null
        else
            cat "$RESULT_FILE" | $ROFI_CMD "VPN Output" > /dev/null
        fi
    else
        kill $BG_PID 2>/dev/null
        notify "Action Cancelled"
    fi
    rm "$RESULT_FILE"
}

speed_test() {
    RESULT_FILE=$(mktemp)
    LOADING_MSG="Running Speed Test..."

    ( speedtest > "$RESULT_FILE"; pkill -f "rofi .* -p $LOADING_MSG" ) &
    BG_PID=$!

    echo "Please wait ~30 seconds" | $ROFI_CMD "$LOADING_MSG" > /dev/null 2>&1

    if [[ -s "$RESULT_FILE" ]]; then
        # ALIGNMENT FIX: Matches the VPN format exactly
        # Icon + 2 spaces + Label (padded to 12) + Colon + Value
        cat "$RESULT_FILE" | awk '
            /Hosted by/  { printf "  %-12s : %s ms\n", "Ping", $(NF-1) }
            /^Download:/ { printf "  %-12s : %s %s\n", "Download", $2, $3 }
            /^Upload:/   { printf "祝  %-12s : %s %s\n", "Upload", $2, $3 }
        ' | $ROFI_CMD "Speed Results" > /dev/null
    else
        notify "Speed Test yielded no results."
    fi
    rm "$RESULT_FILE"
}

wired_menu() {
    SEL=$(echo -e "Enable\nDisable" | $ROFI_CMD "Ethernet")
    case "$SEL" in
        "Enable") nmcli networking on; notify "Ethernet Enabled" ;;
        "Disable") nmcli networking off; notify "Ethernet Disabled" ;;
    esac
}

# --- Main Logic ---

if nmcli radio wifi | grep -q "enabled"; then
    WIFI_TOGGLE="⛔  Disable Wi-Fi"
else
    WIFI_TOGGLE="🟢  Enable Wi-Fi"
fi

MENU="$OPT_WIFI
$WIFI_TOGGLE
$OPT_ETH
$OPT_VPN
$OPT_TEST
$OPT_INFO
$OPT_DISC
$OPT_RESTART"

SELECTION=$(echo "$MENU" | $ROFI_CMD "$PROMPT")

case "$SELECTION" in
    "$OPT_WIFI")    wifi_menu ;;
    "$OPT_ETH")     wired_menu ;;
    "$OPT_VPN")     vpn_menu ;;
    "$OPT_TEST")    speed_test ;;
    "$OPT_INFO")    
        INFO=$(nmcli -t -f IP4.ADDRESS,GENERAL.DEVICE device show | head -n 3)
        echo -e "$INFO" | $ROFI_CMD "Info"
        ;;
    "$OPT_DISC")    
        ACTIVE=$(nmcli -t -f NAME connection show --active | head -n1)
        nmcli connection down "$ACTIVE" && notify "Disconnected"
        ;;
    "$OPT_RESTART") pkexec systemctl restart NetworkManager; notify "NM Restarted" ;;
    "⛔  Disable Wi-Fi") nmcli radio wifi off; notify "Wi-Fi Disabled" ;;
    "🟢  Enable Wi-Fi") nmcli radio wifi on; notify "Wi-Fi Enabled" ;;
esac