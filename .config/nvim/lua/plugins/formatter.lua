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
                markdown = { "prettier" },
                sh = { "shfmt" },
                yaml = { "prettier" },
            },
            formatters = {
                prettier = {
                    args = { "--stdin-filepath", "$FILENAME", "--tab-width", "4" },
                },
                stylua = {
                    args = { "--indent-type", "Spaces", "--indent-width", "4", "-" },
                },
                clang_format = {
                    prepend_args = { "--style={IndentWidth: 4}" },
                },
            },
            format_on_save = function(bufnr)
                if not vim.g.autoformat_enabled or vim.b[bufnr].autoformat_enabled == false then
                    return nil
                end

                return {
                    timeout_ms = 500,
                    lsp_fallback = true,
                }
            end,
        })

        vim.api.nvim_create_user_command("FormatToggle", function()
            vim.g.autoformat_enabled = not vim.g.autoformat_enabled
            vim.notify(vim.g.autoformat_enabled and "Format on save is on" or "Format on save is off")
        end, { desc = "Toggle format on save" })
    end,
}
