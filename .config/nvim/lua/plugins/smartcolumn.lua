return {
    "m4xshen/smartcolumn.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        colorcolumn = "100",
        disabled_filetypes = { "help", "text", "markdown", "Ntree", "lazy", "mason", "trouble", "dashboard", "snacks_dashboard" },
        scope = "file",
    },
}
