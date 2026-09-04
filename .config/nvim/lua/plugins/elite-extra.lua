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
            { "<leader>Tr", function() require("neotest").run.run() end, desc = "Test: Run nearest" },
            { "<leader>Tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Test: Run file" },
            { "<leader>Ts", function() require("neotest").summary.toggle() end, desc = "Test: Toggle summary" },
            { "<leader>To", function() require("neotest").output.open({ enter = true }) end, desc = "Test: Open output" },
            { "<leader>Tp", function() require("neotest").output_panel.toggle() end, desc = "Test: Toggle output panel" },
            { "<leader>Td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Test: Debug nearest" },
            { "<leader>TS", function() require("neotest").run.stop() end, desc = "Test: Stop running tests" },
        },
        config = function()
            local function get_python_path()
                if vim.env.VIRTUAL_ENV then
                    local venv_python = vim.env.VIRTUAL_ENV .. "/bin/python"
                    if vim.fn.executable(venv_python) == 1 then
                        return venv_python
                    end
                end
                local local_venv = vim.fn.findfile(".venv/bin/python", ".;")
                if local_venv ~= "" and vim.fn.executable(local_venv) == 1 then
                    return vim.fn.fnamemodify(local_venv, ":p")
                end
                return "python3"
            end

            require("neotest").setup({
                adapters = {
                    require("neotest-python")({
                        dap = { adapter = "python" },
                        runner = "pytest",
                        python = get_python_path,
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
