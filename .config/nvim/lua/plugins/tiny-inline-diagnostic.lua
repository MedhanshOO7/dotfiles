return {
    "rachartier/tiny-inline-diagnostic.nvim",
    -- virtual_text is off (lua/plugins/lsp.lua), so this is the only inline
    -- renderer: load it for nvim-lint results in buffers without an LSP too.
    event = { "LspAttach", "DiagnosticChanged" },
    opts = {
        preset = "modern",
        transparent_bg = false,
        signs = {
            left = "",
            right = "",
            diag = "●",
            arrow = "  ",
            up_arrow = "  ",
            vertical = " │",
            vertical_end = " └",
        },
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
            break_line = {
                enabled = true,
                after = 40,
            },
        },
    },
}
