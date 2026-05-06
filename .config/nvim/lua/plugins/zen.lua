return {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {
        window = {
            backdrop = 0, -- Keep the background transparent
            width = 95,
            options = {
                signcolumn = "no",
                number = true,
                relativenumber = true,
                colorcolumn = "",
            },
        },
        plugins = {
            options = {
                enabled = true,
                laststatus = 0,
            },
            twilight = { enabled = false }, -- Disable Twilight by default in ZenMode
        },
    },
}
