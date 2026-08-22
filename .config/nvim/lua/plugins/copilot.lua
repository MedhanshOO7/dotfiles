return {
    {
        "zbirenbaum/copilot.lua",
        event = { "BufReadPre", "BufNewFile" },
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
                debounce = 40,
                keymap = {
                    accept = false, -- Handled with top priority via <Tab> in cmp.lua
                    accept_word = "<M-w>", -- Press Alt+W to accept next word
                    accept_line = "<M-l>", -- Press Alt+L to accept next sentence/line
                    next = "<M-]>",
                    prev = "<M-[>",
                    dismiss = "<C-]>",
                },
            },
            filetypes = {
                markdown = true,
                text = true,
                gitcommit = true,
                gitrebase = true,
                quarto = true,
                rmd = true,
                asciidoc = true,
                typst = true,
                tex = true,
                plaintex = true,
                yaml = false,
                help = false,
                hgcommit = false,
                svn = false,
                cvs = false,
                ["."] = false,
            },
        },
        keys = {
            { "<leader>Cp", "<cmd>Copilot panel<cr>", desc = "Copilot Panel" },
            { "<leader>Cd", "<cmd>CopilotToggle<cr>", desc = "Kill Switch: Disable/Toggle Copilot Engine" },
            { "<leader>Cx", "<cmd>CopilotToggle<cr>", desc = "Kill Switch: Disable/Toggle Copilot Engine" },
            { "<leader>Cs", "<cmd>Copilot status<cr>", desc = "Copilot Status" },
            { "<M-\\>", function() require("copilot.suggestion").next() end, mode = "i", desc = "Trigger Copilot Suggestion" },
            { "<M-w>", function() require("copilot.suggestion").accept_word() end, mode = "i", desc = "Accept Copilot Word (Alt+W)" },
            { "<M-Right>", function() require("copilot.suggestion").accept_word() end, mode = "i", desc = "Accept Copilot Word (Alt+Right)" },
            { "<M-l>", function() require("copilot.suggestion").accept_line() end, mode = "i", desc = "Accept Copilot Line (Alt+L)" },
        },
        config = function(_, opts)
            require("copilot").setup(opts)

            local function toggle_copilot()
                local client = require("copilot.client")
                if client.is_disabled() then
                    vim.cmd("Copilot enable")
                    vim.notify("Copilot Engine ENABLED 󱐌 ", vim.log.levels.INFO, { title = "Copilot" })
                else
                    vim.cmd("Copilot disable")
                    vim.notify("Copilot Engine DISABLED 󰂭 ", vim.log.levels.WARN, { title = "Copilot" })
                end
            end

            vim.api.nvim_create_user_command("CopilotToggle", toggle_copilot, { desc = "Toggle Copilot Engine (Kill Switch)" })
        end,
    },
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        branch = "main",
        build = "make tiktoken",
        cmd = {
            "CopilotChat",
            "CopilotChatToggle",
            "CopilotChatOpen",
            "CopilotChatClose",
            "CopilotChatExplain",
            "CopilotChatFix",
            "CopilotChatDocs",
            "CopilotChatTests",
            "CopilotChatCommit",
        },
        dependencies = {
            { "zbirenbaum/copilot.lua" },
            { "nvim-lua/plenary.nvim" },
        },
        opts = {
            model = "auto", -- Automatically match GitHub Student Copilot plan model
            system_prompt = [[
You are an expert technical note-taking and programming assistant.
Your output must strictly follow these formatting and stylistic rules:

1. CONCISENESS & GRAMMAR:
   - Be ultra-concise. Eliminate filler words and conversational pleasantries (never say "Sure!", "Here is", "The X operator is used to...").
   - Use simple, direct, active-voice grammar in the present tense.
   - Keep individual bullet points short (under 12-15 words).

2. HIERARCHICAL BULLET STRUCTURE:
   - Break long, compound, or multi-part concepts into nested sub-bullets instead of a single long sentence.
   - Use bold markdown (`**term**`) selectively for key concepts, conditions, return values, or keywords.
   - Use backticks (`code`) for commands, SQL keywords, operators, parameters, and variable names.

3. STRUCTURE PATTERNS:
   - Topic/Keyword
       - Core action or definition.
       - Key conditions or return behavior.
   - Nested breakdowns for complex statements:
       - Returns:
           - **All records** from left table.
           - **Matched records** from right table.

4. CODE QUALITY:
   - When writing code, provide minimal, clean, modern implementations with brief inline comments.
   - Never output large unformatted walls of text.
]],
            prompts = {
                Notes = {
                    prompt = "Reformat and summarize the provided selection or context into ultra-concise, hierarchical, easy-to-read study bullet points with bold highlights and nested clauses.",
                },
                Summarize = {
                    prompt = "Summarize the key takeaways of this text or code into bite-sized hierarchical bullets. Eliminate all fluff.",
                },
            },
            tools = "copilot", -- Enable workspace search/read tools (glob, grep, file, buffer, gitdiff)
            trusted_tools = { "file", "glob", "grep", "gitdiff", "buffer" }, -- Auto-approve read-only workspace tools
            sticky = { "@copilot", "#buffer:listed" }, -- Automatically provide @copilot tools and open buffers context
            show_folds = false,
            auto_insert_mode = true,
            insert_at_end = true, -- Auto-place cursor at the bottom input position
            window = {
                layout = "vertical",
                width = 0.40,
                border = "rounded",
                title = " 󰚩 Copilot Chat ",
            },
            headers = {
                user = "󰏏 User: ",
                copilot = "󰚩 Copilot: ",
            },
            mappings = {
                complete = {
                    detail = "Use @file, @buffer, or @git for context",
                    insert = "<Tab>",
                },
                close = {
                    normal = "q",
                    insert = "<C-c>",
                },
                reset = {
                    normal = "<C-l>",
                    insert = "<C-l>",
                },
                accept_diff = {
                    normal = "<C-y>",
                    insert = "<C-y>",
                },
                show_diff = {
                    normal = "gd",
                },
            },
        },
        keys = {
            {
                "<leader>Cc",
                function()
                    local ok, chat = pcall(require, "CopilotChat")
                    if not ok then return end
                    local wins = vim.api.nvim_list_wins()
                    if #wins == 1 and (vim.bo.filetype == "copilot-chat" or vim.bo.filetype == "copilot-input") then
                        vim.cmd("enew")
                    end
                    pcall(function() chat.toggle() end)
                end,
                desc = "Toggle Copilot Chat Window",
            },
            {
                "<leader>co",
                function()
                    local ok, chat = pcall(require, "CopilotChat")
                    if not ok then return end
                    local wins = vim.api.nvim_list_wins()
                    if #wins == 1 and (vim.bo.filetype == "copilot-chat" or vim.bo.filetype == "copilot-input") then
                        vim.cmd("enew")
                    end
                    pcall(function() chat.toggle() end)
                end,
                desc = "Toggle Copilot Chat Window",
            },
            {
                "<leader>cp",
                function()
                    vim.ui.input({ prompt = " 󰚩 Ask Copilot: " }, function(input)
                        if input and input ~= "" then
                            require("CopilotChat").ask(input)
                        end
                    end)
                end,
                desc = "Floating Prompt Input Box",
            },
            {
                "<leader>Cq",
                function()
                    vim.ui.input({ prompt = " 󰚩 Ask Copilot: " }, function(input)
                        if input and input ~= "" then
                            require("CopilotChat").ask(input)
                        end
                    end)
                end,
                desc = "Quick Prompt Box",
            },
            { "<leader>Ce", "<cmd>CopilotChatExplain<cr>", mode = { "n", "v" }, desc = "Copilot Explain Code" },
            { "<leader>Cf", "<cmd>CopilotChatFix<cr>", mode = { "n", "v" }, desc = "Copilot Fix Bug" },
            { "<leader>Cn", "<cmd>CopilotChatNotes<cr>", mode = { "n", "v" }, desc = "Copilot Generate Concise Notes" },
            { "<leader>CD", "<cmd>CopilotChatDocs<cr>", mode = { "n", "v" }, desc = "Copilot Write Documentation" },
            { "<leader>Ct", "<cmd>CopilotChatTests<cr>", mode = { "n", "v" }, desc = "Copilot Generate Tests" },
            { "<leader>Cg", "<cmd>CopilotChatCommit<cr>", desc = "Copilot Generate Commit Message" },
            { "<leader>CR", "<cmd>CopilotChatReset<cr>", desc = "Reset Chat History" },
            { "<leader>CM", "<cmd>CopilotChatModels<cr>", desc = "Switch Copilot Model (GPT-4o / Claude)" },
        },
    },
}
