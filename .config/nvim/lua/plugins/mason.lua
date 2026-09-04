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
        event = "VeryLazy",
        dependencies = {
            {
                "mason-org/mason.nvim",
                opts = {},
            },
        },
        opts = {
            ensure_installed = {
                "debugpy",
                "codelldb",
                "clang-format",
                "emmet-language-server",
                "eslint_d",
                "js-debug-adapter",
                "markdownlint",
                "marksman",
                "prettierd",
                "prettier",
                "ruff",
                "qmlls",
                "selene",
                "shellcheck",
                "shfmt",
                "sql-formatter",
                "stylua",
            },
        },
    },
}
