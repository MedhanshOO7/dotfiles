return {
    -- Optimized Man Page viewer
    -- This configures the built-in man.vim plugin that comes with Neovim
    -- but gives it modern defaults and better aesthetics.
    {
        "folke/lazy.nvim",
        init = function()
            vim.g.ft_man_open_mode = "vert"
            vim.g.man_hardwrap = 0
        end,
    },
}
