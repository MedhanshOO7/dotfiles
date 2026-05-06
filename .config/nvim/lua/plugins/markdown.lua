return {
    "MeanderingProgrammer/render-markdown.nvim",
    enabled = true,
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    event = { "BufReadPre *.md", "BufNewFile *.md" },
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

            vim.api.nvim_set_hl(0, "RenderMarkdownCode", { link = "ColorColumn" })
            vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", { link = "Visual" })

            vim.api.nvim_set_hl(0, "RenderMarkdownChecked", { link = "DiagnosticOk" })
            vim.api.nvim_set_hl(0, "RenderMarkdownUnchecked", { link = "DiagnosticHint" })

            vim.api.nvim_set_hl(0, "RenderMarkdownBullet", { link = "Special" })
            vim.api.nvim_set_hl(0, "RenderMarkdownQuote", { link = "Comment" })
            vim.api.nvim_set_hl(0, "RenderMarkdownDash", { link = "LineNr" })
            vim.api.nvim_set_hl(0, "RenderMarkdownLink", { link = "Underlined" })

            -- Callouts and Checkboxes
            vim.api.nvim_set_hl(0, "RenderMarkdownTodo", { link = "DiagnosticInfo" })
            vim.api.nvim_set_hl(0, "RenderMarkdownImportant", { link = "DiagnosticWarn" })
            vim.api.nvim_set_hl(0, "RenderMarkdownInfo", { link = "DiagnosticInfo" })
            vim.api.nvim_set_hl(0, "RenderMarkdownSuccess", { link = "DiagnosticOk" })
            vim.api.nvim_set_hl(0, "RenderMarkdownWarn", { link = "DiagnosticWarn" })
            vim.api.nvim_set_hl(0, "RenderMarkdownError", { link = "DiagnosticError" })
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
        render_modes = true,
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
        },
        code = {
            sign = false,
            width = "block",
            min_width = 30,
            right_pad = 1,
        },
        bullet = {
            enabled = true,
            icons = { "●", "○", "◆", "◇" },
        },
        checkbox = {
            enabled = true,
            unchecked = {
                icon = "󰄱 ",
                highlight = "RenderMarkdownUnchecked",
            },
            checked = {
                icon = "󰱒 ",
                highlight = "RenderMarkdownChecked",
            },
            custom = {
                todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
                important = { raw = "[!]", rendered = "󰀦 ", highlight = "RenderMarkdownImportant" },
            },
        },
        callout = {
            -- Obsidian-style callouts
            note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "RenderMarkdownInfo" },
            tip = { raw = "[!TIP]", rendered = "󰌶 Tip", highlight = "RenderMarkdownSuccess" },
            important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownWarn" },
            warning = { raw = "[!WARNING]", rendered = "󰀦 Warning", highlight = "RenderMarkdownWarn" },
            caution = { raw = "[!CAUTION]", rendered = "󰳦 Caution", highlight = "RenderMarkdownError" },
            abstract = { raw = "[!ABSTRACT]", rendered = "󰨸 Abstract", highlight = "RenderMarkdownInfo" },
            todo = { raw = "[!TODO]", rendered = "󰗡 Todo", highlight = "RenderMarkdownInfo" },
            success = { raw = "[!SUCCESS]", rendered = "󰄬 Success", highlight = "RenderMarkdownSuccess" },
            question = { raw = "[!QUESTION]", rendered = "󰘥 Question", highlight = "RenderMarkdownWarn" },
            failure = { raw = "[!FAILURE]", rendered = "󰅖 Failure", highlight = "RenderMarkdownError" },
            danger = { raw = "[!DANGER]", rendered = "󱐌 Danger", highlight = "RenderMarkdownError" },
            bug = { raw = "[!BUG]", rendered = "󰨰 Bug", highlight = "RenderMarkdownError" },
            example = { raw = "[!EXAMPLE]", rendered = "󰉹 Example", highlight = "RenderMarkdownInfo" },
            quote = { raw = "[!QUOTE]", rendered = "󱆧 Quote", highlight = "RenderMarkdownQuote" },
        },
        pipe_table = {
            enabled = true,
            preset = "round",
            alignment_indicator = "━",
        },
        win_options = {
            conceallevel = {
                default = vim.api.nvim_get_option_value("conceallevel", {}),
                rendered = 2,
            },
            concealcursor = {
                default = vim.api.nvim_get_option_value("concealcursor", {}),
                rendered = "nv",
            },
        },
    },
}
