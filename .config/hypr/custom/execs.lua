-- hyprlang noerror false
-- You can make apps auto-start here
-- https://wiki.hyprland.org/Configuring/Keywords/#executing

-- Input method
-- hl.execonce("fcitx5")

hl.on("hyprland.start", function()
    -- KDE Code Bridge: start it from Hyprland rather than systemd
    hl.exec_cmd("PYTHONPATH=$HOME/.local/share/kde-code-bridge $HOME/.local/share/kde-code-bridge/venv/bin/python -m kde_code_bridge --host 127.0.0.1 --port 8765")

    -- Input method
    -- hl.exec_cmd("fcitx5")

    -- vicinae
    hl.exec_cmd("vicinae server --replace")

    -- fixing the keyring
    -- hl.exec_cmd("/usr/lib/pam_kwallet_init")
    -- hl.exec_cmd("kwalletd6")
    hl.exec_cmd("snappy-switcher --daemon")
    -- hl.exec_cmd("sh -c 'pgrep -x betterbird || betterbird'")
    -- hl.exec_once("caps-overlay -d")
    --exec-once = sh -c 'pgrep -x betterbird || betterbird'
    -- static wallpaper (awww restores the last image); skipped when a video wallpaper is set
    hl.exec_cmd("grep -q mpvpaper $HOME/.config/hypr/custom/scripts/__restore_video_wallpaper.sh || awww-daemon")
    hl.exec_cmd("waybar")
    -- HUD dock (Quickshell, ~/.config/quickshell/hud-dock); toggle with SUPER+SHIFT+D
    hl.exec_cmd("qs -n -c hud-dock")
    -- Predator (nekro-sense): keyboard light without timeout, theme-synced RGB if enabled
    hl.exec_cmd("$HOME/.config/hud/predator.sh login")
    -- night light (schedule in ~/.config/hypr/hyprsunset.conf)
    hl.exec_cmd("pidof hyprsunset || hyprsunset")
    -- volume/brightness OSD (styled in ~/.config/swayosd/style.css)
    hl.exec_cmd("command -v swayosd-server && (pidof swayosd-server || GDK_WAYLAND_DISABLE=ext_background_effect_manager_v1 swayosd-server)")
    hl.exec_cmd("pkill -9 mako") -- swaync is the notification daemon
end)
