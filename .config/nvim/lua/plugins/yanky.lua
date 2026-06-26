return {
    "gbprod/yanky.nvim",
    dependencies = {
        "nvim-telescope/telescope.nvim",
    },
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        ring = { history_length = 100 },
        highlight = {
            on_put = true,
            on_yank = true,
            timer = 200,
        },
    },
    keys = {
        -- Kept to minimal specific bindings to avoid touching native y/p keybinds
        { "<leader>yy", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank text (to Yanky)" },
        { "<leader>yp", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put yanked text after cursor" },
        { "<leader>yP", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put yanked text before cursor" },
        { "<M-n>", "<Plug>(YankyCycleForward)", desc = "Cycle forward through yank history" },
        { "<M-p>", "<Plug>(YankyCycleBackward)", desc = "Cycle backward through yank history" },
        { "<leader>fy", "<cmd>Telescope yank_history<cr>", desc = "Find Yank History" },
    },
}
