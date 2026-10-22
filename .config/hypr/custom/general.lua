-- hyprlang noerror false
-- https://wiki.hyprland.org/Configuring/Variables/
hl.monitor({ output = "eDP-1", mode = "2560x1600@165", position = "1600x0", scale = 1.60 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "0x0", scale = 1.0 })
-- hl.monitor({ output = "HEADLESS-2", mode = "2304x1440@90.00", position = "0x0", scale = 1.50 })

-- =============================================
-- BEZIER CURVES
-- Design language: every curve family shares the same
-- "personality" so the whole compositor feels like one
-- coherent system instead of a pile of one-off tweaks.
-- =============================================

-- FADES: opacity should never overshoot past 100% — it just
-- clips and reads as nothing. Clean, crisp ease-out only.
hl.curve("fadeCrisp", {
    type = "bezier",
    points = { { 0.36, 0.0 }, { 0.1, 1.0 } },
})

-- LAUNCHERS / LAYERS (rofi, notifications): the one place
-- bounce is *not* the goal. Near-zero overshoot, fast settle —
-- these need to feel instant, not springy.
hl.curve("snapIn", {
    type = "bezier",
    points = { { 0.19, 1.15 }, { 0.22, 1.0 } }, -- just a whisper of life, not a bounce
})
hl.curve("snapOut", {
    type = "bezier",
    points = { { 0.4, 0.0 }, { 0.51, 1.0 } }, -- zero wind-up, gone immediately
})

-- WINDOWS: the signature "wow factor" spring family. Open/close/
-- move all share the same back-ease DNA so a window always feels
-- like the same object, whether it's arriving, leaving, or dragging.
hl.curve("springIn", {
    type = "bezier",
    points = { { 0.34, 1.56 }, { 0.24, 1.0 } }, -- pronounced classic back-ease overshoot
})
hl.curve("springOut", {
    type = "bezier",
    points = { { 0.36, 0.0 }, { 0.66, 0.05 } }, -- quick, decisive, no jarring wind-up
})
hl.curve("springMove", {
    type = "bezier",
    points = { { 0.3, 1.35 }, { 0.22, 1.0 } }, -- tactile drag/snap, slightly softer than open
})

-- WORKSPACES: deepest bounce in the system — the "goo" everyone
-- notices. Stretches hardest into the new space, rocks back clean.
hl.curve("workspaceGoo", {
    type = "bezier",
    points = { { 0.16, 1.45 }, { 0.28, 1.0 } },
})

-- SPECIAL WORKSPACE (scratchpad): heaviest, most theatrical bounce —
-- the iOS-modal "sheet drop" feel, one step past even workspaces.
hl.curve("sheetDrop", {
    type = "bezier",
    points = { { 0.22, 1.55 }, { 0.24, 1.0 } },
})
hl.curve("sheetLift", {
    type = "bezier",
    points = { { 0.34, 0.0 }, { 0.64, 0.12 } },
})

-- BORDER: subtle tracking only — a border overshooting color/width
-- reads as a glitch, not polish. Small, tasteful settle.
hl.curve("borderTrack", {
    type = "bezier",
    points = { { 0.12, 0.95 }, { 0.2, 1.0 } },
})

-- HUD BORDER SPIN: constant speed for the rotating active-window gradient
hl.curve("hudLinear", {
    type = "bezier",
    points = { { 0, 0 }, { 1, 1 } },
})

-- ZOOM: continuous focal spring, moderate overshoot so it feels
-- alive without ever losing tracking precision.
hl.curve("zoomSpring", {
    type = "bezier",
    points = { { 0.3, 1.3 }, { 0.22, 1.0 } },
})

-- =============================================
-- ANIMATIONS
-- =============================================

-- Windows
hl.animation({
    leaf = "windowsIn",
    enabled = true,
    speed = 8.5, -- slightly slower so the spring has room to breathe
    bezier = "springIn",
    style = "popin 80%",
})
hl.animation({
    leaf = "fadeIn",
    enabled = true,
    speed = 5.5,
    bezier = "fadeCrisp",
})
hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 11.0, -- fast, decisive close — no lingering
    bezier = "springOut",
    style = "popin 85%",
})
hl.animation({
    leaf = "fadeOut",
    enabled = true,
    speed = 5.0,
    bezier = "fadeCrisp",
})
hl.animation({
    leaf = "windowsMove",
    enabled = true,
    speed = 9.5,
    bezier = "springMove",
    style = "slide",
})
hl.animation({
    leaf = "border",
    enabled = true,
    speed = 7.0,
    bezier = "borderTrack",
})

