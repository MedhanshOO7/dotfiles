return {
    "Wansmer/treesj",
    lazy = true,
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    },
    keys = {
        { "<leader>cs", function() require("treesj").toggle() end, desc = "Code: Split/Join block" },
    },
    config = function()
        require("treesj").setup({
            use_default_keymaps = false,
            max_join_length = 120,
        })
    end,
}
