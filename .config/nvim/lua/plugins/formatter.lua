return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },

    config = function()
        local conform = require("conform")

        conform.setup({
            formatters_by_ft = {
                c = { "clang_format" },
                cpp = { "clang_format" },
                python = { "ruff_organize_imports", "ruff_format", "black" },
                javascript = { "prettierd", "prettier" },
                typescript = { "prettierd", "prettier" },
                typescriptreact = { "prettierd", "prettier" },
                javascriptreact = { "prettierd", "prettier" },
                html = { "prettierd", "prettier" },
                css = { "prettierd", "prettier" },
                scss = { "prettierd", "prettier" },
                less = { "prettierd", "prettier" },
                json = { "prettierd", "prettier" },
                jsonc = { "prettierd", "prettier" },
                lua = { "stylua" },
                markdown = { "prettierd", "prettier" },
                ["markdown.mdx"] = { "prettierd", "prettier" },
                sh = { "shfmt" },
                bash = { "shfmt" },
                zsh = { "shfmt" },
                yaml = { "prettierd", "prettier" },
            },
            formatters = {
                prettier = {
                    args = { "--stdin-filepath", "$FILENAME", "--tab-width", "4" },
                },
                prettierd = {
                    prepend_args = { "--tab-width", "4" },
                },
                stylua = {
                    args = { "--indent-type", "Spaces", "--indent-width", "4", "-" },
                },
                clang_format = {
                    prepend_args = { "--style={BasedOnStyle: LLVM, IndentWidth: 4, TabWidth: 4, UseTab: Never}" },
                },
                shfmt = {
                    prepend_args = { "-i", "4", "-ci" },
                },
            },
            format_on_save = function(bufnr)
                if not vim.g.autoformat_enabled or vim.b[bufnr].autoformat_enabled == false then
                    return nil
                end

                return {
                    timeout_ms = 500,
                    lsp_format = "fallback",
                }
            end,
        })

        vim.api.nvim_create_user_command("FormatToggle", function()
            vim.g.autoformat_enabled = not vim.g.autoformat_enabled
            vim.notify(vim.g.autoformat_enabled and "Format on save is on" or "Format on save is off")
        end, { desc = "Toggle format on save" })
    end,
}
