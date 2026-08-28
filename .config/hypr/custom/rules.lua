-- hyprlang noerror false
-- Window/layer rules: https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- ######## Layer rules ########
-- vicinae
hl.layer_rule({
    match = { class = "vicinae" },
    blur = true,
    xray = false,
    ignore_alpha = 0.1,
})
-- rofi
hl.layer_rule({
    match = { namespace = "rofi" },
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
    size = { "monitor_w*0.42", "monitor_h*0.48" },
    no_blur = false,
})
hl.window_rule({
    match = { title = "^(HyprVox Dictionary)$" },
    float = true,
    center = true,
    size = { "monitor_w*0.42", "monitor_h*0.48" },
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
