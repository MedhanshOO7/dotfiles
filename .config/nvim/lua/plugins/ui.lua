return {
    {
        "stevearc/dressing.nvim",
        event = "VeryLazy",
        opts = {
            input = {
                border = "rounded",
            },
            select = {
                backend = { "telescope", "builtin" },
                builtin = {
                    border = "rounded",
                },
            },
        },
    },
    {
        "nvim-telescope/telescope-ui-select.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim",
        },
        config = function()
            require("telescope").load_extension("ui-select")
        end,
    },
    {
        "karb94/neoscroll.nvim",
        config = function()
            require("neoscroll").setup({
                easing_function = "quadratic", -- smooth
            })
        end,
    },
}
