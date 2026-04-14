return {
    "folke/zen-mode.nvim",
    config = function()
        require("zen-mode").setup({
            window = {
                width = 1,
                options = {
                    number = false,
                    relativenumber = false,
                },
            },
            plugins = {
                options = {
                    enabled = true,
                    ruler = false,
                    showcmd = false,
                },
            },
        })
    end,
}
