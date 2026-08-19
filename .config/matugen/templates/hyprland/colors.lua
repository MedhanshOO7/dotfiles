hl.config({
    general = {
        col = {
            active_border = "0xff{{colors.primary.default.hex_stripped}}",
            inactive_border = "0xff{{colors.outline.default.hex_stripped}}",
        },
    },
    misc = {
        background_color = "0xff{{colors.surface_dim.default.hex_stripped}}",
    },
})

hl.window_rule({
    match = { pin = 1 },
    border_color = "0xff{{colors.primary.default.hex_stripped}}",
})
