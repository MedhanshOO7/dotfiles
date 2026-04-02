return {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
        require("toggleterm").setup({
            direction = "float",

            float_opts = {
                border = "rounded", -- single | double | shadow | rounded
                width = function()
                    return math.floor(vim.o.columns * 0.8)
                end,
                height = function()
                    return math.floor(vim.o.lines * 0.6)
                end,
            },

            open_mapping = [[<C-`>]],
            start_in_insert = true,
            persist_size = true,
            close_on_exit = false,
        })
    end,
}
