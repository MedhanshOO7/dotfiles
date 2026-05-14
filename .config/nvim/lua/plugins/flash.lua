return {
    "folke/flash.nvim",
    lazy = true,
    keys = {
        { "<leader>sj", function() require("flash").jump() end, desc = "Jump quickly to any visible text" },
        { "<leader>ss", function() require("flash").treesitter() end, desc = "Jump by syntax block" },
    },
    opts = {},
}
