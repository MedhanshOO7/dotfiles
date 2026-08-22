return {
    -- 1. Tiny-Code-Action.nvim (Visual Refactoring Preview)
    -- Replaces the standard code action menu with a beautiful live diff preview.
    {
        "rachartier/tiny-code-action.nvim",
        dependencies = {
            { "nvim-lua/plenary.nvim" },
        },
        event = "LspAttach",
        keys = {
            {
                "<leader>ca",
                function()
                    require("tiny-code-action").code_action()
                end,
                desc = "Code: Actions (visual preview)",
            },
        },
        opts = {
            backend = vim.fn.executable("delta") == 1 and "delta" or "vim",
        },
    },

    -- 3. Neotest (The Ultimate IDE Feature)
    -- Professional testing framework integrated into the editor.
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            -- Adapters
            "nvim-neotest/neotest-python",
            "nvim-neotest/neotest-plenary",
            "haydenmeade/neotest-jest",
            "alfaix/neotest-gtest",
        },
        keys = {
            { "<leader>Tnr", function() require("neotest").run.run() end, desc = "Test: Run nearest" },
            { "<leader>Tnf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Test: Run file" },
            { "<leader>Tns", function() require("neotest").summary.toggle() end, desc = "Test: Toggle summary" },
            { "<leader>Tno", function() require("neotest").output.open({ enter = true }) end, desc = "Test: Open output" },
            { "<leader>Tnp", function() require("neotest").output_panel.toggle() end, desc = "Test: Toggle output panel" },
        },
        config = function()
            require("neotest").setup({
                adapters = {
                    require("neotest-python")({
                        dap = { adapter = "python" },
                    }),
                    require("neotest-plenary"),
                    require("neotest-jest"),
                    require("neotest-gtest"),
                },
                status = { virtual_text = true },
                output = { open_on_run = true },
                summary = {
                    enabled = true,
                    expand_errors = true,
                    follow = true,
                    mappings = {
                        expand = { "<CR>", "<2-LeftMouse>" },
                        run = "r",
                    },
                },
            })
        end,
    },
}
