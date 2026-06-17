return {
    "rmagatti/auto-session",
    lazy = false,
    dependencies = {
        "nvim-telescope/telescope.nvim",
    },
    keys = {
        { "<leader>wr", "<cmd>SessionRestore<cr>", desc = "Restore session for cwd" },
        { "<leader>ws", "<cmd>SessionSave<cr>", desc = "Save session for cwd" },
        { "<leader>wl", "<cmd>Autosession search<cr>", desc = "Search saved sessions" },
    },
    config = function()
        local auto_session = require("auto-session")

        auto_session.setup({
            auto_restore = false,
            auto_save = true,
            auto_create = true,
            suppressed_dirs = { "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/" },
            session_lens = {
                load_on_setup = true,
                previewer = true,
            },
        })
    end,
}
