return {
    -- Optimized Man Page viewer
    -- This configures the built-in man.vim plugin that comes with Neovim
    -- but gives it modern defaults and better aesthetics.
    {
        "neovim/nvim-lspconfig", -- We use an existing event to trigger this
        optional = true,
        config = function()
            -- Set man page variables
            vim.g.ft_man_open_mode = "vert" -- Keep references visible without losing the source page
            vim.g.man_hardwrap = 0 -- Respect terminal width less aggressively when using nvim as pager
        end,
    },
}
