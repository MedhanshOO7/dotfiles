return {
    "akinsho/bufferline.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
        local bufferline = require("bufferline")

        bufferline.setup({
            options = {
                mode = "buffers",
                style_preset = bufferline.style_preset.no_italic,
                diagnostics = "nvim_lsp",
                separator_style = { "", "" },
                indicator = {
                    style = "icon",
                    icon = "▎",
                },
                numbers = "ordinal",
                show_buffer_close_icons = false,
                show_close_icon = false,
                always_show_bufferline = true,
                show_tab_indicators = false,
                tab_size = 18,
                max_name_length = 25,
                modified_icon = "●",
                diagnostics_indicator = function(count, level)
                    local icon = level:match("error") and " " or " "
                    return " " .. icon .. count
                end,
                offsets = {
                    {
                        filetype = "neo-tree",
                        text = "Explorer",
                        highlight = "Directory",
                        separator = true,
                    },
                },
            },
        })
    end
}
