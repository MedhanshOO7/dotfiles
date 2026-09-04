return {
    "windwp/nvim-autopairs",
    event = { "InsertEnter" },
    config = function()
        local autopairs = require("nvim-autopairs")

        autopairs.setup({
            check_ts = true,
            enable_check_bracket_line = false,
            disable_filetype = { "TelescopePrompt", "grug-far", "snacks_picker_input" },
            fast_wrap = {},
            ts_config = {
                lua = { "string" },
                java = false,
            },
        })
    end,
}
