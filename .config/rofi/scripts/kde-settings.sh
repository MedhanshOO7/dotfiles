#!/bin/bash

# 1. Detect KDE version (Plasma 6 vs Plasma 5)
if command -v kcmshell6 &> /dev/null; then
    KCM_CMD="kcmshell6"
elif command -v kcmshell5 &> /dev/null; then
    KCM_CMD="kcmshell5"
else
    rofi -e "Error: neither kcmshell6 nor kcmshell5 found."
    exit 1
fi

# 2. Complete List Organized by Category
options=(
    # --- APPEARANCE & THEME ---
    "🎨 Global Theme|kcm_lookandfeel"
    "🌈 Application Style|kcm_style"
    "🖌️ Colors & Accents|kcm_colors"
    "🖼️ Icons|kcm_icons"
    "🖱️ Cursors|kcm_cursortheme"
    "🅰️ Fonts|kcm_fonts"
    "🔡 Font Management|kcm_fontinst"
    "🖥️ Plasma Style|kcm_desktoptheme"
    "🎭 Splash Screen|kcm_splashscreen"
    "🎬 Boot Splash (Plymouth)|kcm_plymouth"
    "✨ Desktop Effects|kcm_kwin_effects"
    "🎞️ Animations|kcm_animations"
    "🔔 Sound Theme|kcm_soundtheme"
    "🖼️ Wallpaper|kcm_wallpaper"
    
    # --- WORKSPACE BEHAVIOR ---
    "🧠 Workspace Behavior|kcm_workspace"
    "📑 Activities|kcm_activities"
    "🚪 Session Login/Logout|kcm_smserver"
    "🔍 Plasma Search|kcm_plasmasearch"
    "🔎 File Search (Baloo)|kcm_baloofile"
    "📂 File Associations|kcm_filetypes"
    "🏠 Desktop Paths|kcm_desktoppaths"
    "📜 Recent Files History|kcm_recentFiles"
    "🔔 Notifications|kcm_notifications"
    "🌐 Web Shortcuts|kcm_webshortcuts"
    "🔤 Spell Checking|kcmspellchecking"
    
    # --- WINDOW MANAGEMENT ---
    "🪟 Window Decorations|kcm_kwindecoration"
    "⚙️ Window Behavior|kcm_kwinoptions"
    "📏 Window Rules|kcm_kwinrules"
    "↔️ Screen Edges|kcm_kwinscreenedges"
    "👆 Touchscreen Gestures|kcm_kwintouchscreen"
    "⌨️ Virtual Desktops|kcm_kwin_virtualdesktops"
    "🔄 Window Switcher (TabBox)|kcm_kwintabbox"
    "📜 KWin Scripts|kcm_kwin_scripts"
    "💎 Compositor (X11)|kwincompositing"
    
    # --- SHORTCUTS & INPUT ---
    "⌨️ Shortcuts (System)|kcm_keys"
    "⌨️ Keyboard Hardware|kcm_keyboard"
    "🖱️ Mouse Settings|kcm_mouse"
    "👆 Touchpad Settings|kcm_touchpad"
    "🖊️ Wacom Tablet|kcm_wacomtablet"
    "✍️ Tablet Settings|kcm_tablet"
    "⌨️ Virtual Keyboard|kcm_virtualkeyboard"
    "🇮🇳 Input Method (Fcitx5)|kcm_fcitx5"
    "🎮 Game Controller|kcm_gamecontroller"
    
    # --- HARDWARE & SYSTEM ---
    "🖥️ Display Configuration|kcm_kscreen"
    "🌙 Night Light|kcm_nightlight"
    "🔉 Audio (Pulse/Pipewire)|kcm_pulseaudio"
    "🔋 Power Management|kcm_powerdevilprofilesconfig"
    "🔋 Mobile Power|kcm_mobile_power"
    "🌐 Network Connections|kcm_networkmanagement"
    "📡 Mobile Hotspot|kcm_mobile_hotspot"
    "🔵 Bluetooth|kcm_bluetooth"
    "🖨️ Printer Manager|kcm_printer_manager"
    "💾 Disk Usage (KDF)|kcm_kdf"
    "💓 Disk Health (SMART)|kcm_disks"
    "🔌 USB Devices|kcm_usb"
    "⚡ Thunderbolt|kcm_bolt"
    "📷 Camera Settings|kcm_kamera"
    "🌡️ Sensors|kcm_sensors"
    
    # --- SYSTEM ADMIN ---
    "🔒 Login Screen (SDDM)|kcm_sddm"
    "🔒 Screen Locker|kcm_screenlocker"
    "👥 User Management|kcm_users"
    "🚀 Autostart Apps|kcm_autostart"
    "🌍 Region & Language|kcm_regionandlang"
    "📅 Date & Time|kcm_clock"
    "🛡️ Firewall|kcm_firewall"
    "📦 Software Updates|kcm_updates"
    "🔑 KDE Wallet|kcm_kwallet5"
    "☁️ Internet Accounts|kcm_kaccounts"
    "🛡️ App Permissions|kcm_app-permissions"
    "♿ Accessibility|kcm_access"
    
    # --- INFORMATION & TOOLS ---
    "ℹ️ System Information|kcm_about-distro"
    "📉 Energy Statistics|kcm_energyinfo"
    "🖥️ KWin Support Info|kcm_kwinsupportinfo"
    "🛠️ Background Services|kcm_kded"
    "💾 Block Devices|kcm_block_devices"
    "📟 CPU Info|kcm_cpu"
    "🧠 Memory Info|kcm_memory"
    "📡 Network Info|kcm_network"
    "🎮 Vulkan/OpenGL Info|kcm_vulkan"
)

# 3. Generate input for Rofi
rofi_input=$(printf "%s\n" "${options[@]%%|*}")

# 4. Show Rofi and get selection
selected_name=$(echo -e "$rofi_input" | rofi -dmenu -i -p "KDE Settings" -l 15)

# 5. Execute match
if [ -n "$selected_name" ]; then
    for option in "${options[@]}"; do
        if [[ "$option" == "$selected_name"* ]]; then
            module="${option##*|}"
            $KCM_CMD "$module" &
            exit 0
        fi
    done
fi