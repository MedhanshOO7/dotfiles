return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },

    config = function()
        local conform = require("conform")

        conform.setup({
            formatters_by_ft = {
                c = { "clang_format" },
                cpp = { "clang_format" },
                python = { "black" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                typescriptreact = { "prettier" },
                javascriptreact = { "prettier" },
                json = { "prettier" },
                lua = { "stylua" },
                sh = { "shfmt" },
            },
        })
    end,
}