-- Active-window gradient slowly rotates (one turn every ~8s). Battery Saver
-- (SUPER + ALT + P) switches it off since it repaints every frame.
hl.animation({
    leaf = "borderangle",
    enabled = false,
})

-- Layers (rofi, launcher, notifications) — kept deliberately snappy
hl.animation({
    leaf = "layersIn",
    enabled = true,
    speed = 7.5, -- fast: launchers should never feel like they're "arriving"
    bezier = "snapIn",
    style = "popin 92%",
})
hl.animation({
    leaf = "layersOut",
    enabled = true,
    speed = 7.5,
    bezier = "snapOut",
    style = "popin 94%",
})
hl.animation({
    leaf = "fadeLayersIn",
    enabled = true,
    speed = 3.5,
    bezier = "fadeCrisp",
})
hl.animation({
    leaf = "fadeLayersOut",
    enabled = true,
    speed = 3.0,
    bezier = "fadeCrisp",
})

-- Workspaces
hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 8.0, -- slightly slower than before so the deeper goo bounce actually reads
    bezier = "workspaceGoo",
    style = "slide",
})

-- Special workspace (scratchpad)
hl.animation({
    leaf = "specialWorkspaceIn",
    enabled = true,
    speed = 5.0,
    bezier = "sheetDrop",
    style = "slidevert",
})
hl.animation({
    leaf = "specialWorkspaceOut",
    enabled = true,
    speed = 6.0,
    bezier = "sheetLift",
    style = "slidevert",
})

-- Zoom
hl.animation({
    leaf = "zoomFactor",
    enabled = true,
    speed = 20.0,
    bezier = "zoomSpring",
})

hl.config({
    -- cursor = {
    --     min_refresh_rate = 24,
    --     no_hardware_cursors = false, -- Request HW cursors (revert to true if glitchy)
    -- },
    opengl = {
        nvidia_anti_flicker = true,
    },
    render = {
        direct_scanout = 1, -- Direct scanout for fullscreen apps (bypasses compositor rendering)
    },
    misc = {
        vrr = 1, -- VRR for fullscreen apps (saves power, reduces tearing in games)
    },
    xwayland = {
        force_zero_scaling = false,
    },
    decoration = {
        rounding_power = 2,
        rounding = 12, -- HUD design system: uniform-radius surfaces use 12
        blur = {
            enabled = true,
            xray = false,
            special = false,
            new_optimizations = true,
            size = 8,
            passes = 3,
            brightness = 0.80, -- slightly darker glass keeps text on translucent panels readable
            contrast = 1.4,
            noise = 0.025, -- fine frosted grain
            vibrancy = 2.2,
            vibrancy_darkness = 0.5,
            popups = true,
            popups_ignorealpha = 0.6,
            input_methods = true,
            input_methods_ignorealpha = 0.6,
        },
        shadow = {
            enabled = true,
            range = 18,
            offset = "0 2",
            render_power = 2,
            -- colors (and the active-window glow) come from matugen: hyprland/colors.lua
        },
        dim_inactive = true,
        dim_strength = 0.15,
        dim_special = 0.2,
    },

    general = {
        border_size = 2,
    },
    input = {
        kb_layout = "us",
        numlock_by_default = true,
        repeat_delay = 250,
        repeat_rate = 35,
        follow_mouse = 1,
        off_window_axis_events = 2,
        natural_scroll = false,
        accel_profile = "adaptive",
        sensitivity = 0.30,
        touchpad = {
            natural_scroll = true,
            disable_while_typing = false,
            clickfinger_behavior = true,
            scroll_factor = 1.0,
        },
    },
})

hl.device({
    name = "microsoft-microsoft®-nano-transceiver-v2.0-mouse",
    scroll_factor = 0.7,
    natural_scroll = false,
})

hl.device({
    name = "hs6209-2.4g-wireless-receiver-mouse",
    scroll_factor = 1.7,
    natural_scroll = false,
})

hl.device({
    name = "pixart-lenovo-usb-optical-mouse",
    sensitivity = -0.3,
    accel_profile = "flat",
    natural_scroll = false,
})

hl.device({
    name = "pixa3807:01-093a:3807-mouse",
    enabled = false,
})

-- Layout modes (SUPER + ALT + L)
require("custom.layouts")

-- Motion styles (SUPER + ALT + A)
require("custom.animations")

-- Keep Battery Saver (SUPER + ALT + P) effects across config reloads
if is_file_exists("/tmp/hypr_power_saver_active") then
    hl.config({ decoration = { blur = { enabled = false }, shadow = { enabled = false }, glow = { enabled = false } } })
    hl.animation({ leaf = "borderangle", enabled = false })
end
