return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            require("allMyLuaFiles.theme").setup()
        end,
    },
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            styles = {
                sidebars = "transparent",
                floats = "transparent",
            },
        },
    },
    {
        "ellisonleao/gruvbox.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            contrast = "hard",
        },
    },
    {
        "Mofiqul/dracula.nvim",
        lazy = false,
        priority = 1000,
    },
    {
        "rose-pine/neovim",
        name = "rose-pine",
        lazy = false,
        priority = 1000,
        opts = {
            disable_background = true,
        },
    },
}
