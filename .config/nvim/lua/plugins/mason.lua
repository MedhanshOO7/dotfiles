return {
    {
        "mason-org/mason.nvim",
        event = "VeryLazy",
        opts = {
            ui = {
                border = "rounded",
                width = 0.8,
                height = 0.8,
                icons = {
                    package_installed = " ",
                    package_pending = " ",
                    package_uninstalled = " ",
                },
            },
        },
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        event = "BufReadPre",
        dependencies = {
            {
                "mason-org/mason.nvim",
                opts = {},
            },
        },
        opts = {
            -- Mason package names (not lspconfig names). Servers are enabled from
            -- lua/lsp/servers.lua; keep both lists in sync.
            ensure_installed = {
                -- Language servers
                "basedpyright",
                "bash-language-server",
                "clangd",
                "css-lsp",
                "emmet-language-server",
                "html-lsp",
                "json-lsp",
                "lua-language-server",
                "marksman",
                "qmlls",
                "tailwindcss-language-server",
                "vtsls",
                "yaml-language-server",

                -- Debuggers, formatters, linters
                "debugpy",
                "codelldb",
                "clang-format",
                "eslint_d",
                "js-debug-adapter",
                "markdownlint",
                "prettierd",
                "prettier",
                "ruff",
                "selene",
                "shellcheck",
                "shfmt",
                "sql-formatter",
                "stylua",
            },
        },
    },
}
