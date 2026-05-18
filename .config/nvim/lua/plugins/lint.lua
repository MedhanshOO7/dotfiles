return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost", "InsertLeave" },
    config = function()
        local lint = require("lint")

        lint.linters_by_ft = {
            javascript = { "eslint_d" },
            javascriptreact = { "eslint_d" },
            typescript = { "eslint_d" },
            typescriptreact = { "eslint_d" },
            python = { "ruff" },
            lua = { "selene" },
            sh = { "shellcheck" },
            bash = { "shellcheck" },
            zsh = { "shellcheck" },
            markdown = { "markdownlint" },
        }

        -- Set default config for markdownlint
        local config_dir = vim.fn.stdpath("config")
        lint.linters.markdownlint.args = {
            "--stdin",
            "--config", config_dir .. "/.markdownlint-loose.json",
        }

        local lint_group = vim.api.nvim_create_augroup("user_nvim_lint", { clear = true })

        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
            group = lint_group,
            callback = function()
                pcall(lint.try_lint)
            end,
        })
    end,
}
