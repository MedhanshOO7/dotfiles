return {
    {
        "mason-org/mason.nvim",
        cmd = "Mason",
        opts = {
            ui = {
                border = "rounded",
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
        },
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        event = "VeryLazy",
        dependencies = {
            "mason-org/mason.nvim",
        },
        opts = {
            ensure_installed = {
                "black",
                "codelldb",
                "clang-format",
                "eslint_d",
                "js-debug-adapter",
                "markdownlint",
                "prettier",
                "ruff",
                "shellcheck",
                "shfmt",
                "stylua",
            },
        },
    },
}
