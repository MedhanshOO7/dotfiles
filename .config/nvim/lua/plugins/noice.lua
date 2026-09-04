return {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
        "MunifTanjim/nui.nvim",
    },
    config = function()
        require("noice").setup({
            cmdline = {
                enabled = true,
                view = "cmdline_popup",
                format = {
                    cmdline = { icon = " ", hl_group = "Function" },
                    search_down = { icon = "  ", hl_group = "DiagnosticWarn" },
                    search_up = { icon = "  ", hl_group = "DiagnosticWarn" },
                    filter = { icon = "$ ", hl_group = "DiagnosticInfo" },
                    lua = { icon = " ", hl_group = "Special" },
                    help = { icon = "󰋖 ", hl_group = "DiagnosticHint" },
                    input = { icon = "󰥻 ", hl_group = "Title" },
                },
            },
            messages = {
                enabled = false, -- snacks.notifier handles messages
            },
            popupmenu = {
                enabled = false, -- Disable Nui popupmenu container to prevent bottom split bleeding
            },
            notify = {
                enabled = false, -- snacks.notifier handles all toast notifications
            },
            lsp = {
                progress = {
                    enabled = false,
                },
                hover = {
                    enabled = true,
                    view = nil,
                    opts = {
                        max_width = math.max(40, math.floor(vim.o.columns * 0.45)),
                        max_height = math.max(6, math.floor(vim.o.lines * 0.30)),
                    },
                },
                signature = {
                    enabled = true,
                    auto_open = {
                        enabled = false,
                        trigger = true,
                        luasnip = true,
                        throttle = 50,
                    },
                    view = nil,
                    opts = {
                        max_width = math.max(40, math.floor(vim.o.columns * 0.45)),
                        max_height = math.max(4, math.floor(vim.o.lines * 0.18)),
                    },
                },
            },
            views = {
                cmdline_popup = {
                    position = {
                        row = "40%",
                        col = "50%",
                    },
                    size = {
                        min_width = 60,
                        width = "auto",
                        max_width = math.max(60, math.floor(vim.o.columns * 0.75)),
                        height = "auto",
                    },
                    border = {
                        style = "rounded",
                        padding = { 0, 1 },
                    },
                    win_options = {
                        winhighlight = {
                            Normal = "NoiceCmdlinePopup",
                            FloatBorder = "NoiceCmdlinePopupBorder",
                            FloatTitle = "NoiceCmdlinePopupTitle",
                        },
                        wrap = true,
                        linebreak = true,
                        sidescrolloff = 0,
                        cursorline = false,
                        foldenable = false,
                    },
                },
                cmdline_input = {
                    view = "cmdline_popup",
                    border = {
                        style = "rounded",
                        padding = { 0, 1 },
                    },
                },
            },
            presets = {
                bottom_search = false, -- spotlight popup search for consistent centered feel
                command_palette = false, -- use our custom centered & clipped views
                long_message_to_split = true,
                inc_rename = false,
                lsp_doc_border = true,
            },
            routes = {
                {
                    filter = {
                        event = "msg_show",
                        any = {
                            { find = "Terminal did not respond to DSR request" },
                            { find = "E1568" },
                            { find = "is_stopped is deprecated" },
                            { find = "client.request is deprecated" },
                            { find = "written" },
                        },
                    },
                    opts = { skip = true },
                },
            },
        })
    end,
}
