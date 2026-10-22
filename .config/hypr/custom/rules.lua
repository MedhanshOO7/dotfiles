-- hyprlang noerror false
-- Window/layer rules: https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- ######## Layer rules ########
-- vicinae
hl.layer_rule({
    match = { namespace = "^vicinae$" },
    blur = true,
    xray = false,
    ignore_alpha = 0.1,
    animation = "popin 90%",
})
-- rofi
hl.layer_rule({
    match = { namespace = "rofi" },
    blur = true,
    blur_popups = true,
    ignore_alpha = 0,
})

hl.layer_rule({
    match = { namespace = "*obsidian*" },
    blur = true,
    blur_popups = true,
    ignore_alpha = 0,
})

-- nautilus (layer)
hl.layer_rule({
    match = { namespace = "org.gnome.Nautilus" },
    blur = true,
})

-- whisper-overlay (Voice Dictation Floating Pill)
hl.layer_rule({
    match = { namespace = "whisper-overlay" },
    blur = true,
    ignore_alpha = 0.1,
    animation = "slide bottom",
})

-- HUD glass: swaync, swayosd, waybar, alt-tab, wlogout.
-- GTK 4.24 binds ext-background-effect-v1, and with it bound Hyprland 0.56 ignores
-- these rules and blurs only the region the app sends (Renderer.cpp shouldBlur);
-- swaync 0.12.6 sends none for popups. So swaync/swayosd run with
-- GDK_WAYLAND_DISABLE=ext_background_effect_manager_v1 (swaync: systemd drop-in,
-- swayosd: custom/execs.lua) and blur through the rules below. ignore_alpha = 0
-- keeps the blur to painted pixels (swaync's surfaces are mostly transparent).
hl.layer_rule({
    match = { namespace = "^swaync-control-center$" },
    blur = true,
    ignore_alpha = 0,
    xray = false,
    animation = "slide right", -- glides in from the screen edge
})
hl.layer_rule({
    match = { namespace = "^swaync-notification-window$" },
    blur = true,
    ignore_alpha = 0,
    xray = false,
    animation = "slide right",
})
-- alt-tab switcher + wlogout
hl.layer_rule({
    match = { namespace = "^(snappy-switcher|logout_dialog)$" },
    blur = true,
    xray = false,
})
hl.layer_rule({
    match = { namespace = "^swayosd$" },
    blur = true,
    ignore_alpha = 0,
    xray = false,
    animation = "slide top", -- drops down out of the bar
})
-- ignore_alpha = 0: blur only behind painted pixels, not the transparent
-- gaps around the pills / dock margin (otherwise a blurred rectangle shows)
hl.layer_rule({
    match = { namespace = "^waybar$" },
    blur = true,
    blur_popups = true, -- tooltips
    xray = false,
    ignore_alpha = 0,
})

-- hud-dock (Quickshell) needs no rule: it requests its own blur region through
-- ext-background-effect and animates itself.

-- ######## Window rules ########

-- Disable blur for all xwayland apps:
hl.window_rule({
    match = { xwayland = true },
    no_blur = true,
})

-- HyprVox Vocabulary & Dictionary Editor
hl.window_rule({
    match = { class = "^(hyprvox-dictionary)$" },
    float = true,
    center = true,
    size = { "monitor_w*0.44", "monitor_h*0.50" },
    no_blur = false,
    opacity = 0.94,
})
hl.window_rule({
    match = { class = "org.kde.gwenview" },
    float = true,
    center = true,
})
hl.window_rule({
    match = { title = "^(HyprVox Dictionary)$" },
    float = true,
    center = true,
    size = { "monitor_w*0.44", "monitor_h*0.50" },
    no_blur = false,
    opacity = 0.94,
})

-- nautilus
hl.window_rule({
    match = { class = "org.gnome.Nautilus" },
    no_blur = false,
    opacity = 0.90,
})

-- kitty
hl.window_rule({
    match = { class = "kitty" },
    float = true,
    center = true,
    no_blur = false,
    size = { "monitor_w*0.85", "monitor_h*0.85" },
})

hl.window_rule({
    match = { class = "code" },
    no_blur = false,
    opacity = 0.86,
})
hl.window_rule({
    match = { class = "md.obsidian.Obsidian" },
    center = true,
    no_blur = false,
    opacity = 0.85,
})

hl.window_rule({
    match = { class = "org.kde.haruna" },
    float = true,
    center = true,
    no_blur = true,
})

-- uget
hl.window_rule({
    match = { class = "uget-gtk" },
    float = true,
    center = true,
    size = { "monitor_w*0.6", "monitor_h*0.68" },
})
-- NautilusPreviewer
hl.window_rule({
    match = { class = "org.gnome.NautilusPreviewer" },
    center = true,
    float = true,
})

-- vlc
hl.window_rule({
    match = { class = "vlc" },
    float = true,
    center = true,
    size = { 795, 498 },
})

-- hl.window_rule({
--     match = { class = "com.github.wwmm.easyeffects" },
--     float = true,
--     center = true,
--     size = { "monitor_w*0.1", "monitor_h*0.1" }
-- })
hl.window_rule({
    match = { class = "org.kde.dolphin" },
    no_blur = false,
    float = true,
    center = true,
    size = { "monitor_w*0.80", "monitor_h *0.85" },
})

-- Swappy
hl.window_rule({
    match = { class = "swappy" },
    float = true,
    center = true,
    size = { "monitor_w*0.60", "monitor_h*0.70" },
})

-- Signal Desktop
hl.window_rule({
    match = { class = "Signal" },
    float = true,
    center = true,
    size = { "monitor_w*0.5", "monitor_h*0.75" },
})

-- Image viewers
hl.window_rule({
    match = { class = "org.gnome.Loupe" },
    float = true,
    center = true,
})

-- System settings dialogs
hl.window_rule({
    match = { class = "org.kde.kcmshell6" },
    float = true,
    center = true,
    size = { "monitor_w*0.5", "monitor_h*0.65" },
})
hl.window_rule({
    match = { title = "^Title$" },
    float = true,
    center = true,
})
hl.window_rule({
    match = { title = "^title$" },
    float = true,
    center = true,
})
hl.window_rule({
    match = { title = "^SFML$" },
    float = true,
    center = true,
})

-- localsend
hl.window_rule({
    match = { class = "localsend" },
    float = true,
    center = true,
})

-- PredatorSense / NekroSense GUI (Python GTK & Rust Native)
hl.window_rule({
    match = { class = "org.example.NekroSense" },
    float = true,
    center = true,
})
hl.window_rule({
    match = { class = "nekroctl-gui-rs" },
    float = true,
    center = true,
})
hl.window_rule({
    match = { class = "nekroctl_gui_rs" },
    float = true,
    center = true,
})
hl.window_rule({
    match = { title = ".*Nekro.*" },
    float = true,
    center = true,
})

-- Performance & Low Latency rules for games / 3D apps
hl.window_rule({
    match = { class = "^(steam_app_.*|gamescope|heroic|cs2|osu!|lutris|factorio|hl2_linux)$" },
    immediate = true,
    no_blur = true,
    no_shadow = true,
})

-- Quickshell bar + dock
hl.layer_rule({
    match = { namespace = "quickshell:bar" },
    blur = true,
    ignore_alpha = 0.5,
})
hl.layer_rule({
    match = { namespace = "quickshell:dock" },
    blur = true,
    ignore_alpha = 0.04,
})

-- Flameshot overlay rules
hl.window_rule({
    match = { class = "flameshot" },
    float = true,
    fullscreen = true,
    pin = true,
    no_anim = true,
})

hl.window_rule({
    match = { class = "zen" },
    no_blur = false,
})
