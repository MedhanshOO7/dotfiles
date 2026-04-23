return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        require("gitsigns").setup({
            signs = {
                add = { text = "+" },
                change = { text = "~" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
            },
            attach_to_untracked = true,
            current_line_blame = false,
            current_line_blame_opts = {
                delay = 350,
                virt_text_pos = "eol",
            },
            sign_priority = 6,
            update_debounce = 100,
            preview_config = {
                border = "rounded",
            },
        })
    end,
}
