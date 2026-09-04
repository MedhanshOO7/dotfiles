return {
    -- Clean, robust window management without deprecated middleclass/animation libs
    {
        "folke/snacks.nvim",
        keys = {
            {
                "<C-w>z",
                function()
                    Snacks.zen.zoom()
                end,
                desc = "Maximize/Zoom Window",
            },
            {
                "<C-w>=",
                "<cmd>wincmd =<cr>",
                desc = "Equalize Windows",
            },
            {
                "<leader>wm",
                function()
                    Snacks.zen.zoom()
                end,
                desc = "Windows: Maximize / Zoom",
            },
            {
                "<leader>w=",
                "<cmd>wincmd =<cr>",
                desc = "Windows: Equalize sizes",
            },
            {
                "<leader>wh",
                "<cmd>split<cr>",
                desc = "Windows: Split horizontal",
            },
            {
                "<leader>wv",
                "<cmd>vsplit<cr>",
                desc = "Windows: Split vertical",
            },
            {
                "<leader>wc",
                "<cmd>close<cr>",
                desc = "Windows: Close current",
            },
            {
                "<leader>wo",
                "<cmd>only<cr>",
                desc = "Windows: Close all others",
            },
        },
    },
}
