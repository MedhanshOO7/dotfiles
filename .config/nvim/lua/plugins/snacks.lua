return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    config = function(_, opts)
        require("snacks").setup(opts)
        require("snacks.input").enable()
        pcall(function()
            require("snacks.dashboard").setup()
        end)
    end,
    opts = {
        bigfile = { enabled = true },
        bufdelete = { enabled = true },
        quickfile = { enabled = true },
        scope = { enabled = true },
        words = { enabled = true },
        notifier = { enabled = true },
        animate = { enabled = true },
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
        input = { enabled = true },
        lazygit = { enabled = true },
        image = { enabled = false },
        scroll = { enabled = true },
        statuscolumn = { enabled = true },
    },
    keys = {
        { "<leader>gl", function() require("snacks").lazygit() end, desc = "Lazygit (VS Code-style panel)" },
        { "<leader>gf", function() require("snacks").lazygit.log_file() end, desc = "Lazygit Current File History" },
    },
}
