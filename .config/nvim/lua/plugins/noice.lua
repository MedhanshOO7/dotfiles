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
                    cmdline = { icon = "" },
                    search_down = { icon = " " },
                    search_up = { icon = " " },
                    filter = { icon = "$" },
                    lua = { icon = "" },
                    help = { icon = "?" },
                },
            },
            messages = {
                view = "notify",
                view_error = "notify",
                view_warn = "notify",
            },
            popupmenu = {
                enabled = true, -- Enable nice popupmenu
                backend = "nui",
            },
            notify = {
                enabled = true,
                view = "notify",
            },
            lsp = {
                progress = {
                    enabled = false, -- Using fidget instead
                },
                hover = {
                    enabled = true,
                    view = nil, -- use default view
                    opts = {
                        max_width = math.floor(vim.o.columns * 0.40),
                        max_height = math.floor(vim.o.lines * 0.25),
                    },
                },
                signature = {
                    enabled = true,
                    auto_open = {
                        enabled = true,
                        trigger = true, -- Automatically show signature help when typing a function call
                        luasnip = true, -- Will open signature help when jumping to Luasnip insert nodes
                        throttle = 50,  -- Debounce lsp signature help request by 50ms
                    },
                    view = nil, -- use default view
                    opts = {
                        max_width = math.floor(vim.o.columns * 0.40),
                        max_height = math.floor(vim.o.lines * 0.15),
                    },
                },
            },
            views = {
                mini = {
                    win_options = {
                        winblend = 0,
                    },
                },
                hover = {
                    border = {
                        style = "rounded",
                    },
                    position = { row = 2, col = 2 },
                    size = {
                        max_width = math.floor(vim.o.columns * 0.45),
                        max_height = math.floor(vim.o.lines * 0.30),
                    },
                },
            },
            presets = {
                bottom_search = true, -- use a classic bottom cmdline for search
                command_palette = true, -- position the cmdline and popupmenu together
                long_message_to_split = true, -- long messages will be sent to a split
                inc_rename = true, -- enables an input dialog for inc-rename.nvim
                lsp_doc_border = true, -- add a border to hover docs and signature help
            },
        })
    end
}
