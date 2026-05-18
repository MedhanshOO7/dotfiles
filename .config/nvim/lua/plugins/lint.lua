return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost", "InsertLeave" },
    config = function()
        local lint = require("lint")
        local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

        local function prefer_mason(cmd)
            local mason_cmd = mason_bin .. "/" .. cmd
            if vim.fn.executable(mason_cmd) == 1 then
                return mason_cmd
            end

            return cmd
        end

        local function available(cmd)
            return vim.fn.executable(prefer_mason(cmd)) == 1
        end

        lint.linters.selene = vim.tbl_deep_extend("force", lint.linters.selene or {}, {
            cmd = prefer_mason("selene"),
        })
        lint.linters.shellcheck = vim.tbl_deep_extend("force", lint.linters.shellcheck or {}, {
            cmd = prefer_mason("shellcheck"),
        })
        lint.linters.ruff = vim.tbl_deep_extend("force", lint.linters.ruff or {}, {
            cmd = prefer_mason("ruff"),
        })
        lint.linters.eslint_d = vim.tbl_deep_extend("force", lint.linters.eslint_d or {}, {
            cmd = prefer_mason("eslint_d"),
        })
        lint.linters.markdownlint = vim.tbl_deep_extend("force", lint.linters.markdownlint or {}, {
            cmd = prefer_mason("markdownlint"),
        })

        lint.linters_by_ft = {
            javascript = available("eslint_d") and { "eslint_d" } or {},
            javascriptreact = available("eslint_d") and { "eslint_d" } or {},
            typescript = available("eslint_d") and { "eslint_d" } or {},
            typescriptreact = available("eslint_d") and { "eslint_d" } or {},
            python = available("ruff") and { "ruff" } or {},
            lua = available("selene") and { "selene" } or {},
            sh = available("shellcheck") and { "shellcheck" } or {},
            bash = available("shellcheck") and { "shellcheck" } or {},
            zsh = available("shellcheck") and { "shellcheck" } or {},
            markdown = available("markdownlint") and { "markdownlint" } or {},
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
