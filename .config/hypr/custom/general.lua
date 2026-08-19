-- hyprlang noerror false
-- https://wiki.hyprland.org/Configuring/Variables/
hl.monitor({ output = "eDP-1",   mode = "2560x1600@165", position = "1600x0", scale = 1.60 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@75",  position = "0x0",    scale = 1.0 })
-- hl.monitor({ output = "HEADLESS-2", mode = "2304x1440@90.00", position = "0x0", scale = 1.50 })
-- =============================================
-- CURVES
-- =============================================

-- Windows: Smooth, Apple-style harmonic spring (fluid overshoot, gentle settle)
hl.curve("windowSpringIn", {
    type = "bezier",
    points = {{0.25, 1.15}, {0.2, 1.0}}
})
hl.curve("windowSpringOut", {
    type = "bezier",
    points = {{0.2, 0.0}, {0.8, 0.15}}   -- Quick exit, no jarring wind-up
})

-- Window move/snap: Tactile, gooey settle on drag
hl.curve("windowSnap", {
    type = "bezier",
    points = {{0.25, 1.12}, {0.2, 1.0}}
})

-- Workspace: The requested "goo bounce" - deep stretch into the new space, elegant rock back
hl.curve("workspaceGlide", {
    type = "bezier",
    points = {{0.15, 1.25}, {0.25, 1.0}} 
})

-- Popups/layers: Alive and fluid, but respectful of the foreground
hl.curve("popupIn", {
    type = "bezier",
    points = {{0.2, 1.1}, {0.2, 1.0}}
})
hl.curve("popupOut", {
    type = "bezier",
    points = {{0.15, 0.0}, {0.8, 0.1}}   
})

-- Special workspace: Heavy, bouncy sheet drop (like iOS modals)
hl.curve("sheetIn", {
    type = "bezier",
    points = {{0.2, 1.2}, {0.2, 1.0}}
})
hl.curve("sheetOut", {
    type = "bezier",
    points = {{0.2, 0.0}, {0.8, 0.2}}
})

-- Border
hl.curve("borderSnap", {
    type = "bezier",
    points = {{0.1, 1.0}, {0.2, 1.0}}
})

-- Zoom: Fluid focal spring
hl.curve("zoomSpring", {
    type = "bezier",
    points = {{0.25, 1.15}, {0.2, 1.0}}
})


-- =============================================
-- ANIMATIONS
-- =============================================

-- Windows
hl.animation({
    leaf = "windowsIn",
    enabled = true,
    speed = 9.0,                -- Slowed down slightly to let the spring breathe
    bezier = "windowSpringIn",
    style = "popin 80%"         -- Slightly larger start size for a smoother entrance
})
hl.animation({
    leaf = "fadeIn",
    enabled = true,
    speed = 5.0,
    bezier = "popupIn"
})
hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 10.0,                
    bezier = "windowSpringOut",
    style = "popin 85%"
})
hl.animation({
    leaf = "fadeOut",
    enabled = true,
    speed = 4.5,
    bezier = "popupOut"
})
hl.animation({
    leaf = "windowsMove",
    enabled = true,
    speed = 9.5,
    bezier = "windowSnap",
    style = "slide"
})
hl.animation({
    leaf = "border",
    enabled = true,
    speed = 6,
    bezier = "borderSnap"
})

-- Layers (rofi, launcher, notifications)
hl.animation({
    leaf = "layersIn",
    enabled = true,
    speed = 4.8,
    bezier = "popupIn",
    style = "popin 85%"
})
hl.animation({
    leaf = "layersOut",
    enabled = true,
    speed = 4.5,                
    bezier = "popupOut",
    style = "popin 90%"
})
hl.animation({
    leaf = "fadeLayersIn",
    enabled = true,
    speed = 2.5,                
    bezier = "popupIn"
})
hl.animation({
    leaf = "fadeLayersOut",
    enabled = true,
    speed = 2,
    bezier = "popupOut"
})

-- Workspaces
hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 8.5,
    bezier = "workspaceGlide",  
    style = "slide"
})

-- Special workspace (scratchpad)
hl.animation({
    leaf = "specialWorkspaceIn",
    enabled = true,
    speed = 5.0,                
    bezier = "sheetIn",
    style = "slidevert"
})
hl.animation({
    leaf = "specialWorkspaceOut",
    enabled = true,
    speed = 5.5,
    bezier = "sheetOut",
    style = "slidevert"
})

-- Zoom
hl.animation({
    leaf = "zoomFactor",
    enabled = true,
    speed = 20.0,
    bezier = "zoomSpring"
})

hl.config({
    cursor = {
        min_refresh_rate = 24,
        no_hardware_cursors = false,  -- Request HW cursors (revert to true if glitchy)
    },
    opengl = {
        nvidia_anti_flicker = true,
    },
    render = {
        direct_scanout = 1,  -- Direct scanout for fullscreen apps (bypasses compositor rendering)
    },
    misc = {
        vrr = 1,  -- VRR for fullscreen apps (saves power, reduces tearing in games)
    },
    xwayland = {
        force_zero_scaling = true,
    },
    decoration = {
        rounding_power = 2,
        rounding = 18,
        blur = {
            enabled = true,
            xray = false,
            special = false,
            new_optimizations = true,
            size = 7,
            passes = 2,
            brightness = 1.05,
            contrast = 1.08,
            vibrancy = 0.25,
            vibrancy_darkness = 0.25,
            popups = false,
            popups_ignorealpha = 0.6,
            input_methods = true,
            input_methods_ignorealpha = 0.8,
        },
        shadow = {
            enabled = true,
            range = 16,
            offset = "0 2",
            render_power = 2,
            color = "rgba(00000035)",
            color_inactive = "rgba(00000015)",
        },
        dim_inactive = true,
        dim_strength = 0.15,
        dim_special = 0.2,
    },

    general = {
        border_size = 4,
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
        sensitivity = 0.2,
        touchpad = {
            natural_scroll = true,
            disable_while_typing = false,
            clickfinger_behavior = true,
            scroll_factor = 0.4,
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
    scroll_factor = 0.7,
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
