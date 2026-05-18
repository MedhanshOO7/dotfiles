return {
    "petertriho/nvim-scrollbar",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
        "kevinhwang91/nvim-hlslens",
    },
    config = function()
        require("hlslens").setup()
        require("scrollbar").setup({
            show = true,
            handle = {
                text = " ",
                color = "#665c54",
                hide_if_all_visible = true,
            },
            marks = {
                Search = { color = "#fabd2f" },
                Error = { color = "#fb4934" },
                Warn = { color = "#fe8019" },
                Info = { color = "#83a598" },
                Hint = { color = "#8ec07c" },
                Misc = { color = "#d3869b" },
            },
            excluded_filetypes = {
                "cmp_menu",
                "cmp_docs",
                "notify",
                "noice",
                "prompt",
                "TelescopePrompt",
                "alpha",
            },
            handlers = {
                cursor = false,
                diagnostic = true,
                gitsigns = false, -- Temporarily disable gitsigns to see if it's the culprit
                search = true,
            },
        })
    end,
}
