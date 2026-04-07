return {
    "folke/noice.nvim",
    dependencies = {
        "MunifTanjim/nui.nvim",
        {
            "rcarriga/nvim-notify",
            config = function()
                require("notify").setup({
                    timeout = 2000, -- 2 seconds

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
                view = "cmdline_popup",
            },
            messages = {
                view = "notify",
            },
            popupmenu = {
                enabled = true,
                backend = "nui",
            },
        })
    end
}
