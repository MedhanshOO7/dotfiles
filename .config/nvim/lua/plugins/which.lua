return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
        delay = 100,
        preset = "modern",
        win = {
            border = "rounded",
            padding = { 1, 2 },
        },
        layout = {
            height = { min = 4, max = 25 },
        },
    },
    config = function(_, opts)
        local wk = require("which-key")

        wk.setup(opts)
        wk.add({
            -- Group headers with icons & colors
            { "<leader>B", group = "Build and CMake", icon = { icon = "󰜎", color = "blue" } },
            { "<leader>b", group = "Buffers", icon = { icon = "󰈔", color = "cyan" } },
            { "<leader>C", group = "Copilot AI", icon = { icon = "󰚩", color = "green" } },
            { "<leader>c", group = "Code", icon = { icon = "󰅩", color = "orange" } },
            { "<leader>D", group = "Database (Dadbod)", icon = { icon = "󰆼", color = "yellow" } },
            { "<leader>d", group = "Debug", icon = { icon = "󰃤", color = "red" } },
            { "<leader>f", group = "Find", icon = { icon = "", color = "blue" } },
            { "<leader>g", group = "Git", icon = { icon = "", color = "purple" } },
            { "<leader>gC", group = "Git Conflicts", icon = { icon = "󰰚", color = "red" } },
            { "<leader>h", group = "Harpoon", icon = { icon = "󰛢", color = "cyan" } },
            { "<leader>hv", group = "Helpview", icon = { icon = "󰋖", color = "blue" } },
            { "<leader>l", group = "LSP", icon = { icon = "", color = "blue" } },
            { "<leader>m", group = "Molten", icon = { icon = "󰘦", color = "yellow" } },
            { "<leader>M", group = "Multicursor", icon = { icon = "󰆿", color = "purple" } },
            { "<leader>n", group = "Notes and writing", icon = { icon = "󰠮", color = "yellow" } },
            { "<leader>N", group = "Embedded / nRF (Zephyr)", icon = { icon = "󰜎", color = "orange" } },
            { "<leader>o", group = "Obsidian", icon = { icon = "󰠮", color = "purple" } },
            { "<leader>p", group = "PlatformIO", icon = { icon = "", color = "orange" } },
            { "<leader>P", group = "Python", icon = { icon = "", color = "yellow" } },
            { "<leader>r", group = "Run Code", icon = { icon = "", color = "green" } },
            { "<leader>R", group = "Report (markdown)", icon = { icon = "󰈙", color = "blue" } },
            { "<leader>s", group = "Search and jump", icon = { icon = "󰉁", color = "azure" } },
            { "<leader>T", group = "Testing (Neotest)", icon = { icon = "󰙨", color = "green" } },
            { "<leader>t", group = "Terminal and tasks", icon = { icon = "", color = "red" } },
            { "<leader>v", group = "Peek (Glance)", icon = { icon = "󰈈", color = "blue" } },
            { "<leader>u", group = "UI and theme", icon = { icon = "󰔎", color = "cyan" } },
            { "<leader>w", group = "Windows and sessions", icon = { icon = "󰖲", color = "blue" } },
            { "<leader>x", group = "Diagnostics and lists", icon = { icon = "󱖫", color = "red" } },
            { "<leader>y", group = "Yanky / Clipboard", icon = { icon = "󰅍", color = "yellow" } },
            { "<leader>z", group = "Zen and folds", icon = { icon = "󰈈", color = "purple" } },

            -- AI
            { "<leader>Ca", desc = "Copilot: Authenticate", icon = { icon = "󰚩", color = "green" } },
            { "<leader>Cd", desc = "Copilot: Disable / Toggle engine", icon = { icon = "󰂭", color = "red" } },
            { "<leader>Cp", desc = "Copilot: Open panel", icon = { icon = "󰚩", color = "green" } },
            { "<leader>Cs", desc = "Copilot: Status", icon = { icon = "󰚩", color = "green" } },

            -- Core Shortcuts
            { "<leader>e", desc = "Toggle file explorer", icon = { icon = "󰉋", color = "yellow" } },
            { "<leader>:", desc = "Command palette", icon = { icon = "", color = "purple" } },
            { "<leader>q", desc = "Quit window", icon = { icon = "󰅖", color = "red" } },

            -- Buffers
            { "<leader>bb", desc = "Pick a buffer by letter", icon = { icon = "󰓩", color = "cyan" } },
            { "<leader>bd", desc = "Close the current buffer", icon = { icon = "󰆴", color = "red" } },
            { "<leader>bn", desc = "Next buffer", icon = { icon = "󰒭", color = "cyan" } },
            { "<leader>bo", desc = "Close all other buffers", icon = { icon = "󰆤", color = "orange" } },
            { "<leader>bp", desc = "Previous buffer", icon = { icon = "󰒮", color = "cyan" } },

            -- Code
            { "<leader>ca", desc = "Code actions", mode = { "n", "v" }, icon = { icon = "󰌵", color = "yellow" } },
            { "<leader>cf", desc = "Format file", icon = { icon = "󰉢", color = "green" } },
            { "<leader>rn", desc = "Rename symbol", icon = { icon = "󰑕", color = "orange" } },

            -- Run Code
            { "<leader>rr", desc = "Run code selection / block", icon = { icon = "", color = "green" } },
            { "<leader>rf", desc = "Run current file", icon = { icon = "", color = "green" } },
            { "<leader>rp", desc = "Run project", icon = { icon = "", color = "green" } },
            { "<leader>rc", desc = "Close runner output", icon = { icon = "", color = "red" } },
            { "<leader>rs", desc = "Send paragraph / selection to REPL", mode = { "n", "x" }, icon = { icon = "", color = "yellow" } },
            { "<leader>rl", desc = "Send line to REPL", icon = { icon = "", color = "yellow" } },
            { "<leader>rC", desc = "Configure REPL target", icon = { icon = "", color = "yellow" } },

            -- Debug
            { "<leader>db", desc = "Toggle breakpoint", icon = { icon = "", color = "red" } },
            { "<leader>dc", desc = "Continue", icon = { icon = "", color = "green" } },
            { "<leader>di", desc = "Step into", icon = { icon = "󰆹", color = "blue" } },
            { "<leader>do", desc = "Step over", icon = { icon = "󰆸", color = "blue" } },
            { "<leader>dO", desc = "Step out", icon = { icon = "󰆷", color = "blue" } },
            { "<leader>dr", desc = "Toggle REPL", icon = { icon = "", color = "yellow" } },

            -- Database (Dadbod)
            { "<leader>Ds", desc = "Select database for buffer", icon = { icon = "󰆼", color = "yellow" } },
            { "<leader>DS", desc = "View table schema & columns", icon = { icon = "󰓫", color = "cyan" } },
            { "<leader>Db", desc = "Toggle Database UI", icon = { icon = "󰆼", color = "yellow" } },
            { "<leader>Df", desc = "Find DB buffer", icon = { icon = "", color = "blue" } },
            { "<leader>Dl", desc = "Last DB query info", icon = { icon = "", color = "orange" } },

            -- Find
            { "<leader>f/", desc = "Search in current buffer", icon = { icon = "", color = "blue" } },
            { "<leader>fb", desc = "Search buffers", icon = { icon = "󰓩", color = "cyan" } },
            { "<leader>fe", desc = "Open file explorer", icon = { icon = "󰉋", color = "yellow" } },
            { "<leader>ff", desc = "Find file", icon = { icon = "󰈔", color = "blue" } },
            { "<leader>fg", desc = "Live grep", icon = { icon = "", color = "green" } },
            { "<leader>fk", desc = "Keymap help", icon = { icon = "", color = "purple" } },
            { "<leader>fp", desc = "Git files", icon = { icon = "", color = "purple" } },
            { "<leader>fr", desc = "Recent files", icon = { icon = "", color = "orange" } },
            { "<leader>fs", desc = "Save file", icon = { icon = "󰆓", color = "green" } },
            { "<leader>fS", desc = "LSP document symbols", icon = { icon = "󰅩", color = "blue" } },
            { "<leader>ft", desc = "Search TODOs", icon = { icon = "", color = "green" } },
            { "<leader>fw", desc = "LSP workspace symbols", icon = { icon = "󰚗", color = "blue" } },
            { "<leader>fy", desc = "Find Registers / Yank history", icon = { icon = "󰅍", color = "yellow" } },

            -- Folds
            { "<leader>zM", desc = "Close all folds" },
            { "<leader>zR", desc = "Open all folds" },
            { "<leader>zv", desc = "Preview fold" },

            -- Git
            { "<leader>gb", desc = "Show git blame line", icon = { icon = "󰊢", color = "purple" } },
            { "<leader>gp", desc = "Preview hunk", icon = { icon = "󰢔", color = "blue" } },
            { "<leader>gd", desc = "Open side-by-side diffview", icon = { icon = "", color = "blue" } },
            { "<leader>gD", desc = "Close diffview", icon = { icon = "", color = "blue" } },
            { "<leader>gg", desc = "Neogit status tab", icon = { icon = "", color = "purple" } },
            { "<leader>gn", desc = "Next hunk", icon = { icon = "󰒭", color = "purple" } },
            { "<leader>gN", desc = "Prev hunk", icon = { icon = "󰒮", color = "purple" } },
            { "<leader>gr", desc = "Reset hunk", icon = { icon = "󰜢", color = "red" } },
            { "<leader>gs", desc = "Stage hunk", icon = { icon = "󰄬", color = "green" } },
            { "<leader>gu", desc = "Undo stage hunk", icon = { icon = "󰕌", color = "yellow" } },

            -- Git Conflicts
            { "<leader>gCo", desc = "Conflict: Choose Ours", icon = { icon = "󰄬", color = "green" } },
            { "<leader>gCt", desc = "Conflict: Choose Theirs", icon = { icon = "󰄬", color = "blue" } },
            { "<leader>gCb", desc = "Conflict: Choose Both", icon = { icon = "󰓩", color = "purple" } },
            { "<leader>gC0", desc = "Conflict: Choose None", icon = { icon = "󰅖", color = "red" } },
            { "<leader>gC]", desc = "Conflict: Next conflict", icon = { icon = "󰒭", color = "orange" } },
            { "<leader>gC[", desc = "Conflict: Prev conflict", icon = { icon = "󰒮", color = "orange" } },
            { "<leader>gCq", desc = "Conflict: Quickfix list", icon = { icon = "", color = "yellow" } },

            -- Harpoon
            { "<leader>ha", desc = "Add to harpoon", icon = { icon = "󰛢", color = "cyan" } },
            { "<leader>hh", desc = "Toggle harpoon menu", icon = { icon = "󰛢", color = "cyan" } },
            { "<leader>h1", desc = "Harpoon file 1" },
            { "<leader>h2", desc = "Harpoon file 2" },
            { "<leader>h3", desc = "Harpoon file 3" },
            { "<leader>h4", desc = "Harpoon file 4" },

            -- LSP
            { "<leader>ld", desc = "Jump to definition", icon = { icon = "󰅩", color = "blue" } },
            { "<leader>lD", desc = "Jump to declaration", icon = { icon = "󰅩", color = "blue" } },
            { "<leader>le", desc = "Explain problem (float)", icon = { icon = "󰅚", color = "red" } },
            { "<leader>li", desc = "Jump to implementation", icon = { icon = "󰅩", color = "blue" } },
            { "<leader>lI", desc = "Toggle inlay hints", icon = { icon = "󰌵", color = "yellow" } },
            { "<leader>lk", desc = "Signature help", icon = { icon = "󰘳", color = "purple" } },
            { "<leader>lo", desc = "Document symbols", icon = { icon = "󰅩", color = "blue" } },
            { "<leader>lR", desc = "LSP Restart", icon = { icon = "󰑕", color = "orange" } },
            { "<leader>ls", desc = "Workspace symbols", icon = { icon = "󰚗", color = "blue" } },
            { "<leader>lt", desc = "Type definition", icon = { icon = "󰅩", color = "blue" } },

            -- Molten
            { "<leader>md", desc = "Delete cell" },
            { "<leader>me", desc = "Evaluate operator" },
            { "<leader>mh", desc = "Hide output" },
            { "<leader>mi", desc = "Initialize Molten" },
            { "<leader>ml", desc = "Evaluate line" },
            { "<leader>mo", desc = "Open in browser" },
            { "<leader>mr", desc = "Restart kernel" },
            { "<leader>ms", desc = "Show output" },
            { "<leader>mv", desc = "Evaluate visual selection", mode = "v" },

            -- Markdown Tables

            -- Multicursor
            { "<leader>Ma", desc = "Add next match", icon = { icon = "󰆿", color = "purple" } },
            { "<leader>MA", desc = "Add all matches", icon = { icon = "󰆿", color = "purple" } },
            { "<leader>Mj", desc = "Add cursor below", mode = { "n", "x" } },
            { "<leader>MJ", desc = "Skip cursor below", mode = { "n", "x" } },
            { "<leader>Mk", desc = "Add cursor above", mode = { "n", "x" } },
            { "<leader>MK", desc = "Skip cursor above", mode = { "n", "x" } },
            { "<leader>Ms", desc = "Skip next match" },
            { "<leader>Mt", desc = "Toggle cursor" },
            { "<leader>Mv", desc = "Restore cursors" },
            { "<leader>Mx", desc = "Delete cursor" },

            -- Notes and writing
            { "<leader>nn", desc = "Aerial navigation", icon = { icon = "󰠮", color = "yellow" } },
            { "<leader>no", desc = "Aerial toggle", icon = { icon = "󰠮", color = "yellow" } },
            { "<leader>np", desc = "Markdown preview", icon = { icon = "󰍔", color = "blue" } },
            { "<leader>nP", desc = "Professional mode", icon = { icon = "󰠮", color = "purple" } },
            { "<leader>nr", desc = "Recalculate autolist", icon = { icon = "󰑕", color = "orange" } },
            { "<leader>ns", desc = "Strikeout text", mode = { "n", "v" } },
            { "<leader>nt", desc = "Twilight", icon = { icon = "󰈈", color = "purple" } },

            -- Obsidian
            { "<leader>ob", desc = "Show backlinks", icon = { icon = "󰌹", color = "purple" } },
            { "<leader>of", desc = "Find notes", icon = { icon = "", color = "purple" } },
            { "<leader>oi", desc = "Paste image", icon = { icon = "󰋩", color = "purple" } },
            { "<leader>ol", desc = "Show links", mode = { "n", "v" } },
            { "<leader>on", desc = "New note", mode = { "n", "v" }, icon = { icon = "󰈔", color = "purple" } },
            { "<leader>os", desc = "Search notes", icon = { icon = "", color = "purple" } },
            { "<leader>ot", desc = "Today's daily note", icon = { icon = "󰸗", color = "purple" } },
            { "<leader>oy", desc = "Yesterday's daily note", icon = { icon = "󰸗", color = "purple" } },

            -- Python
            { "<leader>Pv", desc = "Select VirtualEnv", icon = { icon = "", color = "yellow" } },
            { "<leader>Pm", desc = "Make / Create VirtualEnv", icon = { icon = "", color = "green" } },
            { "<leader>Pi", desc = "Install package", icon = { icon = "󰏖", color = "cyan" } },
            { "<leader>PR", desc = "Install requirements.txt", icon = { icon = "󰈔", color = "blue" } },
            { "<leader>Pr", desc = "Run current file", icon = { icon = "", color = "green" } },

            -- Testing (Neotest)
            { "<leader>Tr", desc = "Run nearest test", icon = { icon = "", color = "green" } },
            { "<leader>Tf", desc = "Run test file", icon = { icon = "", color = "green" } },
            { "<leader>Ts", desc = "Toggle test summary", icon = { icon = "", color = "yellow" } },
            { "<leader>To", desc = "Open test output", icon = { icon = "󰅩", color = "blue" } },
            { "<leader>Tp", desc = "Toggle test output panel", icon = { icon = "", color = "red" } },
            { "<leader>Td", desc = "Debug nearest test", icon = { icon = "󰃤", color = "red" } },
            { "<leader>TS", desc = "Stop running tests", icon = { icon = "󰅖", color = "red" } },

            -- Search and jump
            { "<leader>sr", desc = "Search and replace", mode = { "n", "x" }, icon = { icon = "󰛔", color = "yellow" } },
            { "<leader>sB", desc = "Search in current file", icon = { icon = "", color = "blue" } },
            { "<leader>sj", desc = "Jump (flash)", icon = { icon = "󰉁", color = "azure" } },
            { "<leader>ss", desc = "Treesitter jump (flash)", icon = { icon = "󰉁", color = "azure" } },
            { "<leader>sw", desc = "Search word under cursor", icon = { icon = "", color = "blue" } },

            -- Terminal and tasks
            { "<leader>ta", desc = "Task action chooser", icon = { icon = "", color = "red" } },
            { "<leader>tf", desc = "Project shell", icon = { icon = "", color = "red" } },
            { "<leader>tg", desc = "Terminal picker", icon = { icon = "", color = "red" } },
            { "<leader>th", desc = "Horizontal shell", icon = { icon = "", color = "red" } },
            { "<leader>to", desc = "Toggle terminal", icon = { icon = "", color = "red" } },
            { "<leader>tr", desc = "Run task", icon = { icon = "", color = "green" } },
            { "<leader>tt", desc = "Toggle task list", icon = { icon = "", color = "yellow" } },
            { "<leader>tv", desc = "Vertical shell", icon = { icon = "", color = "red" } },

            -- UI and theme
            { "<leader>ua", desc = "Toggle auto-save (global)", icon = { icon = "󰔎", color = "cyan" } },
            { "<leader>ub", desc = "Toggle auto-save (buffer)", icon = { icon = "󰔎", color = "cyan" } },
            { "<leader>uC", desc = "Toggle Copilot AI engine", icon = { icon = "󰚩", color = "green" } },
            { "<leader>uc", desc = "Toggle conceal level", icon = { icon = "󰔎", color = "cyan" } },
            { "<leader>ud", desc = "Toggle LSP diagnostics", icon = { icon = "󱖫", color = "red" } },
            { "<leader>uf", desc = "Toggle auto-format", icon = { icon = "󰉢", color = "green" } },
            { "<leader>uh", desc = "Toggle LSP inlay hints", icon = { icon = "󰌵", color = "yellow" } },
            { "<leader>ui", desc = "Toggle image hover previews", icon = { icon = "󰋩", color = "purple" } },
            { "<leader>ul", desc = "Toggle relative line numbers", icon = { icon = "󰔎", color = "cyan" } },
            { "<leader>um", desc = "Toggle buffer modifiable", icon = { icon = "󰔎", color = "cyan" } },
            { "<leader>un", desc = "Next theme", icon = { icon = "󰔎", color = "cyan" } },
            { "<leader>up", desc = "Prev theme", icon = { icon = "󰔎", color = "cyan" } },
            { "<leader>us", desc = "Toggle spell check", icon = { icon = "󰓆", color = "green" } },
            { "<leader>ut", desc = "Theme picker", icon = { icon = "󰔎", color = "cyan" } },
            { "<leader>uu", desc = "Update Neovim config (Git Pull & Sync)", icon = { icon = "󰑕", color = "green" } },
            { "<leader>uw", desc = "Toggle text wrap", icon = { icon = "󰔎", color = "cyan" } },
            { "<leader>ux", desc = "Toggle Treesitter sticky header", icon = { icon = "󰔎", color = "cyan" } },
            { "<leader>uy", desc = "Toggle transparency", icon = { icon = "󰔎", color = "cyan" } },
            { "<leader>uS", desc = "Statusline & Header style picker", icon = { icon = "󰔎", color = "cyan" } },
            { "<leader>uT", desc = "Terminal & Runner style picker", icon = { icon = "󰹚", color = "cyan" } },

            -- Windows and sessions
            { "<leader>wc", desc = "Close window", icon = { icon = "󰅖", color = "red" } },
            { "<leader>wh", desc = "Split horizontal", icon = { icon = "󰤼", color = "blue" } },
            { "<leader>wv", desc = "Split vertical", icon = { icon = "󰤻", color = "blue" } },
            { "<leader>wo", desc = "Only window", icon = { icon = "󰖲", color = "blue" } },
            { "<leader>wm", desc = "Maximize / Zoom window", icon = { icon = "󰈈", color = "purple" } },
            { "<leader>w=", desc = "Equalize window sizes", icon = { icon = "󰝤", color = "cyan" } },
            { "<leader>wr", desc = "Restore session", icon = { icon = "󰦛", color = "green" } },
            { "<leader>ws", desc = "Save session", icon = { icon = "󰆓", color = "green" } },
            { "<leader>wl", desc = "Search sessions", icon = { icon = "", color = "blue" } },

            -- Diagnostics and lists
            { "<leader>xd", desc = "Buffer diagnostics", icon = { icon = "󱖫", color = "red" } },
            { "<leader>xl", desc = "Location list", icon = { icon = "", color = "yellow" } },
            { "<leader>xo", desc = "Document symbols side", icon = { icon = "󰅩", color = "blue" } },
            { "<leader>xq", desc = "Quickfix list", icon = { icon = "", color = "yellow" } },
            { "<leader>xx", desc = "Project diagnostics", icon = { icon = "󱖫", color = "red" } },

            -- Yanky / Clipboard
            { "<leader>yp", desc = "Put yanked text after cursor", mode = { "n", "x" }, icon = { icon = "󰅍", color = "yellow" } },
            { "<leader>yP", desc = "Put yanked text before cursor", mode = { "n", "x" }, icon = { icon = "󰅍", color = "yellow" } },
            { "<leader>yy", desc = "Yank text (to Yanky)", mode = { "n", "x" }, icon = { icon = "󰅍", color = "yellow" } },

            -- Non-leader keys
            { "<M-n>", desc = "Cycle forward through yank history" },
            { "<M-p>", desc = "Cycle backward through yank history" },
            { "[y", desc = "Cycle backward through yank history" },
            { "]y", desc = "Cycle forward through yank history" },
            { "gd", desc = "LSP Definition" },
            { "gD", desc = "LSP Declaration" },
            { "gi", desc = "LSP Implementation" },
            { "gr", desc = "LSP References" },
            { "K", desc = "LSP Hover" },
            { "[d", desc = "Prev Diagnostic" },
            { "]d", desc = "Next Diagnostic" },
            { "[h", desc = "Prev Hunk" },
            { "]h", desc = "Next Hunk" },
            { "<C-`>", desc = "Toggle terminal", mode = { "n", "i", "t" } },
            { "<A-1>", desc = "Go to buffer 1" },
            { "<A-2>", desc = "Go to buffer 2" },
            { "<A-3>", desc = "Go to buffer 3" },
            { "<A-4>", desc = "Go to buffer 4" },
            { "<A-5>", desc = "Go to buffer 5" },
            { "<A-6>", desc = "Go to buffer 6" },
            { "<A-7>", desc = "Go to buffer 7" },
            { "<A-8>", desc = "Go to buffer 8" },
            { "<A-9>", desc = "Go to buffer 9" },
            { "<C-M-Down>", desc = "Add cursor below", mode = { "n", "x" } },
            { "<C-M-Up>", desc = "Add cursor above", mode = { "n", "x" } },
        })
    end,
}
