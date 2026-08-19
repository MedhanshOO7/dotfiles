hl.config({
    general = {
        col = {
            active_border = "rgba({{colors.primary.default.hex_stripped}}66)",
            inactive_border = "rgba({{colors.outline_variant.default.hex_stripped}}22)",
        },
    },
    misc = {
        background_color = "0xff{{colors.surface_dim.default.hex_stripped}}",
    },
})

hl.window_rule({
    match = { pin = 1 },
    border_color = "rgba({{colors.primary.default.hex_stripped}}aa)",
})
