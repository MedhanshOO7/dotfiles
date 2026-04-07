return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
        local wk = require("which-key")

        wk.setup({
            delay = 300,
        })

        wk.add({
            { "<leader>e",  desc = "Explorer" },

            { "<leader>f",  group = "Find" },
            { "<leader>ff", desc = "Find Files" },
            { "<leader>fg", desc = "Live Grep" },
            { "<leader>fb", desc = "Buffers" },
            { "<leader>fk", desc = "Keymaps" },

            { "<leader>g",  group = "Git" },
            { "<leader>gs", desc = "Stage Hunk" },
            { "<leader>gr", desc = "Reset Hunk" },
            { "<leader>gb", desc = "Blame" },

            { "<leader>x",  group = "Diagnostics" },
            { "<leader>xx", desc = "Trouble Toggle" },
            { "<leader>xd", desc = "Document Diagnostics" },

            { "<leader>p",  desc = "Command Palette" },
        })
    end
}
