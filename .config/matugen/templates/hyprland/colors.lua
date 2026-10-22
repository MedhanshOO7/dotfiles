-- matugen template -> ~/.config/hypr/hyprland/colors.lua
-- HUD design system for windows: a rotating primary -> tertiary edge and a soft
-- primary glow on the focused window, near-invisible edges on the rest.
hl.config({
    general = {
        col = {
            active_border = {
                -- bright head -> tertiary -> faint tail; rotated by the borderangle loop
                colors = {
                    "rgba({{colors.primary.default.hex_stripped}}ff)",
                    "rgba({{colors.tertiary.default.hex_stripped}}aa)",
                    "rgba({{colors.primary.default.hex_stripped}}22)",
                },
                angle = 45,
            },
            inactive_border = "rgba({{colors.outline_variant.default.hex_stripped}}44)",
        },
    },
    decoration = {
        shadow = {
            color = "rgba({{colors.shadow.default.hex_stripped}}40)",
            color_inactive = "rgba({{colors.shadow.default.hex_stripped}}1a)",
        },
        glow = {
            enabled = true,
            range = 12,
            render_power = 3,
            color = "rgba({{colors.primary.default.hex_stripped}}38)",
            color_inactive = "rgba({{colors.primary.default.hex_stripped}}00)",
        },
    },
    misc = {
        background_color = "0xff{{colors.surface_dim.default.hex_stripped}}",
    },
})

hl.window_rule({
    match = { pin = 1 },
    border_color = {
        colors = { "rgba({{colors.primary.default.hex_stripped}}ff)", "rgba({{colors.error.default.hex_stripped}}cc)" },
        angle = 45,
    },
})
