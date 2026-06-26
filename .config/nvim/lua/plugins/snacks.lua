return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        bigfile = { enabled = true },
        bufdelete = { enabled = true },
        quickfile = { enabled = true },
        scope = { enabled = true },
        words = { enabled = false },
        notifier = {
            enabled = true,
            timeout = 3000,
            style = "compact",
        },
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
        image = { enabled = true }, -- Enabled for Kitty!
        scroll = { enabled = false },
        statuscolumn = { enabled = true },
        zen = { enabled = true },
        scratch = { enabled = true },
    },
    keys = {
        { "<leader>gl", function() Snacks.lazygit() end, desc = "Lazygit (VS Code-style panel)" },
        { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "Lazygit Current File History" },
        { "<leader>Z", function() Snacks.zen() end, desc = "Toggle Zen Mode" },
        { "<leader>.", function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
        { "<leader>n", function() Snacks.notifier.show_history() end, desc = "Notification History" },
    },
}
