return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        require("gitsigns").setup({
            signs = {
                add = { text = "▎" },
                change = { text = "▎" },
                delete = { text = "󰐊" },
                topdelete = { text = "󰐊" },
                changedelete = { text = "▎" },
                untracked = { text = "┆" },
            },
            attach_to_untracked = true,
            current_line_blame = false,
            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = "eol",
                delay = 300,
                ignore_whitespace = false,
            },
            current_line_blame_formatter = "   󰊢 <author>, <author_time:%Y-%m-%d> · <summary>",
            sign_priority = 6,
            update_debounce = 250,
            preview_config = {
                border = "rounded",
                style = "minimal",
            },
        })
    end,
}
