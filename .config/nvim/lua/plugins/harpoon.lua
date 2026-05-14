return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    lazy = true,
    keys = {
        { "<leader>ha", function() require("harpoon"):list():add() end, desc = "Save this file in the quick access list" },
        { "<leader>hh", function() local h = require("harpoon") h.ui:toggle_quick_menu(h:list()) end, desc = "Open the quick access file list" },
        { "<leader>h1", function() require("harpoon"):list():select(1) end, desc = "Jump to quick access file 1" },
        { "<leader>h2", function() require("harpoon"):list():select(2) end, desc = "Jump to quick access file 2" },
        { "<leader>h3", function() require("harpoon"):list():select(3) end, desc = "Jump to quick access file 3" },
        { "<leader>h4", function() require("harpoon"):list():select(4) end, desc = "Jump to quick access file 4" },
    },
    config = function()
        require("harpoon"):setup()
    end,
}
