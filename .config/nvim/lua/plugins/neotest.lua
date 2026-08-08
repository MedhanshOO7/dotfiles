return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
        "nvim-neotest/neotest-python",
    },
    cmd = { "Neotest" },
    keys = {
        { "<leader>tr", function() require("neotest").run.run() end, desc = "Run nearest unit test" },
        { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run tests in current file" },
        { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle test summary sidebar" },
        { "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Show test output floating panel" },
        { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug nearest test (DAP)" },
    },
    config = function()
        local neotest = require("neotest")
        neotest.setup({
            adapters = {
                require("neotest-python")({
                    dap = { justMyCode = false },
                }),
            },
        })
    end,
}
