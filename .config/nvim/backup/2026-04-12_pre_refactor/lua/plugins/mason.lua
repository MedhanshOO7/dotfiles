return {
    {
        "mason-org/mason.nvim",
        config = function()
            require("mason").setup({
                ui = {
                    border = "rounded",
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗",
                    },
                },
            })
        end,
    },
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = {
            "mason-org/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        opts = {
            ensure_installed = {
                "bashls",
                "clangd",
                "cssls",
                "html",
                "jsonls",
                "lua_ls",
                "pylsp",
                "ts_ls",
            },
            automatic_enable = false,
        },
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = {
            "mason-org/mason.nvim",
        },
        opts = {
            ensure_installed = {
                "black",
                "codelldb",
                "clang-format",
                "js-debug-adapter",
                "prettier",
                "shfmt",
                "stylua",
            },
        },
    },
}
