return {
    {
        "stevearc/dressing.nvim",
        event = "VeryLazy",
        opts = {
            input = {
                border = "rounded",
                win_options = {
                    winblend = 0,
                },
            },
            select = {
                backend = { "telescope", "builtin" },
                builtin = {
                    border = "rounded",
                    win_options = {
                        winblend = 0,
                    },
                },
            },
        },
    },
    {
        "nvim-telescope/telescope-ui-select.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim",
        },
    },
    {
        "karb94/neoscroll.nvim",
        event = "VeryLazy",
        config = function()
            require("neoscroll").setup({
                easing_function = "cubic", -- smooth but still responsive
                hide_cursor = true,
                stop_eof = true,
                respect_scrolloff = true,
            })
        end,
    },
}
