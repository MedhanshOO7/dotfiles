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
                sh = { "shfmt" },
            },

            format_on_save = {
                timeout_ms = 500,
                lsp_fallback = true,
            },
        })

        -- manual format
        vim.keymap.set("n", "<leader>f", function()
            conform.format({ async = true })
        end)
    end,
}
