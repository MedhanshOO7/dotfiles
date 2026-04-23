return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",

    config = function()
        local harpoon = require("harpoon")
        harpoon:setup()

        -- Add file
        vim.keymap.set("n", "<leader>ha", function()
            harpoon:list():add()
        end, { desc = "Save this file in the quick access list" })

        -- Toggle menu
        vim.keymap.set("n", "<leader>hh", function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
        end, { desc = "Open the quick access file list" })

        -- Navigate
        vim.keymap.set("n", "<leader>h1", function() harpoon:list():select(1) end, { desc = "Jump to quick access file 1" })
        vim.keymap.set("n", "<leader>h2", function() harpoon:list():select(2) end, { desc = "Jump to quick access file 2" })
        vim.keymap.set("n", "<leader>h3", function() harpoon:list():select(3) end, { desc = "Jump to quick access file 3" })
        vim.keymap.set("n", "<leader>h4", function() harpoon:list():select(4) end, { desc = "Jump to quick access file 4" })
    end,
}
