return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
        "windwp/nvim-ts-autotag",
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
        local ok, treesitter = pcall(require, "nvim-treesitter")
        if not ok then
            vim.schedule(function()
                vim.notify("nvim-treesitter is not available yet. Run :Lazy sync and reopen Neovim.", vim.log.levels.WARN)
            end)
            return
        end

        treesitter.setup({
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = { "markdown" },
            },
            indent = { enable = true },
            ensure_installed = {
                "bash",
                "c",
                "cpp",
                "css",
                "html",
                "javascript",
                "json",
                "lua",
                "markdown",
                "markdown_inline",
                "python",
                "query",
                "tsx",
                "typescript",
                "vim",
                "vimdoc",
            },
            auto_install = true,
        })

        require("nvim-ts-autotag").setup()
    end,
}
