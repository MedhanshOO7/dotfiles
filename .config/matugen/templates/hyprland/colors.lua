hl.config({
    general = {
        col = {
            active_border = {
                colors = { "rgba({{colors.primary.default.hex_stripped}}cc)", "rgba({{colors.secondary.default.hex_stripped}}cc)" },
                angle = 45
            },
            inactive_border = "rgba({{colors.outline.default.hex_stripped}}22)",
        },
    },
    misc = {
        background_color = "rgba({{colors.surface.dark.hex_stripped}}FF)",
    },
})

hl.window_rule({
    match        = { pin = 1 },
    border_color = "rgba({{colors.primary.default.hex_stripped}}AA) rgba({{colors.primary.default.hex_stripped}}77)",
})
