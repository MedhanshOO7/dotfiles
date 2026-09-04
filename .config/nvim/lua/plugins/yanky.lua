return {
    "gbprod/yanky.nvim",
    event = "VeryLazy",
    opts = {
        ring = {
            history_length = 100,
            storage = "shada",
            sync_with_numbered_registers = true,
            cancel_event = "update",
        },
        system_clipboard = {
            sync_with_ring = true,
        },
        highlight = {
            on_put = true,
            on_yank = true,
            timer = 200,
        },
        preserve_cursor_position = {
            enabled = true,
        },
    },
    keys = {
        -- Core Yank / Put with Yanky ring & clipboard integration
        { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank text" },
        { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put text after cursor" },
        { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put text before cursor" },
        { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put text after cursor (leave cursor after)" },
        { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put text before cursor (leave cursor after)" },

        -- Yank history cycling (after put)
        { "<M-p>", "<Plug>(YankyCycleBackward)", desc = "Cycle backward through yank history" },
        { "<M-n>", "<Plug>(YankyCycleForward)", desc = "Cycle forward through yank history" },
        { "[y", "<Plug>(YankyCycleBackward)", desc = "Cycle backward through yank history" },
        { "]y", "<Plug>(YankyCycleForward)", desc = "Cycle forward through yank history" },

        -- Leader shortcuts
        { "<leader>yy", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank text (to Yanky)" },
        { "<leader>yp", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put yanked text after cursor" },
        { "<leader>yP", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put yanked text before cursor" },

        -- Picker integration
        {
            "<leader>fy",
            function()
                local snacks_ok, snacks = pcall(require, "snacks")
                if snacks_ok and snacks.picker and snacks.picker.yanky then
                    snacks.picker.yanky()
                else
                    local ok, _ = pcall(vim.cmd, "YankyRingHistory")
                    if not ok then
                        vim.cmd("registers")
                    end
                end
            end,
            desc = "Find: Yank history / Registers",
        },
    },
}
