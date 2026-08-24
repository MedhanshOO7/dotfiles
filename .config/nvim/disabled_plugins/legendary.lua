return {
    "mrjones2014/legendary.nvim",
    priority = 10000,
    lazy = false,
    keys = {
        { "<C-S-p>", "<cmd>Legendary<cr>", mode = { "n", "v" }, desc = "Command Palette" },
    },
    opts = {
        select_prompt = " Command Palette",
        col_separator_char = "│",
        icons = {
            command = "",
            fn = "",
            itemgroup = "",
            keymap = "",
            autocmd = "󱐌 ",
        },
        include_builtin = true,
        include_legendary_cmds = true,
    },
}
