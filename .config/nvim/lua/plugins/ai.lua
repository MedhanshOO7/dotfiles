return {
    -- Inline Autocomplete (GitHub Copilot alternative)
    {
        "supermaven-inc/supermaven-nvim",
        event = "InsertEnter",
        keys = {
            { "<M-a>", "<cmd>SupermavenToggle<cr>", desc = "Toggle AI Autocomplete (Supermaven)" },
        },
        cmd = {
            "SupermavenUseFree",
            "SupermavenUsePro",
            "SupermavenToggle",
            "SupermavenLogout",
            "SupermavenStatus",
        },
        config = function()
            require("supermaven-nvim").setup({
                disable_inline_completion = true, -- Completely OFF by default!
                disable_keymaps = false,
                keymaps = {
                    accept_suggestion = "<Tab>",
                    clear_suggestion = "<C-]>",
                    accept_word = "<C-j>",
                },
            })
            
            -- Provide a helpful notify on toggle since Supermaven is silent by default
            -- Mutual exclusion: toggling Supermaven ON disables Copilot and vice versa
            local sm_api_ok, sm_api = pcall(require, "supermaven-nvim.api")
            if sm_api_ok then
                vim.api.nvim_create_user_command("SupermavenToggle", function()
                    if sm_api.is_running() then
                        sm_api.stop()
                        vim.notify("Supermaven OFF · Copilot remains active", vim.log.levels.INFO, { title = "AI Autocomplete" })
                    else
                        -- Disable Copilot before enabling Supermaven to avoid dual ghost-text
                        pcall(function() vim.cmd("Copilot disable") end)
                        sm_api.start()
                        vim.notify("Supermaven ON · Copilot disabled", vim.log.levels.INFO, { title = "AI Autocomplete" })
                    end
                end, {})
            end
        end,
    },
    
    -- Chat / Inline Generator (Cursor alternative)
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
        keys = {
            { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "Toggle AI Chat" },
            { "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI Actions" },
        },
        opts = {
            strategies = {
                chat = { adapter = "anthropic" },
                inline = { adapter = "anthropic" },
            },
            opts = {
                log_level = "ERROR",
            },
        },
    }
}
