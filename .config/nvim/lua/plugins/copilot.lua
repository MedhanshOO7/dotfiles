return {
    {
        "zbirenbaum/copilot.lua",
        lazy = false,
        opts = {
            panel = {
                enabled = true,
                auto_refresh = false,
                keymap = {
                    jump_prev = "[[",
                    jump_next = "]]",
                    accept = "<CR>",
                    refresh = "gr",
                    open = "<M-CR>",
                },
                layout = {
                    position = "bottom",
                    ratio = 0.4,
                },
            },
            suggestion = {
                enabled = true,
                auto_trigger = true,
                debounce = 75,
                keymap = {
                    accept = false, -- Handled deterministically via <Tab> in cmp.lua
                    accept_word = false,
                    accept_line = false,
                    next = "<M-]>",
                    prev = "<M-[>",
                    dismiss = "<C-]>",
                },
            },
            filetypes = {
                yaml = false,
                markdown = true,
                help = false,
                gitcommit = true,
                gitrebase = true,
                hgcommit = false,
                svn = false,
                cvs = false,
                ["."] = false,
            },
        },
        keys = {
            { "<leader>Cp", "<cmd>Copilot panel<cr>", desc = "Copilot Panel" },
            { "<leader>Cd", "<cmd>CopilotToggle<cr>", desc = "Kill Switch: Disable/Toggle Copilot Engine" },
            { "<leader>cd", "<cmd>CopilotToggle<cr>", desc = "Kill Switch: Disable/Toggle Copilot Engine" },
            { "<leader>Cx", "<cmd>CopilotToggle<cr>", desc = "Kill Switch: Disable/Toggle Copilot Engine" },
            { "<leader>ct", "<cmd>CopilotToggle<cr>", desc = "Kill Switch: Disable/Toggle Copilot Engine" },
            { "<leader>Cs", "<cmd>Copilot status<cr>", desc = "Copilot Status" },
        },
        config = function(_, opts)
            require("copilot").setup(opts)

            local function toggle_copilot()
                local client = require("copilot.client")
                if client.is_disabled() then
                    vim.cmd("Copilot enable")
                    vim.notify("Copilot Engine ENABLED ⚡", vim.log.levels.INFO, { title = "Copilot" })
                else
                    vim.cmd("Copilot disable")
                    vim.notify("Copilot Engine DISABLED 🚫", vim.log.levels.WARN, { title = "Copilot" })
                end
            end

            vim.api.nvim_create_user_command("CopilotToggle", toggle_copilot, { desc = "Toggle Copilot Engine (Kill Switch)" })

            -- Kill Switch: Disable Copilot by default for now
            vim.cmd("Copilot disable")
        end,
    },
    {
        "zbirenbaum/copilot-cmp",
        enabled = false, -- Disabled so Copilot acts strictly as inline ghost text without cluttering LSP completion popup
    },
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        dependencies = {
            { "zbirenbaum/copilot.lua" },
            { "nvim-lua/plenary.nvim" },
        },
        opts = {
            show_folds = false,
            auto_insert_mode = true,
            window = {
                layout = "vertical",
                width = 0.35,
            },
        },
        keys = {
            { "<leader>Cc", "<cmd>CopilotChatToggle<cr>", desc = "Toggle Copilot Chat Window" },
            {
                "<leader>Cq",
                function()
                    local input = vim.fn.input("Quick Chat: ")
                    if input ~= "" then
                        require("CopilotChat").ask(input)
                    end
                end,
                desc = "Quick Chat",
            },
            { "<leader>Ce", "<cmd>CopilotChatExplain<cr>", mode = { "n", "v" }, desc = "Copilot Explain Code" },
            { "<leader>Cf", "<cmd>CopilotChatFix<cr>", mode = { "n", "v" }, desc = "Copilot Fix Bug" },
            { "<leader>CD", "<cmd>CopilotChatDocs<cr>", mode = { "n", "v" }, desc = "Copilot Write Documentation" },
            { "<leader>Ct", "<cmd>CopilotChatTests<cr>", mode = { "n", "v" }, desc = "Copilot Generate Tests" },
            { "<leader>Cg", "<cmd>CopilotChatCommit<cr>", desc = "Copilot Generate Commit Message" },
        },
    },
}
