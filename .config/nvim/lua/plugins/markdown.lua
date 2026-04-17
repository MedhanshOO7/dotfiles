return {
    "MeanderingProgrammer/render-markdown.nvim",
    enabled = true,
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown", "norg", "rmd", "org" },
    init = function()
        local function resolve_group(groups)
            for _, group in ipairs(groups) do
                local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
                if ok and hl and not vim.tbl_isempty(hl) then
                    return group
                end
            end
        end

        local function hl_bg(group)
            local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
            return (ok and hl.bg) and string.format("#%06x", hl.bg) or nil
        end

        local function hl_fg(group)
            local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
            return (ok and hl.fg) and string.format("#%06x", hl.fg) or nil
        end

        local function first_hl_bg(groups)
            for _, group in ipairs(groups) do
                local value = hl_bg(group)
                if value then
                    return value
                end
            end
        end

        local function set_highlights()
            local head_groups = {
                { "@markup.heading.1.markdown", "Function", "Title" },
                { "@markup.heading.2.markdown", "String", "Title" },
                { "@markup.heading.3.markdown", "Constant", "Title" },
                { "@markup.heading.4.markdown", "Identifier", "Title" },
                { "@markup.heading.5.markdown", "Special", "Title" },
                { "@markup.heading.6.markdown", "Statement", "Title" },
            }

            local normal_bg = first_hl_bg({ "Normal", "NormalFloat", "ColorColumn" }) or "NONE"

            for i, groups in ipairs(head_groups) do
                local target = resolve_group(groups)
                local fg = target and hl_fg(target) or nil
                local headline_bg = {
                    fg = normal_bg,
                    bold = true,
                }

                if fg then
                    headline_bg.bg = fg
                end

                vim.api.nvim_set_hl(0, "Headline" .. i .. "Bg", headline_bg)

                if target then
                    vim.api.nvim_set_hl(0, "Headline" .. i .. "Fg", { link = target })
                else
                    vim.api.nvim_set_hl(0, "Headline" .. i .. "Fg", { bold = true })
                end
            end

            vim.api.nvim_set_hl(0, "RenderMarkdownCode",       { link = "ColorColumn" })
            vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", { link = "Visual" })

            vim.api.nvim_set_hl(0, "RenderMarkdownChecked",   { link = "DiagnosticOk" })
            vim.api.nvim_set_hl(0, "RenderMarkdownUnchecked", { link = "DiagnosticHint" })

            vim.api.nvim_set_hl(0, "RenderMarkdownBullet",    { link = "Special" })
            vim.api.nvim_set_hl(0, "RenderMarkdownQuote",     { link = "Comment" })
            vim.api.nvim_set_hl(0, "RenderMarkdownDash",      { link = "LineNr" })
            vim.api.nvim_set_hl(0, "RenderMarkdownLink",      { link = "Underlined" })
        end

        -- Apply on startup
        set_highlights()

        -- Re-apply on every theme change
        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("render_markdown_theme_sync", { clear = true }),
            pattern = "*",
            callback = set_highlights,
        })
    end,

    opts = {
        restart_highlighter = false,
        heading = {
            sign = false,
            icons = { "󰎤 ", "󰎧 ", "󰪛 ", "󰎭 ", "󰎱 ", "󰎳 " },
            backgrounds = {
                "Headline1Bg",
                "Headline2Bg",
                "Headline3Bg",
                "Headline4Bg",
                "Headline5Bg",
                "Headline6Bg",
            },
            foregrounds = {
                "Headline1Fg",
                "Headline2Fg",
                "Headline3Fg",
                "Headline4Fg",
                "Headline5Fg",
                "Headline6Fg",
            },
        },
        code = {
            sign = false,
            width = "block",
            min_width = 30,
            right_pad = 1,
        },
        bullet = {
            enabled = true,
        },
        checkbox = {
            enabled = true,
            unchecked = {
                icon = "   󰄱 ",
                highlight = "RenderMarkdownUnchecked",
                scope_highlight = nil,
            },
            checked = {
                icon = "   󰱒 ",
                highlight = "RenderMarkdownChecked",
                scope_highlight = nil,
            },
        },
    },
}
