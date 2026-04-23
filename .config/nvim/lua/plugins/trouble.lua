return {
    "folke/trouble.nvim",
    cmd = "Trouble",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        require("trouble").setup({
            focus = true,
            warn_no_results = false,
            open_no_results = true,
            use_diagnostic_signs = true,
        })
    end,
}
