#!/usr/bin/env bash
# Prints true/false for the Bluetooth toggle (inline quoting broke in config.json).
bluetoothctl show 2>/dev/null | grep -q "Powered: yes" && echo true || echo false
