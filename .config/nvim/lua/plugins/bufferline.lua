return {
    "akinsho/bufferline.nvim",
    lazy = false,
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        local bufferline = require("bufferline")
        local bufferline_group = vim.api.nvim_create_augroup("dynamic_bufferline_theme", { clear = true })

        local function hl(name, key, fallback)
            local ok, value = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
            if ok and value and value[key] then
                return string.format("#%06x", value[key])
            end

            return fallback
        end

        local function hex_to_rgb(hex)
            hex = (hex or "#000000"):gsub("#", "")
            return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
        end

        local function blend(top, bottom, alpha)
            local tr, tg, tb = hex_to_rgb(top)
            local br, bg, bb = hex_to_rgb(bottom)

            local function channel(foreground, background)
                return math.floor((alpha * foreground) + ((1 - alpha) * background) + 0.5)
            end

            return string.format(
                "#%02x%02x%02x",
                channel(tr, br),
                channel(tg, bg),
                channel(tb, bb)
            )
        end

        local function apply()
            local normal_bg = hl("Normal", "bg", "#1a1b26")
            local normal_fg = hl("Normal", "fg", "#c0caf5")
            local comment_fg = hl("Comment", "fg", "#565f89")
            local accent_fg = hl("Function", "fg", hl("Identifier", "fg", "#7aa2f7"))
            local inactive_bg = blend(comment_fg, normal_bg, 0.10)
            local visible_bg = blend(comment_fg, normal_bg, 0.18)
            local separator_fg = blend(comment_fg, normal_bg, 0.35)

            vim.opt.showtabline = 2

            bufferline.setup({
                options = {
                    mode = "buffers",
                    style_preset = bufferline.style_preset.no_italic,
                    diagnostics = "nvim_lsp",
                    separator_style = "slant",
                    color_icons = true,
                    indicator = {
                        style = "icon",
                        icon = "▎",
                    },
                    numbers = "none",
                    show_buffer_close_icons = false,
                    show_close_icon = false,
                    always_show_bufferline = true,
                    show_tab_indicators = false,
                    tab_size = 18,
                    max_name_length = 25,
                    truncate_names = false,
                    hover = {
                        enabled = true,
                        delay = 120,
                        reveal = { "close" },
                    },
                    persist_buffer_sort = true,
                    sort_by = "insert_after_current",
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
                            text_align = "left",
                            separator = true,
                        },
                    },
                },
                highlights = {
                    fill = {
                        bg = inactive_bg,
                    },
                    background = {
                        fg = comment_fg,
                        bg = inactive_bg,
                    },
                    buffer_visible = {
                        fg = normal_fg,
                        bg = visible_bg,
                    },
                    buffer_selected = {
                        fg = normal_fg,
                        bg = normal_bg,
                        bold = true,
                    },
                    separator = {
                        fg = inactive_bg,
                        bg = inactive_bg,
                    },
                    separator_visible = {
                        fg = visible_bg,
                        bg = visible_bg,
                    },
                    separator_selected = {
                        fg = normal_bg,
                        bg = normal_bg,
                    },
                    indicator_selected = {
                        fg = accent_fg,
                        bg = normal_bg,
                    },
                    modified = {
                        fg = comment_fg,
                        bg = inactive_bg,
                    },
                    modified_visible = {
                        fg = accent_fg,
                        bg = visible_bg,
                    },
                    modified_selected = {
                        fg = accent_fg,
                        bg = normal_bg,
                    },
                    close_button = {
                        fg = comment_fg,
                        bg = inactive_bg,
                    },
                    close_button_visible = {
                        fg = comment_fg,
                        bg = visible_bg,
                    },
                    close_button_selected = {
                        fg = accent_fg,
                        bg = normal_bg,
                    },
                    duplicate = {
                        fg = comment_fg,
                        bg = inactive_bg,
                        italic = false,
                    },
                    duplicate_visible = {
                        fg = comment_fg,
                        bg = visible_bg,
                        italic = false,
                    },
                    duplicate_selected = {
                        fg = normal_fg,
                        bg = normal_bg,
                        italic = false,
                    },
                    tab_separator = {
                        fg = separator_fg,
                        bg = inactive_bg,
                    },
                    tab_separator_selected = {
                        fg = separator_fg,
                        bg = normal_bg,
                    },
                },
            })
        end

        apply()

        vim.api.nvim_create_autocmd("ColorScheme", {
            group = bufferline_group,
            callback = function()
                vim.schedule(apply)
            end,
        })
    end
}
