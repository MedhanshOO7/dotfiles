return {
    -- 1. Telescope Undo (Visual History)
    {
        "debugloop/telescope-undo.nvim",
        dependencies = {
            {
                "nvim-telescope/telescope.nvim",
                dependencies = { "nvim-lua/plenary.nvim" },
            },
        },
        keys = {
            {
                "<leader>fu",
                "<cmd>Telescope undo<cr>",
                desc = "Find: Undo history (visual)",
            },
        },
        config = function()
            require("telescope").load_extension("undo")
        end,
    },

    -- 2. Inc-Rename (Live Variable Renaming)
    {
        "smjonas/inc-rename.nvim",
        cmd = "IncRename",
        keys = {
            {
                "<leader>rn",
                function()
                    return ":IncRename " .. vim.fn.expand("<cword>")
                end,
                expr = true,
                desc = "Code: Rename symbol (live)",
            },
        },
        config = function()
            require("inc-rename").setup()
        end,
    },

    -- 3. Refactoring.nvim (Code Transformations)
    {
        "ThePrimeagen/refactoring.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        keys = {
            { "<leader>ce", function() require('refactoring').refactor('Extract Function') end, mode = "v", desc = "Code: Extract function" },
            { "<leader>cE", function() require('refactoring').refactor('Extract Function To File') end, mode = "v", desc = "Code: Extract function to file" },
            { "<leader>cv", function() require('refactoring').refactor('Extract Variable') end, mode = "v", desc = "Code: Extract variable" },
            { "<leader>ci", function() require('refactoring').refactor('Inline Variable') end, mode = { "n", "v" }, desc = "Code: Inline variable" },
            { "<leader>cb", function() require('refactoring').refactor('Extract Block') end, desc = "Code: Extract block" },
            { "<leader>cB", function() require('refactoring').refactor('Extract Block To File') end, desc = "Code: Extract block to file" },
        },
        config = function()
            require("refactoring").setup({
                prompt_func_return_type = {
                    go = false,
                    java = false,
                    cpp = false,
                    c = false,
                    h = false,
                    fortran = false,
                    cs = false,
                },
                prompt_func_param_type = {
                    go = false,
                    java = false,
                    cpp = false,
                    c = false,
                    h = false,
                    fortran = false,
                    cs = false,
                },
                printf_statements = {},
                print_var_statements = {},
            })
        end,
    },

    -- 4. Smart-Splits (Organic Window Resizing)
    {
        'mrjones2014/smart-splits.nvim',
        keys = {
            -- Moving between splits
            { '<C-h>', function() require('smart-splits').move_cursor_left() end, desc = "Move to left split" },
            { '<C-j>', function() require('smart-splits').move_cursor_down() end, desc = "Move to bottom split" },
            { '<C-k>', function() require('smart-splits').move_cursor_up() end, desc = "Move to top split" },
            { '<C-l>', function() require('smart-splits').move_cursor_right() end, desc = "Move to right split" },
            -- Resizing splits
            { '<A-h>', function() require('smart-splits').resize_left() end, desc = "Resize split left" },
            { '<A-j>', function() require('smart-splits').resize_down() end, desc = "Resize split down" },
            { '<A-k>', function() require('smart-splits').resize_up() end, desc = "Resize split up" },
            { '<A-l>', function() require('smart-splits').resize_right() end, desc = "Resize split right" },
        },
        opts = {},
    },
}
