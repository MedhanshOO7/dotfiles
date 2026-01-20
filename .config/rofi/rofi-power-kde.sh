#!/bin/bash

# Options
shutdown="   Shutdown"
reboot="   Reboot"
lock="   Lock"
suspend="   Suspend"
logout="   Logout"

# Get uptime
uptime=$(uptime -p | sed -e 's/up //g')

# Rofi Command
rofi_cmd() {
	rofi -dmenu \
		-p "Uptime: $uptime" \
		-mesg "KDE Power Menu" \
		-theme-str 'window {width: 20em;} listview {lines: 5;}'
}

# Pass variables to rofi
options="$lock\n$suspend\n$logout\n$reboot\n$shutdown"

chosen="$(echo -e "$options" | rofi_cmd)"

# Execute commands
case ${chosen} in
    $shutdown)
        # Safely shutdown via systemd (KDE handles the signal well)
		systemctl poweroff
        ;;
    $reboot)
        # Safely reboot
		systemctl reboot
        ;;
    $lock)
        # The correct way to lock KDE Plasma 5 & 6
		loginctl lock-session
        ;;
    $suspend)
        # Lock screen first, then suspend
		loginctl lock-session && systemctl suspend
        ;;
    $logout)
        # Standard KDE Logout command (works for Plasma 5 & 6)
        # Promptless immediate logout
		qdbus org.kde.ksmserver /KSMServer logout 0 0 3
        ;;
esac