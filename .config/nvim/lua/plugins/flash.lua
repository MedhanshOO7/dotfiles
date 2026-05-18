return {
    "folke/flash.nvim",
    lazy = true,
    keys = {
        { "<leader>sj", function() require("flash").jump() end, desc = "Jump quickly to any visible text" },
        { "<leader>ss", function() require("flash").treesitter() end, desc = "Jump by syntax block" },
    },
    opts = {
        label = {
            uppercase = false,
            rainbow = {
                enabled = true,
            },
        },
        modes = {
            char = {
                enabled = true,
                jump_labels = true,
            },
        },
        prompt = {
            enabled = true,
            prefix = { { "󰉁 ", "FlashPromptIcon" } },
        },
    },
}
