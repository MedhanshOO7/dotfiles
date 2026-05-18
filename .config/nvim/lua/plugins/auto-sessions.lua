return {
    "rmagatti/auto-session",
    lazy = false,
    dependencies = {
        "nvim-telescope/telescope.nvim",
        "rmagatti/session-lens",
    },
    keys = {
        { "<leader>wr", "<cmd>SessionRestore<cr>", desc = "Restore session for cwd" },
        { "<leader>ws", "<cmd>SessionSave<cr>", desc = "Save session for cwd" },
        { "<leader>wl", "<cmd>SearchSession<cr>", desc = "Search saved sessions" },
    },
    config = function()
        local auto_session = require("auto-session")

        auto_session.setup({
            auto_restore = false,
            auto_save = true,
            auto_create = true,
            suppressed_dirs = { "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/" },
        })

        pcall(function()
            require("session-lens").setup({
                path_display = { "shorten" },
                previewer = true,
            })
        end)
    end,
}
