return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    dependencies = {
        "echasnovski/mini.icons",
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
        delay = 200,
        preset = "classic",
    },
    config = function(_, opts)
        local wk = require("which-key")

        wk.setup(opts)
        wk.add({
            -- Group headers
            { "<leader>b", group = "Buffers" },
            { "<leader>c", group = "Code" },
            { "<leader>d", group = "Debug" },
            { "<leader>f", group = "Find" },
            { "<leader>g", group = "Git" },
            { "<leader>h", group = "Harpoon" },
            { "<leader>l", group = "LSP" },
            { "<leader>m", group = "Molten" },
            { "<leader>M", group = "Multicursor" },
            { "<leader>n", group = "Notes and writing" },
            { "<leader>o", group = "Obsidian" },
            { "<leader>s", group = "Search and jump" },
            { "<leader>t", group = "Terminal and tasks" },
            { "<leader>u", group = "UI and theme" },
            { "<leader>w", group = "Windows and sessions" },
            { "<leader>x", group = "Diagnostics and lists" },
            { "<leader>z", group = "Folds" },

            -- Buffers
            { "<leader>bb", desc = "Browse open buffers" },
            { "<leader>bd", desc = "Delete current buffer" },
            { "<leader>bn", desc = "Next buffer" },
            { "<leader>bo", desc = "Close all other buffers" },
            { "<leader>bp", desc = "Previous buffer" },

            -- Code
            { "<leader>ca", desc = "Code actions", mode = { "n", "v" } },
            { "<leader>cf", desc = "Format file" },
            { "<leader>rn", desc = "Rename symbol" },

            -- Debug
            { "<leader>db", desc = "Toggle breakpoint" },
            { "<leader>dc", desc = "Continue" },
            { "<leader>di", desc = "Step into" },
            { "<leader>do", desc = "Step over" },
            { "<leader>dO", desc = "Step out" },
            { "<leader>dr", desc = "Toggle REPL" },
            { "<leader>dt", desc = "Terminate" },
            { "<leader>du", desc = "Toggle UI" },

            -- Find
            { "<leader>f/", desc = "Search in current buffer" },
            { "<leader>fb", desc = "Search buffers" },
            { "<leader>fe", desc = "Classic Explorer (netrw)" },
            { "<leader>ff", desc = "Find file" },
            { "<leader>fg", desc = "Live grep" },
            { "<leader>fk", desc = "Keymap help" },
            { "<leader>fp", desc = "Git files" },
            { "<leader>fr", desc = "Recent files" },
            { "<leader>fS", desc = "LSP document symbols" },
            { "<leader>ft", desc = "Search TODOs" },
            { "<leader>fw", desc = "LSP workspace symbols" },

            -- Folds
            { "<leader>za", desc = "Toggle fold" },
            { "<leader>zc", desc = "Close fold" },
            { "<leader>zM", desc = "Close all folds" },
            { "<leader>zo", desc = "Open fold" },
            { "<leader>zR", desc = "Open all folds" },
            { "<leader>zv", desc = "Preview fold" },

            -- Git
            { "<leader>gb", desc = "Blame line" },
            { "<leader>gc", desc = "Git commit" },
            { "<leader>gd", desc = "Preview hunk" },
            { "<leader>gD", desc = "Diff this" },
            { "<leader>gg", desc = "Neogit status" },
            { "<leader>gn", desc = "Next hunk" },
            { "<leader>gp", desc = "Prev hunk" },
            { "<leader>gr", desc = "Reset hunk" },
            { "<leader>gs", desc = "Stage hunk" },
            { "<leader>gu", desc = "Undo stage hunk" },

            -- Harpoon
            { "<leader>ha", desc = "Add to harpoon" },
            { "<leader>hh", desc = "Toggle harpoon menu" },
            { "<leader>h1", desc = "Harpoon file 1" },
            { "<leader>h2", desc = "Harpoon file 2" },
            { "<leader>h3", desc = "Harpoon file 3" },
            { "<leader>h4", desc = "Harpoon file 4" },

            -- LSP
            { "<leader>ld", desc = "Explain problem (cursor)" },
            { "<leader>lD", desc = "Jump to declaration" },
            { "<leader>le", desc = "Explain problem (float)" },
            { "<leader>li", desc = "Jump to implementation" },
            { "<leader>lI", desc = "Toggle inlay hints" },
            { "<leader>lk", desc = "Signature help" },
            { "<leader>lo", desc = "Document symbols" },
            { "<leader>lR", desc = "LSP Restart" },
            { "<leader>ls", desc = "Workspace symbols" },
            { "<leader>lt", desc = "Type definition" },

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

            -- Multicursor
            { "<leader>Ma", desc = "Add next match" },
            { "<leader>MA", desc = "Add all matches" },
            { "<leader>Mj", desc = "Add cursor below", mode = { "n", "x" } },
            { "<leader>MJ", desc = "Skip cursor below", mode = { "n", "x" } },
            { "<leader>Mk", desc = "Add cursor above", mode = { "n", "x" } },
            { "<leader>MK", desc = "Skip cursor above", mode = { "n", "x" } },
            { "<leader>Ms", desc = "Skip next match" },
            { "<leader>Mt", desc = "Toggle cursor" },
            { "<leader>Mv", desc = "Restore cursors" },
            { "<leader>Mx", desc = "Delete cursor" },

            -- Notes and writing
            { "<leader>nb", desc = "Toggle Brainstorm mode" },
            { "<leader>nn", desc = "Aerial navigation" },
            { "<leader>no", desc = "Aerial toggle" },
            { "<leader>np", desc = "Markdown preview" },
            { "<leader>nP", desc = "Professional mode" },
            { "<leader>nr", desc = "Recalculate autolist" },
            { "<leader>ns", desc = "Strikeout text", mode = { "n", "v" } },
            { "<leader>nt", desc = "Twilight" },
            { "<leader>nw", desc = "Writing mode toggle" },
            { "<leader>nz", desc = "Zen Mode" },

            -- Obsidian
            { "<leader>ob", desc = "Show backlinks" },
            { "<leader>of", desc = "Find notes" },
            { "<leader>oi", desc = "Paste image" },
            { "<leader>ol", desc = "Show links", mode = { "n", "v" } },
            { "<leader>on", desc = "New note", mode = { "n", "v" } },
            { "<leader>os", desc = "Search notes" },
            { "<leader>ot", desc = "Today's daily note" },
            { "<leader>oy", desc = "Yesterday's daily note" },
            { "<leader>ch", desc = "Toggle checkbox (Obsidian)" },

            -- Search and jump
            { "<leader>sr", desc = "Search and replace", mode = { "n", "x" } },
            { "<leader>sB", desc = "Search in current file" },
            { "<leader>sj", desc = "Jump (flash)" },
            { "<leader>ss", desc = "Treesitter jump (flash)" },
            { "<leader>sw", desc = "Search word under cursor" },

            -- Terminal and tasks
            { "<leader>ta", desc = "Task quick action" },
            { "<leader>tl", desc = "Load task bundle" },
            { "<leader>to", desc = "Toggle terminal" },
            { "<leader>tr", desc = "Run task" },
            { "<leader>tt", desc = "Toggle task list" },

            -- UI and theme
            { "<leader>ua", desc = "Toggle auto-save (global)" },
            { "<leader>ub", desc = "Toggle auto-save (buffer)" },
            { "<leader>uf", desc = "Toggle auto-format" },
            { "<leader>un", desc = "Next theme" },
            { "<leader>up", desc = "Prev theme" },
            { "<leader>us", desc = "Toggle spell check" },
            { "<leader>ut", desc = "Theme picker" },
            { "<leader>uy", desc = "Toggle transparency" },
            { "<leader>uw", desc = "Toggle text wrap" },

            -- Windows and sessions
            { "<leader>wc", desc = "Close window" },
            { "<leader>wh", desc = "Split horizontal" },
            { "<leader>wo", desc = "Only window" },
            { "<leader>wr", desc = "Restore session" },
            { "<leader>ws", desc = "Save session" },
            { "<leader>wv", desc = "Split vertical" },

            -- Diagnostics and lists
            { "<leader>xd", desc = "Buffer diagnostics" },
            { "<leader>xl", desc = "Location list" },
            { "<leader>xo", desc = "Document symbols side" },
            { "<leader>xq", desc = "Quickfix list" },
            { "<leader>xx", desc = "Project diagnostics" },

            -- Non-leader keys
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
            { "<C-1>", desc = "Go to buffer 1" },
            { "<C-2>", desc = "Go to buffer 2" },
            { "<C-3>", desc = "Go to buffer 3" },
            { "<C-4>", desc = "Go to buffer 4" },
            { "<C-5>", desc = "Go to buffer 5" },
            { "<C-6>", desc = "Go to buffer 6" },
            { "<C-7>", desc = "Go to buffer 7" },
            { "<C-8>", desc = "Go to buffer 8" },
            { "<C-9>", desc = "Go to buffer 9" },
            { "<C-M-Down>", desc = "Add cursor below", mode = { "n", "x" } },
            { "<C-M-Up>", desc = "Add cursor above", mode = { "n", "x" } },
        })
    end,
}