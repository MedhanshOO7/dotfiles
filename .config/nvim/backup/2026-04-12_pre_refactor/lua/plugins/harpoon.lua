return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },

    config = function()
        local harpoon = require("harpoon")
        harpoon:setup()

        -- Add file
        vim.keymap.set("n", "<leader>a", function()
            harpoon:list():add()
        end, { desc = "Save this file in the quick access list" })

        -- Toggle menu
        vim.keymap.set("n", "<C-e>", function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
        end, { desc = "Open the quick access file list" })

        -- Navigate
        vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end, { desc = "Jump to quick access file 1" })
        vim.keymap.set("n", "<C-j>", function() harpoon:list():select(2) end, { desc = "Jump to quick access file 2" })
        vim.keymap.set("n", "<C-k>", function() harpoon:list():select(3) end, { desc = "Jump to quick access file 3" })
        vim.keymap.set("n", "<C-l>", function() harpoon:list():select(4) end, { desc = "Jump to quick access file 4" })
    end,
}
