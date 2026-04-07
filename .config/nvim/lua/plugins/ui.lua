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
}
