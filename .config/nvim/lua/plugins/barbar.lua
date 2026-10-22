-- Tabline. Per-style colours and keymaps live in lua/ui/tabline.
return {
    "romgrk/barbar.nvim",
    event = "VeryLazy",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    init = function()
        vim.g.barbar_auto_setup = false
        require("utils.status_style").load()
        -- Shared NvChad separator
        vim.g.ui_nvchad_separator = vim.g.ui_nvchad_separator or "round"
    end,
    config = function()
        require("ui.tabline").setup()
    end,
}
