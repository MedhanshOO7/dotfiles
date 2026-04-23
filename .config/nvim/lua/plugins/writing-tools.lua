return {
    {
        "gaoDean/autolist.nvim",
        ft = {
            "markdown",
            "text",
        },
        config = function()
            require("autolist").setup()

            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "markdown", "text" },
                callback = function(event)
                    local opts = { buffer = event.buf }

                    vim.keymap.set("i", "<CR>", "<CR><cmd>AutolistNewBullet<CR>", opts)
                    vim.keymap.set("n", "o", "o<cmd>AutolistNewBullet<CR>", opts)
                    vim.keymap.set("n", "O", "O<cmd>AutolistNewBulletBefore<CR>", opts)
                    vim.keymap.set("n", "<leader>Mr", "<cmd>AutolistRecalculate<CR>",
                        vim.tbl_extend("force", opts, { desc = "Fix markdown list numbering" }))
                end,
            })
        end,
    },
    {
        "stevearc/aerial.nvim",
        cmd = { "AerialToggle", "AerialNavToggle" },
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("aerial").setup({
                backends = { "lsp", "treesitter", "markdown", "man" },
                layout = {
                    min_width = 28,
                    default_direction = "right",
                },
                filter_kind = false,
                show_guides = true,
            })
        end,
    },
    {
        "folke/twilight.nvim",
        cmd = "Twilight",
        config = function()
            require("twilight").setup({
                dimming = {
                    alpha = 0.25,
                },
                context = 12,
                expand = {
                    "function",
                    "method",
                    "table",
                    "if_statement",
                },
            })
        end,
    },
}
