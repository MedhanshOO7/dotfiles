return {
    {
        "RRethy/vim-illuminate",
        event = "LspAttach",
        config = function()
            require("illuminate").configure({
                delay = 150,
                large_file_cutoff = 3000,
                large_file_overrides = {
                    providers = { "lsp", "treesitter" },
                },
                filetypes_denylist = {
                    "alpha",
                    "dashboard",
                    "help",
                    "lazy",
                    "mason",
                    "notify",
                    "snacks_dashboard",
                    "TelescopePrompt",
                    "toggleterm",
                },
                modes_denylist = { "i", "ic", "ix" },
            })
        end,
    },
    {
        "b0o/incline.nvim",
        enabled = false, -- Disabled: barbar.nvim and dropbar.nvim already provide buffer tabs and breadcrumbs
    },
    {
        "kevinhwang91/nvim-bqf",
        enabled = false, -- Disabled: quicker.nvim handles modern editable quickfix windows
    },
}
