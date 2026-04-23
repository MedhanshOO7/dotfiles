return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    dependencies = {
        "echasnovski/mini.icons",
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
        delay = 200,
        preset = "classic",
    },
    config = function(_, opts)
        local wk = require("which-key")

        wk.setup(opts)
        wk.add({
            { "<leader>b", group = "Buffers" },
            { "<leader>c", group = "Code" },
            { "<leader>d", group = "Debug" },
            { "<leader>f", group = "Find and folds" },
            { "<leader>g", group = "Git" },
            { "<leader>h", group = "Harpoon" },
            { "<leader>l", group = "LSP" },
            { "<leader>m", group = "Molten" },
            { "<leader>M", group = "Markdown and multicursor" },
            { "<leader>s", group = "Search and jump" },
            { "<leader>t", group = "Terminal and tasks" },
            { "<leader>u", group = "UI and theme" },
            { "<leader>w", group = "Windows and sessions" },
            { "<leader>x", group = "Diagnostics and lists" },
            { "<leader>z", group = "Writing" },
        })
    end,
}
