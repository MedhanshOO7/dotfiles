return {
    "OXY2DEV/helpview.nvim",
    ft = "help",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "echasnovski/mini.icons",
    },
    opts = {
        preview = {
            enable = true,
            enable_hybrid_mode = true,
            modes = { "n", "c", "no" },
            icon_provider = "mini",
        },
    },
    config = function(_, opts)
        require("helpview").setup(opts)

        -- Ensure helpview re-renders when the theme changes
        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("helpview_colors", { clear = true }),
            callback = function()
                if package.loaded["helpview"] then
                    vim.cmd("Helpview render")
                end
            end,
        })
    end,
    keys = {
        { "<leader>hvt", "<cmd>Helpview toggle<cr>", desc = "Toggle Helpview" },
        { "<leader>hvs", "<cmd>Helpview splitToggle<cr>", desc = "Toggle Helpview Split" },
        { "<leader>hvr", "<cmd>Helpview render<cr>", desc = "Refresh Helpview" },
    },
}
