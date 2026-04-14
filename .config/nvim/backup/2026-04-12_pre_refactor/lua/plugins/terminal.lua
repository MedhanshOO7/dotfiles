return {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
        require("toggleterm").setup({
            direction = "float",
            open_mapping = [[<C-`>]],
            start_in_insert = true,
            persist_size = true,
            close_on_exit = false,
            shell = vim.o.shell,
            float_opts = {
                border = "rounded",
            },
            highlights = {
                Normal = {
                    link = "Normal",
                },
                NormalFloat = {
                    link = "Normal",
                },
                FloatBorder = {
                    link = "FloatBorder",
                },
            },
        })
    end,
}
