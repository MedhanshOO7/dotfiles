return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        enabled = true,

        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },

        ft = {
            "markdown",
            "vimwiki",
            "quarto",
            "rmd",
        },

        init = function()
            local function resolve_group(groups)
                for _, group in ipairs(groups) do
                    local ok, hl = pcall(vim.api.nvim_get_hl, 0, {
                        name = group,
                        link = false,
                    })

                    if ok and hl and not vim.tbl_isempty(hl) then
                        return group
                    end
                end
            end

            local function hl_bg(group)
                local ok, hl = pcall(vim.api.nvim_get_hl, 0, {
                    name = group,
                    link = false,
                })

                if ok and hl and hl.bg then
                    return string.format("#%06x", hl.bg)
                end

                return nil
            end

            local function hl_fg(group)
                local ok, hl = pcall(vim.api.nvim_get_hl, 0, {
                    name = group,
                    link = false,
                })

                if ok and hl and hl.fg then
                    return string.format("#%06x", hl.fg)
                end

                return nil
            end

            local function first_hl_bg(groups)
                for _, group in ipairs(groups) do
                    local value = hl_bg(group)

                    if value then
                        return value
                    end
                end

                return nil
            end

            local function first_hl_fg(groups)
                for _, group in ipairs(groups) do
                    local value = hl_fg(group)

                    if value then
                        return value
                    end
                end

                return nil
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

                local normal_bg = first_hl_bg({
                    "Normal",
                    "NormalFloat",
                    "ColorColumn",
                }) or "NONE"

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

                -- Code blocks
                local code_bg = first_hl_bg({
                    "ColorColumn",
                    "NormalFloat",
                    "CursorLine",
                })

                if code_bg then
                    vim.api.nvim_set_hl(0, "RenderMarkdownCode", {
                        bg = code_bg,
                    })

                    vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", {
                        bg = code_bg,
                    })
                else
                    vim.api.nvim_set_hl(0, "RenderMarkdownCode", {
                        link = "ColorColumn",
                    })

                    vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", {
                        link = "ColorColumn",
                    })
                end

                -- Checkboxes
                vim.api.nvim_set_hl(0, "RenderMarkdownChecked", {
                    link = "DiagnosticOk",
                })

                vim.api.nvim_set_hl(0, "RenderMarkdownUnchecked", {
                    link = "DiagnosticHint",
                })

                -- Markdown elements
                vim.api.nvim_set_hl(0, "RenderMarkdownBullet", {
                    link = "Special",
                })

                vim.api.nvim_set_hl(0, "RenderMarkdownQuote", {
                    link = "Comment",
                })

                vim.api.nvim_set_hl(0, "RenderMarkdownDash", {
                    link = "LineNr",
                })

                vim.api.nvim_set_hl(0, "RenderMarkdownLink", {
                    link = "Underlined",
                })

                -- Callouts
                vim.api.nvim_set_hl(0, "RenderMarkdownTodo", {
                    link = "DiagnosticInfo",
                })

                vim.api.nvim_set_hl(0, "RenderMarkdownImportant", {
                    link = "DiagnosticWarn",
                })

                vim.api.nvim_set_hl(0, "RenderMarkdownInfo", {
                    link = "DiagnosticInfo",
                })

                vim.api.nvim_set_hl(0, "RenderMarkdownSuccess", {
                    link = "DiagnosticOk",
                })

                vim.api.nvim_set_hl(0, "RenderMarkdownWarn", {
                    link = "DiagnosticWarn",
                })

                vim.api.nvim_set_hl(0, "RenderMarkdownError", {
                    link = "DiagnosticError",
                })

                -- ==highlight==
                local mark_bg = first_hl_bg({
                    "IncSearch",
                    "Search",
                    "Visual",
                }) or "#F5C2E7"

                local mark_fg = first_hl_fg({
                    "Normal",
                }) or "#1E1E2E"

                vim.api.nvim_set_hl(0, "RenderMarkdownHighlight", {
                    bg = mark_bg,
                    fg = mark_fg,
                    bold = true,
                })
            end

            -- Theme-dependent highlights
            set_highlights()

            vim.api.nvim_create_autocmd("ColorScheme", {
                group = vim.api.nvim_create_augroup("render_markdown_theme_sync", { clear = true }),
                pattern = "*",
                callback = set_highlights,
            })

            -- Disable normal Vim line wrapping in Markdown buffers.
            -- render-markdown.nvim handles table-cell wrapping itself.
            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("markdown_no_line_wrap", { clear = true }),
                pattern = {
                    "markdown",
                    "vimwiki",
                    "quarto",
                    "rmd",
                },
                callback = function()
                    vim.opt_local.wrap = false
                    vim.opt_local.linebreak = false
                    vim.opt_local.breakindent = false
                end,
            })
        end,

        opts = {
            render_modes = { "n", "c" },

            -- Current option name is file_types, not filetypes.
            file_types = {
                "markdown",
                "vimwiki",
                "quarto",
                "rmd",
            },

            heading = {
                sign = false,

                icons = {
                    "󰎤 ",
                    "󰎧 ",
                    "󰪛 ",
                    "󰎭 ",
                    "󰎱 ",
                    "󰎳 ",
                },

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

                width = "full",
                border = true,
                above = "▄",
                below = "▀",
            },

            code = {
                sign = false,
                style = "full",
                width = "block",
                min_width = 30,
                right_pad = 1,
                language_pad = 0,
                disable_background = { "diff" },

                -- Current API uses highlight/highlight_inline.
                highlight = "RenderMarkdownCode",
                highlight_inline = "RenderMarkdownCodeInline",
            },

            bullet = {
                enabled = true,
                icons = {
                    "●",
                    "○",
                    "◆",
                    "◇",
                },
                highlight = "RenderMarkdownBullet",
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
                    todo = {
                        raw = "[-]",
                        rendered = "󰥔 ",
                        highlight = "RenderMarkdownTodo",
                    },

                    important = {
                        raw = "[!]",
                        rendered = "󰀦 ",
                        highlight = "RenderMarkdownImportant",
                    },
                },
            },

            callout = {
                note = {
                    raw = "[!NOTE]",
                    rendered = " Note",
                    highlight = "RenderMarkdownInfo",
                },

                tip = {
                    raw = "[!TIP]",
                    rendered = "󰌶 Tip",
                    highlight = "RenderMarkdownSuccess",
                },

                important = {
                    raw = "[!IMPORTANT]",
                    rendered = "󰽎 Important",
                    highlight = "RenderMarkdownWarn",
                },

                warning = {
                    raw = "[!WARNING]",
                    rendered = "󰀧 Warning",
                    highlight = "RenderMarkdownWarn",
                },

                caution = {
                    raw = "[!CAUTION]",
                    rendered = "󰝧 Caution",
                    highlight = "RenderMarkdownError",
                },

                abstract = {
                    raw = "[!ABSTRACT]",
                    rendered = "󰨸 Abstract",
                    highlight = "RenderMarkdownInfo",
                },

                todo = {
                    raw = "[!TODO]",
                    rendered = " Todo",
                    highlight = "RenderMarkdownInfo",
                },

                success = {
                    raw = "[!SUCCESS]",
                    rendered = " Success",
                    highlight = "RenderMarkdownSuccess",
                },

                question = {
                    raw = "[!QUESTION]",
                    rendered = "󰺴 Question",
                    highlight = "RenderMarkdownWarn",
                },

                answer = {
                    raw = "[!ANSWER]",
                    rendered = " Question",
                    highlight = "RenderMarkdownWarn",
                },
                failure = {
                    raw = "[!FAILURE]",
                    rendered = "󰅖 Failure",
                    highlight = "RenderMarkdownError",
                },

                danger = {
                    raw = "[!DANGER]",
                    rendered = "󱐌 Danger",
                    highlight = "RenderMarkdownError",
                },

                bug = {
                    raw = "[!BUG]",
                    rendered = "󰨰 Bug",
                    highlight = "RenderMarkdownError",
                },

                example = {
                    raw = "[!EXAMPLE]",
                    rendered = "󰉹 Example",
                    highlight = "RenderMarkdownInfo",
                },

                quote = {
                    raw = "[!QUOTE]",
                    rendered = "󱆧 Quote",
                    highlight = "RenderMarkdownQuote",
                },
            },

            -- Native render-markdown table renderer.
            -- Do not add wrap here because your installed version's
            -- schema explicitly rejects pipe_table.wrap.
            pipe_table = {
                enabled = true,
                preset = "round",
                cell = "padded",
                padding = 1,
                min_width = 0,
                border_enabled = true,
                border_virtual = false,
                style = "full",
            },

            latex = {
                enabled = true,
                converter = "latex2text",
                highlight = "RenderMarkdownMath",
                position = "center",
                top_pad = 0,
                bottom_pad = 0,
            },

            sign = {
                enabled = false,
            },

            inline_highlight = {
                enabled = true,
                highlight = "RenderMarkdownInlineHighlight",
            },

            win_options = {
                conceallevel = {
                    default = vim.o.conceallevel,
                    rendered = 3,
                },

                concealcursor = {
                    default = vim.o.concealcursor,
                    rendered = "",
                },
            },
        },
    },

    {
        "iamcco/markdown-preview.nvim",

        cmd = {
            "MarkdownPreviewToggle",
            "MarkdownPreview",
            "MarkdownPreviewStop",
        },

        ft = {
            "markdown",
        },

        build = "cd app && npm install",

        init = function()
            vim.g.mkdp_filetypes = {
                "markdown",
            }

            vim.g.mkdp_command_for_global = 1
            vim.g.mkdp_auto_start = 0
            vim.g.mkdp_auto_close = 0
            vim.g.mkdp_refresh_slow = 0
            vim.g.mkdp_echo_preview_url = 1
            vim.g.mkdp_page_title = "「${name}」"

            -- Zen Browser
            if vim.fn.executable("zen") == 1 then
                vim.g.mkdp_browser = "zen"
            elseif vim.fn.executable("zen-browser") == 1 then
                vim.g.mkdp_browser = "zen-browser"
            end
        end,

        keys = {
            {
                "<leader>np",
                function()
                    -- The plugin's :MarkdownPreviewToggle is buffer-local and only
                    -- defined on BufEnter; the autoload function works anywhere.
                    vim.fn["mkdp#util#toggle_preview"]()
                end,
                desc = "Open or close the markdown browser preview",
            },
        },
    },
}
