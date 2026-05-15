return {
    {
        "mason-org/mason.nvim",
        cmd = "Mason",
        opts = {
            ui = {
                border = "rounded",
                width = 0.8,
                height = 0.8,
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
                "marksman",
                "prettier",
                "ruff",
                "shellcheck",
                "shfmt",
                "stylua",
            },
        },
    },
}
