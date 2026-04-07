return {
    "akinsho/bufferline.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
        local bufferline = require("bufferline")

        bufferline.setup({
            options = {
                mode = "tabs",
                style_preset = bufferline.style_preset.minimal,
                diagnostics = false,
                separator_style = "thin",
                indicator = {
                    style = "underline",
                },
                show_buffer_close_icons = false,
                show_close_icon = false,
                always_show_bufferline = true,
                show_tab_indicators = true,
                tab_size = 20,
                max_name_length = 20,
            },
        })
    end
}
