return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    dependencies = {
        "windwp/nvim-ts-autotag",
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
        require("nvim-treesitter").setup({
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = { "markdown" },
            },
            indent = { enable = true },
            ensure_installed = {
                "c", "cpp", "lua", "vim", "vimdoc", "query",
                "markdown", "markdown_inline",
                "html", "css", "javascript", "typescript", "tsx",
                "json", "bash", "python",
            },
            auto_install = true,
        })
        require("nvim-ts-autotag").setup()

        -- This starts Treesitter highlighting for every buffer
        vim.api.nvim_create_autocmd("FileType", {
            callback = function()
                pcall(vim.treesitter.start)
            end,
        })
    end,
}
