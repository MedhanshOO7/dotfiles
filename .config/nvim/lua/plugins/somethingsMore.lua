return {
    {
        'ojroques/vim-oscyank',
        event = "VeryLazy",
        init = function()
            vim.g.oscyank_no_mappings = 1
        end,
    },
    {
        'tpope/vim-fugitive',
        cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gwrite", "Gread", "Ggrep" },
    },
    {
        'brenoprata10/nvim-highlight-colors',
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require('nvim-highlight-colors').setup({})
        end
    },
}
