-- matugen template -> ~/.config/hypr/hyprland/colors.lua
-- HUD design system for windows: a rotating primary -> tertiary edge and a soft
-- primary glow on the focused window, near-invisible edges on the rest.
hl.config({
    general = {
        col = {
            active_border = {
                -- bright head -> tertiary -> faint tail; rotated by the borderangle loop
                colors = {
                    "rgba(b9c9cfff)",
                    "rgba(b2cad3aa)",
                    "rgba(b9c9cf22)",
                },
                angle = 45,
            },
            inactive_border = "rgba(46474744)",
        },
    },
    decoration = {
        shadow = {
            color = "rgba(00000040)",
            color_inactive = "rgba(0000001a)",
        },
        glow = {
            enabled = true,
            range = 12,
            render_power = 3,
            color = "rgba(b9c9cf38)",
            color_inactive = "rgba(b9c9cf00)",
        },
    },
    misc = {
        background_color = "0xff121314",
    },
})

hl.window_rule({
    match = { pin = 1 },
    border_color = {
        colors = { "rgba(b9c9cfff)", "rgba(ffb4abcc)" },
        angle = 45,
    },
})
