return {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    enabled = true,
    opts = {
        notification = {
            window = {
                winblend = 0,
            },
        },
        progress = {
            display = {
                done_ttl = 2,
            },
        },
    },
}
