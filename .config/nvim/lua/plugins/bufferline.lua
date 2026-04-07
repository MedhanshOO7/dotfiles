return {
    "akinsho/bufferline.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
        require("bufferline").setup({
            options = {
                mode = "buffers",
                diagnostics = "nvim_lsp",
                separator_style = "slant",
                show_buffer_close_icons = true,
                show_close_icon = false,
                always_show_bufferline = true,
            },
        })
    end
}
