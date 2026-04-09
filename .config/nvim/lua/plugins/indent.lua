return {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
        indent = {
            char = "▏", -- More subtle guide like VS Code
            tab_char = "▏",
        },
        scope = {
            enabled = true,
            show_start = false,
            show_end = false,
            injected_languages = false,
            highlight = { "Function", "Label" }, -- Highlight current scope
            priority = 1024,
        },
        exclude = {
            filetypes = {
                "help",
                "neo-tree",
                "lazy",
                "mason",
                "notify",
                "toggleterm",
                "trouble",
            },
        },
    },
}
