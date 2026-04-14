return {
    {
        'ojroques/vim-oscyank',
        init = function()
            vim.g.oscyank_no_mappings = 1
        end,
    },
    {
        'tpope/vim-fugitive',
    
    },
    {
        'brenoprata10/nvim-highlight-colors',
        config = function()
            require('nvim-highlight-colors').setup({})
        end
    },
    {
        'mg979/vim-visual-multi',
        branch = 'master',
    },
}
