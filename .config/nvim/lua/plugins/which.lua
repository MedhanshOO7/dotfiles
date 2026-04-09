return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
        local wk = require("which-key")

        wk.setup({
            delay = 300,
            preset = "classic",
        })

        wk.add({
            { "<leader>a", desc = "Save this file in the quick access list" },
            { "<leader>b", desc = "Open or close the file sidebar" },
            { "<leader>e", desc = "Open or close the file sidebar" },
            { "<leader>bn", desc = "Go to the next open tab" },
            { "<leader>bp", desc = "Go to the previous open tab" },

            { "<leader>c", group = "Code and tools" },
            { "<leader>ca", desc = "Show suggested code fixes and actions" },
            { "<leader>cf", desc = "Format the current file" },
            { "<leader>cl", desc = "Turn language features on or off" },
            { "<leader>cm", desc = "Open the tool installer" },

            { "<leader>d", group = "Debug and diagnostics" },
            { "<leader>d0", desc = "Debug: step over" },
            { "<leader>d1", desc = "Debug: step into" },
            { "<leader>d2", desc = "Debug: step out" },
            { "<leader>d9", desc = "Add or remove a breakpoint" },
            { "<leader>db", desc = "Add or remove a breakpoint" },
            { "<leader>dc", desc = "Start or continue debugging" },
            { "<leader>di", desc = "Debug: step into" },
            { "<leader>do", desc = "Debug: step over" },
            { "<leader>dO", desc = "Debug: step out" },
            { "<leader>dr", desc = "Open the debugger console" },
            { "<leader>ds", desc = "Explain the problem on this line" },
            { "<leader>dt", desc = "Stop debugging" },
            { "<leader>du", desc = "Open the debugger panels" },

            { "<leader>f", group = "Files, find, and format" },
            { "<leader>fM", desc = "Close every fold in the file" },
            { "<leader>fR", desc = "Open every fold in the file" },
            { "<leader>fa", desc = "Toggle the fold under the cursor" },
            { "<leader>fb", desc = "Switch between open files" },
            { "<leader>fc", desc = "Close the fold under the cursor completely" },
            { "<leader>fe", desc = "Open the classic netrw file list" },
            { "<leader>ff", desc = "Find a file by name" },
            { "<leader>fg", desc = "Search for text in the project" },
            { "<leader>fk", desc = "Browse every keybinding" },
            { "<leader>fo", desc = "Open the fold under the cursor completely" },
            { "<leader>fs", desc = "Save the current file" },
            { "<leader>ft", desc = "Find every TODO, NOTE, or FIX comment" },

            { "<leader>g", group = "Git" },
            { "<leader>gc", desc = "Start a git commit" },
            { "<leader>gg", desc = "Open the full git panel" },

            { "<leader>h", group = "Git changes" },
            { "<leader>hb", desc = "Show who changed this line and when" },
            { "<leader>hd", desc = "Preview this changed block" },
            { "<leader>hn", desc = "Go to the next git change" },
            { "<leader>hp", desc = "Go to the previous git change" },
            { "<leader>hr", desc = "Discard this changed block" },
            { "<leader>hs", desc = "Stage this changed block" },

            { "<leader>ld", desc = "Jump to where this symbol is defined" },
            { "<leader>lh", desc = "Show documentation for the symbol under the cursor" },
            { "<leader>li", desc = "Jump to the implementation" },
            { "<leader>lr", desc = "Show every place this symbol is used" },

            { "<leader>m", group = "Markdown and outline" },
            { "<leader>mn", desc = "Open outline navigation in a floating picker" },
            { "<leader>mo", desc = "Open the document or code outline" },
            { "<leader>mp", desc = "Open or close the markdown browser preview" },
            { "<leader>mr", desc = "Fix markdown list numbering" },

            { "<leader>p", desc = "Open the command palette" },

            { "<leader>q", desc = "Quit the current window" },

            { "<leader>rn", desc = "Rename this symbol everywhere" },
            { "<leader>rr", desc = "Run the current file" },

            { "<leader>s", group = "Search and jump" },
            { "<leader>sj", desc = "Jump quickly to any visible text" },
            { "<leader>ss", desc = "Jump by syntax block" },

            { "<leader>t", group = "Terminal and tasks" },
            { "<leader>ta", desc = "Run a task action on the current item" },
            { "<leader>tl", desc = "Load saved task runs" },
            { "<leader>to", desc = "Open or close the floating terminal" },
            { "<leader>tr", desc = "Choose and run a project task" },
            { "<leader>tt", desc = "Open or close the task list" },

            { "<leader>u", group = "UI and theme" },
            { "<leader>ua", desc = "Turn autosave on or off" },
            { "<leader>ub", desc = "Turn autosave on or off for this file" },
            { "<leader>un", desc = "Switch to the next theme" },
            { "<leader>up", desc = "Switch to the previous theme" },
            { "<leader>ut", desc = "Choose a theme" },
            { "<leader>uy", desc = "Turn transparency on or off" },
            { "<leader>uz", desc = "Hide coding noise for free-form writing" },

            { "<leader>w", group = "Workspace sessions" },
            { "<leader>wr", desc = "Restore session for cwd" },
            { "<leader>ws", desc = "Save session for auto session root dir" },

            { "<leader>bd", desc = "Close the current buffer" },
            { "<leader>xd", desc = "Open the current file problem list" },
            { "<leader>xl", desc = "Open the location list" },
            { "<leader>xq", desc = "Open the quickfix list" },
            { "<leader>xx", desc = "Open the project problem list" },

            { "<leader>zt", desc = "Dim unfocused text around the cursor" },
            { "<leader>zw", desc = "Toggle low-noise writing mode for this buffer" },
            { "<leader>zz", desc = "Focus on writing or reading without distractions" },

            { "<leader>?", desc = "Browse every keybinding" },
        })
    end,
}
