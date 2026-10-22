return {
    {
        "folke/noice.nvim",
        event = "VeryLazy",

        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },

        config = function()
            ----------------------------------------------------------------------
            -- nvim-notify
            --
            -- IMPORTANT:
            -- Noice remains the notification manager.
            -- nvim-notify is only the renderer used by Noice's `notify` view.
            ----------------------------------------------------------------------

            local notify = require("notify")

            notify.setup({
                timeout = 5000,
                minimum_width = 40,
                max_width = function()
                    return math.floor(vim.o.columns * 0.45)
                end,
                max_height = function()
                    return math.floor(vim.o.lines * 0.50)
                end,
                render = "compact",
                top_down = false,
                background_colour = "#000000",
                on_open = function(win)
                    vim.api.nvim_set_option_value("wrap", true, { win = win })
                    vim.api.nvim_set_option_value("linebreak", true, { win = win })
                    vim.api.nvim_set_option_value("showbreak", "↪ ", { win = win })
                end,
            })
            ----------------------------------------------------------------------
            -- Noice
            ----------------------------------------------------------------------

            require("noice").setup({
                ------------------------------------------------------------------
                -- Command line
                ------------------------------------------------------------------

                cmdline = {
                    enabled = true,
                    view = "cmdline_popup",

                    format = {
                        cmdline = {
                            icon = " ",
                            hl_group = "Function",
                        },

                        search_down = {
                            icon = "  ",
                            hl_group = "DiagnosticWarn",
                        },

                        search_up = {
                            icon = "  ",
                            hl_group = "DiagnosticWarn",
                        },

                        filter = {
                            icon = "$ ",
                            hl_group = "DiagnosticInfo",
                        },

                        lua = {
                            icon = " ",
                            hl_group = "Special",
                        },

                        help = {
                            icon = "󰋖 ",
                            hl_group = "DiagnosticHint",
                        },

                        input = {
                            icon = "󰥻 ",
                            hl_group = "Title",
                        },
                    },
                },

                ------------------------------------------------------------------
                -- Messages
                ------------------------------------------------------------------

                messages = {
                    enabled = true,

                    -- Normal command/message output
                    view = "notify",

                    -- Errors and warnings should use the same notification UI.
                    view_error = "notify",
                    view_warn = "notify",

                    -- Keep complete history accessible through :Noice.
                    view_history = "messages",

                    -- Search counts are better kept as virtual text.
                    view_search = "virtualtext",
                },

                ------------------------------------------------------------------
                -- Popup menu
                --
                -- Keep disabled because your setup isn't using Noice's
                -- completion popup.
                ------------------------------------------------------------------

                popupmenu = {
                    enabled = false,
                },

                ------------------------------------------------------------------
                -- vim.notify()
                --
                -- Not overridden (disabled in 06cbe38). vim.notify() then echoes,
                -- and the echo arrives as a `msg_show` message that the
                -- `messages` section above renders in the same notify view and
                -- keeps in :Noice history. The `event = "notify"` routes below
                -- only apply if this is turned back on.
                ------------------------------------------------------------------

                notify = {
                    enabled = false,
                    view = "notify",
                },

                ------------------------------------------------------------------
                -- LSP
                ------------------------------------------------------------------

                lsp = {
                    progress = {
                        enabled = true,
                        view = "mini", -- Using mini for subtle but visible progress
                        -- Smoother updates for better UX
                        throttle = 1000 / 20, -- 50 FPS max for smoother progress
                    },

                    hover = {
                        enabled = true,
                        view = nil, -- Let LSP config handle hover styling
                        opts = {
                            border = "rounded",
                            max_width = math.max(60, math.floor(vim.o.columns * 0.5)),
                            max_height = math.max(10, math.floor(vim.o.lines * 0.25)),
                        },
                    },

                    signature = {
                        enabled = true,

                        auto_open = {
                            enabled = true, -- Enable auto-open for better discoverability
                            trigger = true,
                            luasnip = true,
                            throttle = 50,
                        },

                        view = nil,

                        opts = {
                            border = "rounded",
                            max_width = math.max(60, math.floor(vim.o.columns * 0.5)),
                            max_height = math.max(10, math.floor(vim.o.lines * 0.25)),
                        },
                    },

                    message = {
                        enabled = true,
                        view = "notify",
                    },
                },

                ------------------------------------------------------------------
                -- Custom views
                ------------------------------------------------------------------

                views = {
                    ----------------------------------------------------------------
                    -- Your command-line popup
                    ----------------------------------------------------------------

                    cmdline_popup = {
                        position = {
                            row = "40%",
                            col = "50%",
                        },

                        size = {
                            width = "auto",
                            min_width = 40,
                            max_width = 80,
                            height = "auto",
                        },

                        border = {
                            style = "rounded",
                            padding = { 0, 1 },
                        },

                        win_options = {
                            winblend = 0,

                            winhighlight = table.concat({
                                "Normal:NormalFloat",
                                "FloatBorder:FloatBorder",
                                "FloatTitle:FloatTitle",
                            }, ","),

                            wrap = true,
                            linebreak = true,
                        },
                    },

                    ----------------------------------------------------------------
                    -- Input windows use the same visual style.
                    ----------------------------------------------------------------

                    cmdline_input = {
                        view = "cmdline_popup",

                        border = {
                            style = "rounded",
                            padding = { 0, 1 },
                        },
                    },
                },

                ------------------------------------------------------------------
                -- Presets
                ------------------------------------------------------------------

                presets = {
                    -- We don't want the classic bottom search UI.
                    bottom_search = false,

                    -- Keep command line independent from popup completion.
                    command_palette = false,

                    -- Don't automatically throw long messages into a split.
                    --
                    -- This is important because we want our notification
                    -- renderer to handle normal long notifications.
                    long_message_to_split = false,

                    inc_rename = false,

                    -- Rounded LSP documentation borders.
                    lsp_doc_border = true,
                },

                ------------------------------------------------------------------
                -- Routes
                ------------------------------------------------------------------

                routes = {
                    ----------------------------------------------------------------
                    -- Ignore noisy terminal DSR warning.
                    ----------------------------------------------------------------

                    {
                        filter = {
                            event = "msg_show",

                            any = {
                                {
                                    find = "Terminal did not respond to DSR request",
                                },

                                {
                                    find = "E1568",
                                },

                                {
                                    find = "is_stopped is deprecated",
                                },

                                {
                                    find = "client.request is deprecated",
                                },

                                {
                                    find = "written",
                                },
                            },
                        },

                        opts = {
                            skip = true,
                        },
                    },

                    ----------------------------------------------------------------
                    -- Group write notifications to reduce noise
                    ----------------------------------------------------------------

                    {
                        filter = {
                            event = "notify",
                            find = "written",
                        },

                        opts = {
                            skip = true, -- Skip individual write notifications
                            -- We could implement a custom view that shows a summary
                            -- For now, skipping reduces noise while keeping important info
                        },
                    },

                    ----------------------------------------------------------------
                    -- Make errors more visible with longer timeout
                    ----------------------------------------------------------------

                    {
                        filter = {
                            event = "notify",
                            kind = "error",
                        },

                        opts = {
                            timeout = 12000, -- Longer timeout for errors
                        },
                    },

                    ----------------------------------------------------------------
                    -- Make warnings more noticeable
                    ----------------------------------------------------------------

                    {
                        filter = {
                            event = "notify",
                            kind = "warn",
                        },

                        opts = {
                            timeout = 8000, -- Medium timeout for warnings
                        },
                    },

                    ----------------------------------------------------------------
                    -- Long command output:
                    --
                    -- Don't let extremely large output become a gigantic
                    -- notification.
                    --
                    -- Noice's own documentation explicitly supports routing
                    -- messages based on min_height.
                    ----------------------------------------------------------------

                    {
                        filter = {
                            event = "msg_show",
                            min_height = 15,
                        },

                        view = "split",
                    },
                },
            })
        end,
    },
}
