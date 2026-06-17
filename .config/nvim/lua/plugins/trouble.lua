return {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
        { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Open the project problem list" },
        { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Open the current file problem list" },
        { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Open the quickfix list" },
        { "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Open the location list" },
        { "<leader>xo", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Open document symbols in a side list" },
    },
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        require("trouble").setup({
            focus = true,
            warn_no_results = false,
            open_no_results = true,
        })
    end,
}
