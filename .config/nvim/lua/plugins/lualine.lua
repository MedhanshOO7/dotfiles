-- Statusline. Layouts, components and the :StatusStyle picker live in lua/ui/statusline.
return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    cmd = { "StatusStyle", "UISeparator" },
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        require("ui.statusline").setup()
    end,
}
