return {
    {
        "luckasRanarison/tailwind-tools.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        ft = { "html", "css", "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "svelte" },
        opts = {
            document_color = { enabled = true, kind = "inline" },
            conceal = { enabled = false },
            server = { override = false },
        },
    },
}
