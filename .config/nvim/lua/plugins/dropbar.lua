return {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
        bar = {
            enable = function(buf, win)
                return vim.fn.buflisted(buf) == 1
                    and vim.api.nvim_buf_get_name(buf) ~= ""
                    and not vim.tbl_contains({
                        "help",
                        "snacks_dashboard",
                        "snacks_picker_input",
                        "snacks_explorer",
                        "alpha",
                        "dashboard",
                        "lazy",
                        "mason",
                        "trouble",
                        "toggleterm",
                        "notify",
                        "noice",
                    }, vim.bo[buf].filetype)
            end,
            separator = "  ",
        },
    },
    keys = {
        {
            "<leader>;",
            function()
                require("dropbar.api").pick()
            end,
            desc = "Pick symbols in breadcrumb dropbar",
        },
        {
            "[;",
            function()
                require("dropbar.api").goto_context_start()
            end,
            desc = "Go to start of current context",
        },
        {
            "];",
            function()
                require("dropbar.api").select_next_context()
            end,
            desc = "Select next context",
        },
    },
}
