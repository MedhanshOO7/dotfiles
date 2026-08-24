return {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1000,
    opts = {
        preset = "modern",
        transparent_bg = false,
        options = {
            show_source = true,
            use_icons_from_diagnostic = true,
            add_messages = true,
            multilines = {
                enabled = true,
                always_show = true,
            },
            show_all_diags_on_cursorline = true,
            enable_on_insert = false,
            overflow = {
                mode = "wrap",
            },
        },
    },
}
