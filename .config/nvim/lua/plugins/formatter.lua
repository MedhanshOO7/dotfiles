return {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "FormatToggle",

    config = function()
        local conform = require("conform")

        conform.setup({
            formatters_by_ft = {
                c = { "clang_format" },
                cpp = { "clang_format" },
                python = { "ruff_organize_imports", "ruff_format" },
                javascript = { "prettierd", "prettier", stop_after_first = true },
                typescript = { "prettierd", "prettier", stop_after_first = true },
                typescriptreact = { "prettierd", "prettier", stop_after_first = true },
                javascriptreact = { "prettierd", "prettier", stop_after_first = true },
                html = { "prettierd", "prettier", stop_after_first = true },
                css = { "prettierd", "prettier", stop_after_first = true },
                scss = { "prettierd", "prettier", stop_after_first = true },
                less = { "prettierd", "prettier", stop_after_first = true },
                json = { "prettierd", "prettier", stop_after_first = true },
                jsonc = { "prettierd", "prettier", stop_after_first = true },
                lua = { "stylua" },
                markdown = { "prettierd", "prettier", stop_after_first = true },
                ["markdown.mdx"] = { "prettierd", "prettier", stop_after_first = true },
                sh = { "shfmt" },
                bash = { "shfmt" },
                zsh = { "shfmt" },
                sql = { "sql_formatter" },
                yaml = { "prettierd", "prettier", stop_after_first = true },
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
                    prepend_args = function(self, ctx)
                        local bufnr = vim.api.nvim_get_current_buf()
                        if vim.b[bufnr]._clang_format_root == nil then
                            local found = vim.fs.find({ ".clang-format", "_clang-format" }, {
                                upward = true,
                                path = ctx.dirname,
                            })
                            vim.b[bufnr]._clang_format_root = #found > 0
                        end
                        if vim.b[bufnr]._clang_format_root then
                            return { "--style=file" }
                        end
                        return {
                            "--style={BasedOnStyle: LLVM, IndentWidth: 4, TabWidth: 4, UseTab: Never, AccessModifierOffset: -4}",
                        }
                    end,
                },
                shfmt = {
                    prepend_args = { "-i", "4", "-ci" },
                },
            },
            format_on_save = function(bufnr)
                if not vim.g.autoformat_enabled or vim.b[bufnr].autoformat_enabled == false then
                    return nil
                end

                if vim.b[bufnr].large_file or vim.b[bufnr].bigfile then
                    return nil
                end

                if not vim.api.nvim_buf_is_valid(bufnr) or not vim.bo[bufnr].modifiable then
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
