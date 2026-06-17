return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    config = function(_, opts)
        require("snacks").setup(opts)
    end,
    opts = {
        bigfile = { enabled = true },
        bufdelete = { enabled = true },
        quickfile = { enabled = true },
        scope = { enabled = true },
        words = { enabled = false },
        notifier = { enabled = false },
        animate = {
            enabled = true,
            duration = 20, -- Slower, more 'luxurious' feel
            fps = 100,     -- High refresh rate for Kitty
        },
        picker = { enabled = false },
        explorer = { enabled = false },
        dashboard = { enabled = true },
        indent = {
            enabled = true,
            char = "│",
            scope = {
                enabled = true,
                underline = false,
                hl = "IblScope",
            },
            chunk = {
                enabled = true,
                hl = "IblIndent",
            },
        },
        input = {
            enabled = true,
            win = {
                style = "rounded",
            },
        },
        lazygit = { enabled = true },
        image = { enabled = false },
        scroll = { enabled = false },
        statuscolumn = { enabled = true },
    },
    keys = {
        { "<leader>gl", function() Snacks.lazygit() end, desc = "Lazygit (VS Code-style panel)" },
        { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "Lazygit Current File History" },
    },
}
