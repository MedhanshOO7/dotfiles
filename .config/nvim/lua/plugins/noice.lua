return {
    "folke/noice.nvim",
    dependencies = {
        "MunifTanjim/nui.nvim",
        {
            "rcarriga/nvim-notify",
            config = function()
                require("notify").setup({
                    timeout = 2000, -- 2 seconds
                    top_down = false,

                    max_width = function()
                        return math.floor(vim.o.columns * 0.40)
                    end,

                    max_height = function()
                        return math.floor(vim.o.lines * 0.40)
                    end,

                    stages = "fade",    -- smooth disappear
                    render = "compact", -- smaller layout
                })
            end,
        },
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
            },
            popupmenu = {
                enabled = false,
            },
            lsp = {
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
                command_palette = true,
                long_message_to_split = true,
                lsp_doc_border = true,
            },
        })
    end
}
