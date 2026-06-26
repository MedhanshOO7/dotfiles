return {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewRefresh", "DiffviewFileHistory" },
    keys = {
        { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Git: Open Diffview" },
        { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Git: Current File History" },
        { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Git: Close Diffview" },
    },
    opts = {
        enhanced_diff_hl = true,
    },
}
