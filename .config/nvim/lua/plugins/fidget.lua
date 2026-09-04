return {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    enabled = true,
    opts = {
        notification = {
            override_vim_notify = false,
            window = {
                winblend = 0,
            },
        },
        progress = {
            suppress_on_insert = true,
            ignore = { "basedpyright" },
            display = {
                done_ttl = 2,
            },
        },
    },
}
