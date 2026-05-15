return {
    "numToStr/Comment.nvim",
    lazy = true,
    keys = {
        { "<leader>/", function() require("Comment.api").toggle.linewise.current() end, desc = "Toggle line comment" },
        { "<leader>/", function()
            local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
            vim.api.nvim_feedkeys(esc, "nx", false)
            require("Comment.api").toggle.linewise(vim.fn.visualmode())
        end, mode = "v", desc = "Toggle line comment" },
    },
    opts = {
        padding = true,
        sticky = true,
        ignore = nil,

        toggler = {
            line = "gcc",
            block = "gbc",
        },

        opleader = {
            line = "gc",
            block = "gb",
        },

        extra = {
            above = "gcO",
            below = "gco",
            eol = "gcA",
        },

        mappings = {
            basic = false,
            extra = false,
        },

        pre_hook = nil,
        post_hook = nil,
    },
}
