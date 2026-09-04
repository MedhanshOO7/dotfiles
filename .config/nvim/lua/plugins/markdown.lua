return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
    enabled = true,
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    ft = "markdown",
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

            local code_bg = first_hl_bg({ "ColorColumn", "CursorLine", "NormalFloat" })
            if code_bg then
                vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = code_bg })
                vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", { bg = code_bg })
            else
                vim.api.nvim_set_hl(0, "RenderMarkdownCode", { link = "ColorColumn" })
                vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", { link = "ColorColumn" })
            end

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

            -- Mark highlights (==text==)
            vim.api.nvim_set_hl(0, "RenderMarkdownHighlight", { bg = "#F5C2E7", fg = "#1E1E2E", bold = true })
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
        render_modes = { "n", "c" },

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
            style = "full",
            width = "block",
            min_width = 30,
            left_pad = 1,
            right_pad = 1,
            highlight_mode = "combine",
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
            style = "full",
        },
        latex = {
            enabled = true,
            converter = "latex2text",
            highlight = "RenderMarkdownMath",
        },

        sign = {
            enabled = false,
        },
        mark = {
            enabled = true,
            sign = false,
            highlight = "RenderMarkdownHighlight",
        },
        win_options = {
            conceallevel = {
                default = vim.o.conceallevel,
                rendered = 2,
            },
            concealcursor = {
                default = vim.o.concealcursor,
                rendered = "nv",
            },
        },
    },
    },
    {
        "ice345/markdown-table-wrap.nvim",
        ft = "markdown",
        keys = {
            { "<leader>mTi", "<cmd>MarkdownTableToggleInline<cr>", desc = "Toggle Markdown Table Inline View" },
            { "<leader>mTr", "<cmd>MarkdownTableToggleReader<cr>", desc = "Toggle Markdown Table Reader" },
            { "<leader>mTp", "<cmd>MarkdownTableTogglePreview<cr>", desc = "Toggle Markdown Table Preview" },
        },
        opts = {
            preview_mode = "inline",
            inline_mode = "replace",
            auto_preview = false, -- Manual toggle only (<leader>mTi, <leader>mTp)!
            render_all = false,
            inline_viewport_scrolling = true,
            inline_wrap_scope = "cursor",
            auto_preview_in_insert = false,
            clear_on_insert = true,
            highlight_preset = "render_markdown",
            table_border = "rounded",
            use_unicode_border = true,
            extra_filetypes = { "sql" },
            reader = {
                auto_open = false,
            },
        },
    },
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },
        build = "cd app && npm install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
            vim.g.mkdp_command_for_global = 1
            vim.g.mkdp_auto_start = 0
            vim.g.mkdp_auto_close = 0 -- Keep browser open & sync to current file when switching buffers!
            vim.g.mkdp_refresh_slow = 0 -- Instant refresh on text change
            vim.g.mkdp_echo_preview_url = 1
            vim.g.mkdp_page_title = "「${name}」"

            vim.cmd([[
                function! OpenMarkdownBrowser(url)
                    let l:is_mac = has('mac') || has('macunix') || system('uname') =~? '^darwin'
                    let l:is_win = has('win32') || has('win64')

                    if executable('zen-browser')
                        silent execute '!zen-browser ' . shellescape(a:url) . ' &'
                    elseif executable('zen')
                        silent execute '!zen ' . shellescape(a:url) . ' &'
                    elseif l:is_mac
                        if isdirectory('/Applications/Zen Browser.app')
                            silent execute '!open -a "Zen Browser" ' . shellescape(a:url) . ' &'
                        elseif isdirectory('/Applications/Zen.app')
                            silent execute '!open -a "Zen" ' . shellescape(a:url) . ' &'
                        else
                            silent execute '!open ' . shellescape(a:url) . ' &'
                        endif
                    elseif l:is_win
                        silent execute '!cmd.exe /c start "" ' . shellescape(a:url)
                    elseif executable('xdg-open')
                        silent execute '!xdg-open ' . shellescape(a:url) . ' &'
                    endif
                endfunction

                function! OpenZenBrowser(url)
                    call OpenMarkdownBrowser(a:url)
                endfunction
            ]])
            vim.g.mkdp_browserfunc = "OpenMarkdownBrowser"
        end,
        keys = {
            {
                "<leader>np",
                function()
                    vim.fn["mkdp#util#toggle_preview"]()
                end,
                desc = "Markdown Browser Preview",
            },
            {
                "<leader>mp",
                function()
                    vim.fn["mkdp#util#toggle_preview"]()
                end,
                desc = "Markdown Browser Preview",
            },
        },
    },
}
