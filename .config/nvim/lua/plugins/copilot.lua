return {
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
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
                debounce = 50,
                keymap = {
                    accept = false, -- Handled with top priority via <Tab> in cmp.lua
                    accept_word = "<M-w>",
                    accept_line = "<M-l>",
                    next = "<M-]>",
                    prev = "<M-[>",
                    dismiss = "<C-]>",
                },
            },
            filetypes = {
                ["*"] = true,
                yaml = false,
                markdown = true,
                help = false,
                gitcommit = true,
                gitrebase = true,
                hgcommit = false,
                svn = false,
                cvs = false,
                ["."] = false,
                TelescopePrompt = false,
                snacks_picker_input = false,
                ["dap-repl"] = false,
            },
            copilot_node_command = "node",
            server_opts_overrides = {},
        },
        keys = {
            { "<leader>Cp", "<cmd>Copilot panel<cr>", desc = "Copilot: Open Panel" },
            { "<leader>Cs", "<cmd>Copilot status<cr>", desc = "Copilot: Status" },
            { "<leader>Cx", "<cmd>CopilotToggle<cr>", desc = "Copilot: Toggle Engine" },
            { "<leader>Ca", "<cmd>Copilot auth<cr>", desc = "Copilot: Authenticate" },
            {
                "<M-\\>",
                function()
                    require("copilot.suggestion").next()
                end,
                mode = "i",
                desc = "Copilot: Next Suggestion",
            },
            {
                "<M-w>",
                function()
                    require("copilot.suggestion").accept_word()
                end,
                mode = "i",
                desc = "Copilot: Accept Word",
            },
            {
                "<M-l>",
                function()
                    require("copilot.suggestion").accept_line()
                end,
                mode = "i",
                desc = "Copilot: Accept Line",
            },
        },
        config = function(_, opts)
            require("copilot").setup(opts)

            local function toggle_copilot()
                local client = require("copilot.client")
                if client.is_disabled() then
                    vim.cmd("Copilot enable")
                    vim.notify("Copilot Engine ENABLED 󱐌", vim.log.levels.INFO, { title = "Copilot" })
                else
                    vim.cmd("Copilot disable")
                    vim.notify("Copilot Engine DISABLED 󰂭", vim.log.levels.WARN, { title = "Copilot" })
                end
            end

            vim.api.nvim_create_user_command("CopilotToggle", toggle_copilot, {
                desc = "Toggle Copilot Engine (Enable/Disable)",
            })

            vim.api.nvim_create_user_command("CopilotAuth", function()
                vim.cmd("Copilot auth")
            end, {
                desc = "Authenticate GitHub Copilot",
            })

            -- Large file protection to prevent performance degradation
            vim.api.nvim_create_autocmd("BufReadPre", {
                group = vim.api.nvim_create_augroup("CopilotLargeFileProtection", { clear = true }),
                callback = function(args)
                    local max_size = 100 * 1024 -- 100 KB
                    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
                    if ok and stats and stats.size > max_size then
                        vim.b[args.buf].copilot_suggestion_auto_trigger = false
                        vim.b[args.buf].copilot_enabled = false
                    end
                end,
            })
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
            "CopilotChatReview",
            "CopilotChatOptimize",
            "CopilotChatDocs",
            "CopilotChatTests",
            "CopilotChatCommit",
            "CopilotChatNotes",
            "CopilotChatAlgorithm",
            "CopilotChatSQL",
            "CopilotChatReset",
            "CopilotChatModels",
        },
        dependencies = {
            { "zbirenbaum/copilot.lua" },
            { "nvim-lua/plenary.nvim" },
        },
        opts = {
            model = "auto",
            system_prompt = [[
You are an expert senior software engineer, system architect, and dedicated computer science mentor working inside Neovim.

CORE BEHAVIOR & MENTORSHIP:
- Act as a senior engineer and mentor: guide toward fundamental understanding, engineering rigor, and best practices.
- Give direct answers first: provide the solution immediately without fluff or boilerplate introductions.
- Avoid filler words: no generic preambles ("Certainly!", "Sure, I can help with that", "As an AI...").
- Explain reasoning when useful: provide concise, technical rationale for non-obvious architecture or implementation decisions.
- Do not blindly agree with the user: critically evaluate user proposals and point out flaws, anti-patterns, or misconceptions.
- Point out incorrect approaches: clearly explain why a flawed method fails (edge cases, race conditions, memory leaks, performance traps).
- Ask for missing context instead of assuming: if programming language, environment, constraints, or schemas are ambiguous, ask targeted clarifying questions.

PROGRAMMING & ENGINEERING PRACTICES:
- Write clean, idiomatic, and modern code adhering strictly to language conventions and safety standards.
- Prioritize maintainability, readability, simplicity, and modular design over clever one-liners.
- Design for testability and security: emphasize input validation, boundary checks, concurrency safety, and sanitized queries.
- Optimize for performance and resource utilization (time complexity, cache locality, memory overhead, I/O efficiency).
- Follow systematic debugging: identify root cause, explain failure mechanism, and deliver the minimal correct fix.

COMPUTER SCIENCE FUNDAMENTALS:
- Break down complex concepts from first principles (OS internals, virtual memory, concurrency, memory models, network protocols, compilation passes).
- For Algorithms and Data Structures: explain intuition first, formal approach, step-by-step invariants, mathematical time/space complexity (Big-O), and boundary edge cases.
- For Databases and SQL: prioritize explicit JOINs, explain logical query execution order, index utilization, locking behavior, and schema normalization tradeoffs.
- For Systems and Linux: explain process lifecycles, syscall mechanics, file descriptors, signals, and security permissions.
]],
            prompts = {
                Explain = {
                    prompt = [[
Explain the selected code or concept like a senior software engineer teaching a developer.

Structure your response:
1. **Purpose**: What this code achieves and why it exists.
2. **Execution Flow**: Step-by-step breakdown of the execution logic and state transitions.
3. **Important Details**: Key language mechanisms, APIs, concurrency models, or design patterns used.
4. **Practical Example**: A minimal, concrete example illustrating its behavior.
5. **Common Pitfalls**: Frequent mistakes, edge-case bugs, or anti-patterns developers encounter with this.

Focus on fundamental mechanics rather than simply rephrasing syntax.
]],
                },
                Fix = {
                    prompt = [[
Debug the selected code systematically using a senior engineering approach.

Process:
1. **Root Cause Analysis**: Identify the precise logical, runtime, memory, or concurrency bug.
2. **Why It Happens**: Explain the underlying mechanism triggering the failure.
3. **Minimal Correct Fix**: Provide the cleanest, smallest targeted code change that resolves the bug.
4. **Verification**: Explain why this fix resolves the issue without introducing regressions or side effects.
5. **Edge Cases**: Highlight any boundary conditions handled or needing further tests.
]],
                },
                Review = {
                    prompt = [[
Perform a rigorous code review of the selected code as a senior software engineer.

Evaluate across these dimensions:
1. **Correctness & Logic**: Bugs, off-by-one errors, unhandled states, undefined behavior, or race conditions.
2. **Edge Cases**: Empty inputs, null/nil values, overflow, network/IO failures, boundary boundaries.
3. **Performance & Complexity**: Time and space complexity bottlenecks, unnecessary allocations, redundant work.
4. **Readability & Maintainability**: Naming conventions, modularity, idiomatic patterns, cognitive complexity.
5. **Security & Robustness**: Input validation, resource leaks, memory safety, injection vectors.

Format:
- List high-priority issues first with severity, concrete explanation, and precise code recommendations.
]],
                },
                Optimize = {
                    prompt = [[
Optimize the selected code while strictly preserving its existing external behavior and contract.

Structure:
1. **Bottlenecks Identified**: Inefficiencies in algorithmic complexity, memory allocations, I/O, or cache behavior.
2. **Optimized Implementation**: Clean, production-ready, refactored code.
3. **Engineering Trade-offs**: Explain complexity reduction (e.g. O(N^2) -> O(N log N)), benchmark considerations, and any trade-offs made.
]],
                },
                Notes = {
                    prompt = [[
Convert the selected code or technical concept into concise, high-yield hierarchical study notes.

Guidelines:
- Organize using clean Markdown bullet hierarchies.
- Highlight core terms, invariants, and concepts in **bold**.
- Wrap code, types, syscalls, APIs, and complexity in `backticks`.
- Structure into:
  - **Core Concepts & Theory**
  - **Key Mechanics & Implementation Rules**
  - **Complexity & Trade-offs**
  - **Essential Revision Highlights & Pitfalls**
- Strip away fluff while preserving technical precision.
]],
                },
                Tests = {
                    prompt = [[
Generate a comprehensive, production-grade test suite for the selected code.

Include:
1. **Happy Path / Normal Cases**: Standard execution flows and expected outcomes.
2. **Boundary & Edge Cases**: Empty collections, zero values, max/min integer limits, single-element structures.
3. **Invalid Inputs & Error Conditions**: Ill-formed data, null/nil handling, expected exceptions/errors.
4. **State / Concurrency Scenarios**: State transition invariants and race conditions if applicable.

Follow the testing framework and idiomatic conventions of the active language.
]],
                },
                Docs = {
                    prompt = [[
Generate concise, professional developer documentation for the selected code.

Include:
1. **Summary / Purpose**: Clear high-level description of functionality.
2. **Parameters & Types**: Document each parameter, type, and precondition.
3. **Return Values**: Expected outputs, return types, and possible errors/exceptions.
4. **Usage Example**: Minimal, practical, idiomatic code snippet demonstrating usage.
5. **Invariants & Important Behavior**: Concurrency guarantees, performance characteristics, and limitations.

Format as standard docstrings/comments matching the active programming language (e.g., JSDoc, Rustdoc, Doxygen, Google docstring).
]],
                },
                Commit = {
                    prompt = [[
Generate a professional Git commit message based on the selected changes or diff.

Rules:
- Strictly follow Conventional Commits specification (`feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `chore`).
- Structure:
  `<type>(<scope>): <imperative summary under 50 characters>`
- Provide a concise body explaining:
  - What changed
  - Why the change was made
  - Any breaking changes or issue references
]],
                },
                Algorithm = {
                    prompt = [[
Provide an in-depth computer science analysis of this algorithm or problem solution.

Cover:
1. **Intuition & Mental Model**: The core insight that makes this approach work.
2. **Algorithmic Strategy**: Step-by-step breakdown (e.g. Divide & Conquer, Dynamic Programming, Two Pointers, Greedy).
3. **Proof / Invariant of Correctness**: Why this guarantees the correct result across all states.
4. **Complexity Analysis**:
   - **Time Complexity**: Best, average, and worst case with Big-O derivation.
   - **Space Complexity**: Auxiliary memory and call stack overhead.
5. **Critical Edge Cases**: Tricky boundary conditions (empty, duplicate, inverted, cyclic inputs).
]],
                },
                SQL = {
                    prompt = [[
Analyze this SQL query and database operation in depth.

Cover:
1. **Query Purpose & Behavior**: High-level intent and expected result set.
2. **Logical Execution Flow**: Order of operations (`FROM` -> `JOIN` -> `WHERE` -> `GROUP BY` -> `HAVING` -> `SELECT` -> `ORDER BY` -> `LIMIT`).
3. **JOIN & Aggregation Analysis**: Relational correctness, cardinality impact, and null handling.
4. **Performance & Indexing**: Index opportunities (covering indexes, composite keys), sequential scans, and SARGable predicates.
5. **Optimized Query**: An improved, idiomatic SQL query if anti-patterns or inefficiencies exist.
]],
                },
            },
            tools = "copilot",
            trusted_tools = { "file", "glob", "grep", "gitdiff", "buffer" },
            sticky = { "@copilot", "#buffer:listed" },
            show_folds = false,
            auto_insert_mode = true,
            insert_at_end = true,
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
                    if not ok then
                        return
                    end
                    local wins = vim.api.nvim_list_wins()
                    if #wins == 1 and (vim.bo.filetype == "copilot-chat" or vim.bo.filetype == "copilot-input") then
                        vim.cmd("enew")
                    end
                    pcall(function()
                        chat.toggle()
                    end)
                end,
                desc = "CopilotChat: Toggle Window",
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
                desc = "CopilotChat: Quick Prompt",
            },
            { "<leader>Ce", "<cmd>CopilotChatExplain<cr>", mode = { "n", "v" }, desc = "CopilotChat: Explain" },
            { "<leader>Cf", "<cmd>CopilotChatFix<cr>", mode = { "n", "v" }, desc = "CopilotChat: Fix" },
            { "<leader>Cr", "<cmd>CopilotChatReview<cr>", mode = { "n", "v" }, desc = "CopilotChat: Review" },
            { "<leader>Co", "<cmd>CopilotChatOptimize<cr>", mode = { "n", "v" }, desc = "CopilotChat: Optimize" },
            { "<leader>Cn", "<cmd>CopilotChatNotes<cr>", mode = { "n", "v" }, desc = "CopilotChat: Notes" },
            { "<leader>Ct", "<cmd>CopilotChatTests<cr>", mode = { "n", "v" }, desc = "CopilotChat: Tests" },
            { "<leader>CD", "<cmd>CopilotChatDocs<cr>", mode = { "n", "v" }, desc = "CopilotChat: Docs" },
            { "<leader>Cg", "<cmd>CopilotChatCommit<cr>", desc = "CopilotChat: Commit Message" },
            { "<leader>CR", "<cmd>CopilotChatReset<cr>", desc = "CopilotChat: Reset History" },
            { "<leader>CM", "<cmd>CopilotChatModels<cr>", desc = "CopilotChat: Select Model" },
        },
    },
}
