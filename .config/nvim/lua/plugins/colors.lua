return {
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            style = "night",
            styles = {
                comments = { italic = false },
                keywords = { italic = false },
                sidebars = "dark",
                floats = "dark",
            },
        },
    },
    {
        "rose-pine/neovim",
        name = "rose-pine",
        lazy = false,
        priority = 1000,
    },
    {
        "rebelot/kanagawa.nvim",
        lazy = false,
        priority = 1000,
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
        "sainnhe/everforest",
        lazy = false,
        priority = 1000,
    },
    {
        "Mofiqul/vscode.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            italic_comments = false,
        },
    },
    {
        "EdenEast/nightfox.nvim",
        lazy = false,
        priority = 1000,
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,
        priority = 900,
        config = function()
            require("allMyLuaFiles.theme").setup()
        end,
    },
}
